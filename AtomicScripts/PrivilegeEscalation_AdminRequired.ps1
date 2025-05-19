###################################################################################################
# Privilege escalation atomic tests - da effettuare con powershell con privilegi di amministratore.
###################################################################################################

# Configurazioni
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomic-red-team-master\atomics"
$LogDir = "C:\Temp\Mead\AtomicLogs\PrivilegeEscalationAsAdmin"
$ReportPath = Join-Path $LogDir "PrivilegeEscalationAsRequired_Report.csv"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

# Lista test da eseguire (Tecnica + TestNumber)
$testsToRun = @(
        @{ Technique = "T1053.005"; TestNumber = 4 }
        @{ Technique = "T1574.011"; TestNumber = 2 }
        @{ Technique = "T1546.008"; TestNumber = 1 }
        @{ Technique = "T1546.008"; TestNumber = 2 }
        @{ Technique = "T1546.010"; TestNumber = 1 }
        @{ Technique = "T1546.011"; TestNumber = 1 }
        @{ Technique = "T1546.011"; TestNumber = 2 }
        @{ Technique = "T1546.011"; TestNumber = 3 }
        @{ Technique = "T1548.002"; TestNumber = 6 }
        @{ Technique = "T1548.002"; TestNumber = 8 }
        @{ Technique = "T1574.012"; TestNumber = 2 }
        @{ Technique = "T1546.001"; TestNumber = 1 }
        @{ Technique = "T1134.002"; TestNumber = 1 }
        @{ Technique = "T1574.001"; TestNumber = 1 }
        @{ Technique = "T1078.001"; TestNumber = 1 }
        @{ Technique = "T1078.001"; TestNumber = 2 }
        @{ Technique = "T1055.001"; TestNumber = 1 }
        @{ Technique = "T1546.012"; TestNumber = 1 }
        @{ Technique = "T1546.012"; TestNumber = 2 }
        @{ Technique = "T1078.003"; TestNumber = 1 }
        @{ Technique = "T1546.007"; TestNumber = 1 }
        @{ Technique = "T1574.009"; TestNumber = 1 }
        @{ Technique = "T1547.010"; TestNumber = 1 }
        @{ Technique = "T1547.001"; TestNumber = 2 }
        @{ Technique = "T1547.001"; TestNumber = 3 }
        @{ Technique = "T1547.001"; TestNumber = 4 }
        @{ Technique = "T1547.001"; TestNumber = 5 }
        @{ Technique = "T1547.001"; TestNumber = 6 }
        @{ Technique = "T1547.001"; TestNumber = 7 }
        @{ Technique = "T1053.005"; TestNumber = 1 }
        @{ Technique = "T1053.005"; TestNumber = 3 }
        @{ Technique = "T1546.002"; TestNumber = 1 }
        @{ Technique = "T1547.009"; TestNumber = 2 }
        @{ Technique = "T1134.001"; TestNumber = 1 }
        @{ Technique = "T1134.001"; TestNumber = 2 }
        @{ Technique = "T1543.003"; TestNumber = 2 }
        @{ Technique = "T1543.003"; TestNumber = 3 }
)

# Carica tutte le tecniche da file YAML
$yamlFiles = Get-ChildItem -Path $AtomicPath -Recurse -Include T*.yaml
$allTechniques = $yamlFiles | Get-AtomicTechnique

# Inizializza report
$report = @()

foreach ($test in $testsToRun) {
    $technique = $test.Technique
    $testNumber = $test.TestNumber
    $testName = "$technique-$testNumber"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $LogDir "$testName.txt"

    "n==============================" | Out-File -FilePath $logFile -Encoding UTF8
    "[$timestamp] Avvio test $testName" | Out-File -Append $logFile
    "n" | Out-File -Append $logFile

    $testStatus = ""
    $executor = ""
    $elevationRequired = ""

    try {
        $tech = $allTechniques | Where-Object { $_.attack_technique -eq $technique }

        if (-not $tech) {
            "[ERRORE] Tecnica $technique non trovata." | Out-File -Append $logFile
            $testStatus = "TECHNIQUE_NOT_FOUND"
            continue
        }

        $atomicTest = $tech.atomic_tests[$testNumber - 1]

        if (-not $atomicTest) {
            "[ERRORE] Test numero $testNumber non trovato per $technique." | Out-File -Append $logFile
            $testStatus = "TEST_NOT_FOUND"
            continue
        }

        $executor = $atomicTest.executor.name
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

        Invoke-AtomicTest $technique -TestNumbers $testNumber -GetPrereqs -PathToAtomicsFolder $AtomicPath 2>&1 | Tee-Object -Append $logFile
        Invoke-AtomicTest $technique -TestNumbers $testNumber -PathToAtomicsFolder $AtomicPath 2>&1 | Tee-Object -Append $logFile

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

    $report += [PSCustomObject]@{
        Timestamp         = $timestamp
        Technique         = $technique
        TestNumber        = $testNumber
        TestName          = $testName
        Executor          = $executor
        RequiresElevation = $elevationRequired
        Status            = $testStatus
        LogPath           = $logFile
    }

    "nPremi INVIO per continuare..." | Out-File -Append $logFile
    Read-Host "Premi INVIO per passare al test successivo"
}

# Esporta report finale
$report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "n[INFO] Report CSV salvato in: $ReportPath" -ForegroundColor Green
