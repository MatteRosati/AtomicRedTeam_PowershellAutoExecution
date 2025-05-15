##############################################################################################
# Esecuzione test Atomic di Privilege Escalation con auto-skip dei manual executor
# e generazione di report CSV finale
##############################################################################################

# Configurazioni
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomic-red-team-master\atomics"
$LogDir = "C:\Temp\Mead\AtomicLogs\PrivilegeEscalation"
$ReportPath = Join-Path $LogDir "PrivilegeEscalation_Report.csv"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

# Lista dei test da eseguire
$testsToRun = @(
    @{ Technique = "T1546.008"; TestNumber = 1 }, @{ Technique = "T1546.008"; TestNumber = 2 }
    @{ Technique = "T1546.010"; TestNumber = 1 }
    @{ Technique = "T1546.011"; TestNumber = 1 }, @{ Technique = "T1546.011"; TestNumber = 2 }, @{ Technique = "T1546.011"; TestNumber = 3 }
    @{ Technique = "T1055.004"; TestNumber = 1 }
    @{ Technique = "T1053.002"; TestNumber = 1 }
    @{ Technique = "T1548.002"; TestNumber = 1 }, @{ Technique = "T1548.002"; TestNumber = 2 }, @{ Technique = "T1548.002"; TestNumber = 3 }
    @{ Technique = "T1548.002"; TestNumber = 4 }, @{ Technique = "T1548.002"; TestNumber = 5 }, @{ Technique = "T1548.002"; TestNumber = 6 }
    @{ Technique = "T1548.002"; TestNumber = 7 }, @{ Technique = "T1548.002"; TestNumber = 8 }, @{ Technique = "T1548.002"; TestNumber = 9 }
    @{ Technique = "T1548.002"; TestNumber = 10 }, @{ Technique = "T1548.002"; TestNumber = 11 }, @{ Technique = "T1548.002"; TestNumber = 12 }
    @{ Technique = "T1548.002"; TestNumber = 13 }, @{ Technique = "T1548.002"; TestNumber = 14 }, @{ Technique = "T1548.002"; TestNumber = 15 }
    @{ Technique = "T1548.002"; TestNumber = 16 }, @{ Technique = "T1548.002"; TestNumber = 17 }
    @{ Technique = "T1574.012"; TestNumber = 1 }, @{ Technique = "T1574.012"; TestNumber = 2 }, @{ Technique = "T1574.012"; TestNumber = 3 }
    @{ Technique = "T1546.001"; TestNumber = 1 }
    @{ Technique = "T1134.002"; TestNumber = 1 }
    @{ Technique = "T1574.001"; TestNumber = 1 }
    @{ Technique = "T1574.002"; TestNumber = 1 }
    @{ Technique = "T1078.001"; TestNumber = 1 }, @{ Technique = "T1078.001"; TestNumber = 2 }
    @{ Technique = "T1055.001"; TestNumber = 1 }
    @{ Technique = "T1546.012"; TestNumber = 1 }, @{ Technique = "T1546.012"; TestNumber = 2 }
    @{ Technique = "T1078.003"; TestNumber = 1 }
    @{ Technique = "T1037.001"; TestNumber = 1 }
    @{ Technique = "T1546.007"; TestNumber = 1 }
    @{ Technique = "T1134.004"; TestNumber = 1 }, @{ Technique = "T1134.004"; TestNumber = 2 }, @{ Technique = "T1134.004"; TestNumber = 3 }
    @{ Technique = "T1134.004"; TestNumber = 4 }, @{ Technique = "T1134.004"; TestNumber = 5 }
    @{ Technique = "T1574.009"; TestNumber = 1 }
    @{ Technique = "T1547.010"; TestNumber = 1 }
    @{ Technique = "T1546.013"; TestNumber = 1 }
    @{ Technique = "T1055.012"; TestNumber = 1 }, @{ Technique = "T1055.012"; TestNumber = 2 }
    @{ Technique = "T1055";     TestNumber = 1 }, @{ Technique = "T1055";     TestNumber = 2 }
    @{ Technique = "T1547.001"; TestNumber = 1 }, @{ Technique = "T1547.001"; TestNumber = 2 }, @{ Technique = "T1547.001"; TestNumber = 3 }
    @{ Technique = "T1547.001"; TestNumber = 4 }, @{ Technique = "T1547.001"; TestNumber = 5 }, @{ Technique = "T1547.001"; TestNumber = 6 }
    @{ Technique = "T1547.001"; TestNumber = 7 }
    @{ Technique = "T1053.005"; TestNumber = 1 }, @{ Technique = "T1053.005"; TestNumber = 2 }, @{ Technique = "T1053.005"; TestNumber = 3 }, @{ Technique = "T1053.005"; TestNumber = 4 }
    @{ Technique = "T1546.002"; TestNumber = 1 }
    @{ Technique = "T1547.005"; TestNumber = 1 }
    @{ Technique = "T1574.011"; TestNumber = 1 }, @{ Technique = "T1574.011"; TestNumber = 2 }
    @{ Technique = "T1547.009"; TestNumber = 1 }, @{ Technique = "T1547.009"; TestNumber = 2 }
    @{ Technique = "T1134.001"; TestNumber = 1 }, @{ Technique = "T1134.001"; TestNumber = 2 }
    @{ Technique = "T1546.003"; TestNumber = 1 }
    @{ Technique = "T1543.003"; TestNumber = 1 }, @{ Technique = "T1543.003"; TestNumber = 2 }, @{ Technique = "T1543.003"; TestNumber = 3 }
    @{ Technique = "T1547.004"; TestNumber = 1 }, @{ Technique = "T1547.004"; TestNumber = 2 }, @{ Technique = "T1547.004"; TestNumber = 3 }
)

# Inizializza report finale
$report = @()

# Carica YAML
$yamlFiles = Get-ChildItem -Path $AtomicPath -Recurse -Include T*.yaml
$allTechniques = $yamlFiles | Get-AtomicTechnique

foreach ($test in $testsToRun) {
    $technique = $test.Technique
    $testNumber = $test.TestNumber
    $testName = "$technique-$testNumber"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $LogDir "$testName.txt"

    "===============================" | Out-File -FilePath $logFile -Encoding UTF8
    "[$timestamp] Avvio test $testName" | Out-File -Append $logFile
    "" | Out-File -Append $logFile

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
            "[SKIP] Executor 'manual'. Test ignorato." | Out-File -Append $logFile
            $testStatus = "SKIPPED_MANUAL"
            continue
        }

        if ($elevationRequired) {
            "[AVVISO] Richiesti privilegi elevati!" | Out-File -Append $logFile
        }

        # Prerequisiti
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

    "" | Out-File -Append $logFile
    Read-Host "Premi INVIO per passare al test successivo"
}

# Salva il report CSV
$report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "`n[INFO] Report CSV salvato in: $ReportPath" -ForegroundColor Green
