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
		Инициализация. Проверить существование файла, считать данные из
		файла в hashtable.
		Exception, если не считали, или объект пустой 
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
        Считать секцию
        Возврат:
            [System.Collections.Specialized.OrderedDictionary]
                Список ключей и значений из секции.
                Если секция не существует, то в зависимости от errorAsException, либо пустой список,
                либо формируется Exception
    #>
	[System.Collections.Specialized.OrderedDictionary]readSection([string]$Section) {
		$result=[ordered]@{}
        if ( !$this.isExcept(!$this.CFG.Contains($Section), "Not found section name $($Section)") ) {
            $result = $this.CFG[$Section]
        }
		return $result
	}
    
    <#
        Считать значение ключа, учитывая секцию Default
        Возврат:
            [string] Пустая строка.
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

    <###############################################################################
        Считать из файла данные
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
        Считать значение ключа, учитывая секцию Default
        Вход:
            [string]$Path - имя секции
            [string]$Key  - имя ключа
        Возврат:
            [string] Значение ключа.
                     Если секция $Path отсутсвует, то ""
                     Если ключ есть в требуемой секции, то возвращается значение этого ключа.
                     Если ключа нет в требуемой секции, то возврат ключа из секции [Default]
                     Если ключа нет ни в требуемой секции, ни в секции [Default], то возврат ""
                     Если значение ключа = _empty_, то вернет пустую строку ''
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
