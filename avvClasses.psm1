#. .\classes\classLogger.ps1

function Get-InfoModule{
    $res=@{}
    $res.Add('filenameIgnoreModule', "$($filenameIgnoreModule)")
    $res.Add('filenameSupportedClasses', "$($filenameSupportedClasses)")
    $res.Add('pathModules', "$($pathModules)")
    $res.Add('importedModules', (Get-ImportedModules -Path $pathModules))
    $res.Add('supportedClasses', (Get-SupportedClasses -Path $pathModules))
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
    #return [Logger]::new($Filename, $LogLevel, $IsAppend, $TabWidth, $IsExpandTab)
    return Get-AvvClass -ClassName 'Logger' -Params @{_obj_=@{
            logFile =$Filename
            logLevel=$LogLevel
            isAppend = $IsAppend
            TW = $TabWidth
            isExpandTab = $IsExpandTab
        }};
}

function Get-IniCFG
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$Filename,
        [bool]$ErrorAsException=$false
    )
    #return [IniCFG]::new($Filename, $ErrorAsException);
    return Get-AvvClass -ClassName 'IniCFG' -Params @{_obj_=@{filename=$Filename;errorAsException=$ErrorAsException}}
}

<############################################
������� ��������� ������ �� ����� ������.
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
    $isSupported = Get-SupportedClasses;
    $isSupported = $True;
    if ($isSupported)
    {
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
        $Params.Contains('_obj_') `
                        -and
                ($Params['_obj_'] -ne $null) `
                        -and
                ($Params['_obj_'] -is [Hashtable])
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
    else
    {
        "����� $($ClassName) �� ��������������" | Write-Host -ForegroundColor Cyan
    }
}

#################### ConvertJSONToHash #########################
# ������������ PSCustomObject � Hashtable, ������� ��� ��������� ��������,
# ������� ��� PSCustomObject
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
    <# TODO �� ��������, ����� ������ ������� �����������.
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

    if ([String]::IsNullOrEmpty($InputObject)) {
        $dict = @{}
    } else {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Script.Serialization");
        $deserializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new();
        $deserializer.MaxJsonLength = [int]::MaxValue;
        $dict = $deserializer.Deserialize($InputObject, 'Hashtable');
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
function Get-SupportedClasses
{
    param (
        [Parameter(Position=0, ValueFromPipeline=$True)]
        [string]$Path=(Get-PathModules)
    )
    if ($Path -and ($Path.Substring(($Path.Length)-1, 1) -ne "$DS")) { $Path += "$($DS)" }
    return (Get-Content -Path "$($Path)$($filenameSupportedClasses)");
}
function IsSupportedClass()
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$ClassName
    )
    $sp = (Get-SupportedClasses);
    for ($i=0; $i -lt $sp.Count; $i++)
    {
        $sp[$i] = $sp[$i].ToUpper();
    }
    return $sp.Contains($ClassName.ToUpper());
}

function Get-ImportedModules
{
    param (
        [Parameter(Position=0, ValueFromPipeline=$True)]
        [string]$Path=(Get-PathModules)
    )
    $listModules=(Get-ChildItem -Path "$($Path)*" -Include '*.ps1' -Name)
    try
    {
        if ($Path -and ($Path.Substring(($Path.Length)-1, 1) -ne "$DS")) { $Path += "$($DS)" }
        $listIgnored=(Get-Content -Path "$($Path)$($filenameIgnoreModule)")
    }
    catch
    {
        $listIgnored=@()
    }
    $loadedModules=($listModules| Where-Object { $listIgnored -notcontains $_})
    #$loadedModules=($listModules| ? { $listIgnored -notcontains $_})
    #write-host $loadedModules
    return $loadedModules
}

function Get-PathModules()
{
    $result=$Env:AVVPATHCLASSES
    #  ���� AVVPATHCLASSES �� ����������, �� ����� ������������ ������� ������� ������������ ������ avvTypesv5,
    if ($result -and ($result.Substring(($result.Length)-1, 1) -ne "$DS")) { $result+="$($DS)" }
    if (!$result) {
        $result = (Split-Path $psCommandPath -Parent) + "$($DS)classes"
    }
    if ($result -and ($result.Substring(($result.Length)-1, 1) -ne "$DS")) { $result+="$($DS)" }
    return $result;
}

$DS='\';
#$global:avvVerMajor=$PSVersionTable.PSVersion.Major;
$filenameIgnoreModule='.avvmoduleignore'
$filenameSupportedClasses='.avvclassessupported'
# ����������� ����� ������� ������������ ������� � �������� � ���������� ����� AVVPATHCLASSES
#$pathModules=$Env:AVVPATHCLASSES
#  ���� AVVPATHCLASSES �� ����������, �� ����� ������������ ������� ������� ������������ ������ avvTypesv5,
#if (!$pathModules) {
#    $pathModules = (Split-Path $psCommandPath -Parent) + "$($DS)classes"
#}
$pathModules=Get-PathModules;

#  ���� ��� ���������� ������� ��������, �� ������� .\classes. �� �������� ������-��
#if (!$pathModules) { $pathModules=".$($DS)classes" }

if ($pathModules -and ($pathModules.Substring(($pathModules.Length)-1, 1) -ne "$DS")) { $pathModules+="$($DS)" }
###Write-Host $pathModules
$ic=Get-ImportedModules -Path $pathModules
$ic.foreach({
    . "$($pathModules)$_"
})
