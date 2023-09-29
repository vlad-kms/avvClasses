Get-InfoModule
Import-Module ( ((Get-InfoModule).pathMain | Split-Path -Parent)|Join-Path -ChildPath 'classes\avvBase.ps1' ) -Force -ErrorAction Stop
$global:a=[avvBase]::new()
$a.addHashtable(@{t3=@{t31='t31';t32='t32';t33=@{t331='t331';t332='t332'}}});



$a.ToJson()