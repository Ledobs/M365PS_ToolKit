## Plan: Trousse d'administration M365 — Mise en place & Audit (Québec)

TL;DR - Créer une trousse PowerShell modulaire pour guider les administrateurs M365 lors de la mise en place, durcissement et exploitation quotidienne d'un tenant conforme aux bonnes pratiques et aux exigences réglementaires du Québec (p. ex. Loi 25). Approche : fournir des modules réutilisables (auth, config, logging, reporting, audit), des scripts d'automatisation, des modèles de rapports et une documentation d'implémentation / vérification.

**Steps**
1. Discovery: inventorier scripts existants et gap analysis (*done*: voir `Agent365-Toolkit/Block-ThirdPartyAgentsFromAdminExport.ps1`).
2. Design API surface: définir les cmdlets publiques du module (ex: `Connect-ToolkitAuth`, `Get-TenantBaseline`, `Set-TenantBaseline`, `Get-AuditReport`, `Export-Report`).
3. Auth & permissions: implémenter `Connect-ToolkitAuth` supportant interactive et app-only (certificat), plus `Assert-RequiredScopes`. *depends on step 2*
4. Config & secrets: créer `Toolkit.Config.psd1` + helper `Get-ToolkitConfig` et instructions pour KeyVault / Windows Credential Manager. *parallel with step 3*
5. Logging & observability: `Initialize-ToolkitLogging`, structured JSON logs, `Write-ToolkitLog` (Info/Warn/Error) et optional `Start-Transcript`. *parallel with step 3*
6. Baseline configuration cmdlets: scripts pour hardening recommandé (MFA équilibrée, Conditional Access, secure defaults, Exchange anti-phish/anti-spam, Teams external access, SharePoint sharing). *depends on 3,4*
7. Audit & reporting: modules pour récupérer `auditLogs`, `signIns`, admin role changes, mailbox audit; `New-AuditReport` + templates CSV/Excel/HTML. Inclure modèles conformes à audits Québec (conservation, divulgation, incidents). *depends on 3,4,5*
8. Compliance mapping (Québec): fournir checklists et example queries pour Loi 25, rétention et notification en cas d'incident; liens vers guides réglementaires. *parallel with 6,7*
9. Automation & scheduling: exemples pour Task Scheduler, Azure Automation / Logic Apps runbooks, et pipeline CI pour rapports planifiés. *parallel*
10. Packaging & tests: convertir en module `.psm1` avec `.psd1`, ajouter Pester tests pour validation logique (CSV validation, filters), et manifest. *depends on 2-9*
11. Documentation & runbook: README, guide d'installation pas-à-pas, procédures d'audit et playbooks d'incident pour contexte Québec.
12. Rollout & validation: validation en tenant de test, revue d'accessibilité, checklist de conformité avant production.

**Relevant files**
- `Agent365-Toolkit/Block-ThirdPartyAgentsFromAdminExport.ps1` — script existant réutilisable pour patterns d'auth, retry et CSV I/O.

**Verification**
1. Unit tests: Pester suite couvrant validation CSV, comportement de retry et fonctions utilitaires.
2. Integration: valider `Connect-ToolkitAuth` en mode interactif et app-only (certificat) contre un tenant de test.
3. Baseline check: exécuter `Get-TenantBaseline` et comparer à checklists (MFA, CA, external sharing).
4. Reporting: générer un rapport d'audit sample (`New-AuditReport`) et vérifier format CSV/Excel/HTML.
5. Compliance review: valider que les rapports contiennent les champs demandés par les audits québécois (horodatage, acteur, type d'événement, cible, emplacement des données).

**Decisions / Hypothèses**
- Cible: administrations/entreprises opérant au Québec; inclure références à Loi 25 et exigences provinciales de protection des renseignements personnels.
- Le projet fournit des aides techniques, pas de conseil juridique; pour conformité finale, consulter un conseiller légal.
- Prioriser Microsoft Graph v1.0 pour production et réserver `/beta` pour fonctionnalités expérimentales.

**Further Considerations**
1. Auth strategy: recommander app-only (certificat) pour automatisation sûre; documenter gestion des certificats et rotation.
2. Reporting output: proposer `ImportExcel` usage pour Excel natif mais garder CSV par défaut pour portabilité.
3. Packaging: fournir exemple d'Azure Automation Runbook + instructions pour exécution sécurisée (managed identity / Key Vault).
