function Get-ToolkitDirectoryAudit {
    [CmdletBinding()]
    param(
        [Parameter()]
        [datetime]$From = (Get-Date).AddDays(-7),

        [Parameter()]
        [datetime]$To = (Get-Date),

        [Parameter()]
        [int]$Top = 1000
    )

    Assert-RequiredScopes -RequiredScopes @('AuditLog.Read.All', 'Directory.Read.All') -AllowAppOnly

    $fromText = ConvertTo-ToolkitGraphDateTime -DateTime $From
    $toText = ConvertTo-ToolkitGraphDateTime -DateTime $To
    $filter = [uri]::EscapeDataString("activityDateTime ge $fromText and activityDateTime le $toText")
    $uri = "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?`$filter=$filter&`$top=$Top"

    Invoke-ToolkitGraphCollectionRequest -Uri $uri |
        Select-Object @{
            Name = 'ActivityDateTime'
            Expression = { $_.activityDateTime }
        }, @{
            Name = 'ActivityDisplayName'
            Expression = { $_.activityDisplayName }
        }, @{
            Name = 'Category'
            Expression = { $_.category }
        }, @{
            Name = 'Result'
            Expression = { $_.result }
        }, @{
            Name = 'InitiatedBy'
            Expression = {
                if ($_.initiatedBy.user.userPrincipalName) { $_.initiatedBy.user.userPrincipalName }
                elseif ($_.initiatedBy.app.displayName) { $_.initiatedBy.app.displayName }
                else { $null }
            }
        }, @{
            Name = 'TargetResources'
            Expression = { @($_.targetResources.displayName) -join '; ' }
        }, Id
}
