<#
# Класс FileCFG базовый класс. Сам по себе бесполезен.
# Класс IniCFG для работы с файлами .ini. Содержимое файла загружается в Hashtable.
# Секции это ключи первого уровня, создаются из имен секций. Значения параметров секции
# пишутся как ключи и значения в Hashtable. Если имя файла переданное в конструктор = '_empty_',
# то инициализацию из файла пропустить, т.е. CFG после конструктора будет @{}
# Например:
ФАЙЛ ini
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
# Если имеется секция [default], то значение ключа формируется по правилам
# Если в секции нет ключа, а в [default] есть, значение берется из [default].
# Если в секции есть ключ, неважно есть или нет в [default], значение берется из секции,
# кроме случая, если значение в секции = '_empty_', значение берется из [default].
# В отличии от классического ini, есть поддержка вложенных Hashtable'ов.
# TODO Пока нет чтения такого объекта из файла. Потом сделать для JSON. Новый класс наследовать от FileCFG
# TODO заменив соответствующие методы
# Есть конструктор для создания из Hashtable. Входной объект добавляется через (+) в CFG.
# Здесь и можно использовать вложенность.
# Поле ErrorAsException если True, то при чтении если нет ключа, ошибка преобразования в тип и т.д.
# преобразуется в Exception, иначе возвращается пустая строка.
# Функции:
#   [Hashtable]readSection([string]$section) - считать секцию.
#       Выход: @{
#                   code: 0 - секция есть и ее считали
#                   result: - считанная секция, т.е. ее ключи и значения
#               }
# Следующие методы считывают ключ в заданной секции. get<Type> работают через getKeyValue,
# просто преобразуя результат в требуемый тип
#   [Object] hidden getKeyValue([string]$path, [string]$key)
#   [bool] getBool([string]$path, [string]$key){
#   [string] getString([string]$path, [string]$key){
#   [Int] getInt([string]$path, [string]$key){
#   [long] getLong([string]$path, [string]$key){
#   saveToFile([string]$filename, [bool]$isOverwrite)
#                       - записать в файл INI $filename секцию CFG. Записывается только первый уровень,
#                         не пишутся ключи, значением которых является [Hashtable]
#                         $isOverwrite показывает перезаписывать файл или нет
#   saveToFile()          - то же что и выше, но записывается в файл $this.filename. По умолчанию $isOverwrite=$False
#   saveToFile([bool]$isOverwrite)
#   [bool] hidden setKeyValue([string]$path, [string]$key, [Object]$value){
#                       - записать значение в ключ секции, значение ключа по пути.
#                         Если ключ = '', то метод проверяет есть ли путь, и создает его если его нет.
#
#>

<######################################
    [FileCFG]
Правила именования Java
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
	#	Инициализация. Проверить существование файла, считать данные из
	#	файла в hashtable. Если имя файла = '_empty_', то пропуск метода.
	#	Exception, если не считали, или объект пустой
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
    #   Считать секцию
    #   Возврат:
    #       [Hashtable]@{
    #           code:   0 - секция есть и ее считали
    #                   1 - нет пути, т.е. какой-то элемента в section
    #                   2 - есть путь, но какой-то элемент в пути не
    #                       является [Hashtable]п
    #                   3 -
    #           result:   - считанная секция, т.е. ее ключи и значения
    #                       Список ключей и значений из секции.
    #       }
    #       Если секция не существует, то в зависимости от errorAsException,
    #       либо пустой список, либо формируется Exception
    #########################################################################>
    [Hashtable]readSection([string]$section) {
		$result = @{};
        $code = 0;
        # массив из строки 'sec1.sec2.sec3...
        $arrSections = $section.Split('.', [StringSplitOptions]::RemoveEmptyEntries);
        $path = $this.CFG;
        # проверить для каждого из массива, что существует ключ и его значение есть Hashtable:
        # как-то так
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
                    # путь есть, но элемент не [Hashtable]
                    $path = @{};
                    $code = 2;
                }
            }
            else
            {
                # нет такого пути
                $path = @{};
                $code = 1;
            }
        });
        # ошибка и пустой Hashtable, если считанное значение не Hashtable.
        # Т.е. убрали считывание ключа, оставили только секцию
        if (!($path -is [Hashtable]) -and
                !($path -is [System.Collections.Specialized.OrderedDictionary])
            )
        #if (!($this.isHashtable($path)) )
        {
            # последний элемент в пути не является [Hashtable]
            $path = @{};
            $code = 2;
        }
        $res = @{};
        $path.Keys.foreach({
            $res.Add("$_", $path[$_]);
        });
        # Если в секции нет значений и $this.ErrorAsException и $code <> 0, то породить Exception
        !$this.isExcept( ($res.Keys.Count -eq 0) -and ($code -ne 0), "Not found section name $($section) or is not Section type");
        $result = @{
            'code'=$code;
            'result'=$res
        }
		return $result;
	}
    
    <#
    # Считать значение ключа, учитывая секцию default
    # Возврат:
    #   [Object] ''
    [Object] hidden getKeyValue([string]$path, [string]$key){
        return '';
    }
    #>

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
    # Записать значение ключа по пути.
    # Если ключ = '', то метод проверяет есть ли путь, и создает его если его нет.
    # и возвращает True,
    # если есть, или смог его создать только попытаться создать путь (секции), если его нет,
    # или вернуть
    # Вход:
    #   $path   - секция, куда добавить key=value, или изменить его
    #   $key    - ключ для которого менять значение
    #   $value  - значение, которое записать по пути
    #   о
    # Возврат:
    #   $true если запись удачно, иначе $false.
    #   Если key='': $true если путь есть или смогли создать, иначе $false
    ##########################################################
    #[bool] hidden setKeyValue([string]$path, [string]$key, [Object]$value){
    #    return $this.isReadOnly;
    #}
    [bool] hidden setKeyValue([string]$path, [string]$key, [Object]$value){
        $result = $false;
        if (!$this.isReadOnly) {
            # здесь только если свойство isReadOnly = $True
            try
            {
                $r = $this.readSection($path);
                if ($r.code -ne 0)
                {
                    if ($r.code -eq 1) {
                        # секции нет, создать ее

                        $result = $true;
                    }
                    elseif ($r.code -eq 2)
                    {
                        # путь есть, но это не секция, а значение
                        throw [System.AccessViolationException]::New('Нельзя записать $($key) по пути $($path), `
                            т.к. путь не является секцией');
                    }
                    else
                    {
                        # неизвестная ошибка
                        throw [System.Exception]::New('Неопределенная ошибка при запсис $($key) по пути $($path)');
                    }
                }
                # записать значение, если присутствует key и он не равен ''
                if ($key)
                {
                    # массив из строки 'sec1.sec2.sec3...
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
    # Считать из файла данные.
    # Если в файле указаны значения как $($str), "$str2", то такие значения будут
    # вычислены, по правилам powershel, при чтении файла.
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
	
    [Void] saveToFile([string]$filename, [bool]$isOverwrite){
        # проверить что каталога с таким именем.
        if (Test-Path $filename -PathType Container){
            throw "Невозможно записать в файл, так как он является каталогом";
        }
        # проверить что файл с таким именем есть и перезапись запрешена.
        if ( (Test-Path $filename -PathType Leaf) -and !$isOverwrite){
            throw "Невозможно записать в файл, так как перезапись запрещена";
        }
        $sections=$this.readSection('.');
        #$sections=$this.readSection('.'); # аналогичный результат
        # проверить что смогли считать корневую секцию CFG
        if ($sections.code -eq 0) {
            # считали секцию CFG
            $data2file=@();
            $sections=$sections.result;
            foreach ($key in $sections.Keys){
                # здесь только если в секции есть ключи
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
            # записать в файл, если в массиве есть данные
            if ($data2file.Count -gt 0) {
                $data2file | Out-File -FilePath $filename -Force -Encoding default;
            }
        } ### если были секции в hashtable
    }
} ### class 2
