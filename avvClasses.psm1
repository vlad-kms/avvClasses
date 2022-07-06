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
function Hashtable2Params([Hashtable]$ht)
{
    if ($ht -is [hashtable]) {
        if ($ht.Contains("type") -and $ht.type -and $ht.type -ne ""){
            if ($ht.type.ToUpper() -eq "STRING") {$ts = """$($ht.Value)"""}
            elseif ($ht.type.ToUpper() -eq "INT") {$ts = "$($ht.Value)"}
            #elseif ($ht.type.ToUpper() -eq "BOOL") {$ts = [int][bool]$ht.Value}
            elseif ($ht.type.ToUpper() -eq "OBJ") {$ts = $ht.Value}
            else {$ts = """$($ht.Value)"""};
        } else {$ts = """$($ht.Value)""" }
    } else {$ts='qwerty TYPE'};
    return $ts;
}
function Get-AvvClass {
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$ClassName,
        [Hashtable]$Params=@{}
    )
    if ( $Params.Contains('Constructor') -and
        ($Params['Constructor'] -is [Hashtable]) -and
        ($Params['Constructor'].Count -ne 0) )
    {
        $construct=$Params['Constructor'];
        $parStr = '';
        for ($i = 0; $i -lt $Params['Constructor'].Count; $i++)
        {
            #$str = ([string]$Params['Constructor']["param$($i)"]).Trim();
            $ht  = $construct["param$($i)"];
            if ($ht.Count -ne 0)
            {
                $parStr += (Hashtable2Params($ht)) + ',';
            }
        }
        if ($parStr) {
            $parStr = $parStr.Substring(0, $parStr.Length - 1);
        }
        return Invoke-Expression -Command "[$ClassName]::new($parStr)"
    }
    else
    {
        return Invoke-Expression -Command "[$ClassName]::new()"
    }
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
