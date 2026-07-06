function Get-ToolkitRepositoryRoot {
    [CmdletBinding()]
    param()

    Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent
}
