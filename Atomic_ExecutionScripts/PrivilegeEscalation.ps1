# Percorso alla cartella atomics
$AtomicPath = "C:\Temp\Mead\atomic-red-team-master\atomics"

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
