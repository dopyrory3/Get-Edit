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
        [ConsoleKeyInfo]$Direction
    ) {
        $Console = $this.w_world.Value.w_Console.Value
        $World = $this.w_world.Value

        if ($Direction.Modifiers -eq "Control") {

        }
        else {
            switch ($Direction.Key) {
                "UpArrow" {
                    # Check the console Bounds
                    if ($this.yPos - 1 -ne 0) {
                        $this.yPos -= 1
                    }
                }
                "DownArrow" {
                    # Check the console Bounds
                    if ($this.yPos + 1 -lt $Console.WindowHeight) {
                        # Also check the buffer bounds
                        if ($this.yPos -lt $World.Buffer.Count) {
                            $offset_translation = $World.OffsetCount("Down")
                            $this.yPos += 1
                            $this.xPos = $offset_translation
                        }
                    } 
                }
                "LeftArrow" {
                    # Check the console Bounds
                    if ($this.xPos -ge 0) {
                        # Lets get our offset return position
                        $offset_translation = $World.OffsetCount("Left")
                        $this.xPos = $offset_translation
                    }
                }
                "RightArrow" {
                    # Check the console Bounds
                    if ($this.xPos + 1 -le $Console.WindowWidth) {
                        $offset_translation = $World.OffsetCount("Right")
                        $this.xPos = $offset_translation
                    }
                }
            }
        }
        return $true
    }
}