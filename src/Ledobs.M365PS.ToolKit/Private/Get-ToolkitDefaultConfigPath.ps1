function Get-ToolkitDefaultConfigPath {
    [CmdletBinding()]
    param()

    $repoRoot = Get-ToolkitRepositoryRoot
    $localConfigPath = Join-Path -Path $repoRoot -ChildPath 'config\Toolkit.Config.local.psd1'

    if (Test-Path -LiteralPath $localConfigPath -PathType Leaf) {
        return $localConfigPath
    }

    Join-Path -Path $repoRoot -ChildPath 'config\Toolkit.Config.example.psd1'
}
