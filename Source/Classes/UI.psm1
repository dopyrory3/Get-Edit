class UI {
    # UI Datatype
    [String] $Name
    [int]$xPos
    [int]$yPos
    [char[]]$content
    [System.ConsoleColor]$Background

    # Constructor: Creates a new UI object
    UI(
        [String]$NewName,
        [int]$xPos,
        [int]$yPos,
        [char[]]$content,
        [System.ConsoleColor]$BackGround
    ) {
        $this.Name = $NewName
        $this.xPos = $xPos
        $this.yPos = $yPos
        $this.content = $content
        $this.BackGround = [System.ConsoleColor]::Blue
    }
}