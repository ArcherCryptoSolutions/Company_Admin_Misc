✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


from Snipey_OG.snipey.config import load_config

def test_load_config_values():
    cfg = load_config()
    assert cfg["BUY_PCT_OF_TOTAL"] == 0.15
    assert cfg["STOP_LOSS_DROP_FROM_PEAK"] == 0.02
    assert cfg["STOP_LOSS_STALL_SECONDS"] == 10
    assert cfg["MAX_OPEN_TRADES"] == 5
