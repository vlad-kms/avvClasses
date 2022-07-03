<######################################
    [FileCFG]
#######################################>
Class FileCFG {
    [string]$filename
    [System.Collections.Specialized.OrderedDictionary]$CFG
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
    
    <#
		�������������. ��������� ������������� �����, ������� ������ ��
		����� � hashtable.
		Exception, ���� �� �������, ��� ������ ������ 
    #>
    [bool]initFileCFG() {
        $this.isExcept(!$this.filename, $true, "Not defined Filename for file configuration.")
        $isFile = Test-Path -Path "$($this.filename)" -PathType Leaf
        $this.isExcept(!$isFile, $true, "Not exists file configuration: $($this.filename)")
	    $this.CFG=$this.importInifile($this.filename)
        $result=($this.CFG.Count -ne 0)
        $this.isExcept(!$result, "Error parsing file CFG: $($this.filename)")

        return $result
    }
    
    <##>
    [System.Collections.Specialized.OrderedDictionary]importInifile([string]$Filename){
        return [ordered]@{}
    }

    <##>
    [string]isExcept ([bool]$Value, [string]$Msg) {
        return $this.isExcept($Value, $this.errorAsException, $Msg)
    }

    [string]isExcept ([bool]$Value, [bool]$EasE, [string]$Msg) {
        if ( $EasE -and $Value ) {
            throw($Msg)
        }
        if ($Value) {return $Msg} else {return ""}
    }
    
	<#
        ������� ������
        �������:
            [System.Collections.Specialized.OrderedDictionary]
                ������ ������ � �������� �� ������.
                ���� ������ �� ����������, �� � ����������� �� errorAsException, ���� ������ ������,
                ���� ����������� Exception
    #>
	[System.Collections.Specialized.OrderedDictionary]readSection([string]$Section) {
		$result=[ordered]@{}
        if ( !$this.isExcept(!$this.CFG.Contains($Section), "Not found section name $($Section)") ) {
            $result = $this.CFG[$Section]
        }
		return $result
	}
    
    <#
        ������� �������� �����, �������� ������ Default
        �������:
            [string] ������ ������.
    #>
    [string] hidden getKeyValue([string]$Path, [string]$Key){
        return ''
    }

    [bool] getBool([string]$Path, [string]$Key){
        return [bool]$this.getKeyValue($Path, $Key)
    }
    [string] getString([string]$Path, [string]$Key){
        return $this.getKeyValue($Path, $Key)
    }
    [Int] getInt([string]$Path, [string]$Key){
        return [int]$this.getKeyValue($Path, $Key)
    }
    [long] getLong([string]$Path, [string]$Key){
        return [long]$this.getKeyValue($Path, $Key)
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

    <###############################################################################
        ������� �� ����� ������
	###############################################################################>
    [System.Collections.Specialized.OrderedDictionary]importInifile([string]$Filename){
        $iniObj = [ordered]@{}
        $section=""
        switch -regex -File $Filename {
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
        ������� �������� �����, �������� ������ Default
        ����:
            [string]$Path - ��� ������
            [string]$Key  - ��� �����
        �������:
            [string] �������� �����.
                     ���� ������ $Path ����������, �� ""
                     ���� ���� ���� � ��������� ������, �� ������������ �������� ����� �����.
                     ���� ����� ��� � ��������� ������, �� ������� ����� �� ������ [Default]
                     ���� ����� ��� �� � ��������� ������, �� � ������ [Default], �� ������� ""
                     ���� �������� ����� = _empty_, �� ������ ������ ������ ''
    ###############################################################################>
    [string] hidden getKeyValue([string]$Path, [string]$Key){
        $Result=''
        if ($this.CFG.Contains($Path)){
            $section = $this.CFG[$Path]
            if ($section.Contains($Key) -and $section[$Key]) {
                $Result=$section[$Key]
            } else {
                try{
                    $result=$this.CFG.Default[$Key]
                } catch {$Result=""}

            }
        }
        if ($Result -eq '_empty_') { $Result='' }
        return $Result
    }

}
