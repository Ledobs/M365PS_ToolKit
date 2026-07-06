function Export-ToolkitReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]]$InputObject,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [ValidateSet('Csv', 'Json')]
        [string]$Format = 'Csv'
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
    }

    process {
        foreach ($item in $InputObject) {
            $buffer.Add($item)
        }
    }

    end {
        $directory = Split-Path -Path $Path -Parent
        if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }

        switch ($Format) {
            'Csv' {
                $buffer | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
            }
            'Json' {
                $buffer | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
            }
        }

        Get-Item -LiteralPath $Path
    }
}
