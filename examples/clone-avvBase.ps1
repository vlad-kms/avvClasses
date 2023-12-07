[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [string] $ini="E:\!my-configs\configs\src\dns-hostinger\dns-cli.ps1.ini"
)

Get-InfoModule
Import-Module ( ((Get-InfoModule).pathMain | Split-Path -Parent)|Join-Path -ChildPath 'classes\avvBase.ps1' ) -Force -ErrorAction Stop
#Import-Module ( ((Get-InfoModule).pathMain | Split-Path -Parent)|Join-Path -ChildPath 'classes\classCFG.ps1' ) -Force -ErrorAction Stop

. .\classes\classCFG.ps1

$global:i = [iniCFG]::new($ini)
