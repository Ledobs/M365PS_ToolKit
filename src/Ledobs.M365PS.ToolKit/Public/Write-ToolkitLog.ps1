function Write-ToolkitLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Info', 'Warn', 'Error')]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [hashtable]$Data
    )

    if (-not $script:ToolkitLogFile) {
        Initialize-ToolkitLogging | Out-Null
    }

    $record = [ordered]@{
        TimestampUtc = (Get-Date).ToUniversalTime().ToString('o')
        Level        = $Level
        Message      = $Message
        Data         = $Data
    }

    ($record | ConvertTo-Json -Depth 5 -Compress) | Add-Content -LiteralPath $script:ToolkitLogFile

    switch ($Level) {
        'Info' { Write-Host "[INFO] $Message" }
        'Warn' { Write-Warning $Message }
        'Error' { Write-Error $Message }
    }
}
