function Connect-ToolkitAuth {
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param(
        [Parameter(ParameterSetName = 'Interactive')]
        [string[]]$Scopes = @(
            'Directory.Read.All',
            'Policy.Read.All',
            'AuditLog.Read.All'
        ),

        [Parameter(ParameterSetName = 'Interactive')]
        [string]$TenantId,

        [Parameter(Mandatory = $true, ParameterSetName = 'AppOnly')]
        [string]$AppTenantId,

        [Parameter(Mandatory = $true, ParameterSetName = 'AppOnly')]
        [string]$ClientId,

        [Parameter(Mandatory = $true, ParameterSetName = 'AppOnly')]
        [string]$CertificateThumbprint
    )

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

    if ($PSCmdlet.ParameterSetName -eq 'Interactive') {
        $connectSplat = @{
            Scopes    = $Scopes
            NoWelcome = $true
        }

        if ($TenantId) {
            $connectSplat.TenantId = $TenantId
        }

        Connect-MgGraph @connectSplat | Out-Null
        return Get-MgContext
    }

    Connect-MgGraph -TenantId $AppTenantId -ClientId $ClientId -CertificateThumbprint $CertificateThumbprint -NoWelcome | Out-Null
    Get-MgContext
}
