#!/data/data/com.termux/files/usr/bin/bash

#########################################
# CCMiner Automated Setup for Termux
# For Verus Coin Mining
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
echo "Enter your Verus wallet address:"
read -r WALLET_ADDRESS

echo ""
echo "Enter worker name (e.g., phone-1, A03-3):"
read -r WORKER_NAME

echo ""
echo "Enter number of threads (recommended: 4-8):"
read -r THREADS

echo ""
echo "Enter primary pool address (e.g., stratum+tcp://verus.farm:9999):"
read -r PRIMARY_POOL

echo ""
echo "Enter secondary/backup pool address (e.g., stratum+tcp://us.vipor.net:5040):"
read -r SECONDARY_POOL

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
    "algo": "verus",
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

# Final instructions
echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Configuration created:"
echo "  Wallet: ${WALLET_ADDRESS}"
echo "  Worker: ${WORKER_NAME}"
echo "  Threads: ${THREADS}"
echo "  Primary Pool: ${PRIMARY_POOL}"
echo "  Backup Pool: ${SECONDARY_POOL}"
echo ""
echo "To edit config later:"
echo "  nano ~/ccminer/config.json"
echo ""
echo "To start mining:"
echo "  cd ~/ccminer"
echo "  ./start.sh"
echo ""
echo "To stop mining:"
echo "  Press Ctrl+C"
echo ""
echo "========================================="
echo "Ready to mine! Run: cd ~/ccminer && ./start.sh"
echo "========================================="
