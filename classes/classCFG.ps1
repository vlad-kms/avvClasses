<#
# ����� FileCFG ������� �����. ��� �� ���� ����������.
# ����� IniCFG ��� ������ � ������� .ini. ���������� ����� ����������� � Hashtable.
# ������ ��� ����� ������� ������, ��������� �� ���� ������. �������� ���������� ������
# ������� ��� ����� � �������� � Hashtable.
# ��������:
���� ini
    [default]
    Token=<KEY API TELEGRAM>0
    access_token=789
    ExtVersion=ext
    ClinicVersion=2
    test=test
    test1=test1

    [dns_cli]
    Token=$($Token)
    access_token=$($ExtParams.Token)
    ExtVersion=$($ExtParams.ExtVersion)
    ClinicVersion=$($ExtParams.ClinicVersion)
    ;Token=_empty_

    [dns_cli1]
    test1=_empty_
    Hashtable
    Name                           Value
    ----                           -----
    default                        {Token, access_token, ExtVersion, ClinicVersion...}
    dns_cli                        {Token, access_token, ExtVersion, ClinicVersion}
    dns_cli1                       {test1}

    PS C:\Windows\system32> $c.CFG.default
    Name                           Value
    ----                           -----
    Token                          <KEY API TELEGRAM>0
    access_token                   789
    ExtVersion                     ext
    ClinicVersion                  2
    test                           test
    test1                          test1
# ���� ������� ������ [default], �� �������� ����� ����������� �� ��������
# ���� � ������ ��� �����, � � [default] ����, �������� ������� �� [default].
# ���� � ������ ���� ����, ������� ���� ��� ��� � [default], �������� ������� �� ������,
# ����� ������, ���� �������� � ������ = '_empty_', �������� ������� �� [default].
# � ������� �� ������������� ini, ���� ��������� ��������� Hashtable'��.
# TODO. ���� ��� ������ ������ ������� �� �����.
# ���� ����������� ��� �������� �� Hashtable. ������� ������ ����������� ����� (+) � CFG.
# ����� � ����� ������������ �����������.
# ���� ErrorAsException ���� True, �� ��� ������ ���� ��� �����, ������ �������������� � ��� � �.�.
# ������������� � Exception, ����� ������������ ������ ������.
# �������:
#   [Hashtable]readSection([string]$section) - ������� ������.
#       �����: @{
#                   code: 0 - ������ ���� � �� �������
#                   result: - ��������� ������, �.�. �� ����� � ��������
#               }
# ��������� ������ ��������� ���� � �������� ������. get<Type> �������� ����� getKeyValue,
# ������ ���������� ��������� � ��������� ���
#   [Object] hidden getKeyValue([string]$path, [string]$key)
#   [bool] getBool([string]$path, [string]$key){
#   [string] getString([string]$path, [string]$key){
#   [Int] getInt([string]$path, [string]$key){
#   [long] getLong([string]$path, [string]$key){
#
#
# #>

<######################################
    [FileCFG]
������� ���������� Java
#######################################>
Class FileCFG {
    [string]$filename=''
    #[Hashtable]$CFG
    [Hashtable]$CFG=[ordered]@{}
	[bool]$errorAsException = $false

    <#################################################
    #   Constructors
    #################################################>
    FileCFG(){
        $this.filename=$PSCommandPath + '.cfg'
        $this.initFileCFG();
    }
    FileCFG([bool]$EaE){
        $this.filename=$PSCommandPath + '.cfg'
		$this.errorAsException=$EaE
        $this.initFileCFG();
    }
    FileCFG([string]$FN){
        $this.filename=$FN;
        $this.initFileCFG();
    }
    FileCFG([string]$FN, [bool]$EaE) {
        $this.filename=$FN;
		$this.errorAsException=$EaE
        $this.initFileCFG();
    }
    <##>
    FileCFG([Hashtable]$CFG) {
        $this.CFG=$CFG;
    }
    FileCFG([Hashtable]$CFG, [bool]$EaE) {
        $this.CFG=$CFG;
        $this.errorAsException=$EaE
    }
    <##>
    <#
		�������������. ��������� ������������� �����, ������� ������ ��
		����� � hashtable.
		Exception, ���� �� �������, ��� ������ ������ 
    #>
    [bool]initFileCFG() {
        $result=$false
        if ($this.filename.ToUpper() -ne '_EMPTY_' )
        {
            $this.isExcept(!$this.filename, $true, "Not defined Filename for file configuration.")
            $isFile = Test-Path -Path "$($this.filename)" -PathType Leaf
            $this.isExcept(!$isFile, $true, "Not exists file configuration: $($this.filename)")
	        $this.CFG=$this.importInifile($this.filename)
            $result=($this.CFG.Count -ne 0)
            $this.isExcept(!$result, "Error parsing file CFG: $($this.filename)")
        }
        return $result
    }
    
    <##>
    [Hashtable]importInifile([string]$filename){
        return [ordered]@{}
    }

    <##>
    [string]isExcept ([bool]$Value, [string]$Msg) {
        return $this.isExcept($Value, $this.errorAsException, $Msg)
    }

    [string]isExcept ([bool]$value, [bool]$EasE, [string]$msg) {
        if ( $EasE -and $value ) {
            throw($msg)
        }
        if ($value) {return $msg} else {return ""}
    }

	<#
        ������� ������
        �������:
            [Hashtable]
                ������ ������ � �������� �� ������.
                ���� ������ �� ����������, �� � ����������� �� errorAsException, ���� ������ ������,
                ���� ����������� Exception
    #>
	#[Hashtable]readSection([string]$section) {
    [Hashtable]readSection([string]$section) {
		$result = @{};
        $code = 0;
        $arrSections = $section.Split('.', [StringSplitOptions]::RemoveEmptyEntries);
        $path = $this.CFG;
        $arrSections.ForEach({
            if ( $path.Contains($_) -and
                    (
                        ($path[$_] -is [Hashtable]) -or
                        ($path[$_] -is [System.Collections.Specialized.OrderedDictionary])
                    )
                )
            {
                $path = $path[$_];
            }
            else
            {
                $path = @{};
                $code = 1;
            }
        });
        if (!($path -is [Hashtable]) -and
                !($path -is [System.Collections.Specialized.OrderedDictionary])
            )
        {
            $path = @{};
            $code = 1;
        }
        $res = @{};
        $path.Keys.foreach({
            $res.Add("$_", $path[$_]);
        });
        # ���� � ������ ��� �������� � $this.ErrorAsException, ����� �������� Exception
        !$this.isExcept($res.Keys.Count -eq 0, "Not found section name $($section) or is not Section type");
        $result = @{
            'code'=$code;
            'result'=$res
        }
		return $result;
	}
    
    <#
        ������� �������� �����, �������� ������ default
        �������:
            [string] ������ ������.
    #>
    [Object] hidden getKeyValue([string]$path, [string]$key){
        return ''
    }

    [bool] getBool([string]$path, [string]$key){
        return [bool]$this.getKeyValue($path, $key)
    }
    [string] getString([string]$path, [string]$key){
        return       $this.getKeyValue($path, $key)
    }
    [Int] getInt([string]$path, [string]$key){
        return  [int]$this.getKeyValue($path, $key)
    }
    [long] getLong([string]$path, [string]$key){
        return [long]$this.getKeyValue($path, $key)
    }

}

<######################################
    [IniCFG]
    ������ ��� ������ � ������ �������� ini
#######################################>
Class IniCFG : FileCFG {

    IniCFG() : base() {
        #$this.filename=$PSCommandPath + '.cfg'
        #$res=$this.initFileCFG();
    }
    IniCFG([bool]$EaE) : base($EaE) {
        #$this.filename=$PSCommandPath + '.cfg'
        #$this.errorAsException=$EaE
        #$res=$this.initFileCFG();
    }
    IniCFG([string]$FN) : base($FN) {
        #$this.filename=$FN;
        #$res=$this.initFileCFG();
    }
    IniCFG([string]$FN, [bool]$EaE) : base($FN, $EaE) {
        #$this.filename=$FN;
        #$this.errorAsException=$EaE
        #$res=$this.initFileCFG();
    }
    <##>
    IniCFG([String]$FN, [bool]$EaE, [Hashtable]$CFG) : base ($FN, $EaE) {
    #IniCFG([Hashtable]$CFG, [bool]$EaE) {
        $this.CFG += $CFG;
    }
    <##>

    <###############################################################################
        ������� �� ����� ������
	###############################################################################>
    [Hashtable]importInifile([string]$filename){
        $iniObj = [ordered]@{}
        $section=""
        switch -regex -File $filename {
            "^\[(.+)\]$" {
                $section = $matches[1]
                $iniObj[$section] = [ordered]@{}
                #Continue
            }
            "(?<key>^[^\#\;\=]*)[=?](?<value>.+)" {
                $key  = $matches.key.Trim()
                $value  = $matches.value.Trim()

                if ( ($value -like '$(*)') -or ($value -like '"*"') ) {
                    # � INI ����� �������������� ���������� (�������) �� ������� 
                    # key1=$($var1)
                    # key2="$var1"
                    $value = Invoke-Expression $value
                }
                if ( $section ) {
                    $iniObj[$section][$key] = $value
                } else {
                    $iniObj[$key] = $value
                }
                continue
            }
            "(?<key>^[^\#\;\=]*)[=?]" {
                $key  = $matches.key.Trim()
                if ( $section ) {
                    $iniObj[$section][$key] = ""
                } else {
                    $iniObj[$key] = ""
                }
            }
        } ### switch -regex -File $IniFile {
        return $iniObj
    }
	
    <###############################################################################
        ������� �������� �����, �������� ������ default
        ����:
            [string]$Path - ��� ������
            [string]$Key  - ��� �����
        �������:
            [string] �������� �����.
                     ���� ������ $Path ����������, �� ""
                     ���� ���� ���� � ��������� ������, �� ������������ �������� ����� �����.
                     ���� ����� ��� � ��������� ������, �� ������� ����� �� ������ [default]
                     ���� ����� ��� �� � ��������� ������, �� � ������ [default], �� ������� ""
                     ���� �������� ����� = _empty_, �� ������ ������ ������ ''
    ###############################################################################>
    [Object]hidden getKeyValue([string]$path, [string]$key){
        $result=''
        $res = $this.readSection($path);
        if ($res.code -ne 0 ) {
            return $result
        }
        $section = $res.result;
        if ($section.Contains($key) -and $section[$key]) {
            $result=$section[$key]
        } else {
            try{
                $result=$this.CFG.default[$key]
            }
            catch {
                $result=""
            }
        }
        !$this.isExcept($result.Length -eq 0, "Not found key $($key) in section name $($path)");
        if ($result -eq '_empty_') { $result='' }
        return $result
    }
}
