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

    # Method: Returns an X Coordinate position int value for a given index in the line
    [int] GetOffsetOfIndex(
        [int]$index
    ) {
        $r_index = 0

        if ($index -le $this.content.Length -and $index -ne 0) {
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
            # Return 0 for no change, not happening if we're indexing OOB or to 0
            $r_index = 0
        }

        return $r_index
    }

    # Method: Returns an index value for the nearest char in the line to a given offset
    [int] GetIndexOfOffset(
        [int]$offset
    ) {

        # Loop through the contents of the buffer, get the offset of the current index. Get the difference between the 2 offsets
        # and if it's smaller than the best difference so far, assign it to the return value & make it the new best difference
        # if the difference is 0, we might as well quit because we can't do better than that
        $r_index = 0
        if ($offset -gt 0) {
            $best_diff = 999999
            for ($x = 0; $x -lt $this.content.Length; $x++) {
                $loop_offset = $this.GetOffsetOfIndex($x)
                if ($loop_offset -lt $offset) {
                    $diff = $offset - $loop_offset
                }
                elseif ($loop_offset -gt $offset) {
                    $diff = $loop_offset - $offset
                }
                else {
                    $diff = 0
                }

                if ($diff -lt $best_diff) {
                    $best_diff = $diff
                    $r_index = $x
                }
                if ($best_diff -eq 0) {
                    break
                }
            }
        }

        return $r_index
    }

    # Method: Returns a string JSON representation of the line object
    [string] Serialise() {
        return ($this | ConvertTo-Json -Depth 10 -Compress)
    }
}