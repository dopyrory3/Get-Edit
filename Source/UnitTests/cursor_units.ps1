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
$Sample_World_Buffer = '[{"parent":0,"id":0,"content":["T","h","e"," ","Q","u","i","c","k"," ","B","r","o","w","n"," ","F","o","x"," ","J","u","m","p","s"," ","O","v","e","r"," ","t","h","e"," ","L","a","z","y"," ","D","o","g"],"virtual":false},{"parent":0,"id":1,"content":["T","h","e"," "," "," "," ","Q","u","i","c","k"," ","B","r","o","w","n"," ","F","o","x"," ","J","u","m","p","s"," ","O","v","e","r"," ","t","h","e"," ","L","a","z","y"," ","D","o","g","."," ","T","h","e"," ","Q","u","i","c","k"," ","B","r","o","w","n"," ","F","o","x"," ","J","u","m","p","s"," ","O","v","e","r"," ","t","h","e"," ","L","a","z","y"," ","D","o","g","."," ","T","e","s","t"," ","T","e"],"virtual":false},{"parent":1,"id":2,"content":["s","t"," ","g","r","e","a","t","e","r"," ","t","h","a","n"," ","1","0","0"," ","c","h","a","r","s"],"virtual":true},{"parent":0,"id":3,"content":["T","h","e"," ","Q","u","i","c","k"," ","B","r","o","w","n"," ","F","o","x"," ","J","u","m","p","s"," ","O","v","e","r"," ","t","h","e"," ","L","a","z","y"," ","D","o","g"],"virtual":false}]' | ConvertFrom-Json

$Sample_World = [PSCustomObject]@{
    w_Console = $console_ref
    Buffer    = $Sample_World_Buffer
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
    
    It "Test Move navigation" {
        $Cursor = [Cursor]::New(
            0,
            0
        )
        $Cursor.Init($Sample_World)

        $Cursor.Move(
            [System.ConsoleKeyInfo]::new([char]$null, [System.ConsoleKey]::DownArrow, $false, $false, $false)
        ) | Should -Be $true 

        $Cursor.Move(
            [System.ConsoleKeyInfo]::new([char]$null, [System.ConsoleKey]::RightArrow, $false, $false, $false)
        ) | Should -Be $true

        $Cursor.yPos | Should -Be 1
        $Cursor.xPos | Should -Be 1
    }
}