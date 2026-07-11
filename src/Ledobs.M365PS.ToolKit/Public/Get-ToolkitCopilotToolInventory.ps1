function Get-ToolkitCopilotToolInventory {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [string[]]$PublisherAllowList = @('Microsoft Corporation'),

        [Parameter()]
        [switch]$SkipGraphConnect,

        [Parameter()]
        [int]$MaxRetries = 3,

        [Parameter()]
        [int]$RetryDelaySeconds = 5
    )

    Connect-ToolkitCopilotPackageCatalog -SkipGraphConnect:$SkipGraphConnect

    $packages = @(Get-ToolkitCopilotPackages -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds)
    $results = @(
        foreach ($package in $packages) {
            New-ToolkitCopilotToolInventoryResult -Package $package -PublisherAllowList $PublisherAllowList
        }
    )

    if ($OutputPath) {
        $results | Export-ToolkitReport -Path $OutputPath -Format Csv | Out-Null
    }

    $results
}
