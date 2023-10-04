. .\classes\avvBase.ps1
. .\classes\classCFG.ps1

$fn="E:\!my-configs\configs\src\dns-api\config.json"
#"-TypeConfig", "JSON", "-ExtParams", "@{_obj_add_value_=@{CFG=@{dns_1cloud1=@{p1='v1'};dns_cli=@{p1='v1'}}}}
$ExtParams=@{_obj_add_value_=@{CFG=@{dns_1cloud1=@{p1='v1'};dns_cli=@{p1='v1'}}}}
$global:i=[JsonCFG]::New($fn, $True, $ExtParams)
$i
