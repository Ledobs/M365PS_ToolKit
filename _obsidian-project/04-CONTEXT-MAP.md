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
- `tests/`: tests Pester du module, à conserver versionnés.

## Commandes utiles

Depuis `Ledobs-M365PS_ToolKit`:

```powershell
git status --short --branch
git log --oneline -5
Import-Module .\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1 -Force
Test-ModuleManifest .\src\Ledobs.M365PS.ToolKit\Ledobs.M365PS.ToolKit.psd1
Invoke-Pester -Path .\tests\Ledobs.M365PS.ToolKit.Tests.ps1
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
