<#
 #  Get-Edit
 #  Author: Rory Maher
 #  Date 20/04/2020
 #>
param (
    [Parameter(Mandatory = $true)]
    [string]
    $file
)

# Globals
$Script:Buffer = $null

$Script:Cursor = [PSCustomObject]@{
    X = 0
    Y = 0
}

function Save-Edit {
}

function Open-Edit {
    try {
        $FileContent = Get-Content -Path $file -Delimiter "`n" # break it up by newlines to help calculate our console space
    }
    catch {
        Write-Error "Could not open the specified file"
        return -1
    }
    $Script:Buffer = $FileContent
}

function Move-Cursor {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        [ValidateSet('Up', 'Down', 'Left', 'Right')]
        $direction
    )
    
    # Modify the cursor, ignore if we're going to break bounds
    switch ($direction) {
        'Up' {
            if ($Script:Cursor.Y -gt 0) {
                $Script:Cursor.Y = $Script:Cursor.Y - 1
            } 
        }
        'Down' {
            if ($Script:Cursor.Y -lt [System.Console]::WindowHeight - 1) {
                $Script:Cursor.Y = $Script:Cursor.Y + 1
            }
        }
        'Left' {
            if ($Script:Cursor.X -gt 0) {
                $Script:Cursor.X = $Script:Cursor.X - 1
            }
        }
        'Right' {
            if ([System.Console]::CursorLeft -lt $Script:Buffer[([System.Console]::CursorTop)].Length) {
                $Script:Cursor.X = $Script:Cursor.X + 1
            }
        }
        Default { $null }
    }
}

function Sync-Console {
    [System.Console]::Clear()
    $Script:Buffer | ForEach-Object {
        [System.Console]::Write($_)
    }
}

function Start-Edit {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        [System.Console]::WindowWidth
        [System.Console]::TreatControlCAsInput = $true
        [System.Console]::Title = "Get-Edit PowerShell Editor"
        Sync-Console
    }
    
    process {
        [bool]$Finish = $false
        # Main processing loop
        do {
            # Update the cursor
            [System.Console]::SetCursorPosition($Script:Cursor.X, $Script:Cursor.Y)

            if ([System.Console]::KeyAvailable) {

                # Application controls
                $key = [System.Console]::ReadKey()
                if ($key.Key -eq 'UpArrow' ) { Move-Cursor -direction Up }
                if ($key.Key -eq 'DownArrow' ) { Move-Cursor -direction Down }
                if ($key.Key -eq 'LeftArrow' ) { Move-Cursor -direction Left }
                if ($key.Key -eq 'RightArrow' ) { Move-Cursor -direction Right }

                # Save with Ctrl + C
                if ($key.Key -eq 'C' -and $key.Modifiers -eq 'Control') {  
                    [System.Console]::Clear()
                    Write-Warning "Saving!..."
                    $Script:Buffer | Out-String -Stream | Out-File $file -NoNewline -Force
                    return 0
                }
                
                # Redraw after any navigation
                Sync-Console
                
                # User Input
                
                # Insert to the buffer at cursor coordinates when not using a navigation or control key
                if ($key.Key -ne 'UpArrow' `
                        -and $key.Key -ne 'DownArrow' `
                        -and $key.Key -ne 'LeftArrow' `
                        -and $key.Key -ne 'RightArrow') {
                    
                    # TODO: We're typing in reverse...
                    $Script:Buffer[$Script:Cursor.Y] = $Script:Buffer[$Script:Cursor.Y].Insert($Script:Cursor.X, $key.KeyChar)
                    Sync-Console
                }
                
            }
            else {
                # We do nothing :) Only refresh the screen when a key is pressed - helps it not look so epileptic  
            }
        }while ($Finish -ne $true)
    }
    
    end {
        [System.Console]::Title = "Windows PowerShell"
    }
}

## Call the required things
Open-Edit
Start-Edit