#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# CONFIG
MAHIHKAN_DIR="$HOME/Mahihkan"
MAHIHKAN_REMOTE="https://archercryptosolutions-inc.ghe.com/idlwqj8d_admin/mahihkan.com.git"
DOMAIN="mahihkan.com"

mkdir -p "$MAHIHKAN_DIR"
cd "$MAHIHKAN_DIR"

[ -d .git ] || git init
git remote remove origin 2>/dev/null || true
git remote add origin "$MAHIHKAN_REMOTE"
git branch -M main

mkdir -p docs docs/Billing

# Landing page
cat > docs/index.html <<'EOF'
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<title>Mahihkan.com</title><meta name="viewport" content="width=device-width,initial-scale=1">
<style>body{background:#0f0f0f;color:#f5f5f5;font-family:sans-serif;text-align:center;padding:5em;}
h1{font-size:3em;margin-bottom:.5em;}p{font-size:1.1em;color:#ccc;max-width:720px;margin:0 auto 1em;}
.small{font-size:.9em;color:#888;}</style></head><body>
<h1>Mahihkan.com</h1>
<p>Branded crypto ecosystems. Emotional legacy. Tactical integrity.</p>
<p class="small">Part of ArcherCryptoSolutions Inc. (ACS) — governed under the Archer Family Trust.</p>
</body></html>
EOF

touch docs/.nojekyll
echo "$DOMAIN" > docs/CNAME

# Repo README
cat > docs/README.md <<'EOF'
# Mahihkan.com
Consumer-facing brand within ACS ecosystem.  
Contains Mahihkan-specific docs, billing, and site deployment.
EOF

# Licensing Agreement
cat > docs/LicensingAgreement_Mahihkan_to_ACS.md <<'EOF'
# Licensing Agreement — Mahihkan → ACS
Scope: Branding/IP licensed from ACS to Mahihkan for consumer product use.
Term: Multi-year, renewable. Fees invoiced per schedule.
Ownership: IP remains with ACS; non-transferable license to Mahihkan.
Quality control: Brand usage guidelines and approvals required by ACS.
EOF

# Billing README
cat > docs/Billing/README.md <<'EOF'
# Mahihkan Billing Documentation
Flows:
- CVR Essentials → Mahihkan: subscription tiers for delayed records.
- Mahihkan → ACS: IP branding license, renewable multi-year.
EOF

# Invoices
cat > docs/Billing/Invoice_CVR_to_Mahihkan.md <<'EOF'
# Invoice: CVR Essentials → Mahihkan
Date: 2025-11-27 | Invoice #: CVR-MAH-001 | Service Period: Nov 2025 | Due: 2025-12-15
| Description | Tier | Monthly Rate | Total |
|-------------|------|--------------|-------|
| Delayed record access (Solana, Ethereum) | Pro | $500.00 | $500.00 |
Subtotal: $500.00 | GST (5%): $25.00 | Total Due: $525.00
EOF

cat > docs/Billing/Invoice_Mahihkan_to_ACS.md <<'EOF'
# Invoice: Mahihkan → ACS
Date: 2025-11-27 | Invoice #: MAH-ACS-001 | Service Period: Annual 2025–2026 | Due: 2025-12-31
| Description | Term | Rate | Total |
|-------------|------|------|-------|
| IP branding license (Snipey line) | 12 months | $1,200.00 | $1,200.00 |
Subtotal: $1,200.00 | GST (5%): $60.00 | Total Due: $1,260.00
EOF

# Commercial License
cat > docs/LICENSE_COMMERCIAL.md <<'EOF'
# Commercial License — Mahihkan.com
Proprietary license held by ACS.  
Ownership: IP remains with ACS and Archer Family Trust.  
Grant: Non-transferable license to Mahihkan.com for consumer deployment.  
Fees: Annual licensing per Billing.  
Restrictions: No sublicensing/redistribution without ACS approval.  
EOF

git add .
git commit -m "Mahihkan: full scaffold (site, docs, billing, license)"
git push -u origin main || git push
