#!/usr/bin/env python3
"""从维基文库《周易正義》分页抓取经文行，用于异文交叉复核。用法: spot.py 頁名 正則"""
import re
import subprocess
import sys
import time


def main() -> None:
    page, pat = sys.argv[1], sys.argv[2]
    url = f"https://zh.wikisource.org/wiki/{page}?action=raw"
    for attempt in range(5):
        try:
            out = subprocess.run(
                ["curl", "-sL", "--retry", "3", "--retry-delay", "3",
                 "--retry-all-errors", "--max-time", "60", url],
                capture_output=True, text=True, check=True,
            ).stdout
        except subprocess.CalledProcessError:
            time.sleep(3)
            continue
        if "redirect" in out[:200].lower() or len(out) < 500:
            time.sleep(3)
            continue
        hits = re.findall(pat, out)
        for h in hits[:6]:
            print(h)
        return
    print("FETCH-FAILED")


if __name__ == "__main__":
    main()
