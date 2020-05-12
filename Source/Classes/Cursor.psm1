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
                if ($this.CheckBounds("Up")) {
                    $this.yPos -= 1
                }
            }
            "DownArrow" {
                if ($this.CheckBounds("Down")) {
                    $this.yPos += 1
                } 
            }
            "LeftArrow" {
                #if ($this.CheckBounds("Left")) {
                # Lets get our offset return position
                $offset_translation = $this.w_world.Value.OffsetCount("Left")
                $this.xPos -= $offset_translation
                $this.w_world.Value.offset = $this.xPos
                #}
            }
            "RightArrow" {
                #if ($this.CheckBounds("Right")) {
                $offset_translation = $this.w_world.Value.OffsetCount("Right")
                $this.xPos += $offset_translation
                $this.w_world.Value.offset = $this.xPos
                #}
            }
        }
        return $true
    }

    [bool] CheckBounds(
        [string]$Direction
    ) {
        $result = $false
        switch ($Direction) {
            "Up" {
                if ($this.yPos - 1 -ne 0) {
                    return $true
                }
            }
            "Down" {
                if ( $this.yPos + 1 -lt $this.w_world.Value.w_Console.Value.WindowHeight) {
                    return $true
                }
            }
            "Left" {
                if ($this.xPos - 1 -ge 0) {
                    return $true
                }
            }
            "Right" {
                if ($this.xPos + 1 -lt $this.w_world.Value.w_Console.Value.WindowWidth) {
                    return $true
                }
            }
        }
        return $true
    }
}