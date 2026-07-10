[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,

    [Parameter()]
    [string]$OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath ("Block-ThirdPartyAgentsFromAdminExport-Results_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))),

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

$moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath '..\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1'
Import-Module $moduleManifest -Force

$invokeSplat = @{
    CsvPath           = $CsvPath
    OutputPath        = $OutputPath
    StatusToBlock     = $StatusToBlock
    VerifyWithGraph   = $VerifyWithGraph
    SkipGraphConnect  = $SkipGraphConnect
    MaxRetries        = $MaxRetries
    RetryDelaySeconds = $RetryDelaySeconds
    Confirm           = $false
}

if ($WhatIfPreference) {
    $invokeSplat.WhatIf = $true
}

Block-ToolkitThirdPartyAgent @invokeSplat
