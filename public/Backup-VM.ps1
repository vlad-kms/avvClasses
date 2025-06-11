function Backup-VM {
    <#
    .SYNOPSIS
    Резервное копирование одной или нескольких виртуальных машин Hyper-V

    .DESCRIPTION
    Резервное копирование одной или нескольких виртуальных машин Hyper-V. Экспорт VM и их архивирование, если требуется.
    Для работы требуются модули 7Zip4Powershell и Hyper-V >=2.0.0.
    Модуль 7Zip4Powershell установится автоматически при импорте модуля avvHyperV

    .PARAMETER Name
    Имя виртуальной машины. Список всех VM можно получить вызовом Get-VM.

    .PARAMETER Destination
    папка назначения для резервной копии.

    .PARAMETER CompressionLevel
    Степень сжатия при архивировании.
    Значение из 'None', 'Fast', 'Low', 'Normal', 'High' или 'Ultra'

    .PARAMETER CompressionMethod
    Метод сжатия при архивировании.
    Значение из 'Copy', 'Deflate', 'Deflate64', 'BZip2', 'Lzma', 'Lzma2', 'Ppmd' или 'Default'

    .PARAMETER CaptureLiveState
    Указывает, как Hyper-V фиксирует состояние памяти работающей виртуальной машины. Допустимые значения для этого параметра:
        CaptureSavedState           - включает состояние памяти, использует технологию Standart Checkpoint.
        CaptureDataConsistentState  - использует технологию Production Checkpoint.
        CaptureCrashConsistentState - Ничего не делать для обработки состояния виртуальной машины.
    
    .PARAMETER Compression
    Флаг -Compression включает архивирование после экпорта VM.

    .PARAMETER Interactive
    Флаг -Interactive включает запрос на подтверждение резервирования VM.

    .EXAMPLE
    Backup-VM -Name "VM-01", "VM-02" -Destination 'D:\Hyper-V.backup'

    резервировать две VMs (VM-01 and VM-02) в папку 'D:\Hyper-V.backup'.

    .EXAMPLE
    Get-VM | Backup-VM -BackupDestination 'D:\Hyper-V.backup'

    Резервирование всех VMs на сервере Hyper-V в 'D:\Hyper-V.backup'.

    .NOTES
    Автор: Алексеев Владимир

    #>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium')]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Имя одной или нескольких VMs разделенных запятой.',
            Position = 0
        )]
        [string[]]$Name,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Папка для резервирования.',
            Position = 1
        )]
        [Alias('BackupDestination')]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Fast', 'Low', 'Normal', 'High', 'Ultra')]
        [string]$CompressionLevel = 'Fast',
        [Parameter(Mandatory = $false)]
        [ValidateSet('Copy', 'Deflate', 'Deflate64', 'BZip2', 'Lzma', 'Lzma2', 'Ppmd', 'Default')]
        [string]$CompressionMethod = 'Default',
        [Parameter(Mandatory = $false)]
        [ValidateSet('CaptureCrashConsistentState', 'CaptureSavedState', 'CaptureDataConsistentState')]
        $CaptureLiveState = 'CaptureDataConsistentState',
        [Parameter(Mandatory = $false)]
        [switch]$Compression,
        [Parameter(Mandatory = $false)]
        [switch]$Interactive
    )

    process {
        $BackupSCMessage = @"
Вы будете делать резервную копию следующей VM:
    $($Name)
"@
        if (-not [bool]$Interactive -or $PSCmdlet.ShouldContinue($BackupSCMessage, 'Резервировать данную VM?')) {
            Write-Verbose -Message "VM для резервирования: $($Name)."
            Write-Verbose -Message "Папка для резервирования: $($Destination)."
            $WhIf = [bool]$PSBoundParameters.WhatIf
            $TimeStamp = Get-Date -Format "yyyy-MM-dd-HHmm"
            # Экспорт VM
            if ([bool]$WhIf) {
                Write-Host "RUN: Export-VM -Name $Name -Path $($Destination)\$($Name)-$($TimeStamp) -CaptureLiveState $($CaptureLiveState)"
            } else {
                Export-VM -Name $Name -Path "$($Destination)\$($Name)-$($TimeStamp)" -CaptureLiveState $CaptureLiveState
            }
            if ($Compression) {
                # Инит splat аргументов.
                $CompressParameters = @{
                    'Path'             = "$($Destination)\$($Name)-$($TimeStamp)";
                    'ArchiveFileName'  = "$($Destination)\$($Name)-$($TimeStamp).7z";
                }
                # CompressionLevel в splat аргументов.
                if ($null -ne $CompressionLevel) {
                    Write-Verbose -Message "Степень сжатия $($CompressionLevel)."

                    $CompressParameters += @{
                        'CompressionLevel' = $CompressionLevel
                    }
                }
                # CompressionMethod в splat аргументов.
                if ($null -ne $CompressionMethod) {
                    Write-Verbose -Message "Метод сжатия для резервирования $($CompressionMethod)."
                    $CompressParameters += @{
                        'CompressionMethod' = $CompressionMethod
                    }
                }
                Write-Verbose -Message 'Сжатие резервной копии в .7z archive.'
                if ([bool]$WhIf) {
                    Write-Host "RUN: Compress-7Zip $($CompressParameters | ConvertTo-Json)"
                    Write-Host "RUN: Remove-Item -Path $($Destination)\$($Name)-$($TimeStamp) -Force -Recurse"
                } else {
                    # Архивирование
                    Compress-7Zip @CompressParameters
                    # Удалить папку с резервной копией после архивирования
                    Remove-Item -Path "$($Destination)\$($Name)-$($TimeStamp)" -Force -Recurse
                }
            }
        }
    }
}

# TEST
# Backup-VM -Name qwe -Destination asd -WhatIf -Compression