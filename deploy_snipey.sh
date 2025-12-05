✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


#!/data/data/com.termux/files/usr/bin/bash
set -e
WORKDIR=~/Mahihkan/Snipey_OG
cd "$WORKDIR"

pkg install -y python

touch __init__.py
touch tests/__init__.py

cat > snipey_runner.py << 'PYEOF'
#!/usr/bin/env python3
import argparse, sys
from Snipey_OG.tests import test_runner

def main():
    parser = argparse.ArgumentParser(description="Snipey OG Runner")
    parser.add_argument("--config", default="Snipey_OG/tests/test_config.py",
                        help="Path to config file")
    args = parser.parse_args()

    print("=== Snipey OG Runner ===")
    print(f"Using config: {args.config}")

    try:
        result = test_runner.run()
        print(f"Snipey OG execution result: {result}")
        return 0
    except Exception as e:
        print(f"Runner error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
PYEOF
chmod +x snipey_runner.py

python -m pytest -q
cd ~/Mahihkan
python -m Snipey_OG.snipey_runner --config Snipey_OG/tests/test_config.py
