function New-ToolkitThirdPartyAgentResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Agent,

        [Parameter()]
        [object]$GraphPackage,

        [Parameter(Mandatory = $true)]
        [string]$Action,

        [Parameter()]
        [string]$Result,

        [Parameter()]
        [string]$Error
    )

    [pscustomobject]@{
        Name                 = $Agent.Name
        PackageId            = $Agent.'Title ID'
        CsvStatus            = $Agent.Status
        GraphDisplayName     = if ($GraphPackage) { $GraphPackage.displayName } else { $null }
        GraphType            = if ($GraphPackage) { $GraphPackage.type } else { $null }
        GraphIsBlockedBefore = if ($GraphPackage) { $GraphPackage.isBlocked } else { $null }
        Action               = $Action
        Result               = $Result
        Error                = $Error
        TimestampUtc         = (Get-Date).ToUniversalTime().ToString('o')
    }
}
