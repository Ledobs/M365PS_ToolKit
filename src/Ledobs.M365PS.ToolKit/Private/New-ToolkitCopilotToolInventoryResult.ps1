function New-ToolkitCopilotToolInventoryResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Package,

        [Parameter()]
        [string[]]$PublisherAllowList = @('Microsoft Corporation')
    )

    $publisher = [string]$Package.publisher
    $isAllowedPublisher = $publisher -in $PublisherAllowList
    $isBlocked = $Package.isBlocked -eq $true
    $elementTypes = @(Convert-ToolkitDelimitedStringToArray -Value $Package.elementTypes)
    $supportedHosts = @(Convert-ToolkitDelimitedStringToArray -Value $Package.supportedHosts)

    $blockCandidate = (-not $isAllowedPublisher) -and (-not $isBlocked)
    $blockReason = if ($isAllowedPublisher) {
        'Allowed publisher.'
    }
    elseif ($isBlocked) {
        'Already blocked.'
    }
    else {
        'Non-Microsoft publisher.'
    }

    [pscustomobject]@{
        Name                 = $Package.displayName
        PackageId            = $Package.id
        Publisher            = $publisher
        GraphType            = $Package.type
        ElementTypes         = ($elementTypes -join ';')
        SupportedHosts       = ($supportedHosts -join ';')
        Platform             = $Package.platform
        IsBlocked            = $isBlocked
        LastModifiedDateTime = $Package.lastModifiedDateTime
        BlockCandidate       = $blockCandidate
        BlockReason          = $blockReason
    }
}
