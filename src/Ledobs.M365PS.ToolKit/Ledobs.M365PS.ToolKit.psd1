@{
    RootModule        = 'Ledobs.M365PS.ToolKit.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '8bf9d6ad-b4fc-4372-b6f4-8a0bf628d1c1'
    Author            = 'Ledobs'
    CompanyName       = 'Ledobs'
    Copyright         = '(c) Ledobs. All rights reserved.'
    Description       = 'Toolkit PowerShell pour l''administration, l''audit et le durcissement Microsoft 365.'
    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        'Assert-RequiredScopes',
        'Connect-ToolkitAuth',
        'Get-ToolkitConfig',
        'Get-TenantBaseline',
        'Initialize-ToolkitLogging',
        'Write-ToolkitLog'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags       = @('Microsoft365', 'Graph', 'Security', 'Audit', 'PowerShell')
            ProjectUri = 'https://github.com/Ledobs/M365PS_ToolKit'
        }
    }
}
