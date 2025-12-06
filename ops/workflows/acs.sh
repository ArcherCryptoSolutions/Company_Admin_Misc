#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ACS_DIR="$HOME/ACS"
ACS_REMOTE="https://archercryptosolutions-inc.ghe.com/idlwqj8d_admin/ArcherCryptoSolutions.git"

mkdir -p "$ACS_DIR"
cd "$ACS_DIR"

[ -d .git ] || git init
git remote remove origin 2>/dev/null || true
git remote add origin "$ACS_REMOTE"
git branch -M main

mkdir -p docs docs/Billing

cat > docs/README.md <<'DOC'
# ArcherCryptoSolutions Inc. (ACS)

ACS is the umbrella holding company for ACA, CVR Essentials, and Mahihkan.com.  
This repo contains governance and inter‑company documentation:

- BusinessPlan.md — ACS umbrella plan  
- MasterServiceAgreement.md — licensing and governance terms  
- Billing/ — inter‑company invoices and records  

Mahihkan‑specific consumer docs are maintained in the Mahihkan repo.
DOC

cat > docs/BusinessPlan.md <<'DOC'
# ACS Business Plan  
Umbrella strategy for ACA, CVR Essentials, Mahihkan.com, and Archer Family Trust governance.
DOC

cat > docs/MasterServiceAgreement.md <<'DOC'
# Master Service Agreement (MSA)  
Framework terms governing licensing, services, and inter‑company responsibilities.
DOC

cat > docs/Billing/README.md <<'DOC'
# ACS Billing Documentation  
Draft scaffolding — not legal or accounting advice.

## Flows  
- ACA → ACS: analytics for audit reporting  
- ACA → CVR Essentials: data supply for delayed records  
- CVR Essentials → Mahihkan: subscription tiers for records  
- Mahihkan → ACS: IP licensing fees  

All records maintained for GST/HST readiness, banking, and investor transparency.
DOC

git add .
git commit -m "ACS: umbrella docs clarified; billing scaffold added"
git push -u origin main || git push
