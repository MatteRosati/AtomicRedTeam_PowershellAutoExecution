##############################################################################################
# Script contenente tutti gli atomic tests da eseguire relativi al privilege escalations
##############################################################################################

# Percorso alla cartella atomics
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomics"

# Cartella dove salvare i log
$LogDir = "C:\Temp\Mead\AtomicLogs\PrivilegeEscalation"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Lista dei test da eseguire (Tecnica + TestNumber)
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

# Avvio test uno alla volta in nuove finestre con logging e gestione errori
foreach ($test in $testsToRun) {
    $technique = $test.Technique
    $testNumber = $test.TestNumber
    $testName = "$technique-$testNumber"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $LogDir "$testName.txt"
    Write-Host "[$timestamp] Avvio test $testName..." -ForegroundColor Cyan

    $innerCommand = @"
`$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
`$logPath = '$logFile'
`$PSDefaultParameterValues = @{ "Invoke-AtomicTest:PathToAtomicsFolder" = '$AtomicPath' }

'[$timestamp] Avvio test $testName' | Out-File -FilePath `$logPath -Encoding UTF8

try {
    '>> Esecuzione di Invoke-AtomicTest $testName' | Out-File -Append `$logPath
    Invoke-AtomicTest '$technique' -TestNumbers $testNumber -ExecutionMode Local 2>&1 | Tee-Object -FilePath `$logPath -Append
    '[SUCCESS] Test $testName completato con successo.' | Out-File -Append `$logPath
} catch {
    '[ERROR] Errore durante il test $testName :' | Out-File -Append `$logPath
    \$_ | Out-String | Out-File -Append `$logPath
}

'Premere un tasto per chiudere la finestra...' | Out-File -Append `$logPath
pause
"@

    Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $innerCommand

    # Pausa nella finestra principale per evitare lanci simultanei
    Read-Host "Premi INVIO per passare al test successivo"
}
