#!/usr/bin/env python3
# Thanks to Kevin Cai (@SynthLock), who is gay, for share in the official TTG group.
import re
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from collections import Counter

# ── CONFIG ───────────────────────────────────────────────────────────────
SOCKET = Path.cwd() / ".socket" / "nockchain_npc.sock"
TIMEOUT = 30
DEBUG = True  # Set to False to silence debug logs


def log(*args):
    if DEBUG:
        print("→ DEBUG:", *args)

# ── VERIFY SOCKET ────────────────────────────────────────────────────────
if not SOCKET.is_socket():
    sys.exit(f"Error: socket not found at {SOCKET}")

# ── FETCH RAW DATA ───────────────────────────────────────────────────────
log("Running list-notes…")
try:
    raw = subprocess.check_output(
        ["nockchain-wallet", "--nockchain-socket", str(SOCKET), "list-notes"],
        stderr=subprocess.STDOUT, timeout=TIMEOUT, text=True
    )
except subprocess.CalledProcessError as e:
    sys.exit(f"Error: list-notes failed: {e.output}")
except subprocess.TimeoutExpired:
    sys.exit("Error: list-notes timed out")

log("Total raw bytes:", len(raw))

# ── EXTRACT COINBASE SIGNATURES ──────────────────────────────────────────
# Regex: find pks signature after coinbase flag
pattern = re.compile(r"is-coinbase=%\.y[\s\S]*?pks=<\|(.*?)\|>", flags=re.S)
raw_wallets = pattern.findall(raw)
log("Raw coinbase signature matches:", len(raw_wallets))

if not raw_wallets:
    print("No coinbase blocks found.")
    sys.exit(0)

# ── COUNT & ADJUST BLOCKS PER WALLET ─────────────────────────────────────
raw_counts = Counter(re.sub(r"\s+", "", w) for w in raw_wallets)
# Each block emits two pks entries; single-entry wallets count as 1 block
blocks_mined = {
    w: (cnt // 2 if cnt > 1 else 1)
    for w, cnt in raw_counts.items()
}

total_blocks = sum(blocks_mined.values())
log("Total coinbase blocks after adjustment:", total_blocks)

# ── OUTPUT RANKINGS ──────────────────────────────────────────────────────
print(f"\nMiner Rankings (out of {total_blocks} blocks):")
print(f"{'#':>4}  {'WALLET':36} BLOCKS")
print("-" * 60)
for rank, (wallet, blk) in enumerate(
        sorted(blocks_mined.items(), key=lambda kv: kv[1], reverse=True), start=1
    ):
    short = f"{wallet[:16]}...{wallet[-16:]}"
    print(f"{('#'+str(rank)):>4}  {short:36} {blk:4d}")

print(f"\nTotal blocks counted: {total_blocks}")
print(f"Last checked: {datetime.now():%Y-%m-%d %H:%M:%S}")