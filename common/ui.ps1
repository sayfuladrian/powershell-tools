# Inisialisasi variabel global
$Global:hostname = Get-Hostname
$Global:publicIP = Get-PublicIPAddress
$Global:localIP = Get-LocalIPAddress

function Write-Text {
	param(
		[string]$Text,
		[string]$Color = "White",
		[switch]$NoLine
	)
	
	Write-Host $Text -ForegroundColor $Color -NoNewLine:$NoLine
}

function Write-Title {
    param (
        [string]$Text,
        [string]$Color = "Green",
        [char]$BorderChar = "=",
        [bool]$IsMark = $true,
        [bool]$IsHost = $true,
        [bool]$IsCentered = $true,
        [bool]$IsCopyright = $true,
        [int]$Space = 0
    )

    Write-Space -Count $Space
    Write-Border -Color $Color -BorderChar $BorderChar

    if ($IsMark) {
        Write-AlignedText -Text "FUSION TOOLS V2.0 -- $Text" -Color $Color -IsCentered $IsCentered
    } else {
        Write-AlignedText -Text "-- $Text" -Color $Color -IsCentered $IsCentered
    }

    if ($IsHost) {
        Write-AlignedText -Text "Connected from: $Global:hostname with Public IP: $Global:publicIP ($Global:localIP)" -Color $Color -IsCentered $IsCentered
    }

    if ($IsCopyright) {
        Write-AlignedText "Created by: Sayful Adrian" -NoLine -Color "Magenta"
    }

    Write-Border -Color $Color -BorderChar $BorderChar
    Write-Space -Count $Space
}

function Write-Subtitle {
	param (
		[string]$Text,
		[string]$Color = "White",
		[bool]$Mark = $false
	)
	
	Write-Title $Text -Color $Color -IsMark $Mark -IsHost $false -IsCentered $false -BorderChar "-" -IsCopyright $false
	
}

function Write-AlignedText {
    param (
        [string]$Text,
        [string]$Color = 'Green',
        [bool]$IsCentered = $true
    )
    if ($IsCentered) {
        $width = $Host.UI.RawUI.WindowSize.Width
        $padding = [Math]::Max(0, ($width - $Text.Length) / 2)
        $formattedText = (" " * [Math]::Floor($padding)) + $Text
    } else {
        $formattedText = $Text
    }
    Write-Host $formattedText -ForegroundColor $Color
}

function Write-Border {
    param (
        [char]$BorderChar = '=',
        [string]$Color = 'Green',
        [int]$Top = 0,
        [int]$Bot = 0
    )

    $width = $Host.UI.RawUI.WindowSize.Width
    $border = "$BorderChar" * $width

    Write-Space -Count $Top
    Write-Host $border -ForegroundColor $Color
    Write-Space -Count $Bot
}

function Write-Space {
    param([int]$Count)
    for ($i = 0; $i -lt $Count; $i++) {
        Write-Host
    }
}

function Wait-Key {
    param(
        [int]$TimeoutInSeconds = 10,
        [string]$Message = "Press 'Space' to pause, 'Esc' to return to main menu, or any other key to proceed immediately...",
        [string]$Color = "Yellow",
        [string]$Info = ""
    )

    if ($Info) {
		
		Write-Space 1
		Write-Border "-" -Color "DarkCyan"
		Write-AlignedText $Info -Color $Color -IsCentered $False
		Write-Border "-" -Color "DarkCyan"
		Write-Space 1
		
    }

    Write-AlignedText $Message -Color $Color -IsCentered $False
    $host.UI.RawUI.FlushInputBuffer()
    $startTime = Get-Date
    $paused = $false
    $escapePressed = $false

    for ($i = 0; $i -le $TimeoutInSeconds; $i++) {
        $keyResponse = Read-Key ([ref]$paused)
        if ($keyResponse.EscapePressed -or $keyResponse.KeyPressed) {
            $escapePressed = $keyResponse.EscapePressed
            break
        }

        if (-not $paused) {
            Display-ProgressBar -Current $i -Total $TimeoutInSeconds
            Start-Sleep -Seconds 1
        }
    }
    Write-AlignedText `n`n -Color $Color -IsCentered $False

    return $escapePressed
}

function Read-Key {
    param(
        [ref]$Paused
    )

    if ([console]::KeyAvailable) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.VirtualKeyCode) {
            32 { # Space key
                if (-not $Paused.Value) {
                    Write-Host "`nPaused. Press Space, Escape, or Enter to continue..." -ForegroundColor "Yellow"
                    $Paused.Value = $true
                    do {
                        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    } while ($key.VirtualKeyCode -ne 32 -and $key.VirtualKeyCode -ne 27 -and $key.VirtualKeyCode -ne 13)
                    Write-Host "`nResuming..." -ForegroundColor "Yellow"
                }
                return @{ Paused = $false; EscapePressed = $false; KeyPressed = $true }
            }
            27 { # Escape key
                return @{ Paused = $false; EscapePressed = $true; KeyPressed = $true }
            }
            13 { # Return key
                return @{ Paused = $false; EscapePressed = $false; KeyPressed = $true }
            }
            default {
                return @{ Paused = $Paused.Value; EscapePressed = $false; KeyPressed = $false }
            }
        }
    } else {
        return @{ Paused = $Paused.Value; EscapePressed = $false; KeyPressed = $false }
    }
}

function Display-ProgressBar {
    param(
        [int]$Current,
        [int]$Total
    )
    
    $totalTicks = 50
    $ticks = [Math]::Round(($Current / $Total) * $totalTicks)
    $progressBar = "[" + "=" * $ticks + " " * ($totalTicks - $ticks) + "]"
    $secondsLeft = $Total - $Current
    Write-Host "`r$progressBar $secondsLeft second(s) to skip" -NoNewLine -ForegroundColor "Yellow"
}