# Décisions

Format:

```markdown
## YYYY-MM-DD - Décision courte

Contexte:
- ...

Décision:
- ...

Conséquence:
- ...
```

## 2026-07-10 - Vault Obsidian dans le repo

Contexte:

- Le contexte de conversation peut être perdu entre sessions.
- Le projet a besoin d'un point de reprise stable et peu coûteux en tokens.
- L'utilisateur a Obsidian localement et préfère l'employer.

Décision:

- Créer un vault Obsidian directement dans `Ledobs-M365PS_ToolKit/_obsidian-project/`.

Conséquence:

- Les notes peuvent être versionnées avec le code.
- Le point de reprise reste proche du projet.
- Les sessions futures doivent commencer par `00-START-HERE.md`.

## 2026-07-10 - Résumé court avant contexte complet

Contexte:

- Relire tout le repo ou tout l'historique consomme beaucoup de tokens.

Décision:

- `00-START-HERE.md` est la source de reprise minimale.
- Les autres notes ne sont lues que si le prochain pas le demande.

Conséquence:

- Le fichier d'entrée doit rester court, à jour, et orienter vers les notes pertinentes.

## 2026-07-10 - Français accentué dans les notes Markdown

Contexte:

- Les premières notes ont été créées en ASCII, ce qui rendait le français moins naturel.
- L'utilisateur veut que les fichiers Markdown soient commentés en français avec les caractères francophones appropriés.

Décision:

- Rédiger les notes Markdown de suivi en français accentué.
- Utiliser les accents, apostrophes et caractères francophones normaux.

Conséquence:

- Les prochaines mises à jour Markdown doivent conserver l'encodage UTF-8 et éviter l'ASCII forcé.

## 2026-07-10 - Les tests restent versionnés

Contexte:

- Une session antérieure a modifié `.gitignore` pour exclure tout le dossier `tests/`.
- Or le module dispose d'une suite Pester minimale utile pour valider la surface publique et `New-AuditReport`.
- Exclure tout `tests/` affaiblit la maintenance et rend le repo incohérent avec le README et les validations locales.

Décision:

- Garder `tests/` versionné dans Git.
- Ignorer uniquement `tests/artifacts/`.

Conséquence:

- Les suppressions Git actuelles sur `tests/` doivent être régularisées en réintégrant les fichiers de test.
- Les futures validations Pester peuvent rester traçables dans le repo.

## 2026-07-10 - Le state UI Obsidian n'est pas versionné

Contexte:

- Le vault `_obsidian-project/` contient des notes Markdown utiles au projet.
- Il contient aussi un sous-dossier `.obsidian/` généré par l'outil et lié à l'interface locale.
- Ce state varie d'une machine à l'autre et apporte peu de valeur au code ou à la reprise.

Décision:

- Versionner les notes Markdown du vault.
- Ignorer `_obsidian-project/.obsidian/`.

Conséquence:

- Le repo garde la mémoire projet sans embarquer la configuration UI locale d'Obsidian.

## 2026-07-10 - V1 agents tiers en double forme

Contexte:

- Le besoin porte sur le blocage des agents tiers M365 à partir d'un export CSV admin.
- L'usage visé couvre à la fois l'intégration durable dans le toolkit et un mode script simple pour un admin.

Décision:

- Implémenter une cmdlet module `Block-ToolkitThirdPartyAgent`.
- Ajouter un script wrapper `scripts/Block-ThirdPartyAgentsFromAdminExport.ps1`.

Conséquence:

- La logique métier reste centralisée dans le module.
- Le script wrapper reste léger et sans duplication de comportement.

## 2026-07-10 - V1 agents tiers basée sur CSV avec vérification Graph

Contexte:

- Le centre d'administration expose un export CSV contenant `Title ID`, `Status` et `Publisher Type`.
- Le besoin utilisateur veut reproduire le workflow UI, mais avec une validation côté Graph avant action.

Décision:

- La sélection des cibles part du CSV.
- Le blocage ne se fait qu'après une vérification Graph du package par `Title ID`.
- Le périmètre v1 reste limité au blocage, pas au déblocage.

Conséquence:

- Le CSV reste l'entrée opératoire principale.
- Une session Graph avec `CopilotPackages.ReadWrite.All` est requise pour le mode complet.
- Le déblocage sera un chantier séparé.

## 2026-07-10 - Les types Graph tiers supportés sont `thirdParty` et `external`

Contexte:

- Le test `WhatIf` avec vérification Graph active a été exécuté sur des agents tiers réels du tenant.
- Les packages testés ont renvoyé `GraphType = thirdParty` et non `external`.
- La v1 actuelle saute donc à tort les candidats avec `SkippedNotExternal`.

Décision:

- Considérer `thirdParty` comme la valeur observée de référence dans le tenant cible.
- Accepter aussi `external` en compatibilité défensive pour d'autres tenants ou variations de service.

Conséquence:

- La logique de filtrage Graph de `Block-ToolkitThirdPartyAgent` doit accepter les 2 valeurs.
- Les tests doivent couvrir explicitement `thirdParty`, `external` et un type hors périmètre.
- Les plans et validations suivants doivent s'appuyer sur cette réalité observée, pas sur l'hypothèse initiale `external` seule.

## 2026-07-10 - Les outils non-Microsoft sont gérés en Graph-first

Contexte:

- La vue `Agents > Outils` ne fournit pas d'export CSV exploitable comme la vue des agents.
- Le toolkit dispose déjà d'un moteur Graph robuste pour inventorier et bloquer des packages Copilot.
- La documentation Microsoft expose les packages Copilot avec `publisher`, `isBlocked`, `elementTypes` et l'action `block`.

Décision:

- Implémenter l'inventaire et le blocage des outils non-Microsoft à partir de `GET /copilot/admin/catalog/packages`.
- Garder l'Agent 365 CLI comme source de comparaison facultative seulement.
- Prendre `Microsoft Corporation` comme unique éditeur autorisé par défaut en v1.

Conséquence:

- Les futures validations doivent confirmer quelles catégories réelles de packages de la vue Outils remontent dans le catalogue Graph.
- Le blocage en lot des outils repose sur un inventaire Graph revu avant exécution réelle.
