function Invoke-ToolkitGraphRequestWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE')]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter()]
        [int]$MaxRetries = 3,

        [Parameter()]
        [int]$RetryDelaySeconds = 5
    )

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

    for ($attempt = 1; $attempt -le ($MaxRetries + 1); $attempt++) {
        try {
            return Invoke-MgGraphRequest -Method $Method -Uri $Uri
        }
        catch {
            $statusCode = $null
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }

            $shouldRetry = $statusCode -in @(429, 500, 502, 503, 504)
            if (-not $shouldRetry -or $attempt -gt $MaxRetries) {
                throw
            }

            $delay = $RetryDelaySeconds * $attempt
            Write-Warning "Graph request failed with HTTP $statusCode. Retry $attempt/$MaxRetries in $delay seconds."
            Start-Sleep -Seconds $delay
        }
    }
}
