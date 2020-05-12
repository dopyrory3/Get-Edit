class ConsoleManager {
    # Properties
    [String] $WindowTitle
    [int] $WindowHeight
    [int] $WindowWidth
    
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

        [System.Console]::TreatControlCAsInput = $true
        [System.Console]::Title = $this.WindowTitle
        [System.Console]::Clear()
    }

    # Method: Returns true if there is a keypress to capture in the input stream
    [bool] KeyPressed() {
        return [System.Console]::KeyAvailable
    }

    # Method: reads the input stream and returns a ConsoleKeyInfo object
    [ConsoleKeyInfo] GetKeyPress() {
        return [System.Console]::ReadKey()
    }

    # Method: Draws the contents of the world buffer chain
    [void] Draw() {
        # Set cursor below title line
        [System.Console]::CursorTop = 1
        [System.Console]::CursorLeft = 0

        # Loop through the buffer & calculate how to write the content to the screen
        foreach ($char in $this.w_World.Value.Buffer) {
            [System.Console]::Write($char.content)
            [System.Console]::Write([char]10)
        }
    }

    # Method: Draws the UI from the world config
    [void] DrawUI(
        [ref]$UIObject
    ) {
        # Store the colour state variable for later
        $oldColour = [System.Console]::BackgroundColor

        # Set the console values
        [System.Console]::CursorLeft = $UIObject.Value.xPos
        [System.Console]::CursorTop = $UIObject.Value.yPos
        [System.Console]::BackgroundColor = [System.ConsoleColor]::Blue

        # Draw
        [System.Console]::Write($UIObject.Value.content)

        # Reset
        [System.Console]::BackgroundColor = $oldColour
        [System.Console]::CursorLeft = $this.w_World.Value.w_Cursor.Value.xPos
        [System.Console]::CursorTop = $this.w_World.Value.w_Cursor.Value.yPos
    }

    # Method: Syncs the position of the cursor & changed objects
    [void] Sync() {
        [System.Console]::CursorLeft = $this.w_World.Value.w_Cursor.Value.xPos
        [System.Console]::CursorTop = $this.w_World.Value.w_Cursor.Value.yPos
    }
}