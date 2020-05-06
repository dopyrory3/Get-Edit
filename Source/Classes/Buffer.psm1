class Buffer { 
    # Standard contents
    [int]$ID                    # ID of the buffer
    [ref]$next_link             # The next buffer in the chain
    [ref]$last_link             # The previous buffer in the chain
    [char[]]$content            # The characters that make up the buffer
    [int]$length                # The length of the buffer object
    [int]$point = 0             # Last point of the cursor on this buffer

    # Coordinates set by ConsoleManager for Cursor
    [int]$startX = 0
    [int]$startY = 0
    [int]$endX = 0
    [int]$endY = 0


    # Constructor: Creates a new Buffer object, with the specified name
    Buffer(
        [int]$ID,
        [char[]]$content
    ) {
        $this.ID = $ID
        $this.content = $content
        $this.length = $content.Length
    }

    # Method: Method that sets the next link in the chain
    [void] SetNextLink(
        [ref]$buffer
    ) {
        $this.next_link = $buffer
    }

    # Method: Method that sets the previous link in the chain
    [void] SetLastLink(
        [ref]$buffer
    ) {
        $this.last_link = $buffer
    }


    # Method: Method that changes the screen coordinates of the buffer
    [void] SetCoordinates (
        [int]$x1,
        [int]$y1,
        [int]$x2,
        [int]$y2
    ) {
        $this.startX = $x1
        $this.startY = $y1
        $this.endX = $x2
        $this.endY = $y2
    }

    # Method: Returns an array of the buffer coordinates
    [int[]] GetCoordinates () {
        return @($this.startX, $this.startY, $this.endX, $this.endY)
    }
}