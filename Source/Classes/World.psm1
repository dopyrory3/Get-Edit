using module .\Buffer.psm1

class World {
    # Properties
    #[Buffer[]]$Buffer_Chain
    [char[]]$Buffer_Chain
    #[Buffer]$Current_Buffer

    [ref]$w_Console
    [ref]$w_Cursor

    # Constructor: Creates a new World object, given a console, cursor, and IO Buffer
    World(
        [ref]$Console,
        [ref]$Cursor,
        [char[]]$IOBuffer
    ) {
        # Link the Console & Cursor objects
        $this.w_Console = $Console
        $this.w_Cursor = $Cursor
        $this.Buffer_Chain = $IOBuffer
    }
    <#
        #Region Build Chain
        # First buffer is manual, empty buffer with id=0 and $null last link
        $id_int = 0
        $this.Buffer_Chain += [Buffer]::New(
            $id_int,
            $null
        )
        $this.Buffer_Chain[0].StartX = 0
        $this.Buffer_Chain[0].StartY = 1
        $this.Buffer_Chain[0].EndX = 0
        $this.Buffer_Chain[0].EndY = 1
        
        #region Main_Loop
        foreach ($line in $IOBuffer) {
            # ID's are in HEX
            $buffer_id = $id_int
            # We'll give line it's own variable for continuity in the constructor?
            $buffer_co = $line

            #region LineBuffer
            $new_buffer = [Buffer]::New(
                $buffer_id,
                $buffer_co
            )
            $this.Buffer_Chain += $new_buffer
            #endregion

            #region NewLineBuffer
            # Create a newline buffer object
            $id_int += 1
            $buffer_newline = [Buffer]::New(
                $id_int,
                "`n"
            )
            $this.Buffer_Chain += $buffer_newline
            #endregion

            # Final counter increment.
            $id_int += 1
        }
        #endregion

        #region Linking_Pass
        for ($count = 1; $count -lt $this.Buffer_Chain.Count; $count++) {
            # count-1 => next_link=count // previous entry *next_link is self
            $this.Buffer_Chain[$count - 1].SetNextLink([ref]$this.Buffer_Chain[$count])
            # count => last_link=count-1 // self *last_link is previous entry 
            $this.Buffer_Chain[$count].SetLastLink([ref]$this.Buffer_Chain[$count - 1])
        }
        #endregion

        #endregion

        # First non-null is where we start in the file
        $this.Current_Buffer = $this.Buffer_Chain[1]
        #>
    

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

    # Method: Return the contents of the modified buffer chain for saving
    [char[]] Chain() {
        return $this.Buffer_Chain
    }

    # Method: Return the state of the current world for another session
    [psobject] Save() {
        # Create a state object of the world and all it's member properties
        $State = New-Object -TypeName psobject
        
        #TODO

        return $this
    }
}