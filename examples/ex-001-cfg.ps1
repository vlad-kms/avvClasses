#Import-Module D:\tools\PSModules\avvClasses\avvTypesv5.psd1
param(
    [string]$par1
)

$ps = Split-Path $psCommandPath -Parent

$fc="$($ps)\test.ps1.cfg"


$global:ver='res';
$global:abc='123456';

echo "ver=$ver"
echo "abc=$abc"

$global:ini=Get-IniCFG -Filename "$($fc)"

$ini
echo "$ini"

echo "Данные из файла $($fc):"
Get-Content -Path $fc

echo "******************************************************************************************"
echo "1. Демонстрация использования переменных скрипта в файле CFG"

$tc=$ini.CFG.aa
echo '[aa]'

$tc.Keys.foreach({
    echo "$_=$($tc[$_])"
})

echo "******************************************************************************************"
echo "2. Демонстрация использования секции Default в файле CFG"
echo "Ключ 'as1' в секции '[ww]' GetString('ww', 'as1'). Ключ есть и в секции 'ww' и в секции 'Default'"
$ini.GetString('ww', 'as1')
echo "Ключ 'as1' в секции '[ww1]' GetString('ww1', 'as1'). Ключа нет в секции 'ww1', но есть в секции 'Default'"
$ini.GetString('ww1', 'as1')
echo "Ключ 'as1' в секции '[ww2]' GetString('ww2', 'as1'). Нет вообще секции 'ww2'"
$ini.GetString('ww2', 'as1')

$ini.ErrorAsException=$true
try
{
    echo "******************************************************************************************"
    echo "3. Демонстрация использования секции Default в файле CFG. ErrorAsException = True "
    echo "Ключ 'as1' в секции '[ww]' GetString('ww', 'as1'). Ключ есть и в секции 'ww' и в секции 'Default'"
    $ini.GetString('ww', 'as1')
    echo "Ключ 'as1' в секции '[ww1]' GetString('ww1', 'as1'). Ключа нет в секции 'ww1', но есть в секции 'Default'"
    $ini.GetString('ww1', 'as1')
    echo "Ключ 'as1' в секции '[ww2]' GetString('ww2', 'as1'). Нет вообще секции 'ww2'"
    $ini.GetString('ww2', 'as1')
}
catch {
    echo $PSItem;
}
#$ini.InitFileCFG("D:\tools\selectel.dns-hosting\classCFG.ps1.cfg")

echo "******************************************************************************************"
echo "4. Демонстрация вывода на экран"
echo "$fc"

#$p=[ordered]@{'ver'=$PSVersionTable.PSVersion;'Constructor'=@{'param2'=@{'value'='$p';'type'='obj'};'param1'=@{'value'='1';'type'='int'};'param0'=@{'value'='_empty_';'type'='string'}}}; $cj=(Get-AvvClass -ClassName jsonCFG -Params $p);
