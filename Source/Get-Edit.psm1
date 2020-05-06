# Import custom classes
using module .\Classes\World.psm1
using module .\Classes\Console.psm1
using module .\Classes\Cursor.psm1
using module .\Classes\UI.psm1

# Startup variables
$Script:IOBuffer = @() # Array stores the original file content throughout the program lifecycle
$Script:FriendlyName = "Get-Edit Text Editor"
$Script:OriginalTitle = [System.Console]::Title

function Get-Edit {
    param (
        # Path to the file the user wishes to edit
        [Parameter(Mandatory = $false,
            Position = 0,
            ParameterSetName = "ParameterSetName",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to one or more locations.")]
        [Alias("PSPath")]
        [string]
        $InputObject
    )
    begin {
        #region FileLoading
        # Load the file contents into the world buffer before init
        if ($null -ne $InputObject) {
            # Use a streamreader to load the contents of the file
            try {
                # Try to resolve the path of the input file, streamreader doesn't like relative paths
                $FQFilePath = (Get-ChildItem -Path $InputObject)[0].FullName
                # Set the friendly file name for window mangager
                $Script:FriendlyName = "Get-Edit | {0}" -f (Get-ChildItem -Path $InputObject)[0].Name

                # Read that file into the IO Buffer array
                $Reader = New-Object System.IO.StreamReader -Arg $FQFilePath
                while ($null -ne ($line = $Reader.ReadLine())) {
                    $Script:IOBuffer += $line.ToCharArray()
                    $Script:IOBuffer += [char]10
                }
                $Reader.close()
            }
            catch {
                Write-Error "Could not open the specified file"
                exit
            }
        }
        #endregion

        #region UIDefinition
        $TitleBar = [UI]::New(
            "Title",
            0,
            0,
            ("Get-Edit | {0}" -f $Script:FriendlyName),
            [System.ConsoleColor]::Blue
        )
        #endregion
    }
    process {
        #region Init
        # Create Cursor and Console manager context
        $_Console = [ConsoleManager]::New($Script:FriendlyName)
        $_Cursor = [Cursor]::New(0, 1)

        # Create a new world instance, passing in the file content, then perform chain_init
        $_World = [World]::New(
            $_Console,
            $_Cursor,
            $Script:IOBuffer
        )

        # Initialise the console, then the cursor, passing the world context, and perform first draw
        $_Console.Init(
            $_World
        )
        $_Cursor.Init(
            $_World
        )

        $_Console.Draw()
        $_Console.DrawUI($TitleBar)
        $_Console.DrawUI($Debug)
        #endregion

        #region Main application loop
        [bool]$running = $true
        do {
            if ($_Console.KeyPressed()) {
                # Get input from the console manager
                $InputKey = $_Console.GetKeyPress()

                if ($InputKey.Key -eq "C" -and $InputKey.Modifiers -eq "Control") {
                    exit
                }

                # Send it to the world for processing
                $KeyIntent = $_World.Input($InputKey)
            
                # Reroute the keypress to the correct context
                switch ($KeyIntent) {
                    "Navigate" {
                        # Sync the console once input has been processed
                        if ($_Cursor.Move($InputKey.Key)) {
                            $_Console.DrawUI($TitleBar)
                            $_Console.DrawUI([UI]::New(
                                    "DebugPane",
                                    100,
                                    30,
                                    ("Cursor: {0},{1}" -f `
                                            $_World.w_Cursor.Value.xPos, `
                                            $_World.w_Cursor.Value.xPos),
                                    [System.ConsoleColor]::Blue
                                ))
                            $_Console.Sync()
                        }
                    }
                    "Save" {

                    }
                    "Edit" {

                    }
                    "Quit" {
                        # End the drawing loop
                        $running = $false
                    }
                    default {

                    }
                }
            }
            else {
                # Update console changes
                $_Console.Sync()
            }
        } while ($running)
        #endregion
    }
    end {
        # Set the title back to it's original setting
        [System.Console]::Title = $Script:OriginalTitle
        # Clear the window
        [System.Console]::Clear()
        # Reset Script scope variables
        $Script:IOBuffer = @()
        $Script:FriendlyName = "Get-Edit Text Editor"

        # DEBUG - return the buffer chain
        $_World.Buffer_Chain
    }
}