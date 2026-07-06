# Ledobs M365PS ToolKit

Trousse PowerShell modulaire pour guider les administrateurs M365 lors de la mise en place du tenant.

Voir : `plan-m365AdminToolkit.prompt.md`

## Structure initiale

- `src/Ledobs.M365PS.ToolKit` : module PowerShell principal.
- `config/Toolkit.Config.example.psd1` : exemple de configuration.
- `tests/` : base de tests Pester.

## Fonctions disponibles

- `Connect-ToolkitAuth` : connexion Microsoft Graph en interactif ou app-only.
- `Export-ToolkitReport` : export CSV ou JSON des jeux de données collectés.
- `Get-ToolkitDirectoryAudit` : lecture des événements `directoryAudits` Microsoft Entra ID.
- `Assert-RequiredScopes` : validation des scopes Graph attendus.
- `Get-ToolkitConfig` : chargement de la configuration toolkit.
- `Get-ToolkitSignIn` : lecture des événements `signIns` Microsoft Entra ID.
- `Get-TenantBaseline` : lecture des paramètres de base du tenant à partir de la config et du contexte Graph.
- `Initialize-ToolkitLogging` : initialisation du dossier et du fichier de log.
- `Write-ToolkitLog` : journalisation JSONL structurée.

## Démarrage rapide

```powershell
Import-Module .\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1 -Force

$config = Get-ToolkitConfig
$logState = Initialize-ToolkitLogging
Write-ToolkitLog -Level Info -Message 'Toolkit initialized' -Data @{
    TenantId = $config.Tenant.TenantId
}
```

Par défaut, `Get-ToolkitConfig` charge `config\Toolkit.Config.local.psd1` si le fichier existe, sinon bascule sur `config\Toolkit.Config.example.psd1`.

## Exemple reporting

```powershell
Connect-ToolkitAuth -Scopes 'AuditLog.Read.All', 'Directory.Read.All'

$signIns = Get-ToolkitSignIn -From (Get-Date).AddDays(-1) -To (Get-Date)
$signIns | Export-ToolkitReport -Path '.\out\signins.csv' -Format Csv
```

Inspiration:
- https://github.com/microsoft/Microsoft365DSC
- https://github.com/microsoftgraph/dataconnect-solutions
- https://github.com/Ledobs/Audit365-Governance
- https://github.com/Ledobs/M365_PSToolkit
- https://github.com/tonipohl/M365AgentGovernance
