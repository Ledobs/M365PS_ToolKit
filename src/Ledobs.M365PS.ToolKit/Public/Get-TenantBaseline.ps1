function Get-TenantBaseline {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigPath,

        [Parameter()]
        [switch]$IncludeGraphContext
    )

    $config = Get-ToolkitConfig -Path $ConfigPath

    $baselineChecks = @(
        [pscustomobject]@{
            Area         = 'Authentication'
            Setting      = 'DefaultMode'
            DesiredValue = $config.Authentication.DefaultMode
        }
        [pscustomobject]@{
            Area         = 'Logging'
            Setting      = 'EnableTranscript'
            DesiredValue = $config.Logging.EnableTranscript
        }
        [pscustomobject]@{
            Area         = 'Reporting'
            Setting      = 'DefaultFormat'
            DesiredValue = $config.Reporting.DefaultFormat
        }
    )

    $result = [ordered]@{
        TenantId       = $config.Tenant.TenantId
        TenantDomain   = $config.Tenant.Domain
        GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        Checks         = $baselineChecks
    }

    if ($IncludeGraphContext) {
        $context = Get-ToolkitGraphContext
        $result.GraphContext = [pscustomobject]@{
            TenantId = $context.TenantId
            ClientId = $context.ClientId
            AuthType = $context.AuthType
            Scopes   = @($context.Scopes)
        }
    }

    [pscustomobject]$result
}
