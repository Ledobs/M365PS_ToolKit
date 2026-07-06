function Invoke-ToolkitGraphCollectionRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri
    )

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

    $items = New-Object System.Collections.Generic.List[object]
    $nextUri = $Uri

    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $nextUri

        if ($response.value) {
            foreach ($item in $response.value) {
                $items.Add($item)
            }
        }

        $nextUri = $response.'@odata.nextLink'
    }
    while ($nextUri)

    $items
}
