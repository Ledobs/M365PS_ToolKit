function Get-ToolkitConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path
    )

    if (-not $Path) {
        if ($env:LEDOBS_M365_TOOLKIT_CONFIG) {
            $Path = $env:LEDOBS_M365_TOOLKIT_CONFIG
        }
        else {
            $Path = Get-ToolkitDefaultConfigPath
        }
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Toolkit config file not found: $Path"
    }

    Import-PowerShellDataFile -LiteralPath $Path
}
