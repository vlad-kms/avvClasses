<######################################
    [FileCFG]

Парвила именования Java
#######################################>
Class FileCFG {
    [string]$filename=''
    #[System.Collections.Specialized.OrderedDictionary]$CFG
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
		Инициализация. Проверить существование файла, считать данные из
		файла в hashtable.
		Exception, если не считали, или объект пустой 
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
    [System.Collections.Specialized.OrderedDictionary]importInifile([string]$filename){
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
        Считать секцию
        Возврат:
            [System.Collections.Specialized.OrderedDictionary]
                Список ключей и значений из секции.
                Если секция не существует, то в зависимости от errorAsException, либо пустой список,
                либо формируется Exception
    #>
	#[System.Collections.Specialized.OrderedDictionary]readSection([string]$section) {
    [Hashtable]readSection([string]$section) {
		$result=@{};
        $arrSections = $section.Split('.', [StringSplitOptions]::RemoveEmptyEntries);
        $sectionName = '';
        try
        {
            $path = $this.CFG;
            $i = 0;
            $arrSections.ForEach({
                $sectionName = $_;
                if ($path.Contains($_))
                {
                    $path = $path[$_];
                }
                else
                {
                    $path = @{};
                    #$sectionName = $_;
                    #Break;
                }
            });
            if (!($path -is [Hashtable]))
            {
                $path = @{};
            }
            $path.Keys.foreach({
                $result.Add("$_", $path[$_]);
            });
            #$result += @{"$sectionName"=$path};
        }
        catch
        {
            throw;
        }
        <#
        if ( !$this.isExcept(!$this.CFG.Contains($section), "Not found section name $($section)") ) {
            $result = $this.CFG[$section];
        }
        #>
		return $result;
	}
    
    <#
        Считать значение ключа, учитывая секцию default
        Возврат:
            [string] Пустая строка.
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
    Объект для работы с файлом форматов ini
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
        Считать из файла данные
	###############################################################################>
    [System.Collections.Specialized.OrderedDictionary]importInifile([string]$filename){
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
                    # в INI могут использоваться переменные (команды) из скрипта 
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
        Считать значение ключа, учитывая секцию default
        Вход:
            [string]$Path - имя секции
            [string]$Key  - имя ключа
        Возврат:
            [string] Значение ключа.
                     Если секция $Path отсутсвует, то ""
                     Если ключ есть в требуемой секции, то возвращается значение этого ключа.
                     Если ключа нет в требуемой секции, то возврат ключа из секции [default]
                     Если ключа нет ни в требуемой секции, ни в секции [default], то возврат ""
                     Если значение ключа = _empty_, то вернет пустую строку ''
    ###############################################################################>
    [Object]hidden getKeyValue([string]$path, [string]$key){
        $result=''
        if ($this.CFG.Contains($path)){
            $section = $this.CFG[$path]
            if ($section.Contains($key) -and $section[$key]) {
                $result=$section[$key]
            } else {
                try{
                    $result=$this.CFG.default[$key]
                }
                catch {
                    $Result=""
                }

            }
        }
        if ($result -eq '_empty_') { $result='' }
        return $result
    }
}
