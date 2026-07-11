function Connect-ToolkitCopilotPackageCatalog {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$SkipGraphConnect,

        [Parameter()]
        [switch]$RequireWrite
    )

    if ($SkipGraphConnect) {
        return
    }

    $readScope = 'CopilotPackages.Read.All'
    $writeScope = 'CopilotPackages.ReadWrite.All'

    $context = Get-ToolkitGraphContext
    if (-not $context) {
        if ($RequireWrite) {
            Connect-ToolkitAuth -Scopes $writeScope | Out-Null
        }
        else {
            Connect-ToolkitAuth -Scopes $readScope | Out-Null
        }

        return
    }

    if ($context.AuthType -eq 'AppOnly') {
        return
    }

    $scopes = @($context.Scopes)
    if ($RequireWrite) {
        if ($scopes -notcontains $writeScope) {
            throw "The active Microsoft Graph context is missing the required scope '$writeScope'."
        }

        return
    }

    if ($scopes -notcontains $readScope -and $scopes -notcontains $writeScope) {
        throw "The active Microsoft Graph context is missing either '$readScope' or '$writeScope'."
    }
}
