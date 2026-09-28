# Restores the CareerGuide Postgres database from a .sql file previously
# created by backup-db.ps1 (or a Flyway-style dump). This OVERWRITES the
# current database contents.
#
# Usage (from the backend/ folder):
#   .\scripts\restore-db.ps1 -File careerguide_20260917_120000.sql
#
# The file must already be in backend\backups\ (that folder is bind-mounted
# into the postgres container at /backups, so the restore runs entirely
# inside the container — no host-side piping/encoding to worry about).
param(
    [Parameter(Mandatory = $true)]
    [string]$File
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Split-Path -Parent $scriptDir
$backupPath = Join-Path $backendDir "backups\$File"

if (-not (Test-Path $backupPath)) {
    throw "Backup file not found: $backupPath"
}

Write-Host "This will overwrite the current careerguide database with the contents of $File."
$confirmation = Read-Host "Type 'yes' to continue"
if ($confirmation -ne "yes") {
    Write-Host "Cancelled."
    exit 0
}

Push-Location $backendDir
try {
    docker compose exec postgres sh -c "psql -U careerguide -d careerguide -f /backups/$File"
    if ($LASTEXITCODE -ne 0) {
        throw "psql restore failed (exit code $LASTEXITCODE). Is 'docker compose up' running?"
    }
    Write-Host "Restored from backend\backups\$File"
} finally {
    Pop-Location
}
