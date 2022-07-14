Import-Module D:\tools\PSModules\avvClasses\avvTypesv5

$l=Get-Logger -Filename D:\temp\123.log -LogLevel 4 -IsAppend $false -TabWidth 4 -IsExpandTab $False
$l
echo '$l.log(("1 call", "line 2", 3333, "ÿקס`nיצף"), 1, 4, 3)                       ============================================='
$l.log(("1 call", "line 2", 3333, "ÿקס`nיצף"), 1, 4, 3)
echo '$l.log(("2 call", "line 2", 3333, "ÿקס`nיצף"), 2, 4, 10)                      ============================================='
$l.log(("2 call", "line 2", 3333, "ÿקס`nיצף"), 2, 4, 10)
echo '$l.log(("3 call", "line 2", 3333, "ÿקס`nיצף"), 2, 4, 10, $true)               ============================================='
$l.log(("3 call", "line 2", 3333, "ÿקס`nיצף"), 2, 4, 10, $true)
echo '$l.log(("4 call", "line 2", 3333, "ÿקס`nיצף"), 1, 4, 3, $true, "dsadasdasd")  ============================================='
$l.log(("4 call", "line 2", 3333, "ÿקס`nיצף"), 1, 4, 3, $true, "dsadasdasd")
