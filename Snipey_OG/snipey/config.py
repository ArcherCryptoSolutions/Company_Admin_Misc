✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


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
