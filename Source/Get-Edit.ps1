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
    try {
        $Script:Buffer | Out-String -Stream | Out-File $Path -Force
    }
    catch {
        return "Error! Could not save file"
    }
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

    # Firstly, resync the cursor variables to the console cursor, just in case we've lost track of where we are since the last update
    $Script:Cursor.X = [System.Console]::CursorLeft
    $Script:Cursor.Y = [System.Console]::CursorTop
    
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
                # Tab handling
                if ($Script:Buffer[([System.Console]::CursorTop)][([System.Console]::CursorLeft)] -eq [System.ConsoleKey]::Tab) {
                    $Script:Cursor.X = $Script:Cursor.X - 5
                }
                else {
                    $Script:Cursor.X = $Script:Cursor.X - 1
                }
            }
            else {
                # EOL handling
                if ($Script:Cursor.Y - 1 -gt 0) {
                    $Script:Cursor.Y = $Script:Cursor.Y - 1
                    $Script:Cursor.X = $Script:Buffer[$Script:Cursor.Y].Length
                } 
            }
        }
        'Right' {
            # Move to the next line if we've reached the line bounds, otherwise next cursor position
            if ([System.Console]::CursorLeft -lt $Script:Buffer[([System.Console]::CursorTop)].Length) {
                # TAB handling
                if ($Script:Buffer[([System.Console]::CursorTop)][([System.Console]::CursorLeft)] -eq [System.ConsoleKey]::Tab) {
                    $Script:Cursor.X = $Script:Cursor.X + 5
                    Sync-Console -CursorOnly
                }
                else {
                    $Script:Cursor.X = $Script:Cursor.X + 1
                }
            }
            else {
                # EOL handling
                if ($Script:Cursor.Y -lt $Script:Buffer.Count) {
                    $Script:Cursor.Y = $Script:Cursor.Y + 1
                    $Script:Cursor.X = 0
                }
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
            $Script:Buffer[$Script:Cursor.Y] = $Script:Buffer[$Script:Cursor.Y].Insert($Script:Cursor.X, "`t")
            Move-Cursor -direction Right
        }
        "Backspace" {
            # Check if we're up against the line bounds
            if ($Script:Cursor.X -le 0) {

            }
            else {
                $Script:Buffer[$Script:Cursor.Y] = $Script:Buffer[$Script:Cursor.Y].Remove($Script:Cursor.X - 1, 1)
                Move-Cursor -direction Left
            }  
        }
        Default {
            # Standard Input
            $Script:Buffer[$Script:Cursor.Y] = $Script:Buffer[$Script:Cursor.Y].Insert($Script:Cursor.X, $InputKey.KeyChar)
            Move-Cursor -direction Right
        }
    }
}

function Sync-Console {
    param (
        [switch]
        $CursorOnly
    )
    if ($CursorOnly) {
        [System.Console]::SetCursorPosition($Script:Cursor.X, $Script:Cursor.Y)
    }
    else {
        # Clear the screen, write the buffer, update the cursor.
        [System.Console]::Clear()
        $Script:Buffer | ForEach-Object {
            [System.Console]::WriteLine($_)
        }
        [System.Console]::SetCursorPosition($Script:Cursor.X, $Script:Cursor.Y)
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
            if ([System.Console]::KeyAvailable) {

                # Grab console input
                $key = [System.Console]::ReadKey()
                
                # Navigation controls
                if ($key.Key -eq 'UpArrow' ) { Move-Cursor -direction Up }
                if ($key.Key -eq 'DownArrow' ) { Move-Cursor -direction Down }
                if ($key.Key -eq 'LeftArrow' ) { Move-Cursor -direction Left }
                if ($key.Key -eq 'RightArrow' ) { Move-Cursor -direction Right }

                # Save with Ctrl + C
                if ($key.Key -eq 'C' -and $key.Modifiers -eq 'Control') {  
                    Save-Edit
                    return "Saved!"
                }
                
                # Redraw cursor after any navigation
                Sync-Console -CursorOnly

                # Insert to the buffer at cursor coordinates when not using a navigation key
                if ($key.Key -ne 'UpArrow' `
                        -and $key.Key -ne 'DownArrow' `
                        -and $key.Key -ne 'LeftArrow' `
                        -and $key.Key -ne 'RightArrow') {
                    
                    Update-Input -InputKey $key
                    # Redraw whole console after input
                    Sync-Console
                }
            }
            else {
                # Keep on redrawing that cursor
                Sync-Console -CursorOnly
            }
        }while ($Finish -ne $true)
    }
    
    end {
        # Reset the console
        [System.Console]::Title = "Windows PowerShell"
    }
}

## Call the required things
Open-Edit
Start-Edit