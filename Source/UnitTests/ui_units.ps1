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
    }
}