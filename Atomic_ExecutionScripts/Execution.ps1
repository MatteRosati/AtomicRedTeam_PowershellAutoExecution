##################################################################################################################################################
# Script ".ps" che lancia tutti i test relativi alla parte "execution" del file excel.
##################################################################################################################################################


# Percorso personalizzato alla cartella "atomics"
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomics"

# Tecnica e lista dei numeri dei test da eseguire
$technique = "T1047"
$testNumbers = 1..9  # Eseguiamo i test 1-9

# Per ogni test, lancia nuova finestra PowerShell con info su test e orario
foreach ($testNumber in $testNumbers) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $testName = "$technique-$testNumber"

    # Stampa nella finestra principale
    Write-Host "[$timestamp] Avvio del test $testName in nuova finestra..."

    # Comando da eseguire nella nuova finestra PowerShell
    $command = @"
`$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Write-Host '[PS WINDOW] Inizio test $testName alle' `$timestamp -ForegroundColor Cyan
`$PSDefaultParameterValues = @{ "Invoke-AtomicTest:PathToAtomicsFolder" = '$AtomicPath' }
Invoke-AtomicTest $testName
"@

    # Avvia nuova finestra PowerShell con il test
    Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $command
}