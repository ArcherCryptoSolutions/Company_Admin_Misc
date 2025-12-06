#!/data/data/com.termux/files/usr/bin/bash
# Archer Crypto Solutions Inc. — Full Sweep Push Script (mahihkan-fixed)
# Purpose: Stage, commit, and push ALL files from mahihkan-fixed into Company_Admin_Misc

# === CONFIG ===
REPO_DIR=~/mahihkan-fixed
REMOTE_URL=git@github.com:ArcherCryptoSolutions/Company_Admin_Misc.git
BRANCH=main

# === STEP 1: Navigate to repo root ===
cd $REPO_DIR || {
  echo "Repo directory $REPO_DIR not found."
  exit 1
}

# === STEP 2: Initialize Git if needed ===
if [ ! -d ".git" ]; then
  echo "Initializing new Git repository..."
  git init
  git branch -M $BRANCH
  git remote add origin $REMOTE_URL
else
  echo "Git repo already initialized."
  git branch -M $BRANCH
  git remote set-url origin $REMOTE_URL
fi

# === STEP 3: Stage EVERYTHING systematically ===
echo "Staging all files..."
git add -A

# === STEP 4: Commit with Zero Trust message + timestamp ===
echo "Committing sweep..."
git commit -m "Initial Zero Trust sweep: $(date '+%Y-%m-%d %H:%M:%S') — full mahihkan-fixed repo push"

# === STEP 5: Push to GitHub Enterprise ===
echo "Pushing to $REMOTE_URL..."
git push -u origin $BRANCH

# === STEP 6: Confirmation ===
echo "=== Full sweep complete. Repo is now sealed in GitHub. ==="
