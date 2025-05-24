# CheckWallet Script Overview

A friend from Discord shared the CheckWallet script, which is used to:

- Guide users to input their wallet address on the first run;
- Connect to the local socket each time it runs to fetch current mining info of the wallet;
- Display the current wallet output amount and ranking among miners in the network;
- List other miners and their validated block counts;
- Show global network statistics;
- Provide a way to switch wallets.

see [check_wallet_v1](./check_wallet_v1.sh)

## Frequently Asked Questions

### thread serf panicked

Common on Ubuntu servers such as 24.04.

Error message:

```shell
thread 'serf' panicked at crates/nockvm/rust/nockvm/src/mem.rs:301:23:
Box<dyn Any>

thread 'tokio-runtime-worker' panicked at crates/nockchain/src/mining.rs:175:14:
Could not load mining kernel: OneshotChannelError(RecvError(()))
W (08:14:23) mining: Error during mining attempt: JoinError::Panic(Id(3722), "Could not load mining kernel: OneshotChannelError(RecvError(()))", ...)
```

Solution:

```shell
# Fix serf panicked error
sudo sysctl -w vm.overcommit_memory=1

sudo sysctl -w vm.overcommit_memory=1 && echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf
```

### Address already in use

Occurs when starting nockchain multiple times.

```shell
Error: Os { code: 98, kind: AddrInUse, message: "Address already in use" }

# Remove and restart
rm -rf .socket/nockchain_npc.sock
```

### Memory Usage

```rust
# Modify memory size code
# crates/nockapp/src/utils/mod.rs

// nock stack size
pub const NOCK_STACK_SIZE: usize = (NOCK_STACK_1KB << 10 << 10) * 8; // 8GB

// HUGE nock stack size
pub const NOCK_STACK_SIZE_HUGE: usize = (NOCK_STACK_1KB << 10 << 10) * 64; // 32GB
```

diff code :

```rust
diff --git a/crates/nockapp/src/utils/mod.rs b/crates/nockapp/src/utils/mod.rs
index 2b4dacf..9c9964b 100644
--- a/crates/nockapp/src/utils/mod.rs
+++ b/crates/nockapp/src/utils/mod.rs
@@ -37,7 +37,7 @@ pub const NOCK_STACK_1KB: usize = 1 << 7;
 pub const NOCK_STACK_SIZE: usize = (NOCK_STACK_1KB << 10 << 10) * 8; // 8GB

 // HUGE nock stack size
-pub const NOCK_STACK_SIZE_HUGE: usize = (NOCK_STACK_1KB << 10 << 10) * 128; // 32GB
+pub const NOCK_STACK_SIZE_HUGE: usize = (NOCK_STACK_1KB << 10 << 10) * 8; // 8GB

 /**
  *   ::  +from-unix: unix seconds to @da
```

### Node connection issues

```shell
# Added common nodes
# thx pouyan
--peer /ip4/95.216.102.60/udp/3006/quic-v1 --peer /ip4/65.108.123.225/udp/3006/quic-v1 --peer /ip4/65.109.156.108/udp/3006/quic-v1 --peer /ip4/65.21.67.175/udp/3006/quic-v1 --peer /ip4/65.109.156.172/udp/3006/quic-v1 --peer /ip4/34.174.22.166/udp/3006/quic-v1 --peer /ip4/34.95.155.151/udp/30000/quic-v1 --peer /ip4/34.18.98.38/udp/30000/quic-v1


# thx 0xmoei
--peer /ip4/95.216.102.60/udp/3006/quic-v1 \
--peer /ip4/65.108.123.225/udp/3006/quic-v1 \
--peer /ip4/65.109.156.108/udp/3006/quic-v1 \
--peer /ip4/65.21.67.175/udp/3006/quic-v1 \
--peer /ip4/65.109.156.172/udp/3006/quic-v1 \
--peer /ip4/34.174.22.166/udp/3006/quic-v1 \
--peer /ip4/34.95.155.151/udp/30000/quic-v1 \
--peer /ip4/34.18.98.38/udp/30000/quic-v1 \
--peer /ip4/96.230.252.205/udp/3006/quic-v1 \
--peer /ip4/94.205.40.29/udp/3006/quic-v1 \
--peer /ip4/159.112.204.186/udp/3006/quic-v1 \
--peer /ip4/217.14.223.78/udp/3006/quic-v1
```

Normal running logs:

```
(08:23:22) [%mining-on 4.491.041.536.328.568.307 2.723.062.013.290.809.879 7.318.466.437
.668.401.658 3.743.209.852.110.096.371 16.387.017.028.635.316.580]



I (08:25:38) [%mining-on 15.645.459.468.143.688.469 17.810.181.139.658.483.941 15.804.346.
176.267.028.002 4.068.213.272.027.362.722 8.849.661.701.517.943.151]
```

Check validated blocks:

```shell
# Check latest validated blocks
grep -a "validated blocks at" nockchain_miner.log

# Check mining status
grep -a "mining-on"

# Check successful mined blocks
grep -a "added to validated blocks"
```