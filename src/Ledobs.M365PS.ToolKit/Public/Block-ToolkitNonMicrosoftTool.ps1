<#
.SYNOPSIS
Blocage en lot des outils Copilot dont l'éditeur n'est pas Microsoft.

.DESCRIPTION
La cmdlet lit un inventaire Graph existant via -InventoryPath, ou génère un inventaire en direct
si aucun fichier n'est fourni. Avec la politique par défaut, tout package dont Publisher n'est pas
'Microsoft Corporation' est candidat au blocage.

En mode -WhatIf, aucun blocage réel n'est exécuté. La cmdlet produit seulement le rapport de ce
qu'elle tenterait de bloquer. Sans -WhatIf, elle tente de bloquer tous les éléments éligibles
présents dans le CSV fourni ou dans l'inventaire généré.

La v1 n'inclut pas d'approbation interactive ligne par ligne. Pour bloquer seulement certains
outils non-Microsoft, il faut préparer un CSV approuvé contenant uniquement les lignes souhaitées,
puis utiliser ce CSV avec -InventoryPath.
#>
function Block-ToolkitNonMicrosoftTool {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [ValidateScript({
            if (-not (Test-Path -LiteralPath $_ -PathType Leaf)) {
                throw "Inventory file not found: $_"
            }
            $true
        })]
        [string]$InventoryPath,

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

    if ($VerifyWithGraph) {
        Connect-ToolkitCopilotPackageCatalog -SkipGraphConnect:$SkipGraphConnect -RequireWrite
    }

    if ($InventoryPath) {
        $inventoryRows = @(Import-Csv -LiteralPath $InventoryPath)
        Assert-ToolkitCsvColumns -Rows $inventoryRows -RequiredColumns @(
            'Name',
            'PackageId',
            'Publisher',
            'ElementTypes',
            'IsBlocked'
        )
    }
    else {
        $inventoryRows = @(Get-ToolkitCopilotToolInventory -PublisherAllowList $PublisherAllowList -SkipGraphConnect -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds)
    }

    $results = New-Object System.Collections.Generic.List[object]

    foreach ($item in $inventoryRows) {
        $packageId = if ($item.PackageId) { [string]$item.PackageId } else { [string]$item.'Title ID' }
        if ([string]::IsNullOrWhiteSpace($packageId)) {
            continue
        }

        $inventoryPublisher = [string]$item.Publisher
        $inventoryIsBlocked = $item.IsBlocked -eq $true -or [string]$item.IsBlocked -eq 'True'
        $inventoryElementTypes = @(Convert-ToolkitDelimitedStringToArray -Value $item.ElementTypes)

        if ($inventoryPublisher -in $PublisherAllowList) {
            $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -Action 'Block' -Result 'SkippedAllowedPublisher' -Error 'Allowed publisher.'))
            continue
        }

        if ($ElementTypeAllowList.Count -gt 0) {
            $matchesElementType = @($inventoryElementTypes | Where-Object { $_ -in $ElementTypeAllowList }).Count -gt 0
            if (-not $matchesElementType) {
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -Action 'Block' -Result 'SkippedElementType' -Error 'Element type is outside the allowed list.'))
                continue
            }
        }

        if (-not $VerifyWithGraph -and $inventoryIsBlocked) {
            if ($IncludeAlreadyBlocked) {
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -Action 'Block' -Result 'AlreadyBlocked'))
            }
            continue
        }

        $graphPackage = $null
        if ($VerifyWithGraph) {
            try {
                $graphPackage = Get-ToolkitCopilotPackage -PackageId $packageId -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds
            }
            catch {
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -Action 'Block' -Result 'GraphLookupFailed' -Error $_.Exception.Message))
                continue
            }

            if (-not $graphPackage) {
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -Action 'Block' -Result 'PackageNotFound' -Error 'Package not returned by Graph.'))
                continue
            }

            if ($graphPackage.publisher -in $PublisherAllowList) {
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -GraphPackage $graphPackage -Action 'Block' -Result 'SkippedAllowedPublisher' -Error 'Allowed publisher.'))
                continue
            }

            if ($ElementTypeAllowList.Count -gt 0) {
                $graphElementTypes = @(Convert-ToolkitDelimitedStringToArray -Value $graphPackage.elementTypes)
                $matchesElementType = @($graphElementTypes | Where-Object { $_ -in $ElementTypeAllowList }).Count -gt 0
                if (-not $matchesElementType) {
                    $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -GraphPackage $graphPackage -Action 'Block' -Result 'SkippedElementType' -Error 'Element type is outside the allowed list.'))
                    continue
                }
            }

            if ($graphPackage.isBlocked -eq $true) {
                if ($IncludeAlreadyBlocked -or -not $InventoryPath) {
                    $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -GraphPackage $graphPackage -Action 'Block' -Result 'AlreadyBlocked'))
                }
                continue
            }
        }

        $blockUri = "https://graph.microsoft.com/beta/copilot/admin/catalog/packages/$packageId/block"
        if ($PSCmdlet.ShouldProcess("$($item.Name) [$packageId]", 'Block Copilot tool package')) {
            try {
                Invoke-ToolkitGraphRequestWithRetry -Method POST -Uri $blockUri -MaxRetries $MaxRetries -RetryDelaySeconds $RetryDelaySeconds | Out-Null
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -GraphPackage $graphPackage -Action 'Block' -Result 'Blocked'))
            }
            catch {
                $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -GraphPackage $graphPackage -Action 'Block' -Result 'Failed' -Error $_.Exception.Message))
            }
        }
        else {
            $results.Add((New-ToolkitCopilotToolBlockResult -Item $item -GraphPackage $graphPackage -Action 'Block' -Result 'WhatIf'))
        }
    }

    if ($OutputPath) {
        $results | Export-ToolkitReport -Path $OutputPath -Format Csv | Out-Null
    }

    $results.ToArray()
}
