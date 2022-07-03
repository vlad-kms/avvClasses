Class Logger {
    [int32]$logLevel
    [boolean]$isAppend
    [string]$logFile
    [int32]$TW
    [boolean]$isExpandTab

    <####################################################
    #                   Constructors
    ####################################################>

    Logger ([String]$logFile){
        $this.initDefault(1)
        $fl = $this.initFile($logFile)
        if ( $fl ) {
            $this.logFile=$fl
        }
        else {
            #$this.logFile="";
            $this.logLevel=-1
        }
    }

    Logger ([String]$logFile, [int]$logLevel){
        $this.initDefault($logLevel)
        $fl = $this.initFile($logFile)
        if ( $fl ) {
            $this.logFile=$fl
        }
        else {
            #$this.logFile="";
            $this.logLevel=-1
        }
    }

    Logger ([String]$logFile, [int]$logLevel, [boolean]$isAppend){
        $this.initDefault($logLevel)
        $this.isAppend = $isAppend

        $fl = $this.initFile($logFile)
        if ( $fl ) {
            $this.logFile=$fl
        }
        else {
            $this.logLevel=-1
        }
    }

    Logger ([String]$logFile, [int]$logLevel, [boolean]$isAppend, [int32]$tabWidth){
        $this.initDefault($logLevel)
        $this.isAppend = $isAppend
        $this.TW = $tabWidth

        $fl = $this.initFile($logFile)
        if ( $fl ) {
            $this.logFile=$fl
        }
        else {
            $this.logLevel=-1
        }
    }

    [void]initDefault([int]$logLevel) {
        $this.isExpandTab = $True
        $this.TW       = 4
        $this.isAppend = $True
        $this.logLevel = $logLevel
        $this.logFile  = ""
    }

    <##########################################################
                        Methods
    ##########################################################>

    [string]initFile ([String]$logFile) {
        return [logger]::initFile($logFile, $this.isAppend)
    }

    static [string]initFile ([String]$logFile, [boolean]$isAppend) {
        $Result=$logFile
        if ( !$logFile) {
            return $Result
            throw "Not defined File logger."
        }
        if ( !([logger]::isAbsolutePath($logFile)) ) {
            # абсолютный путь и имя файла
            $result = [Environment]::GetEnvironmentVariable('TEMP')
            if ( $logFile.Substring(0,1) -ne '\' ) {
                $result += '\'
            }
            $result+=$logFile
        }
        $FN = Split-Path -Path $Result -Leaf
        $PathLog = Split-Path -Path $Result -Parent
        <#
        if (! (Test-Path $PathLog -PathType Container) ) {
            New-Item $PathLog -ItemType Directory | Out-Null
        }
#>
        if ( Test-Path $Result -PathType Any ) {
            if ( Test-Path $Result -PathType Container ) {
                $Result = ""
            }
        }
        else {
            if ( Test-Path $PathLog -PathType Any ) {
                if ( !(Test-Path $PathLog -PathType Container) ) {
                    $result = ""
                }
            } else { ### if ( Test-Path $PathLog -PathType Any ) {
                $outNI = New-Item $PathLog -ItemType Directory
                if ( !$outNI ) {
                    $result = ""
                }
            }
        } ### if ( Test-Path $Result -PathType Any ) {
        if ( $Result ) {
            if ( !($isAppend) -or !(Test-Path $Result) ) {
                New-Item $Result -ItemType File -Force | Out-Null
            }
            else {
                #Out-File -FilePath $Result -encoding "default" -InputObject "" -Append
            }
        }
        return $Result
    }

    [string] expandTab([string]$Str) {
        return [logger]::expandTab($str, $this.TW)
    }

    static [string] expandTab([string]$Str, [UInt32]$TabWidth) {
        #if ( ! $this.isExpandTab ) { return $str }
        #if ( $TabWidth -lt 0 ) { $TabWidth = 4 }
        $line=$str
        while ( $TRUE ) {
            $i = $line.IndexOf([Char] 9)
            if ( $i -eq -1 ) { break }
            if ( $TabWidth -gt 0 )
            {
                $pad = " " * ($TabWidth — ($i % $TabWidth))
            }
            else
            {
                $pad =""
            }
            $line = $line -replace "^([^`t]{$i})`t(.*)$","`$1$pad`$2"
        }
        return $line
    } ### [string] expandTab([string]$Str, [UInt32]$TabWidth) {

    <#
    [string] Add([string]$msg, [int32]$Level=1) {
        return "$(Get-Date -Format 'dd.MM.yyyy hh:mm:ss'):`t$msg"
    }
    #>

    static [boolean]isAbsolutePath([string]$Path) {
        $Result=$False
        if ( ($path.Substring(1, 1) -eq ':') -or ($path.Substring(0, 2) -eq '\\') ) {
            $Result=$True
        }
        return $Result
    }

    static [void] log ([string]$FileName, [string]$Msg, [int32]$TabCount, [int32]$UseDate,
                       [int32]$Log, [int32]$logLevel, [boolean]$Always=$False, [boolean]$isExpandTab,
                       [int32]$TabWidth, [string]$ClassMSG){
        #$UseDate=0,
            <###--
                FileName- имя файла? relf gbcfnm логи
                Msg     - строка лога
                TabCount- сколько TAB'ов отступать от начала строки (от 0 и больше)
                UseDate - использование даты в строке лога
                    =0  нет даты в начале строки
                    =1  дата в начале только 1-й строки
                    =2  дата в начале каждой строки
                    =3  нет даты в начале строки, но по длине 'дата:TAB' забито пробелами, TabCount НЕ игнорируется
                    =4  1-я строка - дата в начале, TabCount игнорируется
                        следующие -  даты в начале строки нет,  но по длине 'дата:TAB-' забито пробелами, TabCount НЕ игнорируется
                    =5  1-я строка - дата в начале, TabCount не игнорируется
                        следующие -  даты в начале строки нет,  но по длине 'дата:TAB-' забито пробелами, TabCount НЕ игнорируется
                    =6  1-я строка - дата в начале, TabCount не игнорируется
                        следующие -  даты в начале строки нет,  но по длине 'дата:TAB+TAB-' забито пробелами, TabCount НЕ игнорируется
                    =   все отстальное, нет даты в начале строки, но по длине 'дата:TAB-' забито пробелами, TabCount игнорируется
                ()
                Log     - если Log > LogLevel, то строку не писать в лог-файл.
                          Если Log >=1, то добавить в строку "(Level=$($Log))"
                LogLevel- ограничитель для строк, см. комментарий предыдущего параметра
                Always  - если True, то не обращать внимания на соотношение Log и LogLevel.
                          Т.е. писать в лог-файл всегда
                ()
                isExpandTab - если TRUE, то заменить в строке симвал TAB ([char]9) на пробелы
                TabWidth- количество пробелов для замены символа TAB.
                          Вместо символа TAB вставить TabWidth SPACE
                ClassMsg- добавить в конец строки, начиная со 150 символа подстроку ClassMsg
            ###>
        if ( !$Msg) { return }
        if ( ($logLevel -le 0) -or ( $Log -le 0) ){ return }
        if (!$FileName -or ($FileName -eq '') ) { return }
        $PL = Split-Path $FileName -Parent
        if (! (Test-Path $PL -PathType Container) ) {
            New-Item $PL -ItemType Directory |Out-Null
        }
        if ($Log -gt 1) {
            $StrLevel=" (Level=$($Log))"
        } else {
            $StrLevel=""
        }
        if ( ($Log -le $logLevel) -or $Always ) {
            $dt1=(Get-Date -Format "dd.MM.yyyy HH:mm:ss")
            $dt= $dt1 + ":`t"
            $dtspace="".PadLeft($dt1.Length, " ") + " `t"
            $as = $Msg.Split("`n")
            #$as
            $i=0
            foreach ($str in $as) {

                Switch ( $UseDate) {
                    0 {
                        $str = "".PadLeft($TabCount, "`t") + $str.Trim()
                    }
                    1 {
                        if ( $i -eq 0 ) {
                            $str = $dt + "".PadLeft($TabCount, "`t") + $str.Trim()
                        } else {
                            $str = $dtspace + "".PadLeft($TabCount, "`t") + $str.Trim()
                            #Log -Msg $str -TabCount $TabCount -UseDate 3 # $Always.IsPresent
                        }
                    }
                    2 {
                        $str = $dt + "".PadLeft($TabCount, "`t") + $str.Trim()
                    }
                    3 {
                        $str = $dtspace + "".PadLeft($TabCount, "`t") + $str.Trim()
                    }
                    4 {
                        if ( $i -eq 0 ) {
                            $str = $dt + $str.Trim()
                        } else {
                            $str = $dtspace + "".PadLeft($TabCount, "`t") + $str.Trim()
                        }
                    }
                    5 {
                        if ( $i -eq 0 ) {
                            $str = $dt  + "".PadLeft($TabCount, "`t") + $str.Trim()
                        } else {
                            $str = $dtspace + "".PadLeft($TabCount, "`t") + $str.Trim()
                        }
                    }
                    6 {
                        if ( $i -eq 0 ) {
                            $str = $dt  + "".PadLeft($TabCount, "`t") + $str.Trim()
                        } else {
                            $str = $dtspace + "".PadLeft($TabCount+1, "`t") + $str.Trim()
                        }
                    }
                    default {
                        $str = $str.Trim()
                    }
                }
                if ( $isExpandTab ) { $str=[logger]::expandTab($str, $TabWidth) }
                if ( $i -le 0 ) {
                    if ( $StrLevel ) {
                        $str = $str.PadRight(109, ' ')+$StrLevel
                    }
                    if ( $ClassMSG ) {
                        $str = $str.PadRight(150, ' ')+$ClassMSG
                    }
                }
                Out-File -FilePath $FileName -encoding "default" -InputObject "$($str)" -Append
                $i += 1
            } ### foreach ($str in $as) {
        } ### if ( ($Log -le $logLevel) -or $Always ) {
    }

    [void] log ([string]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always=$False, [string]$ClassMSG){
        #$UseDate=0,
            <#
                =0 нет даты в начале строки
                =1 дата в начале только 1-й строки
                =2 дата в начале каждой строки
                =3 нет даты в начале строки, но по длине 'дата:TAB' забито пробелами, TabCount НЕ игнорируется
                =4 1-я строка - дата в начале, TabCount игнорируется
                       следующие -  даты в начале строки нет,  но по длине 'дата:TAB-' забито пробелами, TabCount НЕ игнорируется
                =5 1-я строка - дата в начале, TabCount не игнорируется
                       следующие -  даты в начале строки нет,  но по длине 'дата:TAB-' забито пробелами, TabCount НЕ игнорируется
                =6 1-я строка - дата в начале, TabCount не игнорируется
                    следующие -  даты в начале строки нет,  но по длине 'дата:TAB+TAB-' забито пробелами, TabCount НЕ игнорируется
                =все отстальное, нет даты в начале строки, но по длине 'дата:TAB-' забито пробелами, TabCount игнорируется
            #>

        [Logger]::log($this.logFile, $Msg, $TabCount, $UseDate, $Log, $this.logLevel, $Always, $this.isExpandTab, $this.TW, $ClassMSG)
    } ### log

    [void] log ([string[]]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always=$False, [string]$ClassMSG){
        foreach ($str in $Msg) {
            $this.log($str, $TabCount, $UseDate, $Log, $Always, $ClassMSG)
        }
    }

}

<###
$l=[logger]::new('d:\temp\123.log', 1)
###>
