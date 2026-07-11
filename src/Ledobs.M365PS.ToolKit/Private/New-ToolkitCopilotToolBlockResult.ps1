function New-ToolkitCopilotToolBlockResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Item,

        [Parameter()]
        [object]$GraphPackage,

        [Parameter(Mandatory = $true)]
        [string]$Action,

        [Parameter()]
        [string]$Result,

        [Parameter()]
        [string]$Error
    )

    $elementTypes = if ($GraphPackage) {
        @(Convert-ToolkitDelimitedStringToArray -Value $GraphPackage.elementTypes)
    }
    else {
        @(Convert-ToolkitDelimitedStringToArray -Value $Item.ElementTypes)
    }

    [pscustomobject]@{
        Name                 = $Item.Name
        PackageId            = if ($Item.PackageId) { $Item.PackageId } else { $Item.'Title ID' }
        Publisher            = if ($GraphPackage) { $GraphPackage.publisher } else { $Item.Publisher }
        GraphType            = if ($GraphPackage) { $GraphPackage.type } else { $Item.GraphType }
        ElementTypes         = ($elementTypes -join ';')
        GraphIsBlockedBefore = if ($GraphPackage) { $GraphPackage.isBlocked } else { $Item.IsBlocked }
        Action               = $Action
        Result               = $Result
        Error                = $Error
        TimestampUtc         = (Get-Date).ToUniversalTime().ToString('o')
    }
}
