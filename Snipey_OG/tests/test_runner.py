✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


from Snipey_OG.snipey.config import load_config
from Snipey_OG.strategies.runner import run_strategy

def test_run_strategy():
    cfg = load_config()
    result = run_strategy(None, cfg, "TEST")
    assert result["status"] == "ok"
