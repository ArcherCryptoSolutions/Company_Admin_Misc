✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


#!/data/data/com.termux/files/usr/bin/bash
# run_snipey.sh - execute Snipey OG with proper config

# Update environment
pkg update -y
pkg install -y python

# Move into Snipey OG directory
cd ~/Mahihkan/Snipey_OG

# Run tests to validate setup
python -m pytest tests

# Execute main runner with config
python snipey_runner.py --config tests/test_config.py
