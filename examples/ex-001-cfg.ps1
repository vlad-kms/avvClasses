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

echo "������ �� ����� $($fc):"
Get-Content -Path $fc

echo "******************************************************************************************"
echo "1. ������������ ������������� ���������� ������� � ����� CFG"

$tc=$ini.CFG.aa
echo '[aa]'

$tc.Keys.foreach({
    echo "$_=$($tc[$_])"
})

echo "******************************************************************************************"
echo "2. ������������ ������������� ������ Default � ����� CFG"
echo "���� 'as1' � ������ '[ww]' GetString('ww', 'as1'). ���� ���� � � ������ 'ww' � � ������ 'Default'"
$ini.GetString('ww', 'as1')
echo "���� 'as1' � ������ '[ww1]' GetString('ww1', 'as1'). ����� ��� � ������ 'ww1', �� ���� � ������ 'Default'"
$ini.GetString('ww1', 'as1')
echo "���� 'as1' � ������ '[ww2]' GetString('ww2', 'as1'). ��� ������ ������ 'ww2'"
$ini.GetString('ww2', 'as1')

$ini.ErrorAsException=$true
try
{
    echo "******************************************************************************************"
    echo "3. ������������ ������������� ������ Default � ����� CFG. ErrorAsException = True "
    echo "���� 'as1' � ������ '[ww]' GetString('ww', 'as1'). ���� ���� � � ������ 'ww' � � ������ 'Default'"
    $ini.GetString('ww', 'as1')
    echo "���� 'as1' � ������ '[ww1]' GetString('ww1', 'as1'). ����� ��� � ������ 'ww1', �� ���� � ������ 'Default'"
    $ini.GetString('ww1', 'as1')
    echo "���� 'as1' � ������ '[ww2]' GetString('ww2', 'as1'). ��� ������ ������ 'ww2'"
    $ini.GetString('ww2', 'as1')
}
catch {
    echo $PSItem;
}
#$ini.InitFileCFG("D:\tools\selectel.dns-hosting\classCFG.ps1.cfg")

echo "******************************************************************************************"
echo "4. ������������ ������ �� �����"
echo "$fc"

#$p=[ordered]@{'ver'=$PSVersionTable.PSVersion;'Constructor'=@{'param2'=@{'value'='$p';'type'='obj'};'param1'=@{'value'='1';'type'='int'};'param0'=@{'value'='_empty_';'type'='string'}}}; $cj=(Get-AvvClass -ClassName jsonCFG -Params $p);
