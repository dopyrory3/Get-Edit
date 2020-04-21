<#
 #  Get-Edit
 #  Author: Rory Maher
 #  Date 20/04/2020
 #>
param (
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]
    $Path
)

# Globals
$Script:Buffer = $null
$Script:Cursor = [PSCustomObject]@{
    X = 0
    Y = 0
}

function Save-Edit {
    [System.Console]::Clear()
    Write-Host "Saving!..."
    $Script:Buffer | Out-String -Stream | Out-File $Path -NoNewline -Force
    Write-Host "Saved!"
}

function Open-Edit {
    # Use a streamreader to load the contents of the file
    $IOBuffer = @()
    try {
        # Try to resolve the path of the input file, doesn't like relative paths
        $FullyQualifiedFilePath = (Get-ChildItem -Path $Path).FullName

        # Read that file into the IO Buffer array
        $Reader = New-Object System.IO.StreamReader -Arg $FullyQualifiedFilePath
        while ($null -ne ($line = $Reader.ReadLine())) {
            $IOBuffer = $IOBuffer + $line
        }
        $Reader.close()
    }
    catch {
        Write-Error "Could not open the specified file"
        return -1
    }
    $Script:Buffer = $IOBuffer
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
            if ($Script:Cursor.Y -le $Script:Buffer.Count) {

                # Snap to furthest right position on line below line, while checking to make sure we haven't reached the bottom of the file
                if (([System.Console]::CursorLeft -gt $Script:Buffer[([System.Console]::CursorTop + 1)].Length) `
                        -and ($null -ne $Script:Buffer[([System.Console]::CursorTop + 1)])) {

                    $Script:Cursor.X = $Script:Buffer[([System.Console]::CursorTop) + 1].Length
                }
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

function Update-Input {
    param (
        $InputKey
    )

    # Special input processing, Handling Carriage returns, Tabs, & backspaces
    switch ($InputKey.Key) {
        "Enter" {
            # Newline processing
        }
        "Tab" {
            # Tab processing
        }
        "Backspace" {
            # In case we're on the next line
        }
        Default {
            # Standard Input
        }
    }
}

function Sync-Console {
    [System.Console]::Clear()
    $Script:Buffer | ForEach-Object {
        [System.Console]::WriteLine($_)
    }
    #[System.Console]::Write($Script:Buffer)
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
                    Save-Edit
                    return 0
                }
                
                # Redraw after any navigation
                Sync-Console
                # Insert to the buffer at cursor coordinates when not using a navigation or control key
                if ($key.Key -ne 'UpArrow' `
                        -and $key.Key -ne 'DownArrow' `
                        -and $key.Key -ne 'LeftArrow' `
                        -and $key.Key -ne 'RightArrow') {
                    
                    $Script:Buffer[$Script:Cursor.Y] = $Script:Buffer[$Script:Cursor.Y].Insert($Script:Cursor.X, $key.KeyChar)
                    
                    # Adjust the cursor positon when characters are added and removed
                    if ($key.Key -eq 'BackSpace') {
                        Move-Cursor -direction Left
                    }
                    else {
                        $Script:Cursor.X = $Script:Cursor.X + 1
                        Move-Cursor -direction Right
                    }
                    
                    Sync-Console
                }
            }
            else {
                # We do nothing :) Only refresh the screen when a key is pressed - helps it not look so epileptic  
            }
        }while ($Finish -ne $true)
    }
    
    end {
        # Reset the console
        [System.Console]::Title = "Windows PowerShell"
        [System.Console]::Clear()
    }
}

## Call the required things
Open-Edit
Start-Edit