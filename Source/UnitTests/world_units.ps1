using module ..\Classes\World.psm1
Import-Module Pester

$SampleCursor = [PSCustomObject]@{
    xPos = 0
    yPos = 1
}

$SampleConsole = [PSCustomObject]@{
    title        = "Get-Edit Unit Testing"
    WindowWidth  = 100
    WindowHeight = 50
}

$SampleBuffer = @(
    "The Quick Brown Fox Jumps Over the Lazy Dog"
    "The    Quick Brown Fox Jumps Over the Lazy Dog. The Quick Brown Fox Jumps Over the Lazy Dog. Test Test greater than 100 chars"
    "The Quick Brown Fox Jumps Over the Lazy Dog"
)

$SampleKeyTests = @(
    # Control C
    [System.ConsoleKeyInfo]::new('c', [System.ConsoleKey]::C, $false, $false, $true),
    # Control Z
    [System.ConsoleKeyInfo]::new('z', [System.ConsoleKey]::Z, $false, $false, $true),
    # RightArrow
    [System.ConsoleKeyInfo]::new([char]$null, [System.ConsoleKey]::RightArrow, $false, $false, $false),
    # UpArrow
    [System.ConsoleKeyInfo]::new([char]$null, [System.ConsoleKey]::UpArrow, $false, $false, $false),
    # LeftArrow
    [System.ConsoleKeyInfo]::new([char]$null, [System.ConsoleKey]::LeftArrow, $false, $false, $false),
    # DownArrow
    [System.ConsoleKeyInfo]::new([char]$null, [System.ConsoleKey]::RightArrow, $false, $false, $false),
    # Any key
    [System.ConsoleKeyInfo]::new('f', [System.ConsoleKey]::F, $false, $false, $false)
)



Describe "Validate constructor" {
    It "Create a new World object" {
        $TestWorld = [World]::New(
            $SampleConsole,
            $SampleCursor
        )
        $TestWorld.GetType().Name | Should -Be World
    }
}


Describe "Init the world" {
    It "Create buffer & test properties" {
        # Rebuild the world
        $TestWorld = [World]::New(
            $SampleConsole,
            $SampleCursor
        )
        # Initialise with the SampleBuffer
        $TestWorld.Init($SampleBuffer)

        # Test the buffer content
        $TestWorld.Buffer[0].id | Should -Be 0
        $TestWorld.Buffer[0].content.Count | Should -Be 43
        $TestWorld.Buffer[0].virtual | Should -Be $false
        $TestWorld.Buffer[0].parent | Should -Be $false

        $TestWorld.Buffer[1].id | Should -Be 1
        $TestWorld.Buffer[1].content.Count | Should -Be 100
        $TestWorld.Buffer[1].virtual | Should -Be $false
        $TestWorld.Buffer[1].parent | Should -Be $false

        $TestWorld.Buffer[2].id | Should -Be 2
        $TestWorld.Buffer[2].content.Count | Should -Be 25
        $TestWorld.Buffer[2].virtual | Should -Be $true
        $TestWorld.Buffer[2].parent | Should -Be 1

        $TestWorld.Buffer[3].id | Should -Be 3
        $TestWorld.Buffer[3].content.Count | Should -Be 43
        $TestWorld.Buffer[3].virtual | Should -Be $false
        $TestWorld.Buffer[3].parent | Should -Be $false
    }
}

Describe "Test Input function" {
    It "Test Example input objects" {
        # Rebuild the world
        $TestWorld = [World]::New(
            $SampleConsole,
            $SampleCursor
        )

        # Test the results of sample keys
        $TestWorld.Input($SampleKeyTests[0]) | Should -Be "Save"
        $TestWorld.Input($SampleKeyTests[1]) | Should -Be "Quit"
        $TestWorld.Input($SampleKeyTests[2]) | Should -Be "Navigate"
        $TestWorld.Input($SampleKeyTests[3]) | Should -Be "Navigate"
        $TestWorld.Input($SampleKeyTests[4]) | Should -Be "Navigate"
        $TestWorld.Input($SampleKeyTests[5]) | Should -Be "Navigate"
        $TestWorld.Input($SampleKeyTests[6]) | Should -Be "Edit"
    }
}