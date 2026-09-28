"use client";

import { createContext, useCallback, useContext, useEffect, useState } from "react";
import {
  User,
  getMe,
  getUserToken,
  userLogin,
  userLogout,
  userRegister,
  UserUnauthorizedError,
} from "@/lib/userApi";

interface UserContextValue {
  user: User | null;
  /** True until the initial token check (if any) resolves -- lets the Navbar avoid a "Sign In" flash for someone who's actually logged in. */
  loading: boolean;
  login: (email: string, password: string) => Promise<User>;
  register: (email: string, password: string, name: string) => Promise<User>;
  logout: () => void;
  refresh: () => Promise<void>;
}

const UserContext = createContext<UserContextValue | null>(null);

/**
 * Mounted once in the root layout (inside ToastProvider, since login/logout
 * show a toast). On mount, if a token is already stored, resolves it against
 * GET /api/me so a refresh doesn't silently log the visitor out; an expired
 * token is cleared quietly (UserUnauthorizedError), not surfaced as an
 * error, since "not logged in" is the expected steady state for most
 * visitors.
 */
export function UserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    if (!getUserToken()) {
      setUser(null);
      return;
    }
    try {
      setUser(await getMe());
    } catch (err) {
      if (err instanceof UserUnauthorizedError) {
        setUser(null);
      } else {
        // A transient network/server error shouldn't log the visitor out --
        // leave `user` as it was and let them retry.
      }
    }
  }, []);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    refresh().finally(() => setLoading(false));
  }, [refresh]);

  const login = useCallback(async (email: string, password: string) => {
    const loggedInUser = await userLogin(email, password);
    setUser(loggedInUser);
    return loggedInUser;
  }, []);

  const register = useCallback(async (email: string, password: string, name: string) => {
    const registeredUser = await userRegister(email, password, name);
    setUser(registeredUser);
    return registeredUser;
  }, []);

  const logout = useCallback(() => {
    userLogout();
    setUser(null);
  }, []);

  return (
    <UserContext.Provider value={{ user, loading, login, register, logout, refresh }}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const ctx = useContext(UserContext);
  if (!ctx) throw new Error("useUser must be used within a UserProvider");
  return ctx;
}
