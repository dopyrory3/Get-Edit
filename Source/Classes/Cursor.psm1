class Cursor {
    # Properties
    [int]$xPos
    [int]$yPos
    [ref]$w_world

    # Constructor: Creates a new Cursor object
    Cursor(
        [int]$x,
        [int]$y
    ) {
        $this.xPos = $x
        $this.yPos = $y
    }

    [void] Init(
        [ref]$world
    ) {
        # Set the world reference
        $this.w_world = $world
    }

    [bool] Move(
        [ConsoleKey]$Direction
    ) {
        $Console = $this.w_world.Value.w_Console.Value
        $World = $this.w_world.Value

        switch ($Direction) {
            "UpArrow" {
                if ($this.yPos - 1 -ne 0) {
                    $this.yPos -= 1
                }
            }
            "DownArrow" {
                if ($this.yPos + 1 -lt $Console.WindowHeight) {
                    $this.yPos += 1
                } 
            }
            "LeftArrow" {
                if ($this.xPos -ge 0) {
                    # Lets get our offset return position
                    $offset_translation = $World.OffsetCount("Left")
                    $this.xPos = $offset_translation
                    $Console.Sync($true)
                }
            }
            "RightArrow" {
                if ($this.xPos + 1 -le $Console.WindowWidth) {
                    $offset_translation = $World.OffsetCount("Right")
                    $this.xPos = $offset_translation
                    $Console.Sync($true)
                }
            }
        }
        return $true
    }
}