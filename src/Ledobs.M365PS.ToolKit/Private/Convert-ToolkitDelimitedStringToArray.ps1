function Convert-ToolkitDelimitedStringToArray {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [System.Array]) {
        return @($Value | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    }

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) {
        return @()
    }

    return @(
        $text.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries) |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
}
