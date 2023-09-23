using module '.\avvBase.ps1';
#using module "D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1";
#. "D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1";

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
    [_always_]
    param1=value1
    param2=value2
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
# ���� ������� ������ [_always_], �� �������� ����� ����������� �� ��������:
# ����������� ��� ����� [default] � �������� ��� ��� ���� �� �����, �.�.
# ������ [_always_] �������������� ��� ��������� ���������.
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
#. .\avvBase.ps1

Class FileCFG : avvBase {
    [string] $filename      ='';
    [Hashtable] $CFG        =[ordered]@{};
    [bool] $errorAsException=$false;
    [bool] $isReadOnly      =$true;
    [bool] $isOverwrite     =$false;
    [bool] $isDebug         =$false;
    [String]hidden $currentSection ='.';

    <#################################################
    #   Constructors
    #################################################>
    FileCFG(){
        $this.filename=$PSCommandPath + $this.getExtensionForClass();
        $this.initFileCFG();
    }
    FileCFG([bool]$EaE){
        $this.filename=$PSCommandPath + $this.getExtensionForClass();
        #$this.errorAsException=$EaE
        $this.errorAsException=$EaE
        $this.initFileCFG();
    }
    FileCFG([string]$FN){
        $this.filename=$FN;
        $this.initFileCFG();
    }
    FileCFG([string]$FN, [bool]$EaE) {
        $this.filename=$FN;
        #$this.errorAsException=$EaE
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
    FileCFG([Hashtable]$CFG) : base ($CFG){
        # �������� hashtable:
        #   @{
        #       '_obj_'           =@{} - �������� ��� ������� ������� �������� ������
        #       '_obj_add_'       =@{} - �������� ��� ������� ������� �������� ������
        #       '_obj_add_value_' =@{} - �������� ��� ������� ������� �������� ������
        #       '_cfg_'=@{}     - �������� ��� ���� CFG, �������� ��������� �� �����
        #       '_cfg_add'=@{}  - �������� ��� ���� CFG, ����������� � ��������� �� �����
        #   }
        if (! $this.filename)
        {
            $this.filename = '_empty_';
        }
        $this.initFileCFG();
        $keyCurrent='cfg';
        if ($CFG.Contains($keyCurrent) -and
                ($null -ne $CFG.$keyCurrent) -and
                ($CFG.$keyCurrent -is [Hashtable])
            )
        {
            $this.CFG = $CFG.$keyCurrent;
        }
        $keyCurrent='cfg_add';
        if ($CFG.Contains($keyCurrent) -and
                ($null -ne $CFG.$keyCurrent) -and
                ($CFG.$keyCurrent -is [Hashtable])
            )
        {
            $this.CFG += $CFG.$keyCurrent;
        }
    }

    <#################################################
    #   MEMBERS
    #################################################>
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
    #   �������������. ��������� ������������� �����, ������� ������ ��
    #   ����� � hashtable. ���� ��� ����� = '_empty_', �� ������� ������.
    #   Exception, ���� �� �������, ��� ������ ������
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
        $this.currentSection = '.';
        return [ordered]@{}
    }

    [string]isExcept ([bool]$Value, [string]$Msg) {
        return $this.isExcept($Value, $this.errorAsException, $Msg)
    }

    [string]isExcept ([bool]$value, [bool]$EasE, [string]$msg) {
        if ( $EasE -and $value ) {
            throw($msg)
        }
        if ($value)
        {
            if ($this.isDebug) { $msg | Out-Host; }
            return $msg;
        } else { return ""; }
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
    [String]
    normalizeSection ([String]$section)
    {
        $result = $section.trim();
        if (!$result) { $result = '.'; }
        $isRoot = $false;
        #while ( !$result -or ($result.Substring(0, 1) -eq '\') -or ($result.Substring(0, 1) -eq '/'))
        while ( !$result -or $result.StartsWith('\') -or $result.StartsWith('/'))
        {
            $isRoot = $true;
            $result = $result.Substring(1, $result.Length -1);
        }
        if (!$isRoot)
        {
            $result = $this.currentSection + '.' + $result;
        }
        #while (($result.Substring(0, 1) -eq '\') -or ($result.Substring(0, 1) -eq '/'))
        while ( $result.StartsWith('\') -or $result.StartsWith('/'))
        {
            $result = $result.Substring(1, $result.Length -1);
        }
        return $result;
    }

    [Hashtable]readSection([string]$section) {
        $result = @{};
        $code = 0;
        # ������ �� ������ 'sec1.sec2.sec3...
        $section = $this.normalizeSection($section);
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
        if ( !$this.isHashtable($path) )
        {
            # ��������� ������� � ���� �� �������� [Hashtable]
            $path = $null;
            $code = 2;
        }
        if ( $code -ne 0 ) { $path = $null; }
        # ���� � ������ ��� �������� � $this.ErrorAsException � $code <> 0, �� �������� Exception
        !$this.isExcept( ($path.Keys.Count -eq 0) -and ($code -ne 0), "Not found section name $($section) or is not Section type");
        $result = @{
            'code'=$code;
            'result'=$path;
        }
        # ������ � ������������ ���������� � ������ ������ [default] [_always_]
        $pathDefs=[ordered]@{};
        while ($section.StartsWith('.')) { $section=$section.Substring(1, $section.Length-1) }
        $path.Keys.foreach({
            $pathDefs.Add($_, $this.getKeyValueUseDefaultAlways($path, $section, $_))
        });
        $result.Add('resultDefs', $pathDefs)
        <# �� ����
        # ������ � ������������ ���������� � ������ ������ [default] [_always_]
        # � � ������������ ������� �� ������ default ���� section_key, section.key,
        # ������� ��� � ������ section
        $pathDefsOnly=[ordered]@{};

        $result.Add('resultDefsOnly', $pathDefsOnly)
        #>
        return $result;
    }
    
    [hashtable] getSectionValues([String]$path, $section)
    {
        if ($section) { $path += ".$($section)"}
        return $this.readSection($path);
    }

    [hashtable] getSectionValues([String]$path)
    {
        return $this.getSectionValues($path, '');
    }

    [hashtable] getSection([String]$path, $section)
    {
        if ($section) { $path += ".$($section)"}
        $res = $this.readSection($path);
        if ($res.code -eq 0) { return $res.result; }
        else { return $null; }
    }
   
    [hashtable] getSection([String]$path)
    {
        return $this.getSection($path, '');
    }
<#
    [hashtable] getSectionProcessedKeys([String]$Path, $section)
    {
        result= @{};
        $readSection=$this.getSection($path, $section);

        return $result
    }

    [hashtable] getSectionProcessedKeys([String]$Path)
    {
        return $this.getSectionProcessedKeys($path, '');
    }
#>
    [hashtable] addSection([string]$path, [string]$section){
        $result = $null;
        if ($this.isReadOnly) { return $result; }
        $res = $true;
        # ��������� ������ ������� � path �
        # ���� �� ���� � �� hashtable
        #   �� �������� � �������
        # ���� �� ���� � hashtable
        #   �� ������� � ���������� ��������
        # ���� ��� ���
        #   �� ������� � ������� � ����������, ���� ��� �������� �� ���� ������
        $path = $this.normalizeSection($path);
        $arrPath = $path.Split('.', [StringSplitOptions]::RemoveEmptyEntries);
        $currentPath = $this.CFG;
        $arrPath.foreach({
            if ( $currentPath.Contains($_) -and $this.isHashtable($currentPath["$_"]) )
            {
                # ����� ��������� ������� ����
                $currentPath = $currentPath["$_"];
                $res = $true;
            }
            elseif (!$currentPath.Contains($_))
            {
                # ������� ����� ���� ���� hashtable
                $currentPath.add($_, @{});
                # ����� ��������� ������� ����
                $currentPath = $currentPath["$_"];
                $res = $true;
            }
            elseif ( $currentPath.Contains($_) -and !$this.isHashtable($currentPath["$_"]) )
            {
                $res = $False;
                $this.isExcept(!$result, "���������� ������� ������ �� ������� ���� $($path). ��� ���� ���� � ����� ������.");
            }
            else
            {
                $res = $False;
                $this.isExcept(!$result, "�������������� ������ ��� �������� ������ �� ������� ���� $($path).");
            }
        })
        # $result= $True, ���� ���� �������� ��� �������� ����� ������,
        if ($res)
        {
            # ��������� ��� �� ����� � ������ ������ � ����� ������ $section
            # ���� ���, �� ������� ����� ������ $section,
            # ����� Exception
            if (!$section)
            {
                $result = $currentPath;
            }
            elseif ( !$currentPath.Contains($section))
            {
                #������� ������
                $currentPath.add($section, @{});
                $result = $currentPath["$section"];
            }
            elseif ($currentPath.Contains($section) -and $this.isHashtable($currentPath["$section"]))
            {
                $result = $currentPath["$section"];
            }
            else #if ( $currentPath.Contains($section) -and !$this.isHashtable($currentPath["$section"]) )
            {
                $result = $null;
                $this.isExcept(($null -eq $result), "���������� ������� ������ �� ������� ���� $($path). ��� ���� ���� � ����� ������.");
            }
        }
        return $result;
    }
    [hashtable] addSection([string]$path)
    {
        return $this.addSection([string]$path, '');
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
    [bool]  setKeyValue([string]$path, [string]$key, [Object]$value){
        $result = $false;
        $currentPath = $null;
        if (!$this.isReadOnly) {
            # ����� ������ ���� �������� isReadOnly != $True
            $r = $this.readSection($path);
            if ($r.code -ne 0)
            {
                if ($r.code -eq 1) {
                    # ������ ���, ������� ��
                    $currentPath = $this.addSection($Path, '');
                    $result = $true;
                }
                elseif ($r.code -eq 2)
                {
                    # ���� ����, �� ��� �� ������, � ��������
                    $this.isExcept($true,'������ �������� $($key) �� ���� $($path), �.�. ���� �� �������� �������');
                    $result = $false;
                }
                else
                {
                    # ����������� ������
                    $this.isExcept($true, '�������������� ������ ��� ������ $($key) �� ���� $($path)');
                    $result = $false;
                }
            }
            else
            {
                $currentPath = $r.result;
                $result = $true;
            }
            # �������� ��������, ���� ������������ key � �� �� ����� ''
            if ($key -and $result)
            {
                $currentPath["$key"] = $value
                $result = $true;
            }
        }
        return $result;
    }
    [bool] setString([string]$path, [string]$key, [string]$value)
    {
        return $this.setKeyValue($path, $key, $value);
    }
    [bool] setInt([string]$path, [string]$key, [Int]$value)
    {
        return $this.setKeyValue($path, $key, $value);
    }

    <# ============================================================ #>
    [Object]hidden getKeyValueUseDefaultAlways([hashtable]$section, [string]$path, [string]$key)
    {
        $result=''
        if ($section.Contains($key) -and $section[$key])
        {
            $result=$section[$key]
        }
        else
        {
            # ��� � ������ $section ����� $Key 
            # ����� �������� �������� �� ������ default
            if ($this.CFG.default.Contains($key)) {
                $result=$this.CFG.default[$key]
            }
            if ($this.CFG.default["${Path}_${key}"]) {
                $result=$this.CFG.default["${Path}_${key}"]
            }
            if ($this.CFG.default["${Path}.${key}"]) {
                $result=$this.CFG.default["${Path}.${key}"]
            }
        }
        # ��������� ������ [_always_]
        if ($this.CFG.Contains('_always_') -and $this.isHashtable($this.CFG['_always_'])) {
            if ($this.CFG['_always_'].Contains($key))
            {
                $result = $this.CFG['_always_'][$key];
            }
            if ($this.CFG['_always_'].Contains("${Path}_${key}")) {
                $result = $this.CFG['_always_']["${Path}_${key}"];
            }
            if ($this.CFG['_always_'].Contains("${Path}.${key}")) {
                $result = $this.CFG['_always_']["${Path}.${key}"];
            }
        }
        $this.isExcept($result.Length -eq 0, "Not found key $($key) in section name $($path)");
        try
        {
            if ( ($result.gettype() -eq ''.gettype()) -and ($result.ToUpper() -eq '_empty_'.ToUpper()) ) { $result='' }
        }
        catch
        {
            $result=''
        };

        return $result;
    }
    <################################## getKeyValue ##########################################
    ������� �������� �����, �������� ������ default
    ����:
        [string]$Path - ��� ������
        [string]$Key  - ��� �����
    �������:
        [string] �������� �����.
                 ���� ������ $Path �����������, �� ""
                 ���� ���� ���� � ��������� ������, �� ������������ �������� ����� �����.
                 ���� ����� ��� � ��������� ������, �� ������� ����� �� ������ [default]
                 ���� ����� ��� �� � ��������� ������, �� � ������ [default], �� ������� ""
                 ���� �������� ����� = _empty_, �� ������ ������ ������ ''
    ###############################################################################>
    [Object]hidden getKeyValue([string]$path, [string]$key)
    {
        $result=''
        <#
        $res = $this.readSection($path);
        if ($res.code -ne 0 ) {
            return $result
        }
        $section = $res.result;
        #>
        $section = $this.getSection($path, '');
        if ($null -eq $section) { return $result; }
        $result = $this.getKeyValueUseDefaultAlways($section, $path, $key)
<#
        if ($section.Contains($key) -and $section[$key])
        {
            $result=$section[$key]
        }
        else
        {
#>
            <#
                ��� � ������ $section ����� $Key 
                ����� �������� �������� �� ������ default
            #>
<#
            if ($this.CFG.default.Contains($key)) {
                $result=$this.CFG.default[$key]
            }
            if ($this.CFG.default["${Path}_${key}"]) {
                $result=$this.CFG.default["${Path}_${key}"]
            }
            if ($this.CFG.default["${Path}.${key}"]) {
                $result=$this.CFG.default["${Path}.${key}"]
            }
        }
        # ��������� ������ [_always_]
        if ($this.CFG.Contains('_always_') -and $this.isHashtable($this.CFG['_always_'])) {
            if ($this.CFG['_always_'].Contains($key))
            {
                $result = $this.CFG['_always_'][$key];
            }
            if ($this.CFG['_always_'].Contains("${Path}_${key}")) {
                $result = $this.CFG['_always_']["${Path}_${key}"];
            }
            if ($this.CFG['_always_'].Contains("${Path}.${key}")) {
                $result = $this.CFG['_always_']["${Path}.${key}"];
            }
        }
        $this.isExcept($result.Length -eq 0, "Not found key $($key) in section name $($path)");
        try
        {
            if ( ($result.gettype() -eq ''.gettype()) -and ($result.ToUpper() -eq '_empty_'.ToUpper()) ) { $result='' }
        }
        catch
        {
            $result=''
        };
#>
        return $result;
    }
    [bool] getBool([string]$path, [string]$key)
    {
        return [bool]$this.getKeyValue($path, $key)
    }
    [string] getString([string]$path, [string]$key)
    {
        return [String]$this.getKeyValue($path, $key)
    }
    [Int] getInt([string]$path, [string]$key)
    {
        return  [int]$this.getKeyValue($path, $key)
    }
    [long] getLong([string]$path, [string]$key)
    {
        return [long]$this.getKeyValue($path, $key)
    }

    ################## saveToFile ###########################
    [Void] saveToFile()
    {
        $this.saveToFile($this.filename, $this.isOverwrite);
    }
    [Void] saveToFile([bool]$isOverwrite)
    {
        $this.saveToFile($this.filename, $isOverwrite);
    }
    [Void] saveToFile([string]$filename)
    {
        $this.saveToFile($filename, $this.isOverwrite);
    }
    [Void] saveToFile([string]$filename, [bool]$isOverwrite)
    {
    }

    ################## isHashtable ###########################
    [bool] isHashtable($value)
    {
        #return ($value -is [Hashtable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary]);
        return ($value -is [System.Collections.IDictionary]);
    }

    ################## toJson ###########################
    [String] ToString()
    {
        return $this.ToJson();
    }
    [String] ToJson()
    {
        return ($this | ConvertTo-Json -Depth 100);
    }
    [String] ToJson([string]$path)
    {
        return ($this.getSection($path) | ConvertTo-Json -Depth 100);
    }
}


### +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#    [IniCFG]
#    ������ ��� ������ � ������ �������� ini
### +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Class IniCFG : FileCFG {
    IniCFG() : base()
    {
    }
    IniCFG([bool]$EaE) : base($EaE)
    {
    }
    IniCFG([string]$FN) : base($FN)
    {
    }
    IniCFG([string]$FN, [bool]$EaE) : base($FN, $EaE)
    {
    }
    IniCFG([Hashtable]$CFG) : base($CFG)
    {
    }
    IniCFG([string]$FN, [bool]$EaE, [Hashtable]$CFG): base($FN, $EaE, $CFG)
    {
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
        ([FileCFG]$this).importInifile($filename);
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
        $nameRootSection = '__root__';
        if ($sections.code -eq 0) {
            # ������� ������ CFG
            $data2file=@{
                "$nameRootSection"=@()
            };
            $sections=$sections.result;
            foreach ($key in $sections.Keys){
                # ���� �� ���� ������
                # �������� �������� �����
                $cSect = $sections[$key];
                if ($this.isHashtable($cSect))
                #if (
                #        ($cSect -is [Hashtable]) -or
                #        ($cSect -is [System.Collections.Specialized.OrderedDictionary])
                #    )
                {
                    # ���� ��� �������� �������� ����� ���� Hashtable
                    #$data2file[$key] += "[$($Key)]";
                    $data2file[$key] = @()
                    $cSect.GetEnumerator() | ForEach-Object { #"{0}={1}" -f $_.key, $_.value }
                        $data2file[$key] += "$($_.key)=$($_.value)";
                    }
                }
                else {
                    # ���� ��� �������� �������� ����� �� Hashtable,
                    # �.�. ������ ����=��������
                    $data2file.$nameRootSection += "$($key)=$($cSect)";
                }
            }
            # �������� � ����, ���� � ������� ���� ������
            <#
            if ($data2file.Count -gt 0) {
                $data2file | Out-File -FilePath $filename -Force -Encoding default;
            }
            #>
            # �������� � ����
            $df = @();
            $data2file.$nameRootSection.foreach({
                $df += $_;
            })
            #if ($df.count -ne 0) { $df += ''; }
            foreach ( $key in $data2file.Keys) {
                #Write-Host $key;
            #
                if ($key -ne $nameRootSection) {
                    $df += '';
                    $df += "[$($key)]";
                    $data2file["$key"].foreach({
                        $df += $_;
                    })
                }
                ###$df += $_;
            #
            }
            $df | Out-File -FilePath $filename -Force -Encoding default;
        } ### ���� ���� ������ � hashtable
    }
}

### +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#    [JsonCFG]
#    ������ ��� ������ � ������ �������� json
### +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
    JsonCFG([Hashtable]$CFG) : base($CFG) {
    }
    JsonCFG([string]$FN, [bool]$EaE, [Hashtable]$CFG) : base ($FN, $Eae, $CFG)
    {
        <#
        if ($this.isHashtable($CFG)) { $FN = '_empty_'; }
        $this.filename = $FN;
        $this.errorAsException = $EaE
        $this.initFileCFG();
        if ($this.isHashtable($CFG)) { $this.CFG += $CFG; }
        #>
    }

    [Hashtable]
    importInifile([string]$filename)# : base($filename)
    {
        ([FileCFG]$this).importInifile($filename);
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
