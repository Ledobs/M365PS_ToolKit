function Block-ToolkitThirdPartyAgent {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            if (-not (Test-Path -LiteralPath $_ -PathType Leaf)) {
                throw "CSV file not found: $_"
            }
            $true
        })]
        [string]$CsvPath,

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [string[]]$StatusToBlock = @('Available'),

        [Parameter()]
        [switch]$VerifyWithGraph = $true,

        [Parameter()]
        [switch]$SkipGraphConnect,

        [Parameter()]
        [int]$MaxRetries = 3,

        [Parameter()]
        [int]$RetryDelaySeconds = 5
    )

    $rows = @(Import-Csv -LiteralPath $CsvPath)
    Assert-ToolkitCsvColumns -Rows $rows -RequiredColumns @('Name', 'Status', 'Publisher Type', 'Title ID')

    $targets = @(
        $rows | Where-Object {
            $_.'Publisher Type' -eq 'ThirdParty' -and
            -not [string]::IsNullOrWhiteSpace($_.'Title ID') -and
            $_.Status -in $StatusToBlock
        }
    )

    if ($targets.Count -eq 0) {
        Write-Host 'No agents to block.'
        return @()
    }

    if ($VerifyWithGraph -and -not $SkipGraphConnect) {
        $context = Get-ToolkitGraphContext
        if (-not $context) {
            Connect-ToolkitAuth -Scopes 'CopilotPackages.ReadWrite.All' | Out-Null
        }
        else {
            Assert-RequiredScopes -RequiredScopes @('CopilotPackages.ReadWrite.All') -AllowAppOnly
        }
    }

    $results = New-Object System.Collections.Generic.List[object]

    foreach ($agent in $targets) {
        $graphPackage = $null

        try {
            if ($VerifyWithGraph) {
                $graphPackage = Get-ToolkitCopilotPackage -PackageId $agent.'Title ID' -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds
            }
        }
        catch {
            $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -Action 'Block' -Result 'GraphLookupFailed' -Error $_.Exception.Message))
            continue
        }

        if ($VerifyWithGraph) {
            if (-not $graphPackage) {
                $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -Action 'Block' -Result 'PackageNotFound' -Error 'Package not returned by Graph.'))
                continue
            }

            if ($graphPackage.type -notin @('thirdParty', 'external')) {
                $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -GraphPackage $graphPackage -Action 'Block' -Result 'SkippedNotExternal' -Error 'Package is not a supported third-party type according to Graph.'))
                continue
            }

            if ($graphPackage.isBlocked -eq $true) {
                $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -GraphPackage $graphPackage -Action 'Block' -Result 'AlreadyBlocked'))
                continue
            }
        }

        $blockUri = "https://graph.microsoft.com/beta/copilot/admin/catalog/packages/$($agent.'Title ID')/block"

        if ($PSCmdlet.ShouldProcess("$($agent.Name) [$($agent.'Title ID')]", 'Block Copilot package')) {
            try {
                Invoke-ToolkitGraphRequestWithRetry -Method POST -Uri $blockUri -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds | Out-Null
                $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -GraphPackage $graphPackage -Action 'Block' -Result 'Blocked'))
            }
            catch {
                $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -GraphPackage $graphPackage -Action 'Block' -Result 'Failed' -Error $_.Exception.Message))
            }
        }
        else {
            $results.Add((New-ToolkitThirdPartyAgentResult -Agent $agent -GraphPackage $graphPackage -Action 'Block' -Result 'WhatIf'))
        }
    }

    if ($OutputPath) {
        $results | Export-ToolkitReport -Path $OutputPath -Format Csv | Out-Null
    }

    $results.ToArray()
}
