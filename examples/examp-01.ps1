$ps = Split-Path $psCommandPath -Parent
$ps
#. "..\classes\classCFG.ps1"
. "D:\tools\PSModules\avvClasses\classes\classCFG.ps1"

$abc="qwerty"
$fc="$($ps)\test.ps1.cfg"
$c1=[IniCFG]::new($fc)
$c1

echo "������ �� ����� $($fc):"
Get-Content -Path $fc

echo "1. ������������ ������������� ���������� ������� � ����� CFG"

$tc=$c1.CFG.aa
echo '[aa]'

$tc.Keys.foreach({
    echo "$_=$($tc[$_])"
})

echo "2. ������������ ������������� ������ Default � ����� CFG"
echo "���� 'as1' � ������ '[ww]' GetString('ww', 'as1'). ���� ���� � � ������ 'ww' � � ������ 'Default'"
$c1.GetString('ww', 'as1')
echo "���� 'as1' � ������ '[ww1]' GetString('ww1', 'as1'). ����� ��� � ������ 'ww1', �� ���� � ������ 'Default'"
$c1.GetString('ww1', 'as1')
echo "���� 'as1' � ������ '[ww2]' GetString('ww2', 'as1'). ��� ������ ������ 'ww2'"
$c1.GetString('ww2', 'as1')

$c1.ErrorAsException=$true
echo "3. ������������ ������������� ������ Default � ����� CFG. ErrorAsException = True "
echo "���� 'as1' � ������ '[ww]' GetString('ww', 'as1'). ���� ���� � � ������ 'ww' � � ������ 'Default'"
$c1.GetString('ww', 'as1')
echo "���� 'as1' � ������ '[ww1]' GetString('ww1', 'as1'). ����� ��� � ������ 'ww1', �� ���� � ������ 'Default'"
$c1.GetString('ww1', 'as1')
echo "���� 'as1' � ������ '[ww2]' GetString('ww2', 'as1'). ��� ������ ������ 'ww2'"
$c1.GetString('ww2', 'as1')

#$c1.InitFileCFG("D:\tools\selectel.dns-hosting\classCFG.ps1.cfg")

