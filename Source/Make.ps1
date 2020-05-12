using module .\Get-Edit.psm1
using module .\Classes\World.psm1
using module .\Classes\Console.psm1
using module .\Classes\Cursor.psm1
using module .\Classes\UI.psm1

$file = Get-ChildItem C:\Users\rory.maher\Desktop\sample.txt | Select-Object -ExpandProperty Fullname
Get-Edit -InputObject $file