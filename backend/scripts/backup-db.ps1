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
#   .\scripts\backup-db.ps1 -KeepDays 30       # also prune old automatic backups
param(
    [string]$Label = "",
    # 0 keeps every backup forever, which is the original behaviour and stays
    # the default. A positive value prunes automatic backups older than that
    # many days -- see the pruning block at the foot of this script for what it
    # deliberately refuses to touch.
    [int]$KeepDays = 0
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

    # A backup nobody checks is a guess. The redirection above happens inside
    # the container, so if pg_dump dies part way through -- disk full, the
    # container stopped, a connection dropped -- a truncated file is left
    # behind that looks exactly like a good one until the day it is needed.
    # pg_dump writes this marker as its last act, so its presence is what
    # separates a complete dump from a partial one.
    $path = Join-Path $backendDir "backups\$filename"
    if (-not (Test-Path $path)) {
        throw "pg_dump reported success but no file appeared at $path."
    }
    if (-not (Select-String -Path $path -Pattern '^-- PostgreSQL database dump complete' -Quiet)) {
        $size = (Get-Item $path).Length
        Remove-Item $path -Force
        throw "Backup was incomplete ($size bytes, no completion marker) and has been deleted. Nothing was kept, so this is a failure rather than a bad backup you might later trust."
    }

    $bytes = (Get-Item $path).Length
    Write-Host "Backup written to backend\backups\$filename ($([math]::Round($bytes / 1KB)) KB, verified complete)"

    if ($KeepDays -gt 0) {
        # Only unlabelled backups are pruned. A labelled one --
        # "before-schema-change" -- was taken deliberately at a moment someone
        # thought mattered, and an automatic cleanup quietly deleting it is
        # exactly the backup you would want back.
        $cutoff = (Get-Date).AddDays(-$KeepDays)
        $stale = Get-ChildItem -Path (Join-Path $backendDir "backups") -Filter "careerguide_*.sql" |
            Where-Object { $_.Name -match '^careerguide_\d{8}_\d{6}\.sql$' -and $_.LastWriteTime -lt $cutoff }
        foreach ($file in $stale) {
            Remove-Item $file.FullName -Force
            Write-Host "  pruned $($file.Name)"
        }
    }
} finally {
    Pop-Location
}
