using module ..\Classes\UI.psm1
Import-Module Pester

Describe "Validate UI Struct" {
    It "Create UI object" {
        $UI = [UI]::New(
            "Draw",
            "Wide",
            10,
            10,
            "Get-Edit | Test",
            [System.ConsoleColor]::Blue
        )
        $UI.SyncTime | Should -Be "Draw"
        $UI.fill | Should -Be "Wide"
        $UI.xPos | Should -Be 10
        $UI.yPos | Should -Be 10
        $UI.content | Should -Be @('G', 'e', 't', '-', 'E', 'd', 'i', 't', ' ', '|', ' ', 'T', 'e', 's', 't')
        $UI.Background | Should -Be Blue
    }
}