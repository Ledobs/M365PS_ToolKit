function Assert-RequiredScopes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredScopes,

        [Parameter()]
        [switch]$AllowAppOnly
    )

    $context = Get-ToolkitGraphContext
    if (-not $context) {
        throw 'No Microsoft Graph context is active. Run Connect-ToolkitAuth first.'
    }

    if ($context.AuthType -eq 'AppOnly') {
        if ($AllowAppOnly) {
            return $true
        }

        throw 'The current Microsoft Graph context is app-only. Use delegated auth or pass -AllowAppOnly.'
    }

    $grantedScopes = @($context.Scopes | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $missingScopes = @($RequiredScopes | Where-Object { $_ -notin $grantedScopes })

    if ($missingScopes.Count -gt 0) {
        throw "Missing Microsoft Graph scope(s): $($missingScopes -join ', ')"
    }

    $true
}
