function New-AuditReport {
    [CmdletBinding()]
    param(
        [Parameter()]
        [datetime]$From = (Get-Date).AddDays(-7),

        [Parameter()]
        [datetime]$To = (Get-Date),

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [ValidateSet('Csv', 'Json')]
        [string]$Format = 'Csv',

        [Parameter()]
        [switch]$IncludeSignIns = $true,

        [Parameter()]
        [switch]$IncludeDirectoryAudits = $true
    )

    if (-not $IncludeSignIns -and -not $IncludeDirectoryAudits) {
        throw 'At least one source must be included. Use -IncludeSignIns and/or -IncludeDirectoryAudits.'
    }

    $records = New-Object System.Collections.Generic.List[object]

    if ($IncludeSignIns) {
        foreach ($signIn in @(Get-ToolkitSignIn -From $From -To $To)) {
            $records.Add([pscustomobject]@{
                Source          = 'SignIn'
                Timestamp       = $signIn.CreatedDateTime
                Category        = 'Authentication'
                Action          = $signIn.AppDisplayName
                Actor           = $signIn.UserPrincipalName
                Target          = $signIn.ResourceDisplayName
                Status          = if ($signIn.StatusCode -eq 0) { 'Success' } else { 'Failure' }
                StatusCode      = $signIn.StatusCode
                ConditionalAccess = $signIn.ConditionalAccessStatus
                IPAddress       = $signIn.IPAddress
                Id              = $signIn.Id
            })
        }
    }

    if ($IncludeDirectoryAudits) {
        foreach ($audit in @(Get-ToolkitDirectoryAudit -From $From -To $To)) {
            $records.Add([pscustomobject]@{
                Source          = 'DirectoryAudit'
                Timestamp       = $audit.ActivityDateTime
                Category        = $audit.Category
                Action          = $audit.ActivityDisplayName
                Actor           = $audit.InitiatedBy
                Target          = $audit.TargetResources
                Status          = $audit.Result
                StatusCode      = $null
                ConditionalAccess = $null
                IPAddress       = $null
                Id              = $audit.Id
            })
        }
    }

    $orderedRecords = @($records | Sort-Object Timestamp, Source)

    $summary = @(
        $orderedRecords |
            Group-Object Source, Category, Status |
            Sort-Object Count -Descending |
            ForEach-Object {
                [pscustomobject]@{
                    Source   = $_.Group[0].Source
                    Category = $_.Group[0].Category
                    Status   = $_.Group[0].Status
                    Count    = $_.Count
                }
            }
    )

    $report = [pscustomobject]@{
        GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        FromUtc        = $From.ToUniversalTime().ToString('o')
        ToUtc          = $To.ToUniversalTime().ToString('o')
        RecordCount    = $orderedRecords.Count
        Summary        = $summary
        Records        = $orderedRecords
        Output         = $null
    }

    if ($OutputPath) {
        $extension = [System.IO.Path]::GetExtension($OutputPath)
        $basePath = if ([string]::IsNullOrWhiteSpace($extension)) { $OutputPath } else { $OutputPath.Substring(0, $OutputPath.Length - $extension.Length) }
        $normalizedExtension = if ($Format -eq 'Csv') { '.csv' } else { '.json' }

        $detailsPath = "$basePath-details$normalizedExtension"
        $summaryPath = "$basePath-summary$normalizedExtension"

        $orderedRecords | Export-ToolkitReport -Path $detailsPath -Format $Format | Out-Null
        $summary | Export-ToolkitReport -Path $summaryPath -Format $Format | Out-Null

        $report.Output = [pscustomobject]@{
            Format      = $Format
            DetailsPath = $detailsPath
            SummaryPath = $summaryPath
        }
    }

    $report
}
