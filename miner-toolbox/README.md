
# Nockchain Miner Toolbox

Thanks to an awesome community contributor, we now have a very cool website to explore the network:
🌐 [https://nockstats.com](https://nockstats.com)

They've also helped build a place for discussion and learning. Personally, I’ve learned a lot from the Discord community!

---

## 🛠️ Build & Install on Ubuntu

```bash
# Install Rust (if not installed yet)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Update packages and install required build tools
sudo apt update
sudo apt install build-essential clang llvm-dev libclang-dev

# Install Hoonc
make install-hoonc
export PATH="$HOME/.cargo/bin:$PATH"

# Build everything (wallet + nockchain)
make build

# Optional: Install wallet and node components separately
make install-nockchain-wallet
make install-nockchain
```

---

## 🍎 Build & Install on macOS

```bash
# Switch to the latest Rust nightly version
rustup override set nightly

# Add Rust nightly binaries to PATH
export PATH="/Users/yourname/.rustup/toolchains/nightly-aarch64-apple-darwin/bin:$PATH"
export PATH="/Users/yourname/.cargo/bin:$PATH"
export PATH="/Users/yourname/.rustup/toolchains/nightly-2025-02-14-aarch64-apple-darwin/bin:$PATH"
```

---

## 📡 UDP Port Configuration

If you're using port `3006`, make sure to manually open the UDP port:

```bash
nockchain --bind /ip4/0.0.0.0/udp/3006/quic-v1
```

Command Explanation:

- `0.0.0.0`: Listen on all public and private IPs
- `quic-v1`: P2P protocol used for network communication
- ✅ Make sure this port is open in your server's firewall or security group settings

---

## 🧩 Common Nockchain Commands

```bash
# Export wallet keys (backup)
nockchain-wallet export-keys

# Import wallet keys later
nockchain-wallet import-keys --input keys.export
# Keys are typically stored under:
# /home/ubuntu/.nockapp/wallet/

# Reduce logs (or focus logs by module)
RUST_LOG=info nockchain
RUST_LOG=nockchain_libp2p_io=debug nockchain

# List notes
nockchain-wallet --nockchain-socket .socket/nockchain_npc.sock list-notes > list_notes.log

# Update wallet balance
nockchain-wallet --nockchain-socket .socket/nockchain_npc.sock update-balance

# Query notes by pubkey
nockchain-wallet --nockchain-socket .socket/nockchain_npc.sock list-notes-by-pubkey -p <your-pubkey>
```

---

## 🧵 Linux Process Control Tips

```bash
# Suspend a foreground job
CTRL-Z

# Send it to background
bg %1

# Bring it back to foreground
fg %1

# List all jobs
jobs

# Kill a job
kill %1
```

---

Stay safe, happy mining, and see you in the tribe!


see [FAQ](FAQ.md)