using module .\UI.psm1
class ConsoleManager {
    # Properties
    [String] $WindowTitle
    [int] $WindowHeight
    [int] $WindowWidth
    [bool] $WindowBreak
    [System.Management.Automation.Host.Coordinates] $ConsoleCursor = [System.Management.Automation.Host.Coordinates]::new(0, 1)
    [UI[]]$ConsoleUI

    [ref]$w_World

    # Constructor: Creates a new ConsoleManager object, with the specified title
    ConsoleManager(
        [String]$title
    ) {
        $this.WindowTitle = $title
        $this.WindowWidth = [System.Console]::WindowWidth
        $this.WindowHeight = [System.Console]::WindowHeight
    }

    [void] Init(
        [ref]$world
    ) {
        $this.w_World = $world
        $this.WindowBreak = $true

        [System.Console]::TreatControlCAsInput = $true
        [System.Console]::Title = $this.WindowTitle
        [System.Console]::Clear()
    }

    # Method: Returns true if there is a keypress to capture in the input stream
    [bool] KeyPressed() {
        return [System.Console]::KeyAvailable
    }

    [void] AddUI([UI]$UI) {
        $this.ConsoleUI += $UI
    }

    # Method: reads the input stream and returns a ConsoleKeyInfo object
    [ConsoleKeyInfo] GetKeyPress() {
        return [System.Console]::ReadKey()
    }

    # Method: Performs first draw of the contents of the world buffer chain
    [void] Draw() {
        # Set cursor below title line
        [System.Console]::CursorTop = 1
        [System.Console]::CursorLeft = 0

        # Loop through the buffer & calculate how to write the content to the screen
        foreach ($line in $this.w_World.Value.Buffer) {
            foreach ($char in $line.content) {
                switch ([byte]$char) {
                    9 {
                        [System.Console]::Write("     ")
                    }
                    Default {
                        [System.Console]::Write($char)
                    }
                }
            }
            [System.Console]::Write([char]10)
        }

        # Load any first draw/refresh UI's
        foreach ($UI in $this.ConsoleUI | Where-Object { $_.SyncTime -eq "Draw" -or $_.SyncTime -eq "Refresh" }) {
            $console_colour = [System.Console]::BackgroundColor

            $this.ConsoleCursor = [System.Management.Automation.Host.Coordinates]::new(
                $UI.xPos,
                $UI.yPos)

            $this.Sync($false)

            [System.Console]::BackgroundColor = $UI.Background
            [System.Console]::Write($UI.content)
            [System.Console]::BackgroundColor = $console_colour

            $this.Sync($true)
        }
    }

    # Method: Syncs the position of the cursor & changed objects
    [void] Sync($cursor) {
        if ($cursor) {
            # If the cursor switch has been passed, reset the ConsoleCursor to a new object with current cursor positions
            $this.ConsoleCursor = [System.Management.Automation.Host.Coordinates]::new(
                $this.w_World.Value.w_Cursor.Value.xPos,
                $this.w_World.Value.w_Cursor.Value.yPos)
        }

        [System.Console]::CursorLeft = $this.ConsoleCursor.X
        [System.Console]::CursorTop = $this.ConsoleCursor.Y
    }
}