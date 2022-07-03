#. .\classes\classLogger.ps1

function Info-avvTypesv5{
    $res=@{}
    $res.Add('pathModules', "$($pathModules)")
    return $res
}

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
    return [IniCFG]::new($Filename, $ErrorAsException)
}

<############################################
Создать экземпляр класса по имени класса.
Создавать только без параметров. Инициализировать только после создания
############################################>
function Get-AvvClass {
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$ClassName
    )
    #$cmd=
    return Invoke-Expression -Command "[$ClassName]::new()"
}

###########################################################
###########################################################
###########################################################
function Get-ImportClass
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$Path
    )
    $listModules=(Get-ChildItem -Path "$($Path)*" -Include '*.ps1' -Name)
    try
    {
        $listIgnored=(Get-Content -Path "$($Path)$($filenameIgnoreClass)")
    }
    catch
    {
        $listIgnored=@()
    }
    $loadedModules=($listModules| ? { $listIgnored -notcontains $_})
    #write-host $loadedModules
    return $loadedModules
}

$DS='\'
$filenameIgnoreClass='.avvclassignore'
# попробовать взять каталог расположения модулей с классами в переменной среды AVVPATHCLASSES
$pathModules=$Env:AVVPATHCLASSES
#  если AVVPATHCLASSES не существует, то будем использовать текущий каталог расположения модуля avvTypesv5,
if (!$pathModules) {
    $pathModules = (Split-Path $psCommandPath -Parent) + "$($DS)classes"
}
#  если две предыдущих попытки неудачны, то пробуем .\classes. НЕ РАБОТАЕТ почему-то
#if (!$pathModules) { $pathModules=".$($DS)classes" }

if ($pathModules -and ($pathModules.Substring(($pathModules.Length)-1, 1) -ne "$DS")) { $pathModules+="$($DS)" }
###Write-Host $pathModules
$ic=Get-ImportClass -Path $pathModules
$ic.foreach({
    . "$($pathModules)$_"
})
