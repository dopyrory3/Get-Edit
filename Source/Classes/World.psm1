using module .\Line.psm1

class World {
    # Properties
    [Line[]]$Buffer
    [int]$offset

    [ref]$w_Console
    [ref]$w_Cursor

    # Constructor: Creates a new World object, given a console, cursor, and IO Buffer
    World(
        [ref]$Console,
        [ref]$Cursor
    ) {
        # Link the Console & Cursor objects
        $this.w_Console = $Console
        $this.w_Cursor = $Cursor
    }

    # Method: Calculates world buffer during startup
    [void] Init(
        [array]$IOBuffer
    ) {
        # Build world buffer
        $id = 0
        foreach ($line in $IOBuffer) {
            # Word wrapping
            if ($line.length -ge $this.w_Console.Value.WindowWidth) {
                # Create the parent line & add to the buffer array
                $parent_line = [Line]::New(
                    $id,
                    $line.SubString(0, $this.w_Console.Value.WindowWidth).ToCharArray()
                )
                $this.Buffer += $parent_line

                # How many lines need to be created
                # Logic: Divide the remainder of the substring of the unwritten portion of the parent line by the windowwidth
                $line_count = 0
                $startingPos = [int]$this.w_Console.Value.WindowWidth
                $length = [int]($line.length - $this.w_Console.Value.WindowWidth)
                
                $line_count = [System.Math]::DivRem(
                    [int]$line.SubString(
                        $startingPos,
                        $length
                    ).length,
                    $this.w_Console.Value.WindowWidth,
                    [ref]$line_count) + 1

                # Create that number of virtual Lines
                $length = $this.w_Console.Value.WindowWidth
                $start_point = $length
                for ($v_line = 0; $v_line -lt $line_count; $v_line++) {
                    $id += 1

                    # If the line cut off is smaller than the starting point + buffer width, select only the line remainder
                    if ($start_point + $length -gt $line.length) {
                        $length = $line.length - $start_point
                    }

                    # Create a new virtual line
                    $this.Buffer += [Line]::New(
                        $id,
                        $line.SubString($start_point, $length).ToCharArray(),
                        $true,
                        $parent_line.id
                    )
                    $start_point += $length
                }
            }
            # Create a normal line
            else {
                $this.Buffer += [Line]::New(
                    $id,
                    $line.ToCharArray()
                )
            }
            $id += 1
        }
    }

    # Method: Primary controller for all console input,
    # return codes provide the key intent, which decides where it gets routed to
    [string] Input(
        [ConsoleKeyInfo]$Key
    ) {
        $Intent = $null

        # Table of recognised nav keys & modifiers, if it isn't one of those it's input
        switch ($Key.Key) {
            "UpArrow" { return "Navigate" }
            "DownArrow" { return "Navigate" }
            "LeftArrow" { return "Navigate" }
            "RightArrow" { return "Navigate" }
            "C" {
                if ($Key.Modifiers -eq "Control") {
                    $Intent = "Save"
                }
            }
            "Z" {
                if ($Key.Modifiers -eq "Control") {
                    $Intent = "Quit"
                }
            }
            Default { return "Edit" }
        }

        return $Intent
    }

    [int] OffsetCount(
        [string]$Direction
    ) {
        $Cursor = $this.w_Cursor.Value
        [int]$new_offset = $Cursor.xPos
        [Line]$current_line = $this.Buffer[$Cursor.yPos - 1]
        

        if ($Direction -eq "Right") {
            if ($this.offset -lt $current_line.content.Length) {
                # Increment the offset & get the new xPos
                $this.offset += 1
                $new_offset = $current_line.GetOffsetOfIndex($this.offset)
            }
            else {
                # Move the cursor down a line & reset offset to 0
                if ($Cursor.yPos + 1 -ne $this.Buffer.Count + 1) {
                    # Never go below the buffer
                    $Cursor.xPos = 0
                    $Cursor.yPos += 1
                    $this.offset = 0
                    $new_offset = 0
                }
            }
        }
        else {
            if ($this.offset -gt 0) {
                # Decrement the offset & get the new xPos
                $this.offset -= 1
                $new_offset = $current_line.GetOffsetOfIndex($this.offset)
            }
            else {
                # Move the cursor up a line
                if ($Cursor.yPos - 1 -ne 0) {
                    # Never reach the top line
                    $Cursor.yPos -= 1
                    $last_line = $this.Buffer[$Cursor.yPos - 1]
                    $new_offset = $last_line.GetOffsetOfIndex($last_line.content.Length) # Cursor offset becomes size of line
                    $this.offset = $last_line.content.Length # World offset becomes lengh of line 
                } 
            } 
        }
        return $new_offset
    }

    # Method: Return the contents of the modified buffer chain for saving
    [char[]] Chain() {
        return $this.Buffer
    }

    # Method: Return the state of the current world for another session
    [psobject] Save() {
        # Create a state object of the world and all it's member properties
        $State = New-Object -TypeName psobject
        
        #TODO

        return $this
    }
}