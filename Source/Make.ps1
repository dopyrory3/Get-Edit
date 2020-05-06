using module .\Get-Edit.psm1
$file = Get-ChildItem C:\Users\rory.maher\Desktop\Sample.txt | Select-Object -ExpandProperty Fullname
Get-Edit -InputObject $file