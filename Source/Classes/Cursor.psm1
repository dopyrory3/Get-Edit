class Cursor {
    # Properties
    [int]$xPos
    [int]$yPos
    [ref]$w_world

    # Constructor: Creates a new MyClass object, with the specified name
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

    # Method: Set the cursor xPos to a given int
    [void] SetX([int]$position) {
        $this.xPos = $position
    }
    # Method: Set the cursor yPos to a given int
    [void] SetY([int]$position) {
        $this.yPos = $position
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
                if ($this.CheckBounds("Left")) {
                    $this.xPos -= 1
                }
                
            }
            "RightArrow" {
                if ($this.CheckBounds("Right")) {
                    $this.xPos += 1
                }
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
        return $result
    }
}