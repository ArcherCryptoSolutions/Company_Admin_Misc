✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


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
