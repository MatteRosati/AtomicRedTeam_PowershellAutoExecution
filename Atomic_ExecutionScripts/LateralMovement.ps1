# Percorso alla cartella atomics
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomics"

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

# Avvio test in finestre separate
foreach ($test in $testsToRun) {
    $technique = $test.Technique
    $testNumber = $test.TestNumber
    $testName = "$technique-$testNumber"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] Avvio test $testName..."

    $command = @"
`$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Write-Host '[PS WINDOW] Inizio test $testName alle' `$timestamp -ForegroundColor Cyan
`$PSDefaultParameterValues = @{ "Invoke-AtomicTest:PathToAtomicsFolder" = '$AtomicPath' }
Invoke-AtomicTest $testName
"@

    Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $command
}
