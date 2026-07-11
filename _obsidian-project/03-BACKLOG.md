# Backlog

Priorités indicatives. Garder les items actionnables et déplacer les détails longs vers le journal ou les décisions.

## P0 - Reprise et hygiène de projet

- Ouvrir `_obsidian-project/` comme vault Obsidian.
- À chaque fin de session, mettre à jour `00-START-HERE.md` et ajouter une entrée dans `01-SESSION-LOG.md`.
- Clarifier l'état des changements Git préexistants avant tout nouveau chantier technique.
- Maintenir les notes Markdown en français accentué.

## P1 - Toolkit PowerShell

- Étendre le toolkit avec d'autres opérations agents si besoin: déblocage, rapports de synthèse, relances ciblées.
- Valider sur tenant réel `Get-ToolkitCopilotToolInventory` et `Block-ToolkitNonMicrosoftTool`.
- Ajuster la qualification des outils si le tenant révèle des `elementTypes` ou catégories inattendues.

## P2 - Reporting et gouvernance

- Étendre `New-AuditReport` vers HTML/Markdown si utile.
- Ajouter des synthèses spécialisées M365/Entra/SharePoint.

## P3 - Documentation et usage

- Garder le README centré sur l'utilisateur final du toolkit.
- Garder `_obsidian-project/` centré sur la reprise de travail et les décisions internes.
- Documenter les commandes de validation courantes dans `04-CONTEXT-MAP.md` quand elles sont confirmées.

## Terminé

- 2026-07-10: Planifier la mémoire de projet Obsidian dans le repo.
- 2026-07-10: Corriger les notes de suivi pour utiliser un français accentué.
- 2026-07-10: Clarifier que les tests restent versionnés et revalider la suite Pester locale.
- 2026-07-10: Implémenter la v1 du blocage des agents tiers depuis CSV avec wrapper admin et tests.
- 2026-07-10: Corriger `Block-ToolkitThirdPartyAgent` pour accepter `GraphType = thirdParty` et `external`.
- 2026-07-10: Valider en conditions réelles la campagne de blocage des agents tiers via CSV admin + Graph.
- 2026-07-10: Implémenter la v1 Graph-first du blocage des outils non-Microsoft avec cmdlets, wrapper et tests.
