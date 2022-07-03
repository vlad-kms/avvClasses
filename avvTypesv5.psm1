
#. .\classes\classLogger.ps1

$pathModules="D:\tools\PSModules\avvClasses\classes"
. "$($pathModules)\classLogger.ps1"
. "$($pathModules)\classCFG.ps1"

function Get-Logger
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$Filename,
        [int32]$LogLevel=1,
        [boolean]$IsAppend=$true,
        [int32]$TabWidth=4,
        [boolean]$IsExpandTab=$true
    )
    #Logger ([String]$logFile, $LogLevel, [boolean]$isAppend, [int32]$tabWidth){
    return [Logger]::new($Filename, $LogLevel, $IsAppend, $TabWidth, $IsExpandTab)
}

function Get-IniCFG
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$Filename,
        [bool]$ErrorAsException=$false
    )
    return [IniCFG]::new($Filename, $ErrorAsException)}