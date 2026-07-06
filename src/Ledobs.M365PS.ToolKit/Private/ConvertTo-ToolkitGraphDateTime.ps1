function ConvertTo-ToolkitGraphDateTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [datetime]$DateTime
    )

    $DateTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}
