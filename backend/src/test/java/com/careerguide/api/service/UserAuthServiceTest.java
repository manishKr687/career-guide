package com.careerguide.api.service;

import com.careerguide.api.dto.AuthResponse;
import com.careerguide.api.entity.User;
import com.careerguide.api.repository.UserRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.UnauthorizedException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Tests for {@link UserAuthService}, which had none. Plain Mockito, matching
 * {@link CareerServiceTest} -- no Spring context and no database.
 *
 * <p>The real password hasher and token signer are used rather than mocked.
 * They are pure and fast enough, and mocking them would remove the only
 * assertion in this class that matters most: that a raw password never reaches
 * the repository.
 *
 * <p>Two properties here are security properties rather than behaviour, and both
 * are stated in the service's own javadoc without anything enforcing them:
 *
 * <ul>
 *   <li><b>Email normalisation.</b> If {@code register} lowercases but
 *       {@code login} does not, an account created as "A@b.com" can never be
 *       logged into. Worse, if normalisation differs the other way, two accounts
 *       can exist for one address.</li>
 *   <li><b>No account enumeration.</b> An unknown email and a wrong password
 *       must fail identically. Any difference -- message, exception type, or
 *       whether the password is even checked -- turns the login endpoint into a
 *       tool for discovering who has an account.</li>
 * </ul>
 */
@ExtendWith(MockitoExtension.class)
class UserAuthServiceTest {

    @Mock
    private UserRepository userRepository;

    private UserAuthService authService;
    private UserPasswordService passwordService;

    @BeforeEach
    void setUp() {
        passwordService = new UserPasswordService();
        authService = new UserAuthService(userRepository, passwordService,
                new UserTokenService("test-only-secret-at-least-32-characters-long"));
    }

    // ----------------------------------------------------------------- register

    @Test
    void registerStoresTheEmailNormalisedAndTheNameTrimmed() {
        when(userRepository.existsByEmail("student@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(inv -> persisted(inv.getArgument(0)));

        authService.register("  Student@Example.COM  ", "hunter2hunter2", "  Asha Menon  ");

        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(captor.capture());
        assertThat(captor.getValue().getEmail()).isEqualTo("student@example.com");
        assertThat(captor.getValue().getName()).isEqualTo("Asha Menon");
    }

    @Test
    void registerNeverPutsTheRawPasswordInTheRepository() {
        // The single most important assertion in this file.
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(inv -> persisted(inv.getArgument(0)));

        authService.register("student@example.com", "hunter2hunter2", "Asha");

        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(captor.capture());
        String stored = captor.getValue().getPasswordHash();

        assertThat(stored).doesNotContain("hunter2hunter2");
        assertThat(stored).startsWith("pbkdf2:");
        assertThat(passwordService.matches("hunter2hunter2", stored)).isTrue();
    }

    @Test
    void registerRejectsAnAlreadyRegisteredEmailWithoutSaving() {
        when(userRepository.existsByEmail("taken@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register("taken@example.com", "password123", "Asha"))
                .isInstanceOf(ConflictException.class);

        verify(userRepository, never()).save(any());
    }

    @Test
    void registerChecksTheDuplicateEmailInNormalisedForm() {
        // If the existence check used the raw input, "TAKEN@example.com" would
        // slip past and create a second account for the same address.
        when(userRepository.existsByEmail("taken@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register("  TAKEN@Example.com ", "password123", "Asha"))
                .isInstanceOf(ConflictException.class);

        verify(userRepository).existsByEmail("taken@example.com");
        verify(userRepository, never()).save(any());
    }

    @Test
    void registerReturnsATokenAndTheUser() {
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(inv -> persisted(inv.getArgument(0)));

        AuthResponse response = authService.register("student@example.com", "hunter2hunter2", "Asha");

        assertThat(response.token()).isNotBlank();
        assertThat(response.user().email()).isEqualTo("student@example.com");
    }

    // -------------------------------------------------------------------- login

    @Test
    void loginSucceedsWithTheCorrectPassword() {
        User stored = existingUser("student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

        AuthResponse response = authService.login("student@example.com", "hunter2hunter2");

        assertThat(response.token()).isNotBlank();
        assertThat(response.user().email()).isEqualTo("student@example.com");
    }

    @Test
    void loginNormalisesTheEmailTheSameWayRegisterDoes() {
        // Without this, an address typed with different capitalisation than at
        // sign-up can never log in.
        User stored = existingUser("student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

        AuthResponse response = authService.login("  Student@Example.COM  ", "hunter2hunter2");

        assertThat(response.token()).isNotBlank();
        verify(userRepository).findByEmail("student@example.com");
    }

    @Test
    void loginRejectsAWrongPassword() {
        User stored = existingUser("student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> authService.login("student@example.com", "not-the-password"))
                .isInstanceOf(UnauthorizedException.class);
    }

    @Test
    void loginRejectsAnUnknownEmail() {
        when(userRepository.findByEmail("nobody@example.com")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.login("nobody@example.com", "hunter2hunter2"))
                .isInstanceOf(UnauthorizedException.class);
    }

    @Test
    void anUnknownEmailAndAWrongPasswordFailIdentically() {
        // The enumeration defence. If these two differ in type or message, the
        // login endpoint answers "does this person have an account?" for anyone
        // who asks.
        User stored = existingUser("student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));
        when(userRepository.findByEmail("nobody@example.com")).thenReturn(Optional.empty());

        Throwable wrongPassword = org.assertj.core.api.Assertions.catchThrowable(
                () -> authService.login("student@example.com", "wrong"));
        Throwable unknownEmail = org.assertj.core.api.Assertions.catchThrowable(
                () -> authService.login("nobody@example.com", "wrong"));

        assertThat(wrongPassword).isInstanceOf(UnauthorizedException.class);
        assertThat(unknownEmail).isInstanceOf(UnauthorizedException.class);
        assertThat(unknownEmail).hasMessage(wrongPassword.getMessage());
        assertThat(unknownEmail.getClass()).isEqualTo(wrongPassword.getClass());
    }

    @Test
    void loginWithANullPasswordIsRejectedRatherThanCrashing() {
        // The service substitutes "" for a null password specifically so this is
        // a 401 and not a 500 from inside the hasher.
        User stored = existingUser("student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> authService.login("student@example.com", null))
                .isInstanceOf(UnauthorizedException.class);
    }

    @Test
    void loginWithANullEmailIsRejectedRatherThanCrashing() {
        // normalize(null) yields "", which simply finds no account.
        when(userRepository.findByEmail("")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.login(null, "hunter2hunter2"))
                .isInstanceOf(UnauthorizedException.class);
    }

    @Test
    void loginDoesNotAcceptAnEmptyPasswordAgainstAStoredHash() {
        User stored = existingUser("student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> authService.login("student@example.com", ""))
                .isInstanceOf(UnauthorizedException.class);
    }

    @Test
    void loginFailsClosedWhenTheStoredHashIsCorrupt() {
        // A row whose password_hash is empty or garbage -- from a bad import or a
        // half-finished migration -- must not authenticate anyone.
        for (String corrupt : new String[]{"", "not-a-hash", "pbkdf2:210000::"}) {
            User stored = existingUser("student@example.com", "Asha", corrupt);
            when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

            assertThatThrownBy(() -> authService.login("student@example.com", "anything"))
                    .as("stored hash \"%s\"", corrupt)
                    .isInstanceOf(UnauthorizedException.class);
            assertThatThrownBy(() -> authService.login("student@example.com", ""))
                    .as("stored hash \"%s\", empty password", corrupt)
                    .isInstanceOf(UnauthorizedException.class);
        }
    }

    @Test
    void tokensIssuedAtLoginResolveBackToThatUser() {
        UserTokenService tokenService = new UserTokenService("test-only-secret-at-least-32-characters-long");
        UserAuthService service = new UserAuthService(userRepository, passwordService, tokenService);
        User stored = existingUser(77L, "student@example.com", "Asha", passwordService.hash("hunter2hunter2"));
        when(userRepository.findByEmail("student@example.com")).thenReturn(Optional.of(stored));

        AuthResponse response = service.login("student@example.com", "hunter2hunter2");

        assertThat(tokenService.resolveUserId(response.token())).contains(77L);
    }

    // --------------------------------------------------------------- test data

    /**
     * Stands in for the row JPA hands back after save: the same field values,
     * plus the generated id the token issuer needs. A mock rather than a real
     * {@link User} because the entity has no id setter, which is correct of it.
     */
    private static User persisted(User toSave) {
        return existingUser(1L, toSave.getEmail(), toSave.getName(), toSave.getPasswordHash());
    }

    private static User existingUser(String email, String name, String passwordHash) {
        return existingUser(1L, email, name, passwordHash);
    }

    private static User existingUser(long id, String email, String name, String passwordHash) {
        // lenient() because this is a shared fixture: a test asserting on the
        // login failure path never reads the name, and strict stubs would fail
        // it for a stub it had no reason to use. The alternative -- stubbing
        // field by field in each test -- would bury what each one is actually
        // about.
        User user = mock(User.class);
        lenient().when(user.getId()).thenReturn(id);
        lenient().when(user.getEmail()).thenReturn(email);
        lenient().when(user.getName()).thenReturn(name);
        lenient().when(user.getPasswordHash()).thenReturn(passwordHash);
        return user;
    }
}
