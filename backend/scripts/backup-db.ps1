# Dumps the CareerGuide Postgres database (running via docker compose) to a
# timestamped .sql file in backend/backups/.
#
# Usage (from the backend/ folder):
#   .\scripts\backup-db.ps1
#   .\scripts\backup-db.ps1 -Label before-schema-change
#
# This is a logical (pg_dump) backup: a plain-text SQL file that recreates
# the schema and data from scratch. It's portable (restorable into any
# Postgres, even a different major version) and small/inspectable, unlike a
# raw copy of the Docker volume. It runs entirely inside the postgres
# container and writes to /backups, which is bind-mounted to this folder —
# no data is piped through PowerShell, so there's no encoding risk to the
# dump file.
param(
    [string]$Label = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Split-Path -Parent $scriptDir

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$suffix = if ($Label) { "_$Label" } else { "" }
$filename = "careerguide_${timestamp}${suffix}.sql"

Push-Location $backendDir
try {
    docker compose exec postgres sh -c "pg_dump -U careerguide -d careerguide --clean --if-exists > /backups/$filename"
    if ($LASTEXITCODE -ne 0) {
        throw "pg_dump failed (exit code $LASTEXITCODE). Is 'docker compose up' running?"
    }
    Write-Host "Backup written to backend\backups\$filename"
} finally {
    Pop-Location
}
