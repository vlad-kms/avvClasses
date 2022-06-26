<######################################
    [FileCFG]
#######################################>
Class FileCFG {
    [string]$FileName
    [System.Collections.Specialized.OrderedDictionary]$CFG
	[bool]$ErrorAsException = $false
	
    FileCFG(){
        $this.FileName=$PSCommandPath + '.cfg'

        $this.InitFileCFG();
    }
    FileCFG([bool]$EaE){
        $this.FileName=$PSCommandPath + '.cfg'
		$this.ErrorAsException=$EaE

        $this.InitFileCFG();
    }
    FileCFG([string]$FN){
        $this.FileName=$FN;
		
        $this.InitFileCFG();
    }
    FileCFG([string]$FN, [bool]$EaE) {
        $this.FileName=$FN;
		$this.ErrorAsException=$EaE
		
        $this.InitFileCFG();
    }
    
    <#
		Инициализация. Проверить существование файла, считать данные из
		файла в hashtable.
		Exception, если не считали, или объект пустой 
    #>
    [bool]InitFileCFG() {
        $this.IsExcept(!$this.FileName, $true, "Not defined Filename for file configuration.")
        $isFile = Test-Path -Path "$($this.FileName)" -PathType Leaf
        $this.IsExcept(!$isFile, $true, "Not exists file configuration: $($this.FileName)")
	    $this.CFG=$this.ImportInifile($this.FileName)
        $result=($this.CFG.Count -ne 0)
        $this.IsExcept(!$result, "Error parsing file CFG: $($this.FileName)")

        return $result
    }
    
    <##>
    [System.Collections.Specialized.OrderedDictionary]ImportInifile([string]$Filename){
        return [ordered]@{}
    }

    <##>
    [string]IsExcept ([bool]$Value, [string]$Msg) {
        return $this.IsExcept($Value, $this.ErrorAsException, $Msg)
    }

    [string]IsExcept ([bool]$Value, [bool]$EasE, [string]$Msg) {
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
                Если секция не существует, то в зависимости от ErrorAsException, либо пустой список,
                либо формируется Exception
    #>
	[System.Collections.Specialized.OrderedDictionary]ReadSection([string]$Section) {
		$result=[ordered]@{}
        if ( !$this.IsExcept(!$this.CFG.Contains($Section), "Not found section name $($Section)") ) {
            $result = $this.CFG[$Section]
        }
		return $result
	}
    
    <#
        Считать значение ключа, учитывая секцию Default
        Возврат:
            [string] Пустая строка.
    #>
    [string] hidden GetKeyValue([string]$Path, [string]$Key){
        return ''
    }

    [bool] GetBool([string]$Path, [string]$Key){
        return [bool]$this.GetKeyValue($Path, $Key)
    }
    [string] GetString([string]$Path, [string]$Key){
        return $this.GetKeyValue($Path, $Key)
    }
    [Int] GetInt([string]$Path, [string]$Key){
        return [int]$this.GetKeyValue($Path, $Key)
    }
    [long] GetLong([string]$Path, [string]$Key){
        return [long]$this.GetKeyValue($Path, $Key)
    }

}

<######################################
    [IniCFG]
    Объект для работы с файлом форматов ini
#######################################>
Class IniCFG : FileCFG {
    IniCFG() : base() {
#        $this.FileName=$PSCommandPath + '.cfg'
#        $res=$this.InitFileCFG();
    }
    IniCFG([bool]$EaE) : base($EaE) {
#        $this.FileName=$PSCommandPath + '.cfg'
#		$this.ErrorAsException=$EaE
#        $res=$this.InitFileCFG();
    }
    IniCFG([string]$FN) : base($FN) {
#        $this.FileName=$FN;
#        $res=$this.InitFileCFG();
    }
    IniCFG([string]$FN, [bool]$EaE) : base($FN, $EaE) {
#        $this.FileName=$FN;
#		$this.ErrorAsException=$EaE
        $res=$this.InitFileCFG();
    }

    <#
        Считать из файла данные
	#>
    [System.Collections.Specialized.OrderedDictionary]ImportInifile([string]$Filename){
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
	
    <#
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
    #>
    [string] hidden GetKeyValue([string]$Path, [string]$Key){
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
        return $Result
    }

}
