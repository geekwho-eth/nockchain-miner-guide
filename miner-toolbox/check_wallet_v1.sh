#!/bin/bash
# Program:
#   check wallet and show nockchain summary, such as current miner、all miner
# History:
# 2025.05.24 geekwho first release.
# see origin code : https://pastebin.com/5iEeswwf. thx dig301.

# serach socket with current dir
workDir=$(cd $(dirname $0);cd ..;pwd)
cd $workDir
echo $workDir

# Config file to store wallet address
CONFIG_FILE="$HOME/.nockchain_wallet_config"

# Socket path - find first available socket
SOCKET=$(find $workDir -name "nockchain_npc.sock" 2>/dev/null | head -1)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if socket exists
if [ -z "$SOCKET" ]; then
    echo -e "${RED}Error: No nockchain socket found!${NC}"
    echo "Make sure miners are running."
    exit 1
fi

# Check if config exists, if not prompt for wallet
if [ ! -f "$CONFIG_FILE" ]; then
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                   FIRST TIME SETUP                               ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Please enter your public key to monitor:${NC}"
    echo ""
    read -p "Public Key: " USER_WALLET
    
    # Validate input
    if [ -z "$USER_WALLET" ]; then
        echo -e "${RED}Error: No wallet address provided!${NC}"
        exit 1
    fi
    
    # Save to config
    echo "$USER_WALLET" > "$CONFIG_FILE"
    echo ""
    echo -e "${GREEN}✓ Wallet saved! Starting monitor...${NC}"
    sleep 2
else
    # Read wallet from config
    USER_WALLET=$(cat "$CONFIG_FILE")
fi

# Header
clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      NOCKCHAIN WALLET MONITOR                    ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Checking blockchain...${NC}"
echo -e "${BLUE}Your wallet:${NC} ${CYAN}${USER_WALLET:0:20}...${USER_WALLET: -20}${NC}"
echo ""

# Get wallet output and extract signers (FIXED: Added tr -d '\0' to remove null bytes)
WALLET_OUTPUT=$(nockchain-wallet --nockchain-socket $SOCKET list-notes 2>/dev/null | tr -d '\0')

# Extract all wallet addresses from signers field
WALLETS=$(echo "$WALLET_OUTPUT" | grep -oP '(?<=pks=<\|)[^|]+(?=\|>)' | sort | uniq)

# If no wallets found
if [ -z "$WALLETS" ]; then
    echo -e "${RED}No mined blocks found in wallet data.${NC}"
    echo ""
    echo -e "${BLUE}Your blocks:${NC} ${RED}0${NC}"
    echo ""
    echo -e "${YELLOW}Keep mining! 💪${NC}"
    exit 0
fi

# Count total unique wallets
UNIQUE_COUNT=$(echo "$WALLETS" | wc -l)

echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                    BLOCKCHAIN MINING SUMMARY                       ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Total unique miners:${NC} ${YELLOW}$UNIQUE_COUNT${NC}"
echo ""
echo -e "${PURPLE}MINER RANKINGS:${NC}"
echo -e "${PURPLE}───────────────${NC}"

# Process each wallet
USER_BLOCKS=0
RANK=1

while IFS= read -r wallet; do
    # Count occurrences (will be doubled)
    COUNT=$(echo "$WALLET_OUTPUT" | grep -c "$wallet")
    # Divide by 2
    BLOCKS=$((COUNT / 2))
    
    # Check if it's user's wallet
    WALLET_TAG=""
    if [ "$wallet" = "$USER_WALLET" ]; then
        USER_BLOCKS=$BLOCKS
        WALLET_TAG=" ${GREEN}← YOU!${NC}"
    fi
    
    # Display wallet (truncated for readability)
    WALLET_SHORT="${wallet:0:20}...${wallet: -20}"
    
    echo -e "${YELLOW}#$RANK${NC} ${CYAN}$WALLET_SHORT${NC}"
    echo -e "   ${GREEN}Blocks mined: $BLOCKS${NC}$WALLET_TAG"
    echo ""
    
    RANK=$((RANK + 1))
done <<< "$WALLETS"

# Summary for user
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                        YOUR STANDINGS                              ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

# Your results
if [ $USER_BLOCKS -gt 0 ]; then
    echo -e "${BLUE}Your blocks:${NC} ${GREEN}$USER_BLOCKS 🎉${NC}"
    YOUR_RANK=$(echo "$WALLETS" | grep -n "^$USER_WALLET$" | cut -d: -f1)
    echo -e "${BLUE}Your rank:${NC} ${YELLOW}#$YOUR_RANK${NC} out of ${YELLOW}$UNIQUE_COUNT${NC} miners"
else
    echo -e "${BLUE}Your blocks:${NC} ${RED}0${NC} ${YELLOW}(Keep mining!)${NC}"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "Last checked: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Fun stats
TOTAL_BLOCKS=$(echo "$WALLETS" | while read w; do echo "$WALLET_OUTPUT" | grep -c "$w"; done | awk '{sum+=$1} END {print sum/2}')
echo -e "${PURPLE}Network Stats:${NC}"
echo -e "  Total blocks mined: ${YELLOW}$TOTAL_BLOCKS${NC}"
echo -e "  Average per miner: ${YELLOW}$(($TOTAL_BLOCKS / $UNIQUE_COUNT))${NC}"

# If user has blocks, celebrate!
if [ $USER_BLOCKS -gt 0 ]; then
    echo ""
    echo -e "${GREEN}🎊 🎊 🎊 CONGRATULATIONS! YOU'RE EARNING NOCK! 🎊 🎊 🎊${NC}"
fi

echo ""

# Add option to change wallet
echo -e "${CYAN}───────────────────────────────────────────────────────────────────${NC}"
echo -e "${BLUE}To monitor a different wallet, delete the config file:${NC}"
echo -e "${YELLOW}rm $CONFIG_FILE${NC}"
echo ""
EOF