# START HERE - Mémoire de projet

Dernière mise à jour: 2026-07-10

## Règle de reprise

1. Lire ce fichier en premier.
2. Lire seulement les notes pointées par `Contexte à charger`.
3. Éviter de relire tout le repo si le prochain pas est clair.
4. En fin de session, mettre à jour `Dernier delta`, `Prochain pas exact`, `01-SESSION-LOG.md`, et les décisions/backlog si nécessaire.

## État actuel

Le projet actif est `Ledobs-M365PS_ToolKit`, un module PowerShell pour outiller l'administration et l'audit Microsoft 365.

Le repo contient déjà une base fonctionnelle avec:

- un module PowerShell sous `src/Ledobs.M365PS.ToolKit`;
- une configuration exemple sous `config/Toolkit.Config.example.psd1`;
- un README utilisateur;
- un plan initial dans `plan-m365AdminToolkit.prompt.md`.

État Git observé le 2026-07-10 avant création de ce vault:

- branche `main`, alignée avec `origin/main`;
- changements préexistants dans `.gitignore`, `README.md`, `src/Ledobs.M365PS.ToolKit/Ledobs.M365PS.ToolKit.psd1`;
- suppressions préexistantes dans `tests/Ledobs.M365PS.ToolKit.Tests.ps1` et `tests/TestData/Toolkit.Config.test.psd1`;
- nouveau fichier préexistant `src/Ledobs.M365PS.ToolKit/Public/New-AuditReport.ps1`.

Ne pas supposer que ces changements viennent de la session courante.

## Objectif actif

Stabiliser l'état Git et la base qualité du module avant d'élargir les fonctionnalités, puis poursuivre le développement du reporting et des cmdlets d'administration M365.

## Dernier delta

2026-07-10:

- Relecture de la mémoire Obsidian et clarification de l'état Git réel.
- Vérification que `New-AuditReport.ps1` est cohérent avec le manifeste et le README.
- Restauration de la stratégie voulue pour les tests: `tests/` reste versionné; seuls `tests/artifacts/` sont ignorés.
- Validation locale du module: manifeste OK, import OK, Pester OK (`Passed: 7`).

## Prochain pas exact

1. Régulariser l'index Git en réintégrant `tests/` comme contenu suivi.
2. Décider si la tranche `New-AuditReport` doit être commitée telle quelle avec la correction `.gitignore`/README.
3. Après stabilisation Git, attaquer la prochaine tranche technique: amélioration de `New-AuditReport` ou première cmdlet de baseline réelle.

## Contexte à charger

- Toujours: `00-START-HERE.md`.
- Pour comprendre les jalons: `01-SESSION-LOG.md`.
- Pour éviter de rouvrir des débats: `02-DECISIONS.md`.
- Pour choisir le travail suivant: `03-BACKLOG.md`.
- Pour retrouver rapidement les fichiers et commandes: `04-CONTEXT-MAP.md`.

## Convention linguistique

- Rédiger les fichiers Markdown de suivi en français.
- Utiliser les accents, apostrophes et caractères francophones normaux.
- Éviter l'ASCII forcé dans les notes Markdown, sauf contrainte technique explicite.

## Bloc standard de fin de session

Copier cette structure dans `01-SESSION-LOG.md` et mettre à jour ce fichier:

```markdown
## YYYY-MM-DD - Titre court

État atteint:

- ...

Delta depuis la session précédente:

- ...

Décisions:

- ...

Fichiers modifiés:

- ...

Tests/validations:

- ...

Prochain pas exact:

- ...
```
