[CmdletBinding()]
Param(
    [switch] $Vr
)

import-module D:\Tools\~scripts.ps\avvClasses\avvClasses
#. D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1
#. D:\Tools\~scripts.ps\avvClasses\classes\classCFG.ps1

$Ve=$Vr.IsPresent

#(get-avvClass -ClassName JsonCFG -Params @{_new_=@{Filename="E:\!my-configs\configs\src\dns-api\config.json";ErrorAsException=$true}} -Verbose:$Ve)
(get-avvClass -ClassName avvTest -Verbose:$Ve).ToJson()

# ERROR. -Params не имеет тип HASHTABLE
#(Get-AvvClass -ClassName avvTest -Params "1, 'asdfghj'" -Verbose:$Ve)|ConvertTo-Json -Depth 100

#exit 0


#Params с ключом Constructor
Write-Host "Params contain key 'Constructor' +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#(Get-AvvClass -ClassName avvTest -Params @{"constructor"=@{"param0"=@{"type"="string"; "value"="E:\!my-configs\configs\src\dns-api\config.json"}}} -Verbose:$Ve)|ConvertTo-Json -Depth 100
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

#Params с ключом Constructor
Write-Host "Params contain key 'Constructor' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
$global:f_c=(Get-AvvClass -ClassName avvTest -Params @{"constructor"=@{"param1"=@{"type"="Str"; "value"="ttt"}; "param0"=@{"type"="int";"value"=10}}} -Verbose:$Ve); $f_c.ToJson()
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

#пока не работает, надо смотреть
#(Get-AvvClass -ClassName avvTest -Params @{"constructor"=@{"param0"=@{"type"="Obj"; "value"=@{"f2"=@{"f1"="bmv"; "ff1"=1234}}}}} -Verbose:$Ve)|ConvertTo-Json -Depth 100
#Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

#Params с ключом _obj_
Write-Host "Params contains keys '_obj_' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
$global:f_o=(Get-AvvClass -ClassName avvTest -Params @{"_obj_"=@{"f1"=@{"f1_1"=1;"f1_2"=2};"id"="id1"; "f2"=12; "fg"=444};} -Verbose:$Ve); $f_o.ToJson()
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

#Params с ключом _obj_add_
Write-Host "Params contains keys '_obj_add_' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
$global:f_oa=(Get-AvvClass -ClassName avvTest -Params @{"_obj_add_"=@{"f1"=@{"f1_1"=1;"f1_2"=2};"id"="id1"; "f2"=@{}; "fg"=444};} -Verbose:$Ve); $f_oa.ToJson()
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

#Params с ключом _obj_add_value_
Write-Host "Params contains keys '_obj_add_value_' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
$global:f_oav=(Get-AvvClass -ClassName avvTest -Params @{"_obj_add_value_"=@{"f3"=100; "fg"=444; "f1"="_as_"; "f2"=@{"ff1"="ggg"; "ff2"=34545}}} -Verbose:$Ve); $f_oav.ToJson()
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


#Params произвольая Hashtable
Write-Host "Params custom Hashtable +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#$global:f=(Get-AvvClass -ClassName avvTest -Params @{"f1"=@{"f1_1"=1;"f1_2"=2};"id"="id1"; "f2"=@{}; "fg"=444} -Verbose:$Ve); $f|ConvertTo-Json -Depth 100
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

#Params с ключом _new_
Write-Host "Params contains keys '_new_' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
$global:f_new=(Get-AvvClass -ClassName avvTest -Params @{"_new_"=@{"f1_1"=1;"f1_2"=2; "id"=1; "tst"=@{f1=1;f2=2}; "f1"="asd"; "f2"=@{"b1"=1;"b2"=2}}; "fg"=444} -Verbose:$Ve); $f_new.ToJson()
Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
