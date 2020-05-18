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
        switch ($Direction) {
            "UpArrow" {
                if ($this.yPos - 1 -ne 0) {
                    $this.yPos -= 1
                }
            }
            "DownArrow" {
                if ($this.yPos + 1 -lt $this.w_world.Value.w_Console.Value.WindowHeight) {
                    $this.yPos += 1
                } 
            }
            "LeftArrow" {
                if ($this.xPos -ge 0) {
                    # Lets get our offset return position
                    $offset_translation = $this.w_world.Value.OffsetCount("Left")
                    $this.xPos = $offset_translation
                    $this.w_world.Value.w_Console.Value.Sync($true)
                }
            }
            "RightArrow" {
                if ($this.xPos + 1 -le $this.w_world.Value.w_Console.Value.WindowWidth) {
                    $offset_translation = $this.w_world.Value.OffsetCount("Right")
                    $this.xPos = $offset_translation
                    $this.w_world.Value.w_Console.Value.Sync($true)
                }
            }
        }
        return $true
    }
}