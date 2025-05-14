##############################################################################################
# Script contenente tutti gli atomic tests da eseguire relativi al lateral movement
##############################################################################################

# Percorso alla cartella atomics
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomic-red-team-master\atomics"

# Cartella per salvare i log
$LogDir = "C:\Temp\Mead\AtomicLogs\LateralMovement"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Lista dei test da eseguire (Tecnica + TestNumber)
$testsToRun = @(
    @{ Technique = "T1021.003"; TestNumber = 1 }
    @{ Technique = "T1550.002"; TestNumber = 1 }, @{ Technique = "T1550.002"; TestNumber = 2 }
    @{ Technique = "T1550.003"; TestNumber = 1 }, @{ Technique = "T1550.003"; TestNumber = 2 }
    @{ Technique = "T1563.002"; TestNumber = 1 }
    @{ Technique = "T1021.001"; TestNumber = 1 }, @{ Technique = "T1021.001"; TestNumber = 2 }, @{ Technique = "T1021.001"; TestNumber = 3 }
    @{ Technique = "T1091";     TestNumber = 1 }
    @{ Technique = "T1021.002"; TestNumber = 1 }, @{ Technique = "T1021.002"; TestNumber = 2 }, @{ Technique = "T1021.002"; TestNumber = 3 }, @{ Technique = "T1021.002"; TestNumber = 4 }
    @{ Technique = "T1072";     TestNumber = 1 }
    @{ Technique = "T1021.006"; TestNumber = 1 }, @{ Technique = "T1021.006"; TestNumber = 2 }, @{ Technique = "T1021.006"; TestNumber = 3 }
)

# Esecuzione uno alla volta in nuove finestre con logging
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
`$PSDefaultParameterValues = @{ 'Invoke-AtomicTest:PathToAtomicsFolder' = '$AtomicPath' }

'[$timestamp] Avvio test $testName' | Out-File -FilePath `$logPath -Encoding UTF8

try {
    '>> Esecuzione di Invoke-AtomicTest $testName' | Out-File -Append `$logPath
    Invoke-AtomicTest '$technique' -TestNumbers $testNumber -ExecutionMode Local 2>&1 | Tee-Object -FilePath `$logPath -Append
    '[SUCCESS] Test $testName completato con successo.' | Out-File -Append `$logPath
} catch {
    '[ERROR] Errore durante il test $testName :' | Out-File -Append `$logPath
    `$_ | Out-String | Out-File -Append `$logPath
}

'Premere un tasto per chiudere la finestra...' | Out-File -Append `$logPath
pause
"@

    Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $innerCommand

    # Pausa tra un test e il successivo
    Read-Host "Premi INVIO per passare al test successivo"
}
