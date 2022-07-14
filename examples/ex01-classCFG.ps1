$ps = Split-Path $psCommandPath -Parent
$ps
#. "..\classes\classCFG.ps1"
#. "D:\tools\PSModules\avvClasses\classes\classCFG.ps1"

$global:abc="qwerty"

echo "0. Демонстрация конструкторов =============================================================================="

$p=[ordered]@{'_obj_'=@{'isReadOnly'=$False;'isOverwrite'=$True; 'isDebug'=$True;'filename'='d:\1.json'}; };$c=(Get-AvvClass -ClassName jsoncFG -Params $p);
echo '$p=[ordered]@{''_obj_''=@{''isReadOnly''=$False;''isOverwrite''=$True; ''isDebug''=$True;''filename''=''d:\1.json''}; };$c=(Get-AvvClass -ClassName jsoncFG -Params $p);$c'
$c.toJson();

$p=[ordered]@{'_obj_'=@{'isReadOnly'=$False;'isOverwrite'=$True; 'isDebug'=$True;'filename'='d:\1.json'};'_cfg_'=@{} };$c=(Get-AvvClass -ClassName jsoncFG -Params $p);
echo '$p=[ordered]@{''_obj_''=@{''isReadOnly''=$False;''isOverwrite''=$True; ''isDebug''=$True;''filename''=''d:\1.json''};''_cfg_''=@{} };$c=(Get-AvvClass -ClassName jsoncFG -Params $p);$c'
$c.toJson();

$p=[ordered]@{'_obj_'=@{'isReadOnly'=$False;'isOverwrite'=$True; 'isDebug'=$True;'filename'='d:\1.json'};'_cfg_'=@{'k1'='v1';'k2'=@{'k1'=1;'k2'=2}} };$c=(Get-AvvClass -ClassName jsoncFG -Params $p);
echo '$p=[ordered]@{''_obj_''=@{''isReadOnly''=$False;''isOverwrite''=$True; ''isDebug''=$True;''filename''=''d:\1.json''};''_cfg_''=@{''k1''=''v1'';''k2''=@{''k1''=1;''k2''=2}} };$c=(Get-AvvClass -ClassName jsoncFG -Params $p);$c'
$c.toJson();

$fc="$($ps)\test.ps1.cfg";
echo "Данные из файла $($fc):"
Get-Content $fc|Out-Host;
echo '$c1=[IniCFG]::new($fc)'
. "..\classes\classCFG.ps1"
$c1=[IniCFG]::new($fc);
$c1.toJson();

echo "1. Демонстрация использования переменных скрипта в файле CFG ==============================================="

$tc=$c1.CFG.aa
echo '[aa]'

$tc.Keys.foreach({
    echo "$_=$($tc[$_])"
})

echo "2. Демонстрация использования секции Default в файле CFG ==================================================="
$c1.ErrorAsException=$false
echo "`tErrorAsException = False -----------------------"
echo "`tКлюч 'as1' в секции '[ww]' GetString('ww', 'as1'). Ключ есть и в секции 'ww' и в секции 'Default'"
echo "`t`t$($c1.GetString('ww', 'as1'))"
echo "`tErrorAsException = True ------------------------"
$c1.ErrorAsException=$true
try{
    echo "`tКлюч 'as1' в секции '[ww]' GetString('ww', 'as1'). Ключ есть и в секции 'ww' и в секции 'Default'"
    echo "`t`t$($c1.GetString('ww', 'as1'))"
} catch {
    echo $PSItem;
}
$c1.ErrorAsException=$false
echo "`tErrorAsException = False -----------------------"
echo "`t`Ключ 'as1' в секции '[ww1]' GetString('ww1', 'as1'). Ключа нет в секции 'ww1', но есть в секции 'Default'"
echo "`t`t$($c1.GetString('ww1', 'as1'))"
$c1.ErrorAsException=$true
echo "`tErrorAsException = True ------------------------"
try
{
    echo "`tКлюч 'as1' в секции '[ww1]' GetString('ww1', 'as1'). Ключа нет в секции 'ww1', но есть в секции 'Default'"
    echo "$($c1.GetString('ww1', 'as1'))"
} catch {
    echo $PSItem;
}
$c1.ErrorAsException=$false
echo "`tErrorAsException = False -----------------------"
echo "`tКлюч 'as1' в секции '[ww2]' GetString('ww2', 'as1'). Нет вообще секции 'ww2'"
echo "$($c1.GetString('ww2', 'as1'))"
$c1.ErrorAsException=$true
echo "`tErrorAsException = True ------------------------"
try
{
    echo "`tКлюч 'as1' в секции '[ww2]' GetString('ww2', 'as1'). Нет вообще секции 'ww2'";
    ech "$($c1.GetString('ww2', 'as1'))";
} catch { echo $PSItem; }
