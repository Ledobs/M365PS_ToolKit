# Carte de contexte

Objectif: retrouver vite les fichiers importants sans relire le dépôt au complet.

## Racine du projet

- Repo actif: `C:\Users\FrançoisBreton\OneDrive - Idexia\#1-R&D\AdminToolBox\Ledobs-M365PS_ToolKit`
- Dossier parent: `C:\Users\FrançoisBreton\OneDrive - Idexia\#1-R&D\AdminToolBox`
- Vault Obsidian du projet: `_obsidian-project/`
- Les notes Markdown du vault sont versionnées; `_obsidian-project/.obsidian/` reste local.

## Fichiers et dossiers importants

- `README.md`: documentation utilisateur et démarrage rapide.
- `plan-m365AdminToolkit.prompt.md`: plan initial produit/technique.
- `config/Toolkit.Config.example.psd1`: configuration exemple.
- `src/Ledobs.M365PS.ToolKit/`: module PowerShell.
- `src/Ledobs.M365PS.ToolKit/Public/`: fonctions publiques.
- `src/Ledobs.M365PS.ToolKit/Private/`: helpers internes.
- `src/Ledobs.M365PS.ToolKit/Public/New-AuditReport.ps1`: rapport combiné `signIns` + `directoryAudits`.
- `src/Ledobs.M365PS.ToolKit/Public/Block-ToolkitThirdPartyAgent.ps1`: moteur de blocage des agents tiers depuis CSV.
- `src/Ledobs.M365PS.ToolKit/Public/Get-ToolkitCopilotToolInventory.ps1`: inventaire Graph des outils Copilot du tenant.
- `src/Ledobs.M365PS.ToolKit/Public/Block-ToolkitNonMicrosoftTool.ps1`: moteur de blocage des outils non-Microsoft depuis l'inventaire Graph.
- `scripts/Block-ThirdPartyAgentsFromAdminExport.ps1`: wrapper admin pour exécuter le blocage.
- `scripts/Block-NonMicrosoftTools.ps1`: wrapper admin pour inventorier ou bloquer les outils non-Microsoft.
- `tests/`: tests Pester du module, à conserver versionnés.
- `C:\Users\FrançoisBreton\Downloads\Agents_test_block_3.csv`: mini CSV de test préparé pour la validation réelle.
- `C:\Users\FrançoisBreton\Downloads\Agents_2026-07-10_15_00_45.csv`: CSV complet à traiter pour le lot réel.
- `C:\Users\FrançoisBreton\Downloads\Agents_2026-07-10_19_19_35.csv`: autre export complet fourni ensuite par l'utilisateur.
- `C:\Users\FrançoisBreton\Downloads\Agents_2026-07-10_19_19_35_no-hubspot.csv`: copie filtrée sans la ligne HubSpot.
- `C:\Users\FrançoisBreton\Downloads\Agents_2026-07-10_20_01_52.csv`: export des agents tiers restant visibles après le lot massif.
- `C:\Users\FrançoisBreton\Downloads\Agents_2026-07-10_20_01_52_retry-no-hubspot.csv`: lot de reprise ciblé sur les agents restants hors HubSpot.
- `out/agents-test-whatif.csv`: rapport de test à blanc à relire après exécution dans un shell Graph connecté.
- `out/agents-full-batch.csv`: rapport cible pour l'exécution complète.
- `out/agents-no-hubspot-batch.csv`: rapport réel du lot massif sans HubSpot.
- `out/agents-retry-no-hubspot.csv`: rapport de reprise final sur le reliquat hors HubSpot.

## Commandes utiles

Depuis `Ledobs-M365PS_ToolKit`:

```powershell
git status --short --branch
git log --oneline -5
Import-Module .\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1 -Force
Test-ModuleManifest .\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1
Invoke-Pester -Path .\tests\Ledobs.M365PS.ToolKit.Tests.ps1
.\scripts\Block-ThirdPartyAgentsFromAdminExport.ps1 -CsvPath <csv> -OutputPath <csv> -WhatIf
.\\scripts\\Block-NonMicrosoftTools.ps1 -InventoryOnly -InventoryOutputPath <csv>
.\\scripts\\Block-NonMicrosoftTools.ps1 -InventoryPath <csv> -OutputPath <csv> -WhatIf
Connect-ToolkitAuth -Scopes 'CopilotPackages.ReadWrite.All'
```

## Conventions de reprise

- Lire `00-START-HERE.md` avant d'explorer le repo.
- Ne pas écraser les changements Git préexistants.
- Noter les décisions dans `02-DECISIONS.md` quand elles changent la suite du projet.
- Mettre à jour `03-BACKLOG.md` quand un item est terminé, bloqué ou remplacé.
- Rédiger les notes Markdown en français avec accents et caractères francophones normaux.

## État Git connu au moment de création du vault

Changements préexistants observés lors de la création du vault:

- `.gitignore` modifié.
- `README.md` modifié.
- `src/Ledobs.M365PS.ToolKit/Ledobs.M365PS.ToolKit.psd1` modifié.
- `tests/Ledobs.M365PS.ToolKit.Tests.ps1` supprimé.
- `tests/TestData/Toolkit.Config.test.psd1` supprimé.
- `src/Ledobs.M365PS.ToolKit/Public/New-AuditReport.ps1` non suivi.

Ces changements doivent être examinés séparément; ils ne font pas partie de la création du vault sauf si Git indique le contraire.

Évolution observée ensuite:

- La stratégie de tests a été corrigée: `tests/` doit rester suivi, et seul `tests/artifacts/` doit être ignoré.
- `New-AuditReport.ps1` a été validé localement avec Pester.
- Le state UI Obsidian n'est pas versionné.
- `Block-ToolkitThirdPartyAgent` a été validé localement avec Pester.
- Une validation manuelle `WhatIf` a été faite sur `C:\Users\FrançoisBreton\Downloads\Agents_2026-07-10_15_00_45.csv` sans vérification Graph réelle.
- Une validation `WhatIf` avec vérification Graph active a été faite sur `C:\Users\FrançoisBreton\Downloads\Agents_test_block_3.csv`.
- Résultat clé observé dans le tenant: `GraphType = thirdParty` sur les agents testés.
- Le correctif local accepte désormais `thirdParty` et `external`; la suite Pester est à `Passed: 16`.
- Attention de reprise: mes shells automatisés n'ont pas de `Get-MgContext`, donc les prochains tests tenant doivent repartir d'un shell PowerShell utilisateur déjà connecté à Graph.
- L'utilisateur a confirmé que le blocage réel fonctionne dans son shell connecté; l'exécution complète doit donc être lancée depuis ce même contexte utilisateur.
- Le CSV `Agents_2026-07-10_19_19_35.csv` contient uniquement des lignes `Status = Not available`; avec le filtre par défaut `Available`, le wrapper ne traitera rien.
- La ligne HubSpot de ce CSV est elle aussi `Not available`.
- Le lot sans HubSpot a réellement bloqué `81` packages.
- Les `27` agents encore visibles se répartissent en `1` exclusion volontaire (`HubSpot`) et `26` échecs Graph avec `FailedDependency`.
- L'utilisateur a confirmé ensuite que la reprise a abouti et que les agents restants sont maintenant bloqués.
- Nouvelle tranche locale validée: inventaire paginé et blocage des outils non-Microsoft, avec suite Pester à `Passed: 24`.
