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
    elseif (
            (
                $Params.Contains('_obj_') -and
                ($Params['_obj_'] -is [Hashtable]) -and
                ($Params['_obj_'] -ne $null)
            ) -or
            (
            $Params.Contains('_cfg_') -and
                    ($Params['_cfg_'] -is [Hashtable]) -and
                    ($Params['_cfg_'] -ne $null)

            )
        )
    {
        return Invoke-Expression -Command ("[$ClassName]::new" + '($Params)' );
    }
    else
    {
        return Invoke-Expression -Command "[$ClassName]::new()"
    }
}

#################### ConvertJSONToHash #########################
# Конвертирует PSCustomObject в Hashtable, включая все вложенные свойства,
# имеющие тип PSCustomObject
function ConvertJSONToHash{
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [AllowNull()]
        $root
    )
    $hash = @{};
    $keys = $root | Get-Member -MemberType NoteProperty | Select-Object -exp Name;
    $keys | %{
        $obj=$root.$($_);
        if($obj -is [PSCustomObject])
        {
            $nesthash=ConvertJSONToHash $obj;
            $hash.add($_,$nesthash);
        }
        else
        {
            $hash.add($_,$obj);
        }
    }
    return $hash
}

function ConvertFrom-JsonToHashtable {
    <# TODO НЕ РАБОТАЕТ, ТОЛКО первый уровень вложенности.
    .SYNOPSIS
        Helper function to take a JSON string and turn it into a hashtable
    .DESCRIPTION
        The built in ConvertFrom-Json file produces as PSCustomObject that has case-insensitive keys. This means that
        if the JSON string has different keys but of the same name, e.g. 'size' and 'Size' the comversion will fail.
        Additionally to turn a PSCustomObject into a hashtable requires another function to perform the operation.
        This function does all the work in step using the JavaScriptSerializer .NET class
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [AllowNull()]
        [string]
        $InputObject,
        [switch]
    # Switch to denote that the returning object should be case sensitive
        $casesensitive
    )

    # Perform a test to determine if the inputobject is null, if it is then return an empty hash table
    if ([String]::IsNullOrEmpty($InputObject)) {
        $dict = @{}
    } else {
        # load the required dll
        #[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        #$deserializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
        #$deserializer.MaxJsonLength = [int]::MaxValue
        #$dict = $deserializer.DeserializeObject($InputObject)
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Script.Serialization");
        #$deserializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer;
        $deserializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new();
        $deserializer.MaxJsonLength = [int]::MaxValue;
        $dict = $deserializer.Deserialize($InputObject, 'Hashtable');

        # If the caseinsensitve is false then make the dictionary case insensitive
        if ($casesensitive -eq $false) {
            $dict = New-Object "System.Collections.Generic.Dictionary[System.String, System.Object]"($dict, [StringComparer]::OrdinalIgnoreCase)
        }
    }
    return $dict
}

function Get-Version{
    return $PSVersionTable;
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

$DS='\';
$global:avvVerMajor=$PSVersionTable.PSVersion.Major;

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
