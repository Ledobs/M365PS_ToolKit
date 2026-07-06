function Get-ToolkitGraphContext {
    [CmdletBinding()]
    param()

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Get-MgContext
}
