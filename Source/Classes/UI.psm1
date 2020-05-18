class UI {
    # UI Datatype
    [string]$SyncTime
    [string]$fill
    [int]$xPos
    [int]$yPos
    [char[]]$content
    [System.ConsoleColor]$Background

    # Constructor: Creates a new UI object
    UI(
        [string]$SyncTime,
        [string]$fill,
        [int]$xPos,
        [int]$yPos,
        [char[]]$content,
        [System.ConsoleColor]$BackGround
    ) {
        $this.SyncTime = $SyncTime
        $this.fill = $fill
        $this.xPos = $xPos
        $this.yPos = $yPos
        $this.content = $content
        $this.BackGround = [System.ConsoleColor]::Blue
    }
}