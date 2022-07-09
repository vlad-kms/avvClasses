<#
# ����� FileCFG ������� �����. ��� �� ���� ����������.
# ����� ���������, ����������, ��������� �����, ��������, ������.
# ��� ������ ��������� ������� ���������� �������� isReadOnly � $False.
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
    par1="$($ExtParams.Token)"
    par1="$ExtParams"
    ke="1+3"
    kf=$(2+1*3) - ����� ���������� �������������� ���������
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
# ���� ����������� ��� �������� �� Hashtable. ������� ������ ����������� ����� (+) � CFG.
# � ����� ini ����� �������������� ����������. ������� � ������ [dns_cli] ����. ����������
# ������������� ��� ������ Invoke-Expression.
# ����� � ����� ������������ ����������� � ������ ����.
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
# ****** class JsonCFG  ************************************
# ��� ���� �����, ������� � ������ � ������� �������� �����, � ������ Json.
# ��������� ����������, ������� ����������� �������������� ��-�� ��������� ������.
#>

<######################################
    [FileCFG]
������� ���������� Java
#######################################>
Class FileCFG {
    [string]$filename           ='';
    [Hashtable]$CFG             =[ordered]@{};
	[bool]$errorAsException     =$false;
    [bool] hidden $isReadOnly   =$true;
    [bool] hidden $isOverwrite  =$false;

    <#################################################
    #   Constructors
    #################################################>
    FileCFG(){
        $this.filename=$PSCommandPath + $this.getExtensionForClass();
        $this.initFileCFG();
    }
    FileCFG([bool]$EaE){
        $this.filename=$PSCommandPath + $this.getExtensionForClass();
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

    FileCFG([string]$FN, [bool]$EaE, [Hashtable]$CFG) {
        $FN = '_empty_';
        $this.filename = $FN;
        $this.errorAsException = $EaE
        $this.initFileCFG();
        $this.CFG += $CFG;
    }
    FileCFG([Hashtable]$CFG) {
        $this.CFG += $CFG;
    }
    FileCFG([Hashtable]$CFG, [bool]$EaE) {
        $this.CFG += $CFG;
        $this.errorAsException = $EaE
    }

    [String] getExtensionForClass()
    {
        $type = $this.GetType();
        if (($type.Name.ToUpper() -eq "JsonCFG".ToUpper()))
        {
            $res = '.json';
        }
        elseif ($type.Name.ToUpper() -eq "INICFG".ToUpper())
        {
            $res = '.ini';
        }
        else
        {
            $res = '.cfg';
        }
        return $res;
    }
    <#
	#	�������������. ��������� ������������� �����, ������� ������ ��
	#	����� � hashtable. ���� ��� ����� = '_empty_', �� ������� ������.
	#	Exception, ���� �� �������, ��� ������ ������
    #>
    [bool]initFileCFG() {
        $result=$false;
        if ($this.filename.ToUpper() -ne '_EMPTY_' )
        {
            # $this.filename != '_empty_';
            #$this.isExcept(!$this.filename, $true, "Not defined Filename for file configuration.");
            $this.isExcept(!$this.filename, "Not defined Filename for file configuration.");
            $isFile = Test-Path -Path "$($this.filename)" -PathType Leaf;
            #$this.isExcept(!$isFile, $true, "Not exists file configuration: $($this.filename)");
            $this.isExcept(!$isFile, "Not exists file configuration: $($this.filename)");
	        $this.CFG=$this.importInifile($this.filename);
            $result=$this.CFG.Count;
            #$this.isExcept(!$result, "Error parsing file CFG: $($this.filename)")
        }
        return $result;
    }
    
    [Hashtable]importInifile([string]$filename){
        return [ordered]@{}
    }

    [string]isExcept ([bool]$Value, [string]$Msg) {
        return $this.isExcept($Value, $this.errorAsException, $Msg)
    }

    [string]isExcept ([bool]$value, [bool]$EasE, [string]$msg) {
        if ( $EasE -and $value ) {
            throw($msg)
        }
        if ($value) {return $msg} else {return ""}
    }

	<######################### readSection ############################################
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
                #if ( ($path[$_] -is [Hashtable]) -or
                #     ($path[$_] -is [System.Collections.Specialized.OrderedDictionary])
                #    )
                if ($this.isHashtable($path[$_]))
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
        #if (!($path -is [Hashtable]) -and
        #        !($path -is [System.Collections.Specialized.OrderedDictionary])
        #    )
        if (!($this.isHashtable($path)) )
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

    ########################## setKeyValue ################################
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

    <################################## getKeyValue ##########################################
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

    ################## saveToFile ###########################
    [Void] saveToFile(){
        $this.saveToFile($this.filename, $this.isOverwrite);
    }
    [Void] saveToFile([bool]$isOverwrite){
        $this.saveToFile($this.filename, $isOverwrite);
    }
    [Void] saveToFile([string]$filename){
        $this.saveToFile($filename, $this.isOverwrite);
    }
    [Void] saveToFile([string]$filename, [bool]$isOverwrite){
    }

    ################## isHashtable ###########################
    [bool] isHashtable($value){
        #return ($value -is [Hashtable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary]);
        return ($value -is [System.Collections.IDictionary]);
    }

    ################## toJson ###########################
    [String] ToString(){
        return $this.ToJson();
    }
    [String] ToJson() {
        return ($this | ConvertTo-Json -Depth 100);
    }
}

###################################################################################################################
#    [IniCFG]
#    ������ ��� ������ � ������ �������� ini
###################################################################################################################
Class IniCFG : FileCFG {
    IniCFG() : base() {
    }
    IniCFG([bool]$EaE) : base($EaE) {
    }
    IniCFG([string]$FN) : base($FN) {
    }
    IniCFG([string]$FN, [bool]$EaE) : base($FN, $EaE) {
    }
    IniCFG([string]$FN, [bool]$EaE, [Hashtable]$CFG) {#} : base("_empty_", $EaE, $CFG) {
        if ($this.isHashtable($CFG)) { $FN = '_empty_'; }
        $this.filename = $FN;
        $this.errorAsException = $EaE
        $this.initFileCFG();
        if ($this.isHashtable($CFG)) { $this.CFG += $CFG; }
    }

    ###############################################################################
    # ������� �� ����� ������.
    # ������ [name] (SECTION) ������������� ��� ������ section. �.�. � [hashtable] ����������� ���
    # ���������� [hashtable]. 1-� ������� � switch
    # ������ ���� name=value (PARAMETER) ������������� ��� �������� � ������ key=value.
    # �.�. ����������� ��� ��������(����) � [hashtable][section]. 2-� ������� � switch
    # ������ ������������ � ';' ,'#', '*' (COMMENT) �� ��������������,
    # �.�. ���������� ��� ������������.  3-� ������� � switch
    #
    # ���� � ������ ���� PARAMETER ������� �������� (value) ��� '$($str)', '"$str2"', �� ����� �������� �����
    # ���������, �� �������� powershel, ��� ������ �����. �������� � ����� ���� key1="nameVariable",
    # ��� ��������� �n� ������ ����� ���������, ���� � ������� ���� ���������� � ��� � ������� ��������� global
    # ��� ������� ������ (������)
    # $nameVariable=valueVariable. ���� ���������� ���, �� ����� �����.
    # �� � [hashtable][$section][$key] ����� ��������� �������� valueVariable.
	###############################################################################
    [Hashtable]importInifile([string]$filename){
        $iniObj = [ordered]@{}
        $this.isExcept(!$filename, "Not defined Filename for file configuration.")
        $isFile = Test-Path -Path "$($filename)" -PathType Leaf
        $this.isExcept(!$isFile, "Not exists file configuration: $($filename)")
        if ($isFile)
        {
            # ���� ���� ���������� � �� �� �������.
            $section = ""
            switch -regex -File $filename
            {
                "^\[(.+)\]$" {
                    # ������ ����:
                    # [name]
                    $section = $matches[1]
                    $iniObj[$section] = [ordered]@{ }
                    #Continue
                }
                "(?<key>^[^\#\;\=]*)[=?](?<value>.+)" {
                    # ������ ����:
                    # name=value, name=$(value), name="value",
                    # ��� value - ����������� ���������, ���������� �������
                    $key = $matches.key.Trim()
                    $value = $matches.value.Trim()

                    if (($value -like '$(*)') -or ($value -like '"*"'))
                    {
                        $value = Invoke-Expression $value
                    }
                    if ($section)
                    {
                        $iniObj[$section][$key] = $value
                    }
                    else
                    {
                        $iniObj[$key] = $value
                    }
                    continue
                }
                "(?<key>^[^\#\;\=]*)[=?]" {
                    # ������ ����:
                    # name=
                    # �.�. ������
                    $key = $matches.key.Trim()
                    if ($section)
                    {
                        $iniObj[$section][$key] = ""
                    }
                    else
                    {
                        $iniObj[$key] = ""
                    }
                }
            } ### switch -regex -File $IniFile {
        } ## if ($isFile)
        return $iniObj
    }
	
    [Void] saveToFile([string]$filename, [bool]$isOverwrite){
        # ���� $this.filename = '_empty_' ��� ������ ������, �� �����
        if (!$filename -or ($filename.ToUpper() -eq '_empty_'.ToUpper() ))
        {
            return;
        }
        # ��������� ��� �������� � ����� ������ ���.
        if (Test-Path $filename -PathType Container){
            $msg = $this.isExcept($true, "���������� �������� � ����, ��� ��� �� �������� ���������");
            Write-Host $msg;
            return;
            #throw "���������� �������� � ����, ��� ��� �� �������� ���������";
        }
        # ��������� ��� ���� � ����� ������ ���� � ���������� ���������.
        if ( (Test-Path $filename -PathType Leaf) -and !$isOverwrite){
            $msg = $this.isExcept($true, "���� ����������, � ���������� ���������");
            Write-Host $msg;
            return;
            #throw "���������� �������� � ����, ��� ��� ���������� ���������";
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
                if ($this.isHashtable($cSect))
                #if (
                #        ($cSect -is [Hashtable]) -or
                #        ($cSect -is [System.Collections.Specialized.OrderedDictionary])
                #    )
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
}

###################################################################################################################
#    [JsonCFG]
#    ������ ��� ������ � ������ �������� json
###################################################################################################################
class JsonCFG : FileCFG
{
    JsonCFG(): base()
    {
    }
    JsonCFG([bool]$EaE): base($EaE)
    {
    }
    JsonCFG([string]$FN): base($FN)
    {
    }
    JsonCFG([string]$FN, [bool]$EaE): base($FN, $EaE)
    {
    }
    JsonCFG([string]$FN, [bool]$EaE, [Hashtable]$CFG)
    {
        if ($this.isHashtable($CFG)) { $FN = '_empty_'; }
        $this.filename = $FN;
        $this.errorAsException = $EaE
        $this.initFileCFG();
        if ($this.isHashtable($CFG)) { $this.CFG += $CFG; }
    }

    [Hashtable]
    importInifile([string]$filename)
    {
        $iniObj = [ordered]@{}
        if ($filename -or ($filename.ToUpper() -ne "_empty_".ToUpper()) )
        {
            # filename �� ������ � �� ����� '_empty'
            #$majV = $avvVersion.Major;
            $json = (Get-Content -Path $filename -Raw);
            #$json = ( (Get-Content -Path $filename -Raw) | ConvertFrom-JsonToHashtable -casesensitive );
            $majV = (Get-Version).PSVersion.Major;
            if ($majV -ge 6) {
                $iniObj = ( $json | ConvertFrom-Json -AsHashtable);
            }
            else
            {
                $iniObj = ($json | ConvertFrom-Json | ConvertJsonToHash );
            }
        }
        return $iniObj;
    }

    [Void]
    saveToFile([string]$filename, [bool]$isOverwrite)
    {
        # ���� $this.filename = '_empty_' ��� ������ ������, �� �����
        if (!$filename -or ($filename.ToUpper() -eq '_empty_'.ToUpper() ))
        {
            return;
        }
        # ��������� ��� �������� � ����� ������ ���.
        if (Test-Path $filename -PathType Container){
            $msg = $this.isExcept($true, "���������� �������� � ����, ��� ��� �� �������� ���������");
            Write-Host $msg;
            return;
            #throw "���������� �������� � ����, ��� ��� �� �������� ���������";
        }
        # ��������� ��� ���� � ����� ������ ���� � ���������� ���������.
        if ( (Test-Path $filename -PathType Leaf) -and !$isOverwrite){
            $msg = $this.isExcept($true, "���� ����������, � ���������� ���������");
            Write-Host $msg;
            return;
            #throw "���������� �������� � ����, ��� ��� ���������� ���������";
        }
        # ��� ����� ������
        $this.CFG | ConvertTo-JSON -Depth 100 | Set-Content -Path $filename;
    }
}
