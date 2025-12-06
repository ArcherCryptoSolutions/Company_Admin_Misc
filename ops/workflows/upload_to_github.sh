✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


#!/bin/bash
set -e
REPO_URL="https://github.com/Wapitsi/Snipey-McSniperson.git"
COMMIT_MESSAGE="Full v1.0 upload (2025-09-29)"
echo "🚀 Preparing Snipey-McSniperson upload..."
if ! command -v git &> /dev/null; then echo "❌ Git not found."; exit 1; fi
if [ ! -d .git ]; then git init; fi
if ! git remote -v | grep -q origin; then git remote add origin "$REPO_URL"; fi
echo "📁 Staging all files..."
git add .
echo "💾 Committing..."
git commit -m "$COMMIT_MESSAGE" || echo "⚠️ No changes to commit."
echo "✅ Local preparation complete. Run 'git push -u origin main' to upload."
