class Line {
    # Properties
    [int]$id
    [char[]]$content
    [hashtable]$offsets

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

    # Method: Calculates the offset of every character in the line, mainly put this here to deal with tabs
    [void] Calculate_Offsets() {
        # Calculate line-offset hashtable
        $line_offsets = @{ }
        for ($counter = 0; $counter -lt $this.content.Length + 1 ; $counter++) {
            $size = 0

            if ( [byte]$this.content[$counter] -eq 9) { $size = 5 }         # TAB is 5 spaces
            #elseif ( [byte]$this.content[$counter] -eq 10) { $size = -1 }   # LF is -1 EOL
            #elseif ( [byte]$this.content[$counter] -eq 13) { $size = -1 }   # CR is -1 EOL
            else { $size = 1 }

            # Add the offset of the next char to 
            $line_offsets.Add($counter, $size)
        }
        $this.offsets = $line_offsets
    }
}

<# 
===debug testing later on===

foreach ($char in $buffer[7].content) {
                $index = $buffer[7].content.IndexOf($char) #(<- doesn't matter which char it matches in the table becuase we only need the offset distance) 
                $String = "Char: {0} | Byte: {1} | Offset: {2}" -f `
                    $char, `
                    [byte]$char, `
                ($buffer[7].offsets.[int]$index)
                Write-Host $String
            }
#>