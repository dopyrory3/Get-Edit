using module ..\Classes\Console.psm1
Import-Module Pester

$Sample_World = [PSCustomObject]@{
    Name = Value
}

Describe "Validate Constructor" {
    It "Create a new ConsoleManager object" {
        $TestConsole = [ConsoleManager]::new("TestConsole")
        $TestConsole.ConsoleCursor.X | Should -Be 0
        $TestConsole.ConsoleCursor.Y | Should -Be 1
        $TestConsole.WindowTitle | Should -Be "TestConsole"
        $TestConsole.WindowWidth | Should -Not -Be $null
        $TestConsole.WindowHeight | Should -Not -Be $null
        $TestConsole.w_World | Should -BeNullOrEmpty
        $TestConsole.ConsoleUI | Should -BeNullOrEmpty
    }
}