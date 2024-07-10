# Import UI functions
. ..\common\function.ps1
. ..\common\ui.ps1

function Monitor-Connections {
    while ($true) {
		
		Clear-Host

        Write-Title -Text "Current Established Connections"

        $netstatOutput = netstat -an | Select-String "ESTABLISHED"

        Write-Subtitle -Text "Established Connections"

        foreach ($line in $netstatOutput) {
            Write-Text -Text $line.ToString() -Color "Green"
        }

        Wait-Key
    }
}

Monitor-Connections