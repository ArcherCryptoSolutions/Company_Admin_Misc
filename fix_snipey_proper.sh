✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Mahihkan"
REPO_DIR="$ROOT/Snipey_OG"

echo "[+] Applying Snipey with Neil's exact parameters..."

# Ensure directories exist
mkdir -p "$REPO_DIR/snipey" "$REPO_DIR/strategies" "$REPO_DIR/tests"

# === CONFIG.PY ===
cat > "$REPO_DIR/snipey/config.py" <<'EOF'
import os

def get_env(key: str, default: str):
    return os.environ.get(key, default)

def load_config():
    return {
        "BUY_PCT_OF_TOTAL": float(get_env("SNIPEY_BUY_PCT_OF_TOTAL", "0.15")),  # 15% of current total
        "STOP_LOSS_DROP_FROM_PEAK": float(get_env("SNIPEY_STOP_LOSS_DROP_FROM_PEAK", "0.02")),  # 2% drop
        "STOP_LOSS_STALL_SECONDS": int(get_env("SNIPEY_STOP_LOSS_STALL_SECONDS", "10")),  # 10s stall
        "MAX_OPEN_TRADES": int(get_env("SNIPEY_MAX_OPEN_TRADES", "5")),  # Max 5 trades
    }
EOF

# === RUNNER.PY ===
cat > "$REPO_DIR/strategies/runner.py" <<'EOF'
def run_strategy(core, cfg, label):
    required = [
        "BUY_PCT_OF_TOTAL",
        "STOP_LOSS_DROP_FROM_PEAK",
        "STOP_LOSS_STALL_SECONDS",
        "MAX_OPEN_TRADES"
    ]
    for k in required:
        if k not in cfg:
            raise KeyError(f"Missing config key: {k}")
    print(f"[{label}] Strategy running with config: {cfg}")
    return {"status": "ok", "label": label}
EOF

# === TESTS ===
cat > "$REPO_DIR/tests/test_config.py" <<'EOF'
from Snipey_OG.snipey.config import load_config

def test_load_config_values():
    cfg = load_config()
    assert cfg["BUY_PCT_OF_TOTAL"] == 0.15
    assert cfg["STOP_LOSS_DROP_FROM_PEAK"] == 0.02
    assert cfg["STOP_LOSS_STALL_SECONDS"] == 10
    assert cfg["MAX_OPEN_TRADES"] == 5
EOF

cat > "$REPO_DIR/tests/test_runner.py" <<'EOF'
from Snipey_OG.snipey.config import load_config
from Snipey_OG.strategies.runner import run_strategy

def test_run_strategy():
    cfg = load_config()
    result = run_strategy(None, cfg, "TEST")
    assert result["status"] == "ok"
EOF

echo "[+] Installing deps, running tests, committing..."
cd "$ROOT"
if [ ! -d ".venv" ]; then python3 -m venv .venv; fi
source .venv/bin/activate
pip install --upgrade pip
pip install flask pytest requests pyyaml

pytest

git add .
git commit -m "Snipey OG: enforce Neil's parameters (15% buy, stop-loss stall 10s or 2% drop, max 5 trades)"
git push -u origin main

echo "[+] Deployment complete."
