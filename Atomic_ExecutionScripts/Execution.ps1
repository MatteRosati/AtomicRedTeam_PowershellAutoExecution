##############################################################################################
# Script contenente tutti gli atomic tests da eseguire relativi all'execution
##############################################################################################

# Percorso alla cartella atomics
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomics"

# Lista dei test da eseguire (Tecnica + TestNumber)
$testsToRun = @(
    @{ Technique = "T1047"; TestNumber = 1 }, @{ Technique = "T1047"; TestNumber = 2 }, @{ Technique = "T1047"; TestNumber = 3 }
    @{ Technique = "T1047"; TestNumber = 4 }, @{ Technique = "T1047"; TestNumber = 5 }, @{ Technique = "T1047"; TestNumber = 6 }
    @{ Technique = "T1047"; TestNumber = 7 }, @{ Technique = "T1047"; TestNumber = 8 }, @{ Technique = "T1047"; TestNumber = 9 }
)

# Avvio test in finestre separate
foreach ($test in $testsToRun) {
    $technique = $test.Technique
    $testNumber = $test.TestNumber
    $testName = "$technique-$testNumber"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] Avvio test $testName..."

    $command = @"
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Write-Host '[PS WINDOW] Inizio test $testName alle' $timestamp -ForegroundColor Cyan
$PSDefaultParameterValues = @{ "Invoke-AtomicTest:PathToAtomicsFolder" = '$AtomicPath' }
Invoke-AtomicTest $testName
"@

    Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $command
}
