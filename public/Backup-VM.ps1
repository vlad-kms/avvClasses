function Backup-VM {
    # [CmdletBinding(SupportsShouldProcess = $true,
    #     ConfirmImpact = 'Medium')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'One or more Hyper-V virtual machine names seperated by commas.',
            Position = 0
        )]
        [string[]]$Name,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Path the backup destination.',
            Position = 1
        )]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Fastest', 'Optimal', 'NoCompression')]
        [string]$CompressionLevel = 'Fastest',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Copy', 'Deflate', 'Deflate64', 'BZip2', 'Lzma', 'Lzma2', 'Ppmd', 'Default')]
        [string]$CompressionMethod = 'Default',

        [Parameter(Mandatory = $false)]
        [switch]$NoCompression,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    process {
        Write-Host "QWERTY"
    } # Process
} # Cmdlet

# Backup-VM