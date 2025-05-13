##############################################################################################
# Script contenente tutti gli atomic tests da eseguire relativi al credential access
##############################################################################################

# Percorso alla cartella atomics
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomic-red-team-master\atomics"

# Cartella dove salvare i log
$LogDir = "C:\Temp\Mead\AtomicLogs\CredentialAccess"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Lista dei test da eseguire (Tecnica + TestNumber)
$testsToRun = @(
    @{ Technique = "T1558.004"; TestNumber = 1 }
    @{ Technique = "T1003.005"; TestNumber = 1 }
    @{ Technique = "T1056.004"; TestNumber = 1 }
    @{ Technique = "T1552.001"; TestNumber = 4 }
    @{ Technique = "T1552.001"; TestNumber = 5 }
    @{ Technique = "T1555";      TestNumber = 1 }
    @{ Technique = "T1555";      TestNumber = 2 }
    @{ Technique = "T1555";      TestNumber = 3 }
    @{ Technique = "T1555";      TestNumber = 4 }
    @{ Technique = "T1555";      TestNumber = 5 }
    @{ Technique = "T1555.003";  TestNumber = 1 }
    @{ Technique = "T1555.003";  TestNumber = 3 }
    @{ Technique = "T1555.003";  TestNumber = 7 }
    @{ Technique = "T1552.002";  TestNumber = 1 }
    @{ Technique = "T1552.002";  TestNumber = 2 }
    @{ Technique = "T1003.006";  TestNumber = 1 }
    @{ Technique = "T1187";      TestNumber = 1 }
    @{ Technique = "T1056.002";  TestNumber = 2 }
    @{ Technique = "T1558.001";  TestNumber = 1 }
    @{ Technique = "T1558.001";  TestNumber = 2 }
    @{ Technique = "T1552.006";  TestNumber = 1 }
    @{ Technique = "T1552.006";  TestNumber = 2 }
    @{ Technique = "T1558.003";  TestNumber = 1 }
    @{ Technique = "T1558.003";  TestNumber = 2 }
    @{ Technique = "T1558.003";  TestNumber = 3 }
    @{ Technique = "T1558.003";  TestNumber = 4 }
    @{ Technique = "T1558.003";  TestNumber = 5 }
    @{ Technique = "T1056.001";  TestNumber = 1 }
    @{ Technique = "T1557.001";  TestNumber = 1 }
    @{ Technique = "T1003.004";  TestNumber = 1 }
    @{ Technique = "T1003.001";  TestNumber = 1 }, @{ Technique = "T1003.001";  TestNumber = 2 }
    @{ Technique = "T1003.001";  TestNumber = 3 }, @{ Technique = "T1003.001";  TestNumber = 4 }
    @{ Technique = "T1003.001";  TestNumber = 5 }, @{ Technique = "T1003.001";  TestNumber = 6 }
    @{ Technique = "T1003.001";  TestNumber = 7 }, @{ Technique = "T1003.001";  TestNumber = 8 }
    @{ Technique = "T1003.001";  TestNumber = 9 }, @{ Technique = "T1003.001";  TestNumber = 10 }
    @{ Technique = "T1003.001";  TestNumber = 11 }, @{ Technique = "T1003.001";  TestNumber = 12 }
    @{ Technique = "T1556.002";  TestNumber = 1 }
    @{ Technique = "T1003.003";  TestNumber = 1 }, @{ Technique = "T1003.003";  TestNumber = 2 }
    @{ Technique = "T1003.003";  TestNumber = 3 }, @{ Technique = "T1003.003";  TestNumber = 4 }
    @{ Technique = "T1003.003";  TestNumber = 5 }, @{ Technique = "T1003.003";  TestNumber = 6 }
    @{ Technique = "T1003.003";  TestNumber = 7 }
    @{ Technique = "T1040";      TestNumber = 3 }, @{ Technique = "T1040";      TestNumber = 4 }
    @{ Technique = "T1003";      TestNumber = 1 }, @{ Technique = "T1003";      TestNumber = 2 }
    @{ Technique = "T1003";      TestNumber = 3 }
    @{ Technique = "T1110.002";  TestNumber = 1 }
    @{ Technique = "T1110.001";  TestNumber = 1 }, @{ Technique = "T1110.001";  TestNumber = 2 }
    @{ Technique = "T1110.003";  TestNumber = 1 }, @{ Technique = "T1110.003";  TestNumber = 2 }, @{ Technique = "T1110.003";  TestNumber = 3 }
    @{ Technique = "T1552.004";  TestNumber = 1 }, @{ Technique = "T1552.004";  TestNumber = 6 }, @{ Technique = "T1552.004";  TestNumber = 7 }
    @{ Technique = "T1003.002";  TestNumber = 1 }, @{ Technique = "T1003.002";  TestNumber = 2 }, @{ Technique = "T1003.002";  TestNumber = 3 }
    @{ Technique = "T1003.002";  TestNumber = 4 }, @{ Technique = "T1003.002";  TestNumber = 5 }, @{ Technique = "T1003.002";  TestNumber = 6 }
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

    # Pausa nella finestra principale (opzionale: puoi anche toglierla)
    Read-Host "Premi INVIO per passare al test successivo"
}
