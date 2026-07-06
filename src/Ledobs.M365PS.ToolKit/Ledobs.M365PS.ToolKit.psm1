$moduleRoot = $PSScriptRoot
$publicPath = Join-Path -Path $moduleRoot -ChildPath 'Public'
$privatePath = Join-Path -Path $moduleRoot -ChildPath 'Private'

foreach ($path in @($privatePath, $publicPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        continue
    }

    foreach ($file in Get-ChildItem -LiteralPath $path -Filter '*.ps1' -File | Sort-Object Name) {
        . $file.FullName
    }
}

$publicFunctions = @(
    Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File |
        Sort-Object BaseName |
        Select-Object -ExpandProperty BaseName
)

Export-ModuleMember -Function $publicFunctions
