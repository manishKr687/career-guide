# Registers (or removes) a Windows Scheduled Task that runs backup-db.ps1 daily.
#
#   .\scripts\schedule-backup.ps1                      # daily at 02:00, keep 30 days
#   .\scripts\schedule-backup.ps1 -At 23:30 -KeepDays 14
#   .\scripts\schedule-backup.ps1 -Status              # is it registered? when did it last run?
#   .\scripts\schedule-backup.ps1 -Remove
#
# WHY THIS EXISTS. The database is the source of truth for the catalogue, and
# migrations V1-V146 are history rather than a way to rebuild it: anything added
# or edited through the admin since V146 exists in exactly one place. A backup
# is therefore the only route back from a lost volume, a bad restore or a
# mistaken bulk delete -- and this project has already lost three admin-created
# exams and a user account to precisely that, because they existed in no
# migration.
#
# README has described pointing Task Scheduler at backup-db.ps1 since backups
# were added. Describing it is not doing it, and a backup plan that depends on
# somebody remembering is not a plan.
#
# Runs as the current user, whenever the machine is on, so it needs no elevation
# and no stored password. The trade-off is that it does not run while logged
# out; for a real deployment the backup belongs on the server beside the
# database, not on a workstation -- see the note printed at the end.
param(
    [string]$At = "02:00",
    [int]$KeepDays = 30,
    [switch]$Remove,
    [switch]$Status
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupScript = Join-Path $scriptDir "backup-db.ps1"
$taskName = "CareerGuide database backup"

if ($Status) {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if (-not $task) {
        Write-Host "Not registered. Run this script with no arguments to create it."
        exit 0
    }
    $info = Get-ScheduledTaskInfo -TaskName $taskName
    Write-Host "Task      : $taskName"
    Write-Host "State     : $($task.State)"
    Write-Host "Last run  : $($info.LastRunTime)"
    # 267011 is "task has not yet run"; 0 is success. Anything else is a failed
    # backup that nobody would otherwise hear about.
    Write-Host "Last result: $($info.LastTaskResult)$(if ($info.LastTaskResult -eq 0) { ' (success)' } elseif ($info.LastTaskResult -eq 267011) { ' (never run yet)' } else { ' -- FAILED, investigate' })"
    Write-Host "Next run  : $($info.NextRunTime)"
    exit 0
}

if ($Remove) {
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Removed scheduled task '$taskName'. Nothing will back up automatically from now on."
    } else {
        Write-Host "No scheduled task named '$taskName' to remove."
    }
    exit 0
}

if (-not (Test-Path $backupScript)) {
    throw "Cannot find backup-db.ps1 at $backupScript."
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$backupScript`" -KeepDays $KeepDays"
$trigger = New-ScheduledTaskTrigger -Daily -At $At
# StartWhenAvailable matters on a workstation: without it, a backup whose
# scheduled time passed while the machine was asleep is simply skipped, and the
# gap is invisible until someone needs that day's data.
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings `
    -Description "Runs backup-db.ps1 daily, keeping $KeepDays days of automatic backups. See backend/README.md." `
    -Force | Out-Null

Write-Host "Registered '$taskName': daily at $At, keeping $KeepDays days."
Write-Host ""
Write-Host "Check it with:   .\scripts\schedule-backup.ps1 -Status"
Write-Host "Remove it with:  .\scripts\schedule-backup.ps1 -Remove"
Write-Host ""
Write-Host "Two things this does NOT do, both of which matter:"
Write-Host "  1. It writes to backend\backups on this machine. A backup on the same"
Write-Host "     disk as the database survives a mistake, not a dead disk. Copy it"
Write-Host "     somewhere else -- another drive, or object storage -- on a schedule too."
Write-Host "  2. It does not run while you are logged out or the machine is off. For a"
Write-Host "     live deployment, schedule the backup on the server hosting Postgres."
Write-Host ""
Write-Host "And restore is the half that is never tested until it is urgent. To check a"
Write-Host "backup without touching your real database, restore it into a scratch one:"
Write-Host "  docker compose exec -T postgres psql -U careerguide -d postgres -c 'CREATE DATABASE restore_test OWNER careerguide;'"
Write-Host "  docker compose exec -T postgres psql -U careerguide -d restore_test -f /backups/<file>.sql"
Write-Host "  ...compare row counts, then: DROP DATABASE restore_test;"
