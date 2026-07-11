function Get-ToolkitCopilotPackages {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [int]$MaxRetries = 3,

        [Parameter()]
        [int]$RetryDelaySeconds = 5
    )

    $uri = 'https://graph.microsoft.com/v1.0/copilot/admin/catalog/packages'
    if (-not [string]::IsNullOrWhiteSpace($Filter)) {
        $uri = '{0}?$filter={1}' -f $uri, [uri]::EscapeDataString($Filter)
    }

    $packages = New-Object System.Collections.Generic.List[object]

    do {
        $response = Invoke-ToolkitGraphRequestWithRetry -Method GET -Uri $uri -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds
        foreach ($package in @($response.value)) {
            $packages.Add($package)
        }

        $uri = $response.'@odata.nextLink'
    } while ($uri)

    $packages.ToArray()
}
