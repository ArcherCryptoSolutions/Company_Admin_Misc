✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


from typing import Optional, Dict

# Monitor-only logic: returns signals; NO orders or wallet calls.
def decide(tick: Dict) -> Optional[str]:
    p = tick.get("price")
    if p is None:
        return None
    if p > 101:
        return "potential-sell"
    if p < 99:
        return "potential-buy"
    return None