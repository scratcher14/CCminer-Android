#!/data/data/com.termux/files/usr/bin/bash

#########################################
# CCMiner Automated Setup for Termux
# For Verus Coin Mining
# GitHub: https://github.com/scratcher14/CCminer-Android
#########################################

echo "========================================="
echo "  CCMiner Setup Script for Termux"
echo "  Setting up Verus mining..."
echo "========================================="
echo ""

# Step 1: Update and upgrade Termux
echo "[1/8] Updating Termux packages..."
yes | pkg update && pkg upgrade -y

# Step 2: Install required dependencies
echo ""
echo "[2/8] Installing dependencies..."
yes | pkg install libjansson build-essential clang binutils git -y

# Step 3: Fix sysctl header issue
echo ""
echo "[3/8] Fixing system headers..."
cp /data/data/com.termux/files/usr/include/linux/sysctl.h /data/data/com.termux/files/usr/include/sys/ 2>/dev/null || echo "Header already exists or not needed"

# Step 4: Clone ccminer repository
echo ""
echo "[4/8] Cloning ccminer repository..."
cd ~
if [ -d "ccminer" ]; then
    echo "ccminer directory already exists. Removing old version..."
    rm -rf ccminer
fi
git clone https://github.com/Darktron/ccminer.git
cd ccminer

# Step 5: Set permissions
echo ""
echo "[5/8] Setting execute permissions..."
chmod +x build.sh configure.sh autogen.sh start.sh

# Step 6: Configure for ARM architecture
echo ""
echo "[6/8] Configuring for ARM CPU (Cortex-A55)..."
# Backup original configure.sh
cp configure.sh configure.sh.backup

# Update configure.sh with ARM optimizations
cat > configure_arm.sh << 'EOF'
#!/bin/bash

# ARM optimizations for Snapdragon
arch="-march=armv8-a+crypto+sha2+crc"
core="-mtune=cortex-a55"

# Export compiler flags
export CFLAGS="$arch $core -O3"
export CXXFLAGS="$arch $core -O3"

# Run original configure
./configure.sh "$@"
EOF

chmod +x configure_arm.sh

# Step 7: Build ccminer
echo ""
echo "[7/8] Building ccminer (this takes 10-20 minutes)..."
echo "Please be patient..."
CXX=clang++ CC=clang ./build.sh

# Check if build was successful
if [ -f "ccminer" ]; then
    echo ""
    echo "✓ Build successful!"
else
    echo ""
    echo "✗ Build failed. Check errors above."
    exit 1
fi

# Step 8: Create config.json
echo ""
echo "[8/8] Creating config.json..."

# Prompt user for all mining parameters
echo ""
echo "========================================="
echo "  Wallet Configuration"
echo "========================================="
echo ""
echo "Enter your Verus wallet address:"
read -r WALLET_ADDRESS

echo ""
echo "========================================="
echo "  Worker Configuration"
echo "========================================="
echo ""
echo "Worker name helps identify this device"
echo "Examples: phone-1, vibe-21, A03-3"
echo ""
read -p "Worker/Rig name: " WORKER_NAME

echo ""
echo "========================================="
echo "  Thread Configuration"
echo "========================================="
echo ""
echo "Recommended thread counts:"
echo "  • Budget phones (4-6 cores): 2-4 threads"
echo "  • Mid-range (6-8 cores): 4-6 threads"
echo "  • Flagship (8+ cores): 6-8 threads"
echo ""
read -p "Number of threads (recommended: 4-8): " THREADS

echo ""
echo "========================================="
echo "  Algorithm Configuration"
echo "========================================="
echo ""
echo "Algorithm for mining (default: verus)"
echo "Press Enter to use verus"
echo ""
read -p "Algorithm (or press Enter for verus): " ALGO
ALGO=${ALGO:-verus}

echo ""
echo "========================================="
echo "  Primary Pool Configuration"
echo "========================================="
echo ""
echo "Enter primary pool address"
echo "Format: stratum+tcp://pool-address.com:port"
echo "Example: stratum+tcp://verus.farm:9999"
echo ""
read -p "Primary pool address: " PRIMARY_POOL

echo ""
echo "========================================="
echo "  Backup Pool Configuration"
echo "========================================="
echo ""
echo "Enter secondary/backup pool address"
echo "Format: stratum+tcp://pool-address.com:port"
echo "Example: stratum+tcp://us.vipor.net:5040"
echo ""
read -p "Backup pool address: " SECONDARY_POOL

# Create config.json
cat > config.json << EOF
{
    "pools": [
        {
            "name": "PRIMARY",
            "url": "${PRIMARY_POOL}",
            "timeout": 180,
            "disabled": 0
        },
        {
            "name": "BACKUP",
            "url": "${SECONDARY_POOL}",
            "timeout": 180,
            "time-limit": 600,
            "disabled": 0
        }
    ],
    "user": "${WALLET_ADDRESS}.${WORKER_NAME}",
    "algo": "${ALGO}",
    "threads": ${THREADS},
    "cpu-priority": 1,
    "retry-pause": 15
}
EOF

# Create easy start script
cat > start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/ccminer
./ccminer -c config.json
EOF

chmod +x start.sh

# Save configuration for reconfigure script
cat > ccminer-config.txt << EOF
# CCMiner configuration
# Created: $(date)
WALLET_ADDRESS="${WALLET_ADDRESS}"
WORKER_NAME="${WORKER_NAME}"
THREADS=${THREADS}
ALGO="${ALGO}"
PRIMARY_POOL="${PRIMARY_POOL}"
SECONDARY_POOL="${SECONDARY_POOL}"
EOF

# Create reconfigure script
cat > reconfigure.sh << 'RECONFIGURE_EOF'
#!/data/data/com.termux/files/usr/bin/bash

#########################################
# CCMiner Reconfiguration Script
# Easily update mining settings
# GitHub: https://github.com/scratcher14/CCminer-Android
#########################################

echo "========================================="
echo "  CCMiner Reconfiguration Tool"
echo "========================================="
echo ""
echo "This will update your mining configuration"
echo ""

# Check if config.json exists
if [ ! -f ~/ccminer/config.json ]; then
    echo "Error: config.json not found!"
    echo "Please run the initial setup first."
    exit 1
fi

cd ~/ccminer

# Load current configuration
if [ -f "ccminer-config.txt" ]; then
    source ccminer-config.txt
fi

echo "What would you like to change?"
echo ""
echo "1) Everything (full reconfiguration)"
echo "2) Algorithm only"
echo "3) Pools only"
echo "4) Wallet and/or worker only"
echo "5) Thread count only"
echo "6) Edit config.json manually"
echo ""
read -p "Enter choice (1-6): " RECONFIG_CHOICE

case $RECONFIG_CHOICE in
    6)
        nano ~/ccminer/config.json
        echo ""
        echo "✓ Configuration edited manually"
        echo "Restart mining for changes to take effect"
        exit 0
        ;;
esac

# Reconfiguration logic
case $RECONFIG_CHOICE in
    1)
        CHANGE_ALL=true
        ;;
    2)
        echo ""
        echo "Current algorithm: ${ALGO}"
        echo ""
        read -p "Enter new algorithm (or press Enter to keep current): " NEW_ALGO
        if [ ! -z "$NEW_ALGO" ]; then
            ALGO=$NEW_ALGO
        fi
        ;;
    3)
        echo ""
        echo "Current primary pool: ${PRIMARY_POOL}"
        echo "Current backup pool: ${SECONDARY_POOL}"
        echo ""
        read -p "Enter new primary pool (or press Enter to keep current): " NEW_PRIMARY
        if [ ! -z "$NEW_PRIMARY" ]; then
            PRIMARY_POOL=$NEW_PRIMARY
        fi
        read -p "Enter new backup pool (or press Enter to keep current): " NEW_BACKUP
        if [ ! -z "$NEW_BACKUP" ]; then
            SECONDARY_POOL=$NEW_BACKUP
        fi
        ;;
    4)
        echo ""
        echo "Current wallet: ${WALLET_ADDRESS}"
        echo "Current worker: ${WORKER_NAME}"
        echo ""
        read -p "Enter new wallet address (or press Enter to keep current): " NEW_WALLET
        if [ ! -z "$NEW_WALLET" ]; then
            WALLET_ADDRESS=$NEW_WALLET
        fi
        read -p "Enter new worker name (or press Enter to keep current): " NEW_WORKER
        if [ ! -z "$NEW_WORKER" ]; then
            WORKER_NAME=$NEW_WORKER
        fi
        ;;
    5)
        echo ""
        echo "Current thread count: ${THREADS}"
        echo ""
        read -p "Enter new thread count (or press Enter to keep current): " NEW_THREADS
        if [ ! -z "$NEW_THREADS" ]; then
            THREADS=$NEW_THREADS
        fi
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Full reconfiguration
if [ "$CHANGE_ALL" = true ]; then
    echo ""
    echo "========================================="
    echo "  Full Reconfiguration"
    echo "========================================="
    echo ""
    
    read -p "Wallet address: " WALLET_ADDRESS
    read -p "Worker name: " WORKER_NAME
    read -p "Thread count: " THREADS
    read -p "Algorithm (default: verus): " ALGO_INPUT
    ALGO=${ALGO_INPUT:-verus}
    read -p "Primary pool (stratum+tcp://...): " PRIMARY_POOL
    read -p "Backup pool (stratum+tcp://...): " SECONDARY_POOL
fi

# Backup old config
cp config.json config.json.backup

# Create new config.json
cat > config.json << EOF
{
    "pools": [
        {
            "name": "PRIMARY",
            "url": "${PRIMARY_POOL}",
            "timeout": 180,
            "disabled": 0
        },
        {
            "name": "BACKUP",
            "url": "${SECONDARY_POOL}",
            "timeout": 180,
            "time-limit": 600,
            "disabled": 0
        }
    ],
    "user": "${WALLET_ADDRESS}.${WORKER_NAME}",
    "algo": "${ALGO}",
    "threads": ${THREADS},
    "cpu-priority": 1,
    "retry-pause": 15
}
EOF

# Update saved configuration
cat > ccminer-config.txt << EOF
# CCMiner configuration
# Updated: $(date)
WALLET_ADDRESS="${WALLET_ADDRESS}"
WORKER_NAME="${WORKER_NAME}"
THREADS=${THREADS}
ALGO="${ALGO}"
PRIMARY_POOL="${PRIMARY_POOL}"
SECONDARY_POOL="${SECONDARY_POOL}"
EOF

echo ""
echo "========================================="
echo "  ✓ Configuration Updated!"
echo "========================================="
echo ""
echo "New Configuration:"
echo "  Wallet: ${WALLET_ADDRESS}"
echo "  Worker: ${WORKER_NAME}"
echo "  Threads: ${THREADS}"
echo "  Algorithm: ${ALGO}"
echo "  Primary Pool: ${PRIMARY_POOL}"
echo "  Backup Pool: ${SECONDARY_POOL}"
echo ""
echo "Previous config saved as: config.json.backup"
echo ""
echo "To start mining with new settings:"
echo "  ./start.sh"
echo "========================================="
RECONFIGURE_EOF

chmod +x reconfigure.sh

# Create info script
cat > info.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "  CCMiner Configuration"
echo "========================================="
echo ""
echo "Wallet: ${WALLET_ADDRESS}"
echo "Worker: ${WORKER_NAME}"
echo "Threads: ${THREADS}"
echo "Algorithm: ${ALGO}"
echo "Primary Pool: ${PRIMARY_POOL}"
echo "Backup Pool: ${SECONDARY_POOL}"
echo ""
echo "========================================="
echo "  Commands"
echo "========================================="
echo ""
echo "Start mining:"
echo "  cd ~/ccminer && ./start.sh"
echo ""
echo "Stop mining:"
echo "  Press Ctrl+C"
echo ""
echo "Change configuration:"
echo "  cd ~/ccminer && ./reconfigure.sh"
echo ""
echo "  Reconfigure lets you:"
echo "  • Switch algorithm"
echo "  • Change pools (primary and backup)"
echo "  • Update wallet and worker name"
echo "  • Adjust thread count"
echo "  • Edit config.json manually"
echo ""
echo "View this info:"
echo "  cd ~/ccminer && ./info.sh"
echo ""
echo "========================================="
EOF

chmod +x info.sh

# Final instructions
echo ""
echo "========================================="
echo "  ✓ Setup Complete!"
echo "========================================="
echo ""
echo "Configuration created:"
echo "  Wallet: ${WALLET_ADDRESS}"
echo "  Worker: ${WORKER_NAME}"
echo "  Threads: ${THREADS}"
echo "  Algorithm: ${ALGO}"
echo "  Primary Pool: ${PRIMARY_POOL}"
echo "  Backup Pool: ${SECONDARY_POOL}"
echo ""
echo "✓ CCMiner automatically switches to backup pool!"
echo ""
echo "⚠️  IMPORTANT TIPS:"
echo ""
echo "  • Disable battery optimization for Termux"
echo "  • Keep phone plugged in while mining"
echo "  • Monitor phone temperature closely"
echo "  • Start with fewer threads if device gets hot"
echo ""
echo "========================================="
echo "  Quick Start Commands"
echo "========================================="
echo ""
echo "Start mining NOW:"
echo "  cd ~/ccminer && ./start.sh"
echo ""
echo "View your info:"
echo "  cd ~/ccminer && ./info.sh"
echo ""
echo "========================================="
echo "  🔧 Changing Configuration"
echo "========================================="
echo ""
echo "To change pools, wallet, threads, or algorithm"
echo "run the reconfiguration script:"
echo ""
echo "  cd ~/ccminer && ./reconfigure.sh"
echo ""
echo "This lets you change settings without"
echo "rebuilding CCminer!"
echo ""
echo "========================================="
echo "  Ready to mine!"
echo "========================================="
echo ""
