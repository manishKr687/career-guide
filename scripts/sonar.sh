#!/usr/bin/env bash
# Runs both SonarQube analyses and exports the findings to files.
#
#   ./scripts/sonar.sh                 # scan both projects, then export
#   ./scripts/sonar.sh --export-only   # skip the scans, just fetch current results
#
# WHY A SCRIPT RATHER THAN A COMMAND IN THE README. SonarQube 26 requires
# authentication to submit an analysis -- `mvn sonar:sonar` without a token
# fails with "Not authorized. Analyzing this project requires authentication."
# So every scan needs a credential, and a credential pasted into a chat, a
# command history or a properties file is a credential leaked. This prompts for
# it with echo off, keeps it in a shell variable for the life of the run, and
# unsets it at the end. It is never written to disk.
#
# Generate one at: http://127.0.0.1:9000/account/security  (type: User Token)
#
# Output lands in .scannerwork/export/, which is gitignored.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUT_DIR="$ROOT_DIR/.scannerwork/export"

# 127.0.0.1 rather than localhost, deliberately. On this machine Docker's
# wslrelay has been seen holding [::1] while com.docker.backend serves 0.0.0.0,
# and Windows resolves localhost to ::1 first -- so localhost intermittently
# reaches a relay that accepts connections and never answers. 127.0.0.1 has
# never done that.
HOST="${SONAR_HOST:-http://127.0.0.1:9000}"
BACKEND_KEY="careerguide-backend"
FRONTEND_KEY="careerguide-frontend"

EXPORT_ONLY=0
[ "${1:-}" = "--export-only" ] && EXPORT_ONLY=1

if ! curl -sf --max-time 10 "$HOST/api/system/status" >/dev/null 2>&1; then
  echo "SonarQube is not answering at $HOST." >&2
  echo "Start it with: cd backend && docker compose up -d sonarqube" >&2
  exit 1
fi
echo "SonarQube is up at $HOST"

read -rsp "SonarQube user token: " SONAR_TOKEN; echo
if [ -z "$SONAR_TOKEN" ]; then
  echo "No token given; nothing to do." >&2
  exit 1
fi
# Make sure the token never outlives this script, even on an error path.
trap 'unset SONAR_TOKEN' EXIT

# Fail early on a bad token rather than halfway through a five-minute analysis.
if ! curl -sf -u "$SONAR_TOKEN:" --max-time 10 "$HOST/api/authentication/validate" \
     | grep -q '"valid":true'; then
  echo "That token was rejected by $HOST." >&2
  exit 1
fi
echo "Token accepted."

mkdir -p "$OUT_DIR"

if [ "$EXPORT_ONLY" -eq 0 ]; then
  echo
  echo "--- Backend analysis (Maven) ---"
  (cd "$ROOT_DIR/backend" && mvn -q sonar:sonar \
      -Dsonar.host.url="$HOST" \
      -Dsonar.token="$SONAR_TOKEN" \
      -Dsonar.projectKey="$BACKEND_KEY" \
      -Dsonar.projectName="CareerGuide Backend")
  echo "Backend analysis submitted."

  echo
  echo "--- Frontend analysis ---"
  # No scanner is vendored in this repo and none is on PATH, so this uses npx,
  # which needs network access the first time. Skipped rather than fatal: a
  # backend-only run is still worth having.
  if (cd "$ROOT_DIR" && npx --yes sonarqube-scanner@latest \
        -Dsonar.host.url="$HOST" \
        -Dsonar.token="$SONAR_TOKEN" 2>&1 | tail -5); then
    echo "Frontend analysis submitted."
  else
    echo "Frontend analysis skipped or failed (npx sonarqube-scanner unavailable?)." >&2
    echo "The backend results below are still valid." >&2
  fi

  # The scanner returns as soon as the report is uploaded; the server processes
  # it asynchronously. Exporting immediately would fetch the PREVIOUS run's
  # findings and look like a successful scan that changed nothing.
  echo
  echo "Waiting for server-side processing..."
  sleep 15
fi

echo
echo "--- Exporting findings ---"
METRICS="bugs,vulnerabilities,security_hotspots,code_smells,coverage,duplicated_lines_density,ncloc,sqale_index,reliability_rating,security_rating,sqale_rating"

for KEY in "$BACKEND_KEY" "$FRONTEND_KEY"; do
  ISSUES="$OUT_DIR/issues-$KEY.json"
  MEASURES="$OUT_DIR/measures-$KEY.json"

  curl -sf -u "$SONAR_TOKEN:" \
    "$HOST/api/issues/search?components=$KEY&ps=500&additionalFields=_all" \
    -o "$ISSUES" || echo "  could not fetch issues for $KEY" >&2
  curl -sf -u "$SONAR_TOKEN:" \
    "$HOST/api/measures/component?component=$KEY&metricKeys=$METRICS" \
    -o "$MEASURES" || echo "  could not fetch measures for $KEY" >&2

  if [ -s "$ISSUES" ]; then
    TOTAL="$(grep -o '"total":[0-9]*' "$ISSUES" | head -1 | cut -d: -f2)"
    echo "  $KEY: ${TOTAL:-?} issue(s) -> ${ISSUES#"$ROOT_DIR/"}"
  fi
done

echo
echo "Done. The export contains no credentials and lives in a gitignored folder."
