class Line {
    # Properties
    [int]$id
    [char[]]$content

    [bool]$virtual
    [int]$parent = $null
    

    # Constructor: Creates a new Line object, with the specified name & content
    Line(
        [int]$id,
        [char[]]$content
    ) {
        $this.id = $id
        $this.content = $content
    }

    # Constructor: Creates a new virtual Line object, with a given parent line
    Line(
        [int]$id,
        [char[]]$content,
        [bool]$virtual,
        [int]$parent
    ) {
        $this.id = $id
        $this.content = $content
        $this.virtual = $virtual
        $this.parent = $parent
    }

    # Method: Returns an X Coordinate position int value for a given index,
    # in the current line
    [int] GetOffsetOfIndex(
        [int]$index
    ) {
        $r_index = 0

        if ($index -le $this.content.Length) {
            # Sum the sizes of tabs & regular characters until we reach $index
            $x = 0
            do {
                if ([byte]$this.content[$x] -eq 9) {
                    $r_index += 5
                }
                else {
                    $r_index += 1
                }
                $x += 1
            }until($x -eq $index)
        }
        else {
            # Return -1 to indicate bigger index than line
            $r_index = -1
        }

        return $r_index
    }

    # Method: Returns a string JSON representation of the line object
    [string] Serialise() {
        return ($this | ConvertTo-Json -Depth 10 -Compress)
    }
}