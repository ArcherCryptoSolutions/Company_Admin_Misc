✠ Sovereign Property of ArcherCryptoSolutionsInc ✠
Bound under Admiralty Law and Intellectual Dominion


#!/usr/bin/env python3
import sys, time
from Snipey_OG.monitor.feed import MarketFeed
from Snipey_OG.strategies.basic_strategy import decide

def main():
    print("=== Snipey OG LIVE MONITOR (signals only) ===")
    feed = MarketFeed()
    for tick in feed.stream():
        signal = decide(tick)
        if signal:
            print(f"[{tick[ts]}] {signal} price={tick[price]}")
        time.sleep(0.25)
    return 0

if __name__ == "__main__":
    sys.exit(main())