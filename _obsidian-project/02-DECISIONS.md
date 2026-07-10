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
