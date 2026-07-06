function Initialize-ToolkitLogging {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path,

        [Parameter()]
        [switch]$StartTranscript
    )

    if (-not $Path) {
        $repoRoot = Get-ToolkitRepositoryRoot
        $Path = Join-Path -Path $repoRoot -ChildPath 'logs'
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }

    $script:ToolkitLogDirectory = (Resolve-Path -LiteralPath $Path).Path
    $script:ToolkitLogFile = Join-Path -Path $script:ToolkitLogDirectory -ChildPath ("toolkit-{0}.jsonl" -f (Get-Date -Format 'yyyyMMdd'))

    if (-not (Test-Path -LiteralPath $script:ToolkitLogFile -PathType Leaf)) {
        New-Item -Path $script:ToolkitLogFile -ItemType File -Force | Out-Null
    }

    if ($StartTranscript) {
        $transcriptPath = Join-Path -Path $script:ToolkitLogDirectory -ChildPath ("transcript-{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
        Start-Transcript -Path $transcriptPath -Force | Out-Null
    }

    [pscustomobject]@{
        LogDirectory = $script:ToolkitLogDirectory
        LogFile      = $script:ToolkitLogFile
    }
}
