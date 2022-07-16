using module '.\avvBase.ps1';
#. '.\avvBase.ps1'

Class Logger : avvBase {
    [int32]$logLevel        = 1;
    [boolean]$isAppend      = $True;
    [string]$logFile        = '';
    [int32]$TW              = 4;
    [boolean]$isExpandTab   = $True;
    [System.Management.Automation.Host.PSHost]$HostVar=$null;

    <####################################################
    #                   Constructors
    ####################################################>
    Logger () {
        $fl = $this.initFile([System.IO.Path]::GetTempFileName())
        if ( $fl ) {
            $this.logFile=$fl
        }
        else {
            #$this.logFile="";
            $this.logLevel=-1
        }
    }

    Logger ([String]$logFile){
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
    Logger ([String]$logFile, [int]$logLevel, [boolean]$isAppend, [int32]$tabWidth, [bool]$isExpandTab){
        $this.isAppend = $isAppend
        $this.TW = $tabWidth
        $this.isExpandTab = $isExpandTab

    }
    Logger ([Hashtable]$Params) : base($Params)
    {
        $fl = $this.initFile($this.logFile)
        if ( !$fl ) {
            $this.logLevel=-1
        }
    }
    <##########################################################
                        Methods
    ##########################################################>

    [string]initFile ([String]$logFile) {
        return [logger]::initFile($logFile, $this.isAppend)
    }

    <##############################################################################################
    # ������������� ����� ��� �����.
    # $logFile  - ��� ����� ��� �����. ���� �������� ���������� ��� ���������� � '\' ��� '.\', ��
    #             � �������� ������ �����. ����� ����� ��������, %TEMP%\$logFile.
    # $isAppend - false, ������ ������� ����� ����, ����� �������� ������������.
    ###############################################################################################>
    static [string]initFile ([String]$logFile, [boolean]$isAppend) {
        $Result=$logFile
        if ( !$logFile) {
            return $Result
            throw "Not defined File logger."
        }
        if ( !([logger]::isAbsolutePath($logFile)) ) {
            # ���������� ���� � ��� �����
            $result = [Environment]::GetEnvironmentVariable('TEMP')
            if ( $result.Substring($Result.Length - 1,1) -ne '\' ) {
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

    <#######################################################################################
    #   expandTab
    #       ������������� ������ ���������� ������ `t (TAB) ' ' (SPACE) ����������� $TabWidth
    #       ����������� ������� � ����� ������
    #######################################################################################>
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
                $pad = " " * ($TabWidth � ($i % $TabWidth))
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

    ##############################################
    # ������� TRUE, ���� ���� �������� ����������
    ##############################################
    static [boolean]isAbsolutePath([string]$Path) {
        $Result=$False
        $Path = $Path.Trim();
        if ( (Split-Path -IsAbsolute -Path $path) -or ($path.Substring(0, 1) -eq '\') -or ($path.Substring(0, 2) -eq '.\') ) {
            $Result=$True
        }
        return $Result
    }

    <############################################################################################################
        FileName    -   ��� �����, ���� ������ ����
        Msg         -   ������ ����, �������������� ����������� �� ������ ����� �� ������� '`n' (������� ������)
        TabCount- ������� TAB'�� ��������� �� ������ ������ (�� 0 � ������)
        UseDate -   ������������� ���� � ������ ����
                =0  ��� ���� � ������ ������
                =1  ���� � ������ ������ 1-� ������
                =2  ���� � ������ ������ ������
                =3  ��� ���� � ������ ������, �� �� ����� '����:TAB' ������ ���������, TabCount �� ������������
                =4  1-� ������ - ���� � ������, TabCount ������������
                    ��������� -  ���� � ������ ������ ���,  �� �� ����� '����:TAB-' ������ ���������, TabCount �� ������������
                =5  1-� ������ - ���� � ������, TabCount �� ������������
                    ��������� -  ���� � ������ ������ ���,  �� �� ����� '����:TAB-' ������ ���������, TabCount �� ������������
                =6  1-� ������ - ���� � ������, TabCount �� ������������
                    ��������� -  ���� � ������ ������ ���,  �� �� ����� '����:TAB+TAB-' ������ ���������, TabCount �� ������������
                =   ��� ����������, ��� ���� � ������ ������, �� �� ����� '����:TAB-' ������ ���������, TabCount ������������
        ()
        Log         -   ���� Log > LogLevel, �� ������ �� ������ � ���-����.
                        ���� Log >=1, �� �������� � ������ "(Level=$($Log))"
        LogLevel    -   ������������ ��� �����, ��. ����������� ����������� ���������
        Always      -   ���� True, �� �� �������� �������� �� ����������� Log � LogLevel.
                        �.�. ������ � ���-���� ������
        ()
        isExpandTab - ���� TRUE, �� �������� � ������ ������ TAB ([char]9) �� �������
        TabWidth    -   ���������� �������� ��� ������ ������� TAB.
                        ������ ������� TAB �������� TabWidth SPACE
        ClassMsg- �������� � ����� ������, ������� �� 150 ������� ��������� ClassMsg
    ############################################################################################################>
    static [void] log ([string]$FileName, [string]$Msg, [int32]$TabCount, [int32]$UseDate,
                       [int32]$Log, [int32]$logLevel, [boolean]$Always=$False, [boolean]$isExpandTab,
                       [int32]$TabWidth, [string]$ClassMSG,
                       $BColor, $FColor, $HostVar)
    {
        if ( !$Msg) { return }
        if ( ($logLevel -le 0) -or ( $Log -le 0) ){ return }
        if (!$FileName -or ($FileName -eq '') ) { return }
        # ���� � ���-�����
        $PL = Split-Path $FileName -Parent
        # ������� �������, ���� ��� ���
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
                        #$str = $str.Trim()
                        $str = $str;
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
                if ( ($HostVar -ne $null) -and ($HostVar -is [System.Management.Automation.Host.PSHost]) )
                {
                    try
                    {
                        $BC = [ConsoleColor]$BColor;
                    }
                    catch
                    {
                        $BC = ([Logger]::getDefaultColor($HostVar)).Background;
                    }
                    try
                    {
                        $FC = [ConsoleColor]$FColor;
                    }
                    catch
                    {
                        $FC = ([Logger]::getDefaultColor($HostVar)).Foreground;
                    }
                    switch ($HostVar.Name) {
                        'ConsoleHost' {
                            "$($Str)" | Write-Host -BackgroundColor $BC -ForegroundColor $FC;
                        }
                        'Windows PowerShell ISE Host'{
                            "$($Str)" | Write-Host;
                        }
                        default {
                            "$($Str)" | Write-Host -BackgroundColor $BC -ForegroundColor $FC;
                        }
                    }
                }
                $i += 1
            } ### foreach ($str in $as) {
        } ### if ( ($Log -le $logLevel) -or $Always ) {
    }
    ### [string]
    [void] log ([string]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG,
                    $BColor, $FColor, $HostVar
                )
    {
        [Logger]::log($this.logFile, $Msg, $TabCount, $UseDate, $Log, $this.logLevel, $Always,
                $this.isExpandTab, $this.TW, $ClassMSG,
                $BColor, $FColor, $HostVar)
    }
    [void] log ([string]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG,
                    $BColor, $FColor
                )
    {
        [Logger]::log($this.logFile, $Msg, $TabCount, $UseDate, $Log, $this.logLevel, $Always,
                $this.isExpandTab, $this.TW, $ClassMSG,
                $BColor, $FColor, $this.HostVar)
    }
    [void] log ([string]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always,  [string]$ClassMSG){
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $null, $null, $null)
    }
    [void] log ([string]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always){
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, '', $null, $null, $null)
    }
    [void] log ([string]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log){
        $this.log($Msg, $TabCount, $UseDate, $Log, $false, '', $null, $null, $null)
    }
    ### [string[]]
    [void] log ([string[]]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG,
                    $BColor, $FColor, $HostVar
                )
    {
        foreach ($str in $Msg) {
            $this.log($str, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $BColor, $FColor, $HostVar)
        }
    }
    [void] log ([string[]]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG,
                    $BColor, $FColor
                )
    {
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $BColor, $FColor, $this.HostVar);
    }
    [void] log ([string[]]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG){
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $null, $null, $null)
    }
    [void] log ([string[]]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always){
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, '', $null, $null, $null)
    }
    [void] log ([string[]]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log){
        $this.log($Msg, $TabCount, $UseDate, $Log, $false, '', $null, $null, $null)
    }
    ### [array]
    [void] log ([array]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG,
                    $BColor, $FColor, $HostVar
                )
    {
        $str=[String]::join("`n", $Msg)
        $this.log([string]$str, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $BColor, $FColor, $HostVar)
    }
    [void] log ([array]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG,
                    $BColor, $FColor
                )
    {
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $BColor, $FColor, $this.HostVar)
    }

    [void] log ([array]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always, [string]$ClassMSG){
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, $ClassMSG, $null, $null, $null)
    }
    [void] log ([array]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log, [boolean]$Always){
        $this.log($Msg, $TabCount, $UseDate, $Log, $Always, '', $null, $null, $null)
    }
    [void] log ([array]$Msg, [int32]$TabCount, [int32]$UseDate, [int32]$Log){
        $this.log($Msg, $TabCount, $UseDate, $Log, $false, '', $null, $null, $null)
    }

    static [Hashtable] getDefaultColor($HostVar)
    {
        $BColor = [System.ConsoleColor]'DarkBlue';
        $FColor = [System.ConsoleColor]"White";
        switch ($HostVar.Name) {
            'ConsoleHost' {
                $BColor = $HostVar.ui.rawui.backgroundcolor;
                $FColor = $HostVar.ui.rawui.Foregroundcolor;
            }
            'Windows PowerShell ISE Host'{
                $BColor = $HostVar.PrivateData.ConsolePaneBackgroundColor;
                $FColor = $HostVar.PrivateData.ConsolePaneForegroundColor;
            }
            default {
                $BColor = [System.ConsoleColor]'DarkBlue';
                $FColor = [System.ConsoleColor]"White";
            }
        }
        return @{'Foreground'=$FColor; 'Background'=$BColor;}
    }



}
