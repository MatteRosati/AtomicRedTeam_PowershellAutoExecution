##############################################################################################
# Esecuzione test atomic con skip manual executor e report finale in CSV
##############################################################################################

# Configurazioni
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomic-red-team-master\atomics"
$LogDir = "C:\Temp\Mead\AtomicLogs\Execution"
$ReportPath = Join-Path $LogDir "Execution_Report.csv"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

# Lista test da eseguire
$testsToRun = @(
    @{ Technique = "T1047"; TestNumber = 1 }, @{ Technique = "T1047"; TestNumber = 2 }, @{ Technique = "T1047"; TestNumber = 3 },
    @{ Technique = "T1047"; TestNumber = 4 }, @{ Technique = "T1047"; TestNumber = 5 }, @{ Technique = "T1047"; TestNumber = 6 },
    @{ Technique = "T1047"; TestNumber = 7 }, @{ Technique = "T1047"; TestNumber = 8 }, @{ Technique = "T1047"; TestNumber = 9 }
)

# Inizializza lista report
$report = @()

foreach ($test in $testsToRun) {
    $technique = $test.Technique
    $testNumber = $test.TestNumber
    $testName = "$technique-$testNumber"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $LogDir "$testName.txt"

    "`n==============================" | Out-File -FilePath $logFile -Encoding UTF8
    "[$timestamp] Avvio test $testName" | Out-File -Append $logFile
    "`n" | Out-File -Append $logFile

    $testStatus = ""
    $executor = ""
    $elevationRequired = ""

    try {
        # Ottieni il test
        $tech = Get-AtomicTechnique -Technique $technique
        $atomicTest = $tech.atomic_tests | Where-Object { $_.auto_generated_guid -match "$technique-$testNumber" }

        if ($null -eq $atomicTest) {
            "[ERRORE] Test $testName non trovato." | Out-File -Append $logFile
            $testStatus = "NOT_FOUND"
            continue
        }

        $executor = $atomicTest.executor
        $elevationRequired = $atomicTest.elevation_required

        ">> Executor: $executor" | Out-File -Append $logFile
        ">> Requires Elevation: $elevationRequired" | Out-File -Append $logFile

        if ($executor -eq "manual") {
            "[SKIP] Il test ha executor 'manual'. Non eseguito." | Out-File -Append $logFile
            $testStatus = "SKIPPED_MANUAL"
            continue
        }

        if ($elevationRequired) {
            "[AVVISO] Il test richiede privilegi elevati!" | Out-File -Append $logFile
        }

        # Prereqs
        Invoke-AtomicTest $technique -TestNumbers $testNumber -GetPrereqs -PathToAtomicsFolder $AtomicPath 2>&1 | Tee-Object -Append $logFile

        # Esecuzione
        Invoke-AtomicTest $technique -TestNumbers $testNumber -PathToAtomicsFolder $AtomicPath 2>&1 | Tee-Object -Append $logFile

        # Cleanup
        Start-Sleep -Seconds 2
        Invoke-AtomicTest $technique -TestNumbers $testNumber -Cleanup -PathToAtomicsFolder $AtomicPath 2>&1 | Tee-Object -Append $logFile

        "[SUCCESSO] Test $testName completato." | Out-File -Append $logFile
        $testStatus = "SUCCESS"
    }
    catch {
        "[ERRORE] Durante il test $testName" | Out-File -Append $logFile
        $_ | Out-String | Out-File -Append $logFile
        $testStatus = "ERROR"
    }

    # Aggiunta al report
    $report += [PSCustomObject]@{
        Technique        = $technique
        TestNumber       = $testNumber
        TestName         = $testName
        Executor         = $executor
        RequiresElevation = $elevationRequired
        Status           = $testStatus
        LogPath          = $logFile
    }

    "`nPremi INVIO per continuare..." | Out-File -Append $logFile
    Read-Host "Premi INVIO per passare al test successivo"
}

# Esporta report
$report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "`n[INFO] Report CSV salvato in: $ReportPath" -ForegroundColor Green
