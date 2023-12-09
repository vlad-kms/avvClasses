[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$True, Position=0)]
    [hashtable] $HT,
    [switch] $ReUse
)


. .\classes\avvBase.ps1
. .\classes\classCFG.ps1



$fn="E:\!my-configs\configs\src\dns-api\config.json"
$fn="D:\Tools\~scripts.ps\avvClasses\examples\ex02-classCFG.ps1.json"

#"-TypeConfig", "JSON", "-ExtParams", "@{_obj_add_value_=@{CFG=@{dns_1cloud1=@{p1='v1'};dns_cli=@{p1='v1'}}}}
$ExtParams=@{_new_=@{CFG=@{dns_1cloud=@{p1='v1';config=@{p4='p4'}};dns_cli=@{p1='v1';p2=@{p21=@{p211=@{p2111='p2111p';p2112=""}};p22="eee";p23='p23'}}}}}
$ExtParams += $HT

<#
$global:i=[JsonCFG]::New($fn, $True, $ExtParams)
$i.ToJson()
#>
<#
$global:i1=[JsonCFG]::New($fn, $True)
$i1.ToJson()
#>
$global:i2=[JsonCFG]::New(@{Filename=$fn; errorAsException=$True; _new_=@{CFG=$ExtParams._new_.CFG;ok1='ok1'}; _obj_=@{errorAsException=$True; AddOrMerge=[FlagAddHashtable]::Merge}})
$i2.ToJson()

$i2.readSection('dns_selectel') | ConvertTo-Json -Depth 100
$i2.readSection('dns_cli') | ConvertTo-Json -Depth 100
$i2.readSection('.') | ConvertTo-Json -Depth 100

$global:i3=( Get-AvvClass -ClassName "JsonCFG"   -Params @{Filename=$fn; _new_=@{CFG=$ExtParams._new_.CFG;ok1='ok1'}; _obj_=@{errorAsException=$True; AddOrMerge=[FlagAddHashtable]::Merge}})
