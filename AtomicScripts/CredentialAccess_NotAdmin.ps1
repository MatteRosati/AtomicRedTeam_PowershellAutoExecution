##############################################################################################
# Credential Access Atomic Tests - da eseguire con powershell, senza privilegi di admin
##############################################################################################

# Configurazioni
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomic-red-team-master\atomics"
$LogDir = "C:\Temp\Mead\AtomicLogs\CredentialAccess_NotAdmin"
$ReportPath = Join-Path $LogDir "CredentialAccessNotAdmin_Report.csv"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

# Lista test da eseguire (Tecnica + TestNumber)
$testsToRun = @(
        @{ Technique = "T1558.004"; TestNumber = 1 }
        @{ Technique = "T1003.005"; TestNumber = 1 }
        @{ Technique = "T1552.001"; TestNumber = 4 }
        @{ Technique = "T1555";     TestNumber = 1 }
        @{ Technique = "T1555";     TestNumber = 2 }
        @{ Technique = "T1555";     TestNumber = 3 }
        @{ Technique = "T1555";     TestNumber = 4 }
        @{ Technique = "T1555";     TestNumber = 5 }
        @{ Technique = "T1555.003"; TestNumber = 1 }
        @{ Technique = "T1555.003"; TestNumber = 7 }
        @{ Technique = "T1552.002"; TestNumber = 1 }
        @{ Technique = "T1552.002"; TestNumber = 2 }
        @{ Technique = "T1003.006"; TestNumber = 1 }
        @{ Technique = "T1187";     TestNumber = 1 }
        @{ Technique = "T1056.002"; TestNumber = 2 }
        @{ Technique = "T1558.001"; TestNumber = 1 }
        @{ Technique = "T1558.001"; TestNumber = 2 }
        @{ Technique = "T1552.006"; TestNumber = 1 }
        @{ Technique = "T1552.006"; TestNumber = 2 }
        @{ Technique = "T1558.003"; TestNumber = 1 }
        @{ Technique = "T1558.003"; TestNumber = 2 }
        @{ Technique = "T1558.003"; TestNumber = 3 }
        @{ Technique = "T1558.003"; TestNumber = 4 }
        @{ Technique = "T1558.003"; TestNumber = 5 }
        @{ Technique = "T1110.001"; TestNumber = 1 }
        @{ Technique = "T1110.001"; TestNumber = 2 }
        @{ Technique = "T1110.003"; TestNumber = 1 }
        @{ Technique = "T1110.003"; TestNumber = 2 }
        @{ Technique = "T1110.003"; TestNumber = 3 }
        @{ Technique = "T1552.004"; TestNumber = 1 }
        @{ Technique = "T1552.004"; TestNumber = 9 }
        @{ Technique = "T1552.004"; TestNumber = 10}
        @{ Technique = "T1003.002"; TestNumber = 5 }
        @{ Technique = "T1003.002"; TestNumber = 6 }
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
