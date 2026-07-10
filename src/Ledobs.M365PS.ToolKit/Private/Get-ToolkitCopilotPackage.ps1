function Get-ToolkitCopilotPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [Parameter()]
        [int]$MaxRetries = 3,

        [Parameter()]
        [int]$RetryDelaySeconds = 5
    )

    $uri = "https://graph.microsoft.com/v1.0/copilot/admin/catalog/packages/$PackageId"
    Invoke-ToolkitGraphRequestWithRetry -Method GET -Uri $uri -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds
}
