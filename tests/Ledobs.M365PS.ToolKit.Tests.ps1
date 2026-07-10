$moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath '..\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1'
Import-Module $moduleManifest -Force

Describe 'Get-ToolkitConfig' {
    It 'imports a config file from the provided path' {
        $configPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestData\Toolkit.Config.test.psd1'
        $config = Get-ToolkitConfig -Path $configPath

        $config.Tenant.TenantId | Should Be '11111111-1111-1111-1111-111111111111'
        $config.Logging.EnableTranscript | Should Be $false
    }
}

Describe 'Initialize-ToolkitLogging and Write-ToolkitLog' {
    It 'creates a jsonl log file and appends one record' {
        $logDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts'
        if (Test-Path -LiteralPath $logDirectory) {
            Remove-Item -LiteralPath $logDirectory -Recurse -Force
        }

        $state = Initialize-ToolkitLogging -Path $logDirectory
        Write-ToolkitLog -Level Info -Message 'test-entry' -Data @{ Source = 'Pester' }

        Test-Path -LiteralPath $state.LogFile | Should Be $true
        (Get-Content -LiteralPath $state.LogFile).Count | Should Be 1
    }
}

Describe 'Get-TenantBaseline' {
    It 'returns the baseline summary from configuration' {
        $configPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestData\Toolkit.Config.test.psd1'
        $baseline = Get-TenantBaseline -ConfigPath $configPath

        $baseline.TenantId | Should Be '11111111-1111-1111-1111-111111111111'
        $baseline.Checks.Count | Should Be 3
        ($baseline.Checks | Where-Object Setting -eq 'DefaultFormat').DesiredValue | Should Be 'Csv'
    }
}

Describe 'Export-ToolkitReport' {
    It 'exports objects to CSV' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\report.csv'
        [pscustomobject]@{ Name = 'Alice'; Status = 'Success' } |
            Export-ToolkitReport -Path $path -Format Csv | Out-Null

        Test-Path -LiteralPath $path | Should Be $true
        (Import-Csv -LiteralPath $path)[0].Name | Should Be 'Alice'
    }

    It 'exports objects to JSON' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\report.json'
        [pscustomobject]@{ Name = 'Bob'; Status = 'Blocked' } |
            Export-ToolkitReport -Path $path -Format Json | Out-Null

        Test-Path -LiteralPath $path | Should Be $true
        ((Get-Content -LiteralPath $path -Raw) | ConvertFrom-Json)[0].Status | Should Be 'Blocked'
    }
}

Describe 'Module surface' {
    It 'exports reporting functions' {
        $names = (Get-Command -Module Ledobs.M365PS.ToolKit).Name
        ($names -contains 'Block-ToolkitThirdPartyAgent') | Should Be $true
        ($names -contains 'Get-ToolkitDirectoryAudit') | Should Be $true
        ($names -contains 'Get-ToolkitSignIn') | Should Be $true
        ($names -contains 'Export-ToolkitReport') | Should Be $true
        ($names -contains 'New-AuditReport') | Should Be $true
    }
}

Describe 'New-AuditReport' {
    It 'builds a combined report and exports details and summary' {
        Mock Get-ToolkitSignIn {
            @(
                [pscustomobject]@{
                    CreatedDateTime = '2026-07-01T10:00:00Z'
                    UserDisplayName = 'Alice'
                    UserPrincipalName = 'alice@contoso.com'
                    AppDisplayName = 'Microsoft 365'
                    IPAddress = '10.0.0.1'
                    ResourceDisplayName = 'SharePoint Online'
                    StatusCode = 0
                    ConditionalAccessStatus = 'success'
                    Id = 'signin-1'
                }
            )
        } -ModuleName Ledobs.M365PS.ToolKit

        Mock Get-ToolkitDirectoryAudit {
            @(
                [pscustomobject]@{
                    ActivityDateTime = '2026-07-01T11:00:00Z'
                    ActivityDisplayName = 'Add member to group'
                    Category = 'GroupManagement'
                    Result = 'success'
                    InitiatedBy = 'admin@contoso.com'
                    TargetResources = 'M365-Admins'
                    Id = 'audit-1'
                }
            )
        } -ModuleName Ledobs.M365PS.ToolKit

        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\weekly-audit'
        $report = New-AuditReport -OutputPath $path -Format Csv

        $report.RecordCount | Should Be 2
        $report.Summary.Count | Should Be 2
        (Test-Path -LiteralPath $report.Output.DetailsPath) | Should Be $true
        (Test-Path -LiteralPath $report.Output.SummaryPath) | Should Be $true
    }
}

Describe 'Block-ToolkitThirdPartyAgent' {
    It 'rejects CSV files with missing required columns' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\invalid-agents.csv'
        @(
            [pscustomobject]@{
                Name = 'Agent A'
                Status = 'Available'
            }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        $errorMessage = $null

        try {
            Block-ToolkitThirdPartyAgent -CsvPath $path -VerifyWithGraph:$false -ErrorAction Stop | Out-Null
        }
        catch {
            $errorMessage = $_.Exception.Message
        }

        $errorMessage | Should Match 'Missing required CSV column'
    }

    It 'filters only third-party rows with title id and available status' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-filter.csv'
        @(
            [pscustomobject]@{ Name = 'ThirdPartyAvailable'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
            [pscustomobject]@{ Name = 'ThirdPartyBlocked'; Status = 'Blocked'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_2' }
            [pscustomobject]@{ Name = 'MicrosoftAvailable'; Status = 'Available'; 'Publisher Type' = 'Microsoft'; 'Title ID' = 'P_3' }
            [pscustomobject]@{ Name = 'ThirdPartyNoId'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = '' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            [pscustomobject]@{ displayName = 'ThirdPartyAvailable'; type = 'thirdParty'; isBlocked = $false }
        } -ModuleName Ledobs.M365PS.ToolKit

        Mock Invoke-ToolkitGraphRequestWithRetry {
            $null
        } -ModuleName Ledobs.M365PS.ToolKit -ParameterFilter { $Method -eq 'POST' }

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result.Count | Should Be 1
        $result[0].Name | Should Be 'ThirdPartyAvailable'
    }

    It 'skips packages already blocked in Graph' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-blocked.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            [pscustomobject]@{ displayName = 'Agent A'; type = 'thirdParty'; isBlocked = $true }
        } -ModuleName Ledobs.M365PS.ToolKit

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result[0].Result | Should Be 'AlreadyBlocked'
    }

    It 'returns graph lookup failure when package verification fails' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-lookup.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            throw '404 not found'
        } -ModuleName Ledobs.M365PS.ToolKit

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result[0].Result | Should Be 'GraphLookupFailed'
    }

    It 'returns blocked when block action succeeds' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-success.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            [pscustomobject]@{ displayName = 'Agent A'; type = 'thirdParty'; isBlocked = $false }
        } -ModuleName Ledobs.M365PS.ToolKit

        Mock Invoke-ToolkitGraphRequestWithRetry {
            $null
        } -ModuleName Ledobs.M365PS.ToolKit -ParameterFilter { $Method -eq 'POST' }

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result[0].Result | Should Be 'Blocked'
    }

    It 'returns failed when block action errors' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-failed.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            [pscustomobject]@{ displayName = 'Agent A'; type = 'thirdParty'; isBlocked = $false }
        } -ModuleName Ledobs.M365PS.ToolKit

        Mock Invoke-ToolkitGraphRequestWithRetry {
            throw '500 server error'
        } -ModuleName Ledobs.M365PS.ToolKit -ParameterFilter { $Method -eq 'POST' }

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result[0].Result | Should Be 'Failed'
    }
}

Describe 'Block-ToolkitThirdPartyAgent Graph type compatibility' {
    It 'accepts external as a valid third-party type' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-external.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            [pscustomobject]@{ displayName = 'Agent A'; type = 'external'; isBlocked = $false }
        } -ModuleName Ledobs.M365PS.ToolKit

        Mock Invoke-ToolkitGraphRequestWithRetry {
            $null
        } -ModuleName Ledobs.M365PS.ToolKit -ParameterFilter { $Method -eq 'POST' }

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result[0].Result | Should Be 'Blocked'
    }

    It 'skips unsupported Graph types' {
        $path = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\agents-unsupported.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8

        Mock Get-ToolkitCopilotPackage {
            [pscustomobject]@{ displayName = 'Agent A'; type = 'microsoft'; isBlocked = $false }
        } -ModuleName Ledobs.M365PS.ToolKit

        $result = Block-ToolkitThirdPartyAgent -CsvPath $path -SkipGraphConnect -Confirm:$false

        $result[0].Result | Should Be 'SkippedNotExternal'
    }
}

Describe 'Block-ThirdPartyAgentsFromAdminExport wrapper' {
    It 'invokes the module cmdlet with the expected parameters' {
        $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..\scripts\Block-ThirdPartyAgentsFromAdminExport.ps1'
        $csvPath = Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\wrapper-agents.csv'
        @(
            [pscustomobject]@{ Name = 'Agent A'; Status = 'Available'; 'Publisher Type' = 'ThirdParty'; 'Title ID' = 'P_1' }
        ) | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

        Mock Block-ToolkitThirdPartyAgent {
            @([pscustomobject]@{ Name = 'Agent A'; Result = 'WhatIf' })
        }

        & $scriptPath -CsvPath $csvPath -OutputPath (Join-Path -Path $PSScriptRoot -ChildPath 'artifacts\wrapper-out.csv') -VerifyWithGraph:$false -WhatIf | Out-Null

        Assert-MockCalled Block-ToolkitThirdPartyAgent -Times 1 -Exactly
    }
}
