function Get-ToolkitSignIn {
    [CmdletBinding()]
    param(
        [Parameter()]
        [datetime]$From = (Get-Date).AddDays(-7),

        [Parameter()]
        [datetime]$To = (Get-Date),

        [Parameter()]
        [string]$UserPrincipalName,

        [Parameter()]
        [int]$Top = 1000
    )

    Assert-RequiredScopes -RequiredScopes @('AuditLog.Read.All', 'Directory.Read.All') -AllowAppOnly

    $fromText = ConvertTo-ToolkitGraphDateTime -DateTime $From
    $toText = ConvertTo-ToolkitGraphDateTime -DateTime $To

    $filterParts = @(
        "createdDateTime ge $fromText"
        "createdDateTime le $toText"
    )

    if ($UserPrincipalName) {
        $escapedUpn = $UserPrincipalName.Replace("'", "''")
        $filterParts += "userPrincipalName eq '$escapedUpn'"
    }

    $filter = [uri]::EscapeDataString(($filterParts -join ' and '))
    $uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=$filter&`$top=$Top"

    Invoke-ToolkitGraphCollectionRequest -Uri $uri |
        Select-Object CreatedDateTime, UserDisplayName, UserPrincipalName, AppDisplayName, IPAddress, ResourceDisplayName, @{
            Name = 'StatusCode'
            Expression = { $_.status.errorCode }
        }, @{
            Name = 'ConditionalAccessStatus'
            Expression = { $_.conditionalAccessStatus }
        }, Id
}
