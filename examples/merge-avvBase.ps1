[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [hashtable] $HT,
    [switch] $ReUse
)

Import-Module ./avvClasses
Get-InfoModule
Import-Module ( ((Get-InfoModule).pathMain | Split-Path -Parent)|Join-Path -ChildPath 'classes\avvBase.ps1' ) -Force -ErrorAction Stop

if ($ReUse -or ($a -is [avvBase])) {
    $global:a.ToJson()
} else {
    $global:a=[avvBase]::new()
}

$a.addHashtable(@{t3=@{t31='t31';t32='t32';t33=@{t331='t331';t332='t332'}}});

if ($HT) {
    $a.addHashtable($HT);
}

$a.ToJson()