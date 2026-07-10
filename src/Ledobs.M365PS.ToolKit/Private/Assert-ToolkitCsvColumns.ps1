function Assert-ToolkitCsvColumns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Rows,

        [Parameter(Mandatory = $true)]
        [string[]]$RequiredColumns
    )

    if (-not $Rows -or $Rows.Count -eq 0) {
        throw 'The CSV file is empty.'
    }

    $availableColumns = @($Rows[0].PSObject.Properties.Name)
    $missingColumns = @($RequiredColumns | Where-Object { $_ -notin $availableColumns })

    if ($missingColumns.Count -gt 0) {
        throw "Missing required CSV column(s): $($missingColumns -join ', ')"
    }
}
