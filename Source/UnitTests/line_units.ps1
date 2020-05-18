using module ..\Classes\Line.psm1
Import-Module Pester

$Sample_Text = "The Quick Brown Fox Jumps Over the Lazy Dog"
#The     Quick Brown     Fox Jumps Over the Lazy Dog
$Sample_Tabs = [char[]](
    [byte]84,
    [byte]104,
    [byte]101,
    [byte]9,
    [byte]81,
    [byte]117,
    [byte]105,
    [byte]99,
    [byte]107,
    [byte]32,
    [byte]66,
    [byte]114,
    [byte]111,
    [byte]119,
    [byte]110,
    [byte]9,
    [byte]70,
    [byte]111,
    [byte]120,
    [byte]32,
    [byte]74,
    [byte]117,
    [byte]109,
    [byte]112,
    [byte]115,
    [byte]32,
    [byte]79,
    [byte]118,
    [byte]101,
    [byte]114,
    [byte]32,
    [byte]116,
    [byte]104,
    [byte]101,
    [byte]32,
    [byte]76,
    [byte]97,
    [byte]122,
    [byte]121,
    [byte]32,
    [byte]68,
    [byte]111,
    [byte]103
)


Describe "Validate Constructor" {
    # ID:       0
    # Content:  Sample_Text
    # Virtual:  False
    # Parent:   Null
    It "Create new real Line" {
        $Parent = [Line]::New(
            0,
            $Sample_Text,
            $false,
            $null
        ) | Should -BeOfType Line
    }

    # ID:       1
    # Content:  Sample_Tabs
    # Virtual:  True
    # Parent:   0
    It "Create new Virtual Line (TABS)" {
        $Child = [Line]::new(
            1,
            $Sample_Tabs,
            $true,
            0) | Should -BeOfType Line
    }
}

Describe "Test Methods" {
    # PARENT LINE
    # As the parent line is made up on non special characters,
    # we should get the same value out as we put in
    It "Calculate the offset value of index 10 on Parent line" {
        $Parent = [Line]::New(
            0,
            $Sample_Text,
            $false,
            $null
        ).GetOffsetOfIndex(10) | Should Be 10
    }

    # CHILD LINE
    # As the child line contains TAB characters, we expect to get:
    # {n + t(4)} | Where { n=number of lines | t=number of tabs }
    It "Calculate the offset value of index 10 on Child line (TABS)" {
        $Child = [Line]::new(
            1,
            $Sample_Tabs,
            $true,
            0).GetOffsetOfIndex(10) | Should Be 14
    }

    It "Test Serialisation of parent line" {
        $Parent = [Line]::New(
            0,
            $Sample_Text,
            $false,
            $null
        ).Serialise() | Should Be '{"parent":0,"id":0,"content":["T","h","e"," ","Q","u","i","c","k"," ","B","r","o","w","n"," ","F","o","x"," ","J","u","m","p","s"," ","O","v","e","r"," ","t","h","e"," ","L","a","z","y"," ","D","o","g"],"virtual":false}'
    }

    It "Test Serialisation of Child line (TABS" {
        $Child = [Line]::new(
            1,
            $Sample_Tabs,
            $true,
            0).Serialise() | Should Be '{"parent":0,"id":1,"content":["T","h","e","\t","Q","u","i","c","k"," ","B","r","o","w","n","\t","F","o","x"," ","J","u","m","p","s"," ","O","v","e","r"," ","t","h","e"," ","L","a","z","y"," ","D","o","g"],"virtual":true}'
    }
}