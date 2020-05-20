using module ..\Classes\Cursor.psm1
Import-Module Pester

# Create Mock data objects for Console & World
$Sample_Console = [PSCustomObject]@{
    title        = "Get-Edit Unit Testing"
    WindowWidth  = 100
    WindowHeight = 50
}
# Reference variable so the Cursor functions behave the same way
$console_ref = [ref]$Sample_Console

$Sample_World = [PSCustomObject]@{
    w_Console = $console_ref
}

$Sample_Console | Add-Member -MemberType ScriptMethod -Name 'Sync' -Force -Value { 
    return $null
}
$Sample_World | Add-Member -MemberType ScriptMethod -Name "OffsetCount" -Force -Value {
    return 1
}

Describe "Validate Constructor" {
    It "Create a new Cursor Object" {
        $Cursor = [Cursor]::New(
            0,
            0
        )
        $Cursor.xPos | Should -Be 0
        $Cursor.yPos | Should -Be 0
    }
}

Describe "Validate Methods" {
    It "Test Init function" {
        $Cursor = [Cursor]::New(
            0,
            0
        )
        $Cursor.Init($Sample_World)
        $Cursor.w_world.Value.w_Console.Value.title | Should -Be 'Get-Edit Unit Testing' 
    }
    
    It "Test Move naviagation" {
        $Cursor = [Cursor]::New(
            0,
            0
        )
        $Cursor.Init($Sample_World)
        $Cursor.Move([System.ConsoleKey]::DownArrow) | Should -Be $true 
        $Cursor.Move([System.ConsoleKey]::RightArrow) | Should -Be $true

        $Cursor.yPos | Should -Be 1
        $Cursor.xPos | Should -Be 1
    }
}