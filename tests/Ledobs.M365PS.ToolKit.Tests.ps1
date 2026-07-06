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
