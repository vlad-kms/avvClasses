#. .\classes\classLogger.ps1

function Get-InfoModule{
<#
    .SYNOPSIS
    Возвращает информацию о модуле avvClasses.
    .DESCRIPTION
    Возвращает полную информацию о модуле avvClasses.
    .OUTPUTS
    Name: Info
    BaseType: [System.Collections.Specialized.OrderedDictionary]
        - filenameIgnoreModule      - файл со списком модулей из Classes, которые не надо импортировать при загрузке модуля avvClasses
        - filenameSupportedClasses  - файл со списком модулей из Classes, поддерживаемые модулем avvClasses
        - pathModules               - путь где находятся вложенные модули
        - pathMain                  - путь к модулю avvClasses.psm1
        - importedModules'          - импортированные модули при загрузке avvClasses.psm1 из вложенных
        - nestedModules'            - модули для импорта в качестве вложенных модулей модуля, указанного в параметре RootModule/ModuleToProcess
        - supportedClasses'         - поддерживаемые классы во вложенных модулях
    .EXAMPLE
    Получить информацию о модуле:
    PS C:\Windows\system32> Get-InfoModule

    Name                           Value
    ----                           -----
    filenameIgnoreModule           .avvmoduleignore
    filenameSupportedClasses       .avvclassessupported
    pathModules                    D:\Tools\~scripts.ps\avvClasses\classes\
    pathMain                       C:\Program Files\WindowsPowerShell\Modules\avvClasses\avvClasses.psm1
    importedModules                {avvBase.ps1, classCFG.ps1, classLogger.ps1, classTest.ps1}
    nestedModules                  {avvBase, classLogger, classCFG}
    supportedClasses               {avvBase, IniCFG, JsonCFG, Logger...}
    
#>
    [OutputType([System.Collections.Specialized.OrderedDictionary])]

    $res=[ordered]@{}
    $res.Add('filenameIgnoreModule', "$($filenameIgnoreModule)")
    $res.Add('filenameSupportedClasses', "$($filenameSupportedClasses)")
    # каталог расположения модулей с классами для модуля avvClasses
    $pathModules=Get-PathModules;    $res.Add('pathModules', "$($pathModules)")
    $res.Add('pathMain', ((Get-Module 'avvClasses').Path))
    $res.Add('importedModules', (Get-ImportedModules -Path $pathModules))
    $res.Add('nestedModules', (Get-ImportedModules -Path $pathModules -includeType 'Nested'))
    $res.Add('supportedClasses', (Get-SupportedClasses -Path $pathModules))
    return $res
}

function Get-Logger
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$Filename,
        [int32]$LogLevel=1,
        [boolean]$IsAppend=$true,
        [int32]$TabWidth=4,
        [boolean]$IsExpandTab=$true
    )
    #Logger ([String]$logFile, $LogLevel, [boolean]$isAppend, [int32]$tabWidth){
    #return [Logger]::new($Filename, $LogLevel, $IsAppend, $TabWidth, $IsExpandTab)
    return Get-AvvClass -ClassName 'Logger' -Params @{_obj_=@{
            logFile =$Filename
            logLevel=$LogLevel
            isAppend = $IsAppend
            TW = $TabWidth
            isExpandTab = $IsExpandTab
        }};
}

function Get-IniCFG
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$Filename,
        [bool]$ErrorAsException=$false
    )
    #return [IniCFG]::new($Filename, $ErrorAsException);
    return Get-AvvClass -ClassName 'IniCFG' -Params @{_obj_=@{filename=$Filename;errorAsException=$ErrorAsException}}
}

function Get-IsHashtable() {
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        $Value
    )
    return ($Value -is [System.Collections.IDictionary]);
}

<############################################
Создать экземпляр класса по имени класса.
############################################>
function Hashtable2Params([Hashtable]$ht)
{
    Write-Verbose "$($MyInvocation.InvocationName) ENTER:============================================="
    if ($ht -is [hashtable]) {
        Write-Verbose "Тип аргумента ht [HASHTABLE]"
        Write-Verbose "Аргумент ht:"
        Write-Verbose ($ht|ConvertTo-Json -Depth 100)
            if ($ht.Contains("type") -and $ht.type -and $ht.type -ne ""){
            Write-Verbose "Аргумент ht содержит ключ 'type' и его значение НЕ ПУСТОЕ"
            if ($ht.type.ToUpper() -eq "STRING") {$ts = """$($ht.Value)"""}
            elseif ($ht.type.ToUpper() -eq "INT") {$ts = "$($ht.Value)"}
            #elseif ($ht.type.ToUpper() -eq "BOOL") {$ts = [int][bool]$ht.Value}
            # TODO пока не реализовано, использование приводит к ошибке
            elseif ($ht.type.ToUpper() -eq "OBJ") {$ts = $ht.Value}
            else {$ts = """$($ht.Value)"""};
        } else {
            Write-Verbose "Аргумент ht содержит ключ 'type' и его значение ПУСТОЕ"
            $ts = """$($ht.Value)"""
        }
    } else {
        Write-Verbose "Тип аргумента ht НЕ [HASHTABLE]"
        Write-Verbose "Аргумент ht:"
        Write-Verbose $ht
        $ts='qwerty TYPE'
    };
    Write-Verbose "$($MyInvocation.InvocationName) return: $($ts)"
    Write-Verbose "$($MyInvocation.InvocationName) EXIT:============================================="
    return $ts;
}

function Get-AvvClass {
<#
    .SYNOPSIS
    Создать экземпляр класса по имени $ClassName. Класс должен быть наследником от [avvBase]
    .DESCRIPTION
    Создание экземпляра класса по имени $ClassName. В зависимостьи от значения $Params, будут вызываться различные конструкторы класса.
    Все эти конструкторы д.б. описаны и реализованы в $ClassName, наследуемые конструкторы напрямую вызвать нельзя.
    .PARAMETER ClassName
    Имя класса. Может быть одним из поддерживаемых, список которых можно получить, используя команду Get-SupportedClasses
    .PARAMETER Params
    Для передачи параметров в конструктор класса.
    В зависимости от значения этого параметра, разная реализация вызова конструктора класса:
        - $null (отсутствует): вызывается конструктор [$ClassName]::new() без параметров
        - [hashtable], где есть ключ 'Constructor', например:
            @{"Constructor"=
                @{
                    "param0=@{"type"="string"; "Value"="str1"};
                    "param2"=@{"type"="obj"; "Value"=@{"f1"="v1";"f2"="v2"}}; // ИСПОЛЬЗОВАТЬ НЕЛЬЗЯ, будет ошибка
                    "param1=@{"type"="INt"; "Value"=1};
                    ...
                }
            }
            Вызывается конструктор [$ClassName]::new(Params.Constructor.param0.value, Params.Constructor.param1.value, ...)
            Тип параметра может быть только INT, STRING
        - [hashtable], произвольная. В ней имеют специальное значение ключи '_obj_', '_obj_add_', '_obj_add_value_', '_new_'.
            Вызывается конструктор [$ClassName]::new([Hashtable]$Params)
            Спец-ключи обрабатываются методом [void] [avvBase]::initFromHashtable([Hashtable]$params)
            Пример класса:
                class avvTest : avvBase
                {
                    $f1='qwerty'
                    [hashtable] $f2=@{"f1"="zxc"; "f3"=2}
                    [int] $f3=0

                    avvTest () : base (){}
                    avvTest ([Hashtable]$p) : base ($p){}
                    avvTest ([String]$p) : base (){
                        $this.f1 = $p
                    }
                    avvTest ([Int]$p0, [String]$p) : base (){
                        $this.f1 = $p
                        $this.f3 = $p0
                    }
                }

            1) @{"_obj_"=
                @{
                    "f1=@{"f1_1"="v1_1"; "f1_2"=2};
                    "f2="eqwe";
                    "f3"=3
                    "f44"=44
                    ...
                }
            }
            Заменяет значения полей в объекте значениями из соответствующих полей [hashtable]_obj_.
            Изменяет только существующие в объекте(классе) поля.
            Если в классе нет поля, которое есть в Params._obj_, то Params._obj_.key_notexists пропускается.
            Пример на основе примера класса и Params:
                this.f1 станет равным @{"f1_1"="v1_1"; "f1_2"=2}
                this.f2 выдаст ошибку преобразования String Hashtable
                this.f3 станет равным 3
                Params.f44 будет проигнорирован
                 ...

            2) @{"_obj_add_"=
                @{
                    "f1=@{"f1_1"="v1_1"; "f1_2"=2};
                    "f2="eqwe";
                    "f3"=3
                    "f44"=44
                    ...
                }
            }
            Добавляет ключи и их значения из Param._obj_add_ в this как поля класса и их значения, если таких полей нет в классе.
            Если в классе есть такое поле, то выводит сообщение об ошибке (не может добавить такое поле, т.к. оно существует) и продолжает работу.
            Пример на основе примера класса и Params:
                this.f1 выдаст ошибку поле существует, добавить нельзя
                this.f2 выдаст ошибку поле существует, добавить нельзя
                this.f3 выдаст ошибку поле существует, добавить нельзя
                this.f44 будет добавлен и станет равным 44
                 ...

            3) @{"_obj_add_value_"=
                @{
                    "f1=@{"f2_1"="v2_1"; "f2_2"=2};
                    "f2="eqwe";
                    "f3"=3
                    "f44"=44
                    ...
                }
            }
            Добавляет к значениям существующих полей класса значения из соответствующих полей Param._obj_add_value_

            4) @{"_new_"=
                @{
                    "f1=@{"f2_1"="v2_1"; "f2_2"=2};
                    "f2="eqwe";
                    "f3"=3
                    "f44"=44
                    ...
                }
            }
            Изменяет существующие поля из Params в this и добавляет несуществующие

    .EXAMPLE
        (get-avvClass -ClassName avvTest).ToJson()
        Создать экземпляр класса avvTest с помощью конструктора new()
        
        {
            "f1":  "qwerty",
            "f2":  {
                "f3":  2,
                "f1":  "zxc"
            },
            "f3":  0,
            "AddOrMerge":  2,
            "id":  '0'
        }
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"constructor"=@{"param0"=@{"type"="string"; "value"="E:\!my-configs\configs\src\dns-api\config.json"}}} -Verbose).ToJson()
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - Constructor

        {
            "f1":  "E:\\!my-configs\\configs\\src\\dns-api\\config.json",
            "f2":  {
                "f3":  2,
                "f1":  "zxc"
                },
            "f3":  0,
            "AddOrMerge":  2,
            "id":  '0'
        }
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"constructor"=@{"param0"=@{"type"="Obj"; "value"=@{"f2"=@{"f1"="bmv"; "ff1"=1234}}}}})|ConvertTo-Json -Depth 100
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - Constructor, type='OBJ' не работает, выдает ошибку

        Хэш-таблицу можно добавить только к другой хэш-таблице.
        D:\Tools\~scripts.ps\avvClasses\avvClasses.psm1:281 знак:21
        +                     $parStr += (Hashtable2Params($ht)) + ',';
        +                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
            + FullyQualifiedErrorId : AddHashTableToNonHashTable

        {
            "f1":  "qwerty",
            "f2":  {
                "f3":  2,
                "f1":  "zxc"
            },
            "f3":  0,
            "AddOrMerge":  2,
            "id":  '0'
        }
    .EXAMPLE
     (Get-AvvClass -ClassName avvTest -Params @{"constructor"=@{"param1"=@{"type"="Str"; "value"="ttt"}; "param0"=@{"type"="int";"value"=10}}} )|ConvertTo-Json -Depth 100
    Создать экземпляр класса avvTest с помощью конструктора new([Int]$p0, [String]$p])
    Спец-ключ - Constructor

        {
            "f1":  "ttt",
            "f2":  {
               "f3":  2,
               "f1":  "zxc"
        },
        "f3":  10,
        "AddOrMerge":  2,
        "id":  '0'
        }
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"_obj_"=@{"f1"=@{"f1_1"=1;"f1_2"=2};"id"="id1"; "f2"=12; "fg"=444};}).ToJson()
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - _obj_, выдает ошибку несоответствия типов

    Исключение при задании "f2" : "Не удается преобразовать значение "12" типа "System.Int32" в тип "System.Collections.Hashtable"."
        D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1:58 знак:21
        +                     $this.$key = $params.$keyObj.$key;
        +                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : NotSpecified: (:) [], SetValueInvocationException
            + FullyQualifiedErrorId : ExceptionWhenSetting

        Невозможно вызвать метод для выражения со значением NULL.
        строка:1 знак:1
        + (Get-AvvClass -ClassName avvTest -Params @{"_obj_"=@{"f1"=@{"f1_1"=1; ...
        + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
            + FullyQualifiedErrorId : InvokeMethodOnNull
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"_obj_"=@{"f1"=@{"f1_1"=1;"f1_2"=2};"id"="id1"; "f2"=@{}; "fg"=444};}).ToJson()
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - _obj_

        {
            "f1":  {
               "f1_1":  1,
               "f1_2":  2
           },
            "f2":  {

            },
            "f3":  0,
            "AddOrMerge":  2,
            "id":  "id1"
        }
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"_obj_add_"=@{"f1"=@{"f1_1"=1;"f1_2"=2};"id"="id1"; "f2"=@{}; "fg"=444};} ).ToJson()
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - _obj_add_

        Add-Member : Не удается добавить элемент с именем "f2", так как элемент с таким именем уже существует. Чтобы все равно перезаписать этот элемент, добавьте в команду параметр Force.
        D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1:71 знак:25
        + ...     $this | Add-Member -NotePropertyName "$($_)" -NotePropertyValue $ ...
        +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : InvalidOperation: (avvTest:PSObject) [Add-Member], InvalidOperationException
            + FullyQualifiedErrorId : MemberAlreadyExists,Microsoft.PowerShell.Commands.AddMemberCommand

        Add-Member : Не удается добавить элемент с именем "f1", так как элемент с таким именем уже существует. Чтобы все равно перезаписать этот элемент, добавьте в команду параметр Force.
        D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1:71 знак:25
        + ...     $this | Add-Member -NotePropertyName "$($_)" -NotePropertyValue $ ...
        +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : InvalidOperation: (avvTest:PSObject) [Add-Member], InvalidOperationException
            + FullyQualifiedErrorId : MemberAlreadyExists,Microsoft.PowerShell.Commands.AddMemberCommand

        Add-Member : Не удается добавить элемент с именем "id", так как элемент с таким именем уже существует. Чтобы все равно перезаписать этот элемент, добавьте в команду параметр Force.
        D:\Tools\~scripts.ps\avvClasses\classes\avvBase.ps1:71 знак:25
        + ...     $this | Add-Member -NotePropertyName "$($_)" -NotePropertyValue $ ...
        +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            + CategoryInfo          : InvalidOperation: (avvTest:PSObject) [Add-Member], InvalidOperationException
            + FullyQualifiedErrorId : MemberAlreadyExists,Microsoft.PowerShell.Commands.AddMemberCommand

        {
            "f1":  "qwerty",
            "f2":  {
               "f3":  2,
               "f1":  "zxc"
            },
            "f3":  0,
            "AddOrMerge":  2,
            "id":  '0',
            "fg":  444
        }
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"_obj_add_value_"=@{"f3"=100; "fg"=444; "id"="23"; "f1"="_as_"; "f2"=@{"ff1"="ggg"; "ff2"=34545}}} ).ToJson()
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - _obj_add_value_

        {
            "f1":  "qwerty_as_",
            "f2":  {
               "f3":  2,
               "f1":  "zxc",
               "ff1":  "ggg",
               "ff2":  34545
                },
            "f3":  100,
            "AddOrMerge":  2,
            "id":  "023"
        }
    .EXAMPLE
    (Get-AvvClass -ClassName avvTest -Params @{"_new_"=@{"f1_1"=1;"f1_2"=2; "id"=1; "tst"=@{f1=1;f2=2}; "f1"="asd"; "f2"=@{"b1"=1;"b2"=2}}; "fg"=444}).ToJson()
    Создать экземпляр класса avvTest с помощью конструктора new([Hashtable] $Params])
    Спец-ключ - _new_

        {
            "f1":  "asd",
            "f2":  {
               "b2":  2,
               "f3":  2,
               "f1":  "zxc",
               "b1":  1
           },
            "f3":  0,
            "AddOrMerge":  2,
            "id":  "1",
            "tst":  {
                "f1":  1,
                "f2":  2
            },
            "f1_2":  2,
            "f1_1":  1
        }    
#>
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$ClassName,
        [Hashtable]$Params=$null
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER:============================================="
    $isSupported = isSupportedClass -ClassName $ClassName;
    #$isSupported = $True;
    if ($isSupported)
    {
        Write-Verbose "Класс $($ClassName) поддерживается модулем и будет загружаться"
        if ($null -eq $Params) {
            Write-Verbose "Params is NULL. Вызвать конструктор без параметров [$($ClassName)]::new()"
            return Invoke-Expression -Command "[$ClassName]::new()"
        }
        elseif ( $Params.Contains('Constructor') -and
                ($Params['Constructor'] -is [Hashtable]) -and
                ($Params['Constructor'].Count -ne 0) )
        {
            Write-Verbose "Params содержит ключ 'Constructor' и тип его значения [Hashtable]$arg=@{""param0""=@{""type""=""string"";""value""=""asd""}; }. Преобразовать такие структуры в параметры для передачи в конструктор"
            Write-Verbose ($Params | ConvertTo-Json -Depth 100)
            $construct=$Params['Constructor'];
            $parStr = '';
            for ($i = 0; $i -lt $Params['Constructor'].Count; $i++)
            {
                #$str = ([string]$Params['Constructor']["param$($i)"]).Trim();
                $ht  = $construct["param$($i)"];
                if ($ht.Count -ne 0)
                {
                    $parStr += (Hashtable2Params($ht)) + ',';
                }
            }
            if ($parStr) {
                $parStr = $parStr.Substring(0, $parStr.Length - 1);
            }
            Write-Verbose "Вызов конструктора: Invoke-Expression -Command ""[$($ClassName)]::new($parStr)"""
            return Invoke-Expression -Command "[$ClassName]::new($parStr)"
        }
        else
        {
            #    Params является Hashtable и он не $null.
            #    Вызов конструктора new([hashtable]$arg), причем arg д.б. вида может содержать спец-ключи
            #    "_obj_", "_obj_add_", "obj_add_value", "_new_"
            Write-Verbose "Params имеет тип Hashtable и передается в конструктор new([Hashtable]$Params)"
            Write-Verbose "Вызов конструктора: Invoke-Expression -Command ""[$($ClassName)]::new($($Params|ConvertTo-Json -Depth 100))"""
            return Invoke-Expression -Command ("[$ClassName]::new" + '($Params)' );
        }
    }
    else
    {
        Write-Verbose "Класс $($ClassName) не поддерживается модулем и загружаться не будет"
        #"Класс $($ClassName) не поддерживается" | Write-Host -ForegroundColor Cyan
        Write-Warning "Класс $($ClassName) не поддерживается модулем и загружаться не будет"
    }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT:============================================="
}

#################### ConvertJSONToHash #########################
# Конвертирует PSCustomObject в Hashtable, включая все вложенные свойства,
# имеющие тип PSCustomObject
function ConvertJSONToHash{
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [AllowNull()]
        $root
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER:============================================="
    $hash = @{};
    $keys = $root | Get-Member -MemberType NoteProperty | Select-Object -exp Name;
    #$keys | %{
    $keys | ForEach-Object{
            $obj=$root.$($_);
        if($obj -is [PSCustomObject])
        {
            $nesthash=ConvertJSONToHash $obj;
            $hash.add($_,$nesthash);
        }
        else
        {
            $hash.add($_,$obj);
        }
    }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT:============================================="
    return $hash
}

function ConvertFrom-JsonToHashtable {
    <#
    .SYNOPSIS
        Helper function to take a JSON string and turn it into a hashtable
        TODO НЕ РАБОТАЕТ, ТОЛКО первый уровень вложенности.
    .DESCRIPTION
        The built in ConvertFrom-Json file produces as PSCustomObject that has case-insensitive keys. This means that
        if the JSON string has different keys but of the same name, e.g. 'size' and 'Size' the comversion will fail.
        Additionally to turn a PSCustomObject into a hashtable requires another function to perform the operation.
        This function does all the work in step using the JavaScriptSerializer .NET class
    #>

    # TODO НЕ РАБОТАЕТ, ТОЛКО первый уровень вложенности.

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [AllowNull()]
        [string]
        $InputObject,
        [switch]
    # Switch to denote that the returning object should be case sensitive
        $casesensitive
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER:============================================="
    if ([String]::IsNullOrEmpty($InputObject)) {
        $dict = @{}
    } else {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Script.Serialization");
        $deserializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new();
        $deserializer.MaxJsonLength = [int]::MaxValue;
        $dict = $deserializer.Deserialize($InputObject, 'Hashtable');
        if ($casesensitive -eq $false) {
            $dict = New-Object "System.Collections.Generic.Dictionary[System.String, System.Object]"($dict, [StringComparer]::OrdinalIgnoreCase)
        }
    }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT:============================================="
    return $dict
}

<#
    .SYNOPSIS
    Вернуть версию Powershell
    .DESCRIPTION
    Вернуть системную переменную $PSVersionTable, содержащую версию Powershell
    .OUTPUTS
    Name: PSVersionTable
    BaseType: Hashtable
#>
function Get-Version{
    return $PSVersionTable;
}

<#
    .SYNOPSIS
    Объединение двух hashtable
    .DESCRIPTION
    Объединить две HASHTABLE: добавить $Source в $Dest.
    Если передан ключ [switch]$Action, то в $Dest добавляются только те значения (Key, Value) из $Source, которые отсутствуют в целевой Hastable
    Если не передан ключ [switch]$Action, то в $Dest добавляются отсутствующие значения (Key, Value) из $Source, существующие значения заменяются значениями из $Source
    .PARAMETER Dest
    Целевая Hashtable, к которой надо добавить исходную Hashtable
    .PARAMETER Source
    Исходная Hashtable, которую надо добавить к целевой
    $Dest       = hashtable к которому надо добавить
    .PARAMETER Action
    Указывает что делать при объединении:
        -Action присутствует: добавить только отсутствующие (Key, Value)
        -Action  отсутствует: добавить отсутствующие и изменить существующие (Key, Value)
 #>

function Add-Hashtable {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$True)]
        [hashtable] $Source,
        [Parameter(Position=1, Mandatory=$True)]
        [hashtable] $Dest,
        [switch] $Action
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER:============================================="
    $result = $Dest
    try {
        if ($null -eq $Dest) {throw "Hashtable назначения не может быть null"}
        Write-Verbose "Source:"
        Write-Verbose "$($Source | ConvertTo-Json -Depth 5)"
        Write-Verbose "Dest:"
        Write-Verbose "$($Dest | ConvertTo-Json -Depth 5)"
        Write-Verbose "Action: $($Action)"
        foreach($Key in $Source.Keys) {
            if ($Dest.ContainsKey($Key)) {
                # ключ есть в объекте назначения
                Write-Verbose "Ключ $($Key) ЕСТЬ в Dest"
                if ($Action) { # AddOnly
                    Write-Verbose "В hashtable Dest есть ключ $Key. Флаг Action = $Action. Тип значения ключа: $($Dest.$Key.GetType())"
                    if ( (Get-IsHashtable -Value $Dest.$Key) -and (Get-IsHashtable -Value $Source.$Key) ) {
                        # Dest.Key и Source.Key имеют тип Hashtable
                        Write-Verbose "Рекурсивный вызов с Source.$($Key),  Dest.$($Key), $Action"
                        $result=Add-Hashtable -Source $Source.$Key -Dest $Dest.$Key -Action:$Action
                    }
                } else { # Merge)
                    Write-Verbose "В hashtable Dest есть ключ $Key. Флаг Action = $Action. Тип значения ключа: $($Dest.$Key.GetType())"
                    #if ($this.isCompositeType($Dest.$Key) -and $this.isCompositeType($Source.$Key)) {
                    if ( (Get-IsHashtable -Value $Dest.$Key) -and (Get-IsHashtable -Value $Source.$Key) ) {
                        # Dest.Key и Source.Key имеют тип Hashtable
                        Write-Verbose "Рекурсивный вызов с Source.$($Key),  Dest.$($Key), $Action"
                        $result=Add-Hashtable -Source $Source.$Key -Dest $Dest.$Key -Action:$Action
                    } else {
                        Write-Verbose "Записали в                                          : Dest.$($Key) = $($Source.$Key)"
                        $Dest.$Key = $Source.$Key
                    }
                } ### if ($Action)
            } else {
                # ключа нет в объекте назначения
                Write-Verbose "Ключа $($key) нет в Dest"
                if ( (Get-isHashtable -Value $Dest) ) {
                    # добавить к Hashtable
                    Write-Verbose "Добавить к Hashtable                                : Dest.$($Key) = $($Source.$key)"
                    $Dest.Add($key, $Source.$key)
                <#
                } elseif ( $this.isObject($Dest) ) {
                    Write-Verbose "Add-Member к типам Object, PSObject, PSCustomObject : Dest.$($Key) = $($Source.$Key)"
                    $Dest | Add-Member -NotePropertyName $key -NotePropertyValue $Source.$key
                #>
                } else {
                    Write-Verbose "Не можем добавить $($Key) к Dest типа $($Dest.GetType())"
                }
            }
        }
        $result=$Dest
    }
    catch {
        $result = $null
        throw $PSItem
    }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT:============================================="
    return $result
}

function Get-VerboseSession {
    Write-Verbose "$($MyInvocation.InvocationName) ENTER: ======================================================="
    Write-Verbose "$($MyInvocation.InvocationName) EXIT: ======================================================="
    return $VerbosePreference
}

function Set-VerboseSession {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True, Position=0)]
        [ValidateSet('Enable', 'Disable')]
        $Value='Disable'
    )
    begin {
        Write-Verbose "$($MyInvocation.InvocationName)  ENTER: ====================================================="
        Write-Verbose "$($MyInvocation.InvocationName)  begin: ====================================================="
        Write-Verbose "Value: $($Value)"
    }
    process {
        Write-Verbose "$($MyInvocation.InvocationName) process: ==================================================="
        if ($Value -eq 'Enable') {
            $VerbosePreference = "Continue"
        } else {
            $VerbosePreference = "SilentlyContinue"
        }
    }
    end {
        Write-Verbose "$($MyInvocation.InvocationName) end: ======================================================="
        Write-Verbose "$($MyInvocation.InvocationName) EXIT: ======================================================="
    }
}

function Merge-Hashtable{
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True, Position=0, Mandatory=$True)]
        [hashtable] $Source,
        [Parameter(Position=1, Mandatory=$True)]
        [hashtable] $Destination,
        [switch] $AddOnly
    )
    begin {
        Write-Verbose "$($MyInvocation.InvocationName) ENTER: ====================================================="
        Write-Verbose "$($MyInvocation.InvocationName) begin: ====================================================="
        Write-Verbose "Destination: $($Destination | ConvertTo-Json -Depth 100)"
        Write-Verbose "AddOnly: $($AddOnly)"
        $result = $Destination
    }
    process {
        Write-Verbose "Merge-Hashtable process: ==================================================="
        <#
        if ($_) {
            [hashtable]$src=$_
        } else {
            [hashtable]$src=$Source
        }
        Write-Verbose "Source (src): $($src | ConvertTo-Json -Depth 100)"
        $result = (Add-Hashtable -Source $src -Dest $result -Action:$AddOnly)
        #>
        Write-Verbose "Source : $($Source | ConvertTo-Json -Depth 100)"
        $result = (Add-Hashtable -Source $Source -Dest $result -Action:$AddOnly)
    }
    end {
        Write-Verbose "$($MyInvocation.InvocationName) end:============================================="
        Write-Verbose "Result hashtable: $($result | ConvertTo-Json -Depth 100)"
        Write-Verbose "$($MyInvocation.InvocationName) EXIT:============================================="
        return $result
    }
}

###########################################################
###########################################################
###########################################################
function Get-SupportedClasses
{
    param (
        [Parameter(Position=0, ValueFromPipeline=$True)]
        [string]$Path=(Get-PathModules)
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER: ============================================="
    #if ($Path) { $Path = (Join-Path -Path $Path -ChildPath "$($DS)") }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT: ============================================="
    return (Get-Content -Path "$($Path)$($filenameSupportedClasses)") | Where-Object {$_ -replace '^[\#\;].*$'}
}
function IsSupportedClass()
{
    param (
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True)]
        [string]$ClassName
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER: ============================================="
    $sp = (Get-SupportedClasses);
    for ($i=0; $i -lt $sp.Count; $i++)
    {
        $sp[$i] = $sp[$i].ToUpper();
    }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT: ============================================="
    return $sp.Contains($ClassName.ToUpper());
}

function Get-ImportedModules
{
    param (
        [Parameter(Position=0, ValueFromPipeline=$True)]
        [string]$Path=(Get-PathModules),
        [ValidateSet('Imported', 'Nested', 'All')]
        [string]$includeType='Imported'
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER: ============================================="
    if ($Path) { $Path = (Join-Path -Path $Path -ChildPath "$($DS)") }
    $listModules=(Get-ChildItem -Path "$($Path)*" -Include '*.ps1' -Name)
    try
    {
        #$listIgnored=(Get-Content -Path "$($Path)$($filenameIgnoreModule)")
        $listIgnored=(Get-Content -Path (Join-Path -Path $Path -ChildPath $filenameIgnoreModule))
    }
    catch
    {
        $listIgnored=@()
    }
    [array]$loadedModules=@();
    if ( ($includeType -eq 'All') -or ($includeType -eq 'Imported') )
    {
        [array]$loadedModules += ($listModules| Where-Object { $listIgnored -notcontains $_ })
    }
    if ( ($includeType -eq 'All') -or ($includeType -eq 'Nested') )
    {
        $m = (Get-Module -Name avvClasses).NestedModules | Select-Object Name;
        $m.foreach({
            $loadedModules += $_.Name;
        })
    }
    Write-Verbose "$($MyInvocation.InvocationName) EXIT: ============================================="
    return $loadedModules
}

function Get-PathModules() {
    <#
    .SYNOPSIS
    Вернуть путь с которого импортирован модуль Name
    .OUTPUTS
    Name: pathModules
    BaseType: [String]
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    Param(
        [Parameter(Position=0, ValueFromPipeline=$True)]
        [String] $Name='avvClasses',
        [String] $ChildPath='classes',
        [switch] $OnlyRoot
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER: ============================================="
    $result = (Get-Module -Name $Name).Path
    Write-Verbose "Получили Path $($result) модуля $($Name)"
    if ($result) {
        $result=Split-Path -Path $result -Parent
    }
    Write-Verbose "Получили RootPath $($result) модуля $($Name)"
    if (-not $OnlyRoot.IsPresent) {
        if ($result) {
            $result = (Join-Path -Path $result -ChildPath $ChildPath)
        } else {
            $result = ''
        }
    }
    if ($result) { $result = (Join-Path -Path $result -ChildPath "$($DS)") }
    Write-Verbose "Result: $($result)"
    Write-Verbose "$($MyInvocation.InvocationName) EXIT: ============================================="
    if ($result) {
        return $result;
    } else {
        throw "Не найден модуль $($Name)"
    }
}

function Use-Modules() {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, ValueFromPipeline=$True)]
        [string[]]$ClassNames=@(),
        [switch]$NotForce
    )
    Write-Verbose "$($MyInvocation.InvocationName) ENTER: ============================================="
    # каталог расположения модулей с классами для модуля avvClasses
    $pathModules=Get-PathModules

    $ic=Get-ImportedModules -Path $pathModules
    $ic.foreach({
        # работает только для сессии, но зато все работает
        #. "$(Join-Path -Path "$($pathModules)" -ChildPath $_)"
        #Import-Module -Global (Join-Path -Path "$($pathModules)" -ChildPath $_) -Force:$(!$NotForce)
        # импортирует, но к типам не достучишься
        Import-Module (Join-Path -Path "$($pathModules)" -ChildPath $_) -Global -Force:$(!$NotForce.IsPresent)
    })
    Write-Verbose "$($MyInvocation.InvocationName) EXIT: ============================================="
}
<#=================================================================================
===================================================================================
===================================================================================
===================================================================================#>
$DS=[System.IO.Path]::DirectorySeparatorChar;
$filenameIgnoreModule='.avvmoduleignore'
$filenameSupportedClasses='.avvclassessupported'

<#
#if ($pathModules -and ($pathModules.Substring(($pathModules.Length)-1, 1) -ne "$DS")) { $pathModules+="$($DS)" }
if ($pathModules) { $pathModules = (Join-Path -Path $pathModules -ChildPath "$($DS)") }
###Write-Host $pathModules
$ic=Get-ImportedModules -Path $pathModules
$ic.foreach({
    . "$($pathModules)$_"
})
#>

#Get-avvClass -ClassName JsonCFG -Params @{_new_=@{Filename="E:\!my-configs\configs\src\dns-api\config.json";ErrorAsException=$true}} -Verbose
