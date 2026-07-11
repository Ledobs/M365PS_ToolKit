[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter()]
    [string]$InventoryPath,

    [Parameter()]
    [string]$InventoryOutputPath = (Join-Path -Path $PSScriptRoot -ChildPath ("Tool-Inventory_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))),

    [Parameter()]
    [string]$OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath ("Block-NonMicrosoftTools-Results_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))),

    [Parameter()]
    [switch]$InventoryOnly,

    [Parameter()]
    [switch]$VerifyWithGraph = $true,

    [Parameter()]
    [switch]$SkipGraphConnect,

    [Parameter()]
    [string[]]$PublisherAllowList = @('Microsoft Corporation'),

    [Parameter()]
    [switch]$IncludeAlreadyBlocked,

    [Parameter()]
    [string[]]$ElementTypeAllowList,

    [Parameter()]
    [int]$MaxRetries = 3,

    [Parameter()]
    [int]$RetryDelaySeconds = 5
)

$moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath '..\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1'
Import-Module $moduleManifest -Force

if ($InventoryOnly) {
    Get-ToolkitCopilotToolInventory `
        -OutputPath $InventoryOutputPath `
        -PublisherAllowList $PublisherAllowList `
        -SkipGraphConnect:$SkipGraphConnect `
        -MaxRetries $MaxRetries `
        -RetryDelaySeconds $RetryDelaySeconds

    return
}

$invokeSplat = @{
    OutputPath            = $OutputPath
    VerifyWithGraph       = $VerifyWithGraph
    SkipGraphConnect      = $SkipGraphConnect
    PublisherAllowList    = $PublisherAllowList
    IncludeAlreadyBlocked = $IncludeAlreadyBlocked
    ElementTypeAllowList  = $ElementTypeAllowList
    MaxRetries            = $MaxRetries
    RetryDelaySeconds     = $RetryDelaySeconds
    Confirm               = $false
}

if ($InventoryPath) {
    $invokeSplat.InventoryPath = $InventoryPath
}

if ($WhatIfPreference) {
    $invokeSplat.WhatIf = $true
}

Block-ToolkitNonMicrosoftTool @invokeSplat
