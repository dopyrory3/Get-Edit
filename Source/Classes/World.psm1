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
        [ref]$Cursor,
        [array]$IOBuffer
    ) {
        # Link the Console & Cursor objects
        $this.w_Console = $Console
        $this.w_Cursor = $Cursor
        
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

        $this.Buffer | % {
            $_.Calculate_Offsets()
        }
    }

    # Method: Calculates world buffer during startup
    [void] Init() {
        
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
        # Establish variables
        [int]$new_offset = 0
        [Line]$current_line = $this.Buffer[$this.w_Cursor.Value.yPos - 1]

        switch ($Direction) {
            "Left" {
                [int]$prev_off = $this.offset
                $new_offset = $current_line.offsets.$prev_off
            }
            "Right" {
                [int]$next_off = $this.offset
                $new_offset = $current_line.offsets.$next_off
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