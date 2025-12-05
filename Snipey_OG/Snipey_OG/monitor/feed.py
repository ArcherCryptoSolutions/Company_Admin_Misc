✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


import time, random

class MarketFeed:
    def __init__(self, start_price: float = 100.0):
        self._price = float(start_price)

    def stream(self):
        """Simulate a continuous live tick stream."""
        while True:
            delta = random.uniform(-0.75, 0.75)
            self._price = max(0.0001, self._price + delta)
            yield {
                "ts": int(time.time()),
                "price": round(self._price, 6)
            }