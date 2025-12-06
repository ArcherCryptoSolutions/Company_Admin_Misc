#!/usr/bin/env bash
set -e

echo "[ACS] Boot starting..."

# 1) Ensure Python and pip exist
command -v python3 >/dev/null 2>&1 || pkg install -y python
# Skip pip upgrade — Termux blocks it
echo "[ACS] Skipping pip upgrade (Termux restriction)"

# 2) Ensure required Python libs
python3 -m pip install --no-cache-dir flask requests

# 3) Ensure folders
mkdir -p templates static/assets

# 4) Ensure app.py exists and has /loading route
if ! grep -q "@app.route('/loading')" app.py 2>/dev/null; then
  cat > app.py << 'PY'
from flask import Flask, render_template

app = Flask(__name__, static_folder='static', template_folder='templates')

@app.route('/loading')
def loading():
    return render_template('loading.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
PY
  echo "[ACS] app.py written"
fi

# 5) Ensure loading.html exists
if [ ! -f templates/loading.html ]; then
  cat > templates/loading.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Snipey McSniperson OG™ — Audit Loading</title>
  <style>
    body { margin:0; background:#000; display:flex; justify-content:center; align-items:center; height:100vh; color:#fff; font-family:system-ui, sans-serif; }
    .wrap { position:relative; width:360px; height:360px; }
    .bg { width:100%; height:100%; object-fit:contain; }
    .scope { position:absolute; top:50%; left:50%; width:200px; height:200px; transform:translate(-50%,-50%); animation:pulse 2s infinite; }
    @keyframes pulse { 0%{transform:translate(-50%,-50%) scale(1);opacity:1;}50%{transform:translate(-50%,-50%) scale(1.08);opacity:0.75;}100%{transform:translate(-50%,-50%) scale(1);opacity:1;} }
    .addr { position:fixed; bottom:14px; left:0; right:0; text-align:center; font-size:12px; opacity:0.75; }
  </style>
</head>
<body>
  <div class="wrap">
    <img src="{{ url_for('static', filename='assets/snipey_og.png') }}" class="bg" alt="Snipey McSniperson OG™">
    <img src="{{ url_for('static', filename='assets/sms_scope.png') }}" class="scope" alt="SMS Scope™">
  </div>
  <div class="addr">127.0.0.1:8000</div>
</body>
</html>
HTML
  echo "[ACS] templates/loading.html written"
fi

# 6) Ensure gui.py exists with live data
if ! grep -q "LIVE MONEY PANEL" gui.py 2>/dev/null; then
  cat > gui.py << 'PY'
import os
import time
import requests

RPC_URL = "https://api.mainnet-beta.solana.com"
WALLET_ADDRESS = "HwYJuzW4fHWZ6y4FSr5rxNnqWqwnZYCvDxyNc39XxUjh"
PRICE_SOURCE = "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd"
TIMEOUT = 10

def clear():
    os.system('clear')

def show_loading_screen():
    ret = os.system("xdg-open http://127.0.0.1:8000/loading")
    if ret != 0:
        print("Open in browser: http://127.0.0.1:8000/loading")

def fetch_sol_balance(wallet: str) -> float:
    payload = {"jsonrpc":"2.0","id":1,"method":"getBalance","params":[wallet]}
    r = requests.post(RPC_URL, json=payload, timeout=TIMEOUT)
    r.raise_for_status()
    lamports = r.json().get("result", {}).get("value", 0)
    return lamports / 1_000_000_000

def fetch_sol_price_usd() -> float:
    r = requests.get(PRICE_SOURCE, timeout=TIMEOUT)
    r.raise_for_status()
    return float(r.json()["solana"]["usd"])

def money_panel():
    clear()
    print("Snipey McSniperson OG™ — LIVE MONEY PANEL")
    print(f"Wallet: {WALLET_ADDRESS}")
    try:
        sol_balance = fetch_sol_balance(WALLET_ADDRESS)
        sol_price = fetch_sol_price_usd()
        exposure_usd = sol_balance * sol_price
        print(f"\nSOL Balance: {sol_balance:.6f} SOL")
        print(f"SOL Price: ${sol_price:,.2f}")
        print(f"Exposure: ${exposure_usd:,.2f}")
        print("\nStatus: LIVE — Real RPC + Price feed")
    except Exception as e:
        print("\n[ERROR] Live fetch failed:")
        print(str(e))
        print("Check network/RPC and try again.")

    print("\nOptions:")
    print("[K] Kill Switch (RED BUTTON)")
    print("[R] Refresh Live Metrics")
    print("[q] Quit")

def kill_switch():
    print("\n[KILL SWITCH ACTIVATED]")
    print("Terminating trading-related processes...")
    os.system("pkill -f 'python3.*trade|bot|worker'")
    print("Processes terminated.\n")
    input("Press Enter to continue...")

def boot():
    clear()
    print("Snipey McSniperson OG™ — Booting")
    print("SMS Scope™ LOCKED")
    show_loading_screen()
    time.sleep(2)

def main():
    boot()
    while True:
        money_panel()
        choice = input("\nSelect option: ").strip().lower()
        if choice in ['q', 'exit']:
            print("Exiting Snipey McSniperson OG™ CLI...")
            break
        elif choice == 'k':
            kill_switch()
        elif choice == 'r':
            continue
        else:
            print("\nInvalid choice. Try again.")
            time.sleep(1)

if __name__ == '__main__':
    main()
PY
  echo "[ACS] gui.py written"
fi

# 7) Start Flask in background (cleanly)
pkill -f "flask" >/dev/null 2>&1 || true
FLASK_APP=app.py flask run --host=0.0.0.0 --port=8000 >/dev/null 2>&1 &

# 8) Launch CLI
python3 gui.py
