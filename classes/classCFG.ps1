<#
# ����� FileCFG ������� �����. ��� �� ���� ����������.
# ����� IniCFG ��� ������ � ������� .ini. ���������� ����� ����������� � Hashtable.
# ������ ��� ����� ������� ������, ��������� �� ���� ������. �������� ���������� ������
# ������� ��� ����� � �������� � Hashtable. ���� ��� ����� ���������� � ����������� = '_empty_',
# �� ������������� �� ����� ����������, �.�. CFG ����� ������������ ����� @{}
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
# TODO ���� ��� ������ ������ ������� �� �����. ����� ������� ��� JSON. ����� ����� ����������� �� FileCFG
# TODO ������� ��������������� ������
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
#   saveToFile([string]$filename, [bool]$isOverwrite)
#                       - �������� � ���� INI $filename ������ CFG. ������������ ������ ������ �������,
#                         �� ������� �����, ��������� ������� �������� [Hashtable]
#                         $isOverwrite ���������� �������������� ���� ��� ���
#   saveToFile()          - �� �� ��� � ����, �� ������������ � ���� $this.filename. �� ��������� $isOverwrite=$False
#   saveToFile([bool]$isOverwrite)
#   [bool] hidden setKeyValue([string]$path, [string]$key, [Object]$value){
#                       - �������� �������� � ���� ������, �������� ����� �� ����.
#                         ���� ���� = '', �� ����� ��������� ���� �� ����, � ������� ��� ���� ��� ���.
#
#>

<######################################
    [FileCFG]
������� ���������� Java
#######################################>
Class FileCFG {
    [string]$filename=''
    #[Hashtable]$CFG
    [Hashtable]$CFG=[ordered]@{}
	[bool]$errorAsException = $false
    [bool] hidden $isReadOnly=$true

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
    <#
	#	�������������. ��������� ������������� �����, ������� ������ ��
	#	����� � hashtable. ���� ��� ����� = '_empty_', �� ������� ������.
	#	Exception, ���� �� �������, ��� ������ ������
    #>
    [bool]initFileCFG() {
        $result=$false
        if ($this.filename.ToUpper() -ne '_EMPTY_' )
        {
            # $this.filename != '_empty_'
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

	<########################################################################
    #   ������� ������
    #   �������:
    #       [Hashtable]@{
    #           code:   0 - ������ ���� � �� �������
    #                   1 - ��� ����, �.�. �����-�� �������� � section
    #                   2 - ���� ����, �� �����-�� ������� � ���� ��
    #                       �������� [Hashtable]�
    #                   3 -
    #           result:   - ��������� ������, �.�. �� ����� � ��������
    #                       ������ ������ � �������� �� ������.
    #       }
    #       ���� ������ �� ����������, �� � ����������� �� errorAsException,
    #       ���� ������ ������, ���� ����������� Exception
    #########################################################################>
    [Hashtable]readSection([string]$section) {
		$result = @{};
        $code = 0;
        # ������ �� ������ 'sec1.sec2.sec3...
        $arrSections = $section.Split('.', [StringSplitOptions]::RemoveEmptyEntries);
        $path = $this.CFG;
        # ��������� ��� ������� �� �������, ��� ���������� ���� � ��� �������� ���� Hashtable:
        # ���-�� ���
        # sec1=@{
        #           sec2=@{
        #                   sec3=@{
        #                       key1=val1
        #                       key2=val2
        #                           ...
        #                   }
        #           }
        # }
        $arrSections.ForEach({
            #if ( $path.Contains($_) -and $this.isHashtable($path[$_]) )
            if ( $path.Contains($_) )
            {
                if ( ($path[$_] -is [Hashtable]) -or
                     ($path[$_] -is [System.Collections.Specialized.OrderedDictionary])
                    )

                {
                    $path = $path[$_];
                }
                else
                {
                    # ���� ����, �� ������� �� [Hashtable]
                    $path = @{};
                    $code = 2;
                }
            }
            else
            {
                # ��� ������ ����
                $path = @{};
                $code = 1;
            }
        });
        # ������ � ������ Hashtable, ���� ��������� �������� �� Hashtable.
        # �.�. ������ ���������� �����, �������� ������ ������
        if (!($path -is [Hashtable]) -and
                !($path -is [System.Collections.Specialized.OrderedDictionary])
            )
        #if (!($this.isHashtable($path)) )
        {
            # ��������� ������� � ���� �� �������� [Hashtable]
            $path = @{};
            $code = 2;
        }
        $res = @{};
        $path.Keys.foreach({
            $res.Add("$_", $path[$_]);
        });
        # ���� � ������ ��� �������� � $this.ErrorAsException � $code <> 0, �� �������� Exception
        !$this.isExcept( ($res.Keys.Count -eq 0) -and ($code -ne 0), "Not found section name $($section) or is not Section type");
        $result = @{
            'code'=$code;
            'result'=$res
        }
		return $result;
	}
    
    <#
    # ������� �������� �����, �������� ������ default
    # �������:
    #   [Object] ''
    [Object] hidden getKeyValue([string]$path, [string]$key){
        return '';
    }
    #>

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
        try{
            if ($result.ToUpper() -eq '_empty_'.ToUpper()) { $result='' }
        }
        catch {
            $result=''
        };
        return $result;
    }

    ##########################################################
    # �������� �������� ����� �� ����.
    # ���� ���� = '', �� ����� ��������� ���� �� ����, � ������� ��� ���� ��� ���.
    # � ���������� True,
    # ���� ����, ��� ���� ��� ������� ������ ���������� ������� ���� (������), ���� ��� ���,
    # ��� �������
    # ����:
    #   $path   - ������, ���� �������� key=value, ��� �������� ���
    #   $key    - ���� ��� �������� ������ ��������
    #   $value  - ��������, ������� �������� �� ����
    #   �
    # �������:
    #   $true ���� ������ ������, ����� $false.
    #   ���� key='': $true ���� ���� ���� ��� ������ �������, ����� $false
    ##########################################################
    #[bool] hidden setKeyValue([string]$path, [string]$key, [Object]$value){
    #    return $this.isReadOnly;
    #}
    [bool] hidden setKeyValue([string]$path, [string]$key, [Object]$value){
        $result = $false;
        if (!$this.isReadOnly) {
            # ����� ������ ���� �������� isReadOnly = $True
            try
            {
                $r = $this.readSection($path);
                if ($r.code -ne 0)
                {
                    if ($r.code -eq 1) {
                        # ������ ���, ������� ��

                        $result = $true;
                    }
                    elseif ($r.code -eq 2)
                    {
                        # ���� ����, �� ��� �� ������, � ��������
                        throw [System.AccessViolationException]::New('������ �������� $($key) �� ���� $($path), `
                            �.�. ���� �� �������� �������');
                    }
                    else
                    {
                        # ����������� ������
                        throw [System.Exception]::New('�������������� ������ ��� ������ $($key) �� ���� $($path)');
                    }
                }
                # �������� ��������, ���� ������������ key � �� �� ����� ''
                if ($key)
                {
                    # ������ �� ������ 'sec1.sec2.sec3...
                    $arrSections = $path.Split('.', [StringSplitOptions]::RemoveEmptyEntries);
                    $s = '';
                    $arrSections.foreach({
                        $s += "['$( $_ )']";
                        #Invoke-Expression -Command ('$c'+".CFG$s['key1']='value'")
                    });
                    if ($s)
                    {
                        Invoke-Expression -Command ('$this.CFG' + "$s['$( $key )']="+'$value');
                        $result = $true;
                    }
                    #$this.CFG
                }
            }
            catch
            {
                #$this.isExcept($this.errorAsException, "Error write $( $value ) in $( $key ) section $( $path )");
                $result = $false;
                if ($this.errorAsException) {throw $PSItem;};
            }
        }
        return $result;
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

    [Void] saveToFile(){
        $this.saveToFile($this.filename, $false);
    }
    [Void] saveToFile([bool]$isOverwrite){
        $this.saveToFile($this.filename, $isOverwrite);
    }
    [Void] saveToFile([string]$filename, [bool]$isOverwrite){
    }

    [bool] isHashtable([hashtable]$value){
        return ($value -is [Hashtable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary]);
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
    # ������� �� ����� ������.
    # ���� � ����� ������� �������� ��� $($str), "$str2", �� ����� �������� �����
    # ���������, �� �������� powershel, ��� ������ �����.
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
	
    [Void] saveToFile([string]$filename, [bool]$isOverwrite){
        # ��������� ��� �������� � ����� ������.
        if (Test-Path $filename -PathType Container){
            throw "���������� �������� � ����, ��� ��� �� �������� ���������";
        }
        # ��������� ��� ���� � ����� ������ ���� � ���������� ���������.
        if ( (Test-Path $filename -PathType Leaf) -and !$isOverwrite){
            throw "���������� �������� � ����, ��� ��� ���������� ���������";
        }
        $sections=$this.readSection('.');
        #$sections=$this.readSection('.'); # ����������� ���������
        # ��������� ��� ������ ������� �������� ������ CFG
        if ($sections.code -eq 0) {
            # ������� ������ CFG
            $data2file=@();
            $sections=$sections.result;
            foreach ($key in $sections.Keys){
                # ����� ������ ���� � ������ ���� �����
                $cSect = $sections[$key];
                #if ($this.isHashtable($cSect))
                if (
                        ($cSect -is [Hashtable]) -or
                        ($cSect -is [System.Collections.Specialized.OrderedDictionary])
                    )
                {
                    $data2file += "[$($Key)]";
                    $cSect.GetEnumerator() | ForEach-Object { #"{0}={1}" -f $_.key, $_.value }
                        $data2file += "$($_.key)=$($_.value)";

                    }
                }
            }
            # �������� � ����, ���� � ������� ���� ������
            if ($data2file.Count -gt 0) {
                $data2file | Out-File -FilePath $filename -Force -Encoding default;
            }
        } ### ���� ���� ������ � hashtable
    }
} ### class 2
