package com.careerguide.api;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Enforces the rule in backend/README.md: <b>migrations carry schema, the
 * database carries content.</b>
 *
 * <p>That rule was written down and then immediately broken thirteen times --
 * V134 to V146 are all content. Not out of carelessness: a README paragraph is
 * advice, and advice loses to whatever is convenient at the time. This test is
 * the same sentence in a form that fails the build, which is the only form that
 * survives contact with a deadline.
 *
 * <p>It checks migrations <b>after V{@value #POLICY_STARTS_AFTER} only</b>.
 * V1-V146 are history: they seeded the catalogue, they record why particular
 * things were left empty, and they are checksummed and immutable. Nothing about
 * this test asks for them to change, and they must not.
 *
 * <h2>What counts as content</h2>
 *
 * Any INSERT, UPDATE, DELETE or COPY against a table that is not taxonomy.
 * Taxonomy -- categories, stages, streams and their join tables -- is schema by
 * the decision recorded in README: roughly 165 rows that foreign keys across the
 * database depend on, that change almost never, and that have no admin screens.
 *
 * <h2>The escape hatch, and why it is deliberately awkward</h2>
 *
 * Some genuine schema work needs DML: adding a NOT NULL column means backfilling
 * the rows that already exist. Banning that outright would make this test wrong
 * often enough that someone would delete it. So a migration may carry DML if it
 * says why, with a line containing {@code POLICY-EXCEPTION:} and a reason.
 *
 * <p>The marker is not a rubber stamp -- it is a sentence the author has to
 * write and a reviewer will see in the diff. "Backfilling a column added above"
 * is a fine reason. "Adding three new colleges" is not; that belongs in the
 * admin.
 */
class MigrationPolicyTest {

    /** Migrations up to and including this version predate the policy and are history. */
    private static final int POLICY_STARTS_AFTER = 146;

    private static final Path MIGRATIONS = Path.of("src/main/resources/db/migration");

    /** Schema, not content -- see README, "Where the line falls". */
    private static final Set<String> TAXONOMY_TABLES = Set.of(
            "categories",
            "stages",
            "streams",
            "stage_streams",
            "stage_exams",
            "stream_careers",
            "stream_combinations",
            "combination_careers"
    );

    private static final String EXEMPTION_MARKER = "POLICY-EXCEPTION:";

    /** Words that can follow UPDATE/DELETE without naming a table (e.g. ON CONFLICT DO UPDATE SET). */
    private static final Set<String> NOT_TABLE_NAMES = Set.of("set", "from", "only", "where");

    private static final Pattern DML = Pattern.compile(
            "(?i)\\b(insert\\s+into|update|delete\\s+from|copy)\\s+(?:public\\.)?([a-z_][a-z0-9_]*)");

    private static final Pattern VERSION = Pattern.compile("^V(\\d+)__");

    @Test
    void migrationsAfterThePolicyDateCarryNoContent() throws IOException {
        List<String> violations = new ArrayList<>();

        for (Path file : migrationFiles()) {
            String name = file.getFileName().toString();
            int version = versionOf(name);
            if (version <= POLICY_STARTS_AFTER) {
                continue;
            }

            String sql = Files.readString(file, StandardCharsets.UTF_8);
            if (sql.contains(EXEMPTION_MARKER)) {
                continue;
            }

            for (String table : contentTablesWrittenBy(sql)) {
                violations.add("  %s writes to '%s'".formatted(name, table));
            }
        }

        assertThat(violations)
                .as("""
                        These migrations add or change CONTENT, which belongs in the database.

                        %s

                        The catalogue's source of truth is the database; migrations carry schema.
                        See backend/README.md, "What owns the content".

                        Fix it one of these ways:
                          * Make the change in the admin UI instead, and delete the migration.
                            This is almost always the right answer.
                          * If the DML is genuinely schema work -- backfilling a column this same
                            migration added, re-densifying sort_order after a structural change --
                            add a comment line containing "%s" and the reason.
                          * If it is taxonomy (categories, stages, streams and their join tables),
                            it is already allowed; check the table name is spelled correctly.

                        V1-V%d are exempt as history and must not be edited: they are checksummed,
                        and changing one stops Flyway starting against every database that ran it.
                        """.formatted(String.join("\n", violations), EXEMPTION_MARKER, POLICY_STARTS_AFTER))
                .isEmpty();
    }

    @Test
    void thePolicyBoundaryMatchesTheMigrationsThatActuallyExist() {
        // Guards the guard. If someone raises POLICY_STARTS_AFTER to silence a
        // failure rather than fix it, the boundary drifts past migrations that
        // were never reviewed under this rule and the test quietly stops
        // protecting anything. It may only ever equal the highest migration that
        // existed when the policy was adopted.
        assertThat(POLICY_STARTS_AFTER)
                .as("POLICY_STARTS_AFTER must stay at 146, the last content migration written "
                        + "before the rule was adopted. Raising it exempts new migrations from "
                        + "review, which is the opposite of what this test is for.")
                .isEqualTo(146);
    }

    @Test
    void everyMigrationFileIsVersionedAndReadable() {
        // Cheap sanity check: a file that does not parse as V<n>__ would be
        // skipped silently by the policy test above, which is a hole.
        List<String> unparsed = migrationFiles().stream()
                .map(p -> p.getFileName().toString())
                .filter(n -> !n.equals("afterMigrate.sql") && !VERSION.matcher(n).find())
                .toList();

        assertThat(unparsed)
                .as("Migration files must be named V<number>__<description>.sql so the policy "
                        + "check can tell which side of the boundary they fall on. "
                        + "afterMigrate.sql is Flyway's reserved callback and is expected.")
                .isEmpty();
    }

    // ------------------------------------------------------------------ helpers

    private static List<Path> migrationFiles() {
        try (Stream<Path> files = Files.list(MIGRATIONS)) {
            return files.filter(p -> p.getFileName().toString().endsWith(".sql")).sorted().toList();
        } catch (IOException e) {
            throw new IllegalStateException(
                    "Could not read " + MIGRATIONS.toAbsolutePath()
                            + ". This test expects to run with the backend module as its working directory.", e);
        }
    }

    private static int versionOf(String fileName) {
        Matcher m = VERSION.matcher(fileName);
        return m.find() ? Integer.parseInt(m.group(1)) : Integer.MAX_VALUE;
    }

    /** Table names written to by {@code sql}, excluding taxonomy. */
    private static List<String> contentTablesWrittenBy(String sql) {
        String stripped = stripCommentsAndLiterals(sql);
        List<String> tables = new ArrayList<>();
        Matcher m = DML.matcher(stripped);
        while (m.find()) {
            String table = m.group(2).toLowerCase(Locale.ROOT);
            if (NOT_TABLE_NAMES.contains(table) || TAXONOMY_TABLES.contains(table)) {
                continue;
            }
            if (!tables.contains(table)) {
                tables.add(table);
            }
        }
        return tables;
    }

    /**
     * Removes line comments, block comments and single-quoted literals before
     * scanning. Without this, a migration whose comment explains "this does not
     * INSERT INTO careers" would be reported as doing exactly that, and prose
     * inside a RAISE EXCEPTION message would too.
     */
    private static String stripCommentsAndLiterals(String sql) {
        String noBlockComments = sql.replaceAll("(?s)/\\*.*?\\*/", " ");
        String noLineComments = noBlockComments.replaceAll("--[^\n]*", " ");
        // Doubled quotes inside a literal are an escaped quote, so consume pairs.
        return noLineComments.replaceAll("'(?:[^']|'')*'", " '' ");
    }
}
