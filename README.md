# Ledobs M365PS ToolKit

Trousse PowerShell modulaire pour guider les administrateurs M365 lors de la mise en place du tenant.

Voir : `plan-m365AdminToolkit.prompt.md`

## Structure initiale

- `src/Ledobs.M365PS.ToolKit` : module PowerShell principal.
- `config/Toolkit.Config.example.psd1` : exemple de configuration.
- `tests/` : suite Pester minimale du module.

## Fonctions disponibles

- `Block-ToolkitNonMicrosoftTool` : blocage en lot des outils non-Microsoft depuis l’inventaire Graph.
- `Block-ToolkitThirdPartyAgent` : blocage des agents tiers depuis un CSV exporté du centre d'administration M365.
- `Connect-ToolkitAuth` : connexion Microsoft Graph en interactif ou app-only.
- `Export-ToolkitReport` : export CSV ou JSON des jeux de données collectés.
- `Get-ToolkitCopilotToolInventory` : inventaire Graph des outils Copilot disponibles dans le tenant.
- `Get-ToolkitDirectoryAudit` : lecture des événements `directoryAudits` Microsoft Entra ID.
- `Assert-RequiredScopes` : validation des scopes Graph attendus.
- `Get-ToolkitConfig` : chargement de la configuration toolkit.
- `Get-ToolkitSignIn` : lecture des événements `signIns` Microsoft Entra ID.
- `Get-TenantBaseline` : lecture des paramètres de base du tenant à partir de la config et du contexte Graph.
- `Initialize-ToolkitLogging` : initialisation du dossier et du fichier de log.
- `New-AuditReport` : rapport combiné `signIns` + `directoryAudits`, avec synthèse et export.
- `Write-ToolkitLog` : journalisation JSONL structurée.

## Démarrage rapide

Prérequis :
- PowerShell 7+
- module `Microsoft.Graph.Authentication`
- pour `Get-ToolkitDirectoryAudit` et `Get-ToolkitSignIn` : droits Microsoft Graph `AuditLog.Read.All` et `Directory.Read.All`

1. Depuis la racine du repo, créez un fichier `config\Toolkit.Config.local.psd1` à partir de `config\Toolkit.Config.example.psd1`.
2. Renseignez au minimum `Tenant.TenantId` et `Tenant.Domain`.
3. Importez le module.
4. Initialisez la configuration et les logs.

```powershell
# Depuis la racine du dépôt
Import-Module .\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1 -Force

$config = Get-ToolkitConfig
$logState = Initialize-ToolkitLogging

Write-ToolkitLog -Level Info -Message 'Toolkit initialized' -Data @{
    TenantId = $config.Tenant.TenantId
    LogFile  = $logState.LogFile
}
```

Par défaut, `Get-ToolkitConfig` charge `config\Toolkit.Config.local.psd1` si le fichier existe, sinon bascule sur `config\Toolkit.Config.example.psd1`.

Exemple de lecture de la baseline locale :

```powershell
$baseline = Get-TenantBaseline
$baseline.Checks | Format-Table -AutoSize
```

Exemple de connexion Microsoft Graph en mode interactif :

```powershell
Connect-ToolkitAuth -Scopes 'AuditLog.Read.All', 'Directory.Read.All'
```

Exemple d’export des connexions des 24 dernières heures :

```powershell
$outputPath = '.\out\signins-last-24h.csv'

$signIns = Get-ToolkitSignIn -From (Get-Date).AddDays(-1) -To (Get-Date)
$signIns | Export-ToolkitReport -Path $outputPath -Format Csv
```

Exemple d’export des audits Entra ID sur 7 jours :

```powershell
$auditPath = '.\out\directory-audits-last-7d.json'

$audits = Get-ToolkitDirectoryAudit -From (Get-Date).AddDays(-7) -To (Get-Date)
$audits | Export-ToolkitReport -Path $auditPath -Format Json
```

Exemple de rapport d’audit combiné :

```powershell
$report = New-AuditReport `
    -From (Get-Date).AddDays(-7) `
    -To (Get-Date) `
    -OutputPath '.\out\weekly-audit' `
    -Format Csv

$report.Summary | Format-Table -AutoSize
```

## Gestion des agents tiers

Prérequis :
- PowerShell 7+
- module `Microsoft.Graph.Authentication`
- permission Microsoft Graph `CopilotPackages.ReadWrite.All`
- accès au Package Management API Microsoft Agent 365

Limites connues :
- la sélection dépend du `Title ID` présent dans l'export CSV du centre d'administration
- l'action de blocage utilise un endpoint `/beta`
- l'état UI et l'état Graph peuvent différer temporairement selon la propagation côté service

Format CSV attendu :
- `Name`
- `Status`
- `Publisher Type`
- `Title ID`

Exemple `WhatIf` depuis le module :

```powershell
Connect-ToolkitAuth -Scopes 'CopilotPackages.ReadWrite.All'

Block-ToolkitThirdPartyAgent `
  -CsvPath 'C:\Exports\Agents_2026-07-10_15_00_45.csv' `
  -OutputPath '.\out\third-party-block-results.csv' `
  -WhatIf
```

Exemple d'exécution réelle :

```powershell
Connect-ToolkitAuth -Scopes 'CopilotPackages.ReadWrite.All'

Block-ToolkitThirdPartyAgent `
  -CsvPath 'C:\Exports\Agents_2026-07-10_15_00_45.csv' `
  -OutputPath '.\out\third-party-block-results.csv'
```

Exemple via script wrapper :

```powershell
.\scripts\Block-ThirdPartyAgentsFromAdminExport.ps1 `
  -CsvPath 'C:\Exports\Agents_2026-07-10_15_00_45.csv' `
  -OutputPath '.\out\third-party-block-results.csv' `
  -WhatIf
```

## Gestion des outils non-Microsoft

Prérequis :
- PowerShell 7+
- module `Microsoft.Graph.Authentication`
- permission Microsoft Graph `CopilotPackages.ReadWrite.All` pour le blocage
- accès au Package Management API Microsoft Agent 365

Limites connues :
- la vue **Agents > Outils** est gérée ici avec une approche Graph-first
- l’action de blocage utilise un endpoint `/beta`
- certains éléments de la vue admin peuvent ne pas remonter exactement comme attendu dans `copilot/admin/catalog/packages` selon l’état du service preview

Exemple d’inventaire :

```powershell
Connect-ToolkitAuth -Scopes 'CopilotPackages.Read.All'

Get-ToolkitCopilotToolInventory `
  -OutputPath '.\out\tools-inventory.csv'
```

Exemple `WhatIf` de blocage des outils non-Microsoft :

```powershell
Connect-ToolkitAuth -Scopes 'CopilotPackages.ReadWrite.All'

Block-ToolkitNonMicrosoftTool `
  -InventoryPath '.\out\tools-inventory.csv' `
  -OutputPath '.\out\block-non-microsoft-tools.csv' `
  -WhatIf
```

Comportement opérationnel de `Block-ToolkitNonMicrosoftTool` :
- la cmdlet lit `tools-inventory.csv` via `-InventoryPath`, ou génère un inventaire Graph si aucun inventaire n'est fourni
- avec la politique par défaut, tout package dont `Publisher` n'est pas `Microsoft Corporation` est candidat au blocage
- avec `-WhatIf`, aucun outil n'est réellement bloqué ; le rapport indique seulement ce qui serait tenté
- sans `-WhatIf`, la cmdlet tente de bloquer tous les éléments éligibles du CSV fourni
- il n'existe pas encore d'approbation interactive ligne par ligne dans la cmdlet
- pour bloquer seulement certains outils non-Microsoft, il faut préparer un CSV approuvé contenant uniquement les lignes souhaitées

En pratique :
1. générer `tools-inventory.csv`
2. relire le CSV
3. créer une copie approuvée, par exemple `tools-inventory-approved.csv`
4. lancer `Block-ToolkitNonMicrosoftTool` sur ce CSV en `-WhatIf`
5. lancer ensuite l'exécution réelle sans `-WhatIf`

Exemple recommandé :

```powershell
Get-ToolkitCopilotToolInventory -OutputPath '.\out\tools-inventory.csv'
```

Puis :

```powershell
Block-ToolkitNonMicrosoftTool `
  -InventoryPath '.\out\tools-inventory-approved.csv' `
  -OutputPath '.\out\block-non-microsoft-tools.csv' `
  -WhatIf
```

Puis la même commande sans `-WhatIf`.

Exemple d’exécution réelle :

```powershell
Connect-ToolkitAuth -Scopes 'CopilotPackages.ReadWrite.All'

Block-ToolkitNonMicrosoftTool `
  -InventoryPath '.\out\tools-inventory.csv' `
  -OutputPath '.\out\block-non-microsoft-tools.csv'
```

Exemple via wrapper :

```powershell
.\scripts\Block-NonMicrosoftTools.ps1 `
  -InventoryOnly `
  -InventoryOutputPath '.\out\tools-inventory.csv'

.\scripts\Block-NonMicrosoftTools.ps1 `
  -InventoryPath '.\out\tools-inventory.csv' `
  -OutputPath '.\out\block-non-microsoft-tools.csv' `
  -WhatIf
```

Limites v1 :
- pas d'approbation interactive ligne par ligne
- pas encore de filtrage natif par `Name`, `PackageId` ou liste explicite d'IDs
- la sélection ciblée repose sur la préparation manuelle d'un CSV d'inventaire réduit
- `PublisherAllowList` et `ElementTypeAllowList` restent des garde-fous complémentaires, pas un mécanisme d'approbation métier

Inspiration:
- https://github.com/microsoft/Microsoft365DSC
- https://github.com/microsoftgraph/dataconnect-solutions
- https://github.com/Ledobs/Audit365-Governance
- https://github.com/Ledobs/M365_PSToolkit
- https://github.com/tonipohl/M365AgentGovernance
