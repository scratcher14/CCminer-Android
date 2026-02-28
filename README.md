# Verus CCminer Setup for Android (Termux)

Automated setup script for mining Verus Coin on Android devices using CCminer in Termux.

## 📱 Requirements

- Android device (ARM64 architecture)
- Termux app installed ([F-Droid](https://f-droid.org/packages/com.termux/) or [GitHub](https://github.com/termux/termux-app/releases))
- Stable internet connection
- At least 2GB free storage space
- Verus wallet address

## ⚡ Quick Start

### 1. Install Termux
Download and install Termux from F-Droid (recommended) or GitHub releases. **Do not use the Play Store version** as it's outdated.

### 2. Download and Run Setup Script

Open Termux and run these commands:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/scratcher14/CCminer-Android/main/setup_ccminer.sh

# Make it executable
chmod +x setup_ccminer.sh

# Run the setup
./setup_ccminer.sh
```

### 3. Configure During Setup

The script will prompt you for:
- **Wallet Address**: Your Verus (VRSC) wallet address
- **Worker Name**: Identifier for this device (e.g., `phone-1`, `A03-3`)
- **Threads**: Number of CPU threads (recommended: 4-8)
- **Primary Pool**: Main mining pool address
- **Secondary Pool**: Backup pool address

### 4. Start Mining

After setup completes:

```bash
cd ~/ccminer
./start.sh
```

## 🔧 What the Script Does

1. Updates Termux packages
2. Installs required dependencies (libjansson, build tools, clang, git)
3. Fixes system header compatibility issues
4. Clones the CCminer repository optimized for ARM
5. Configures build for ARM architecture (Cortex-A55)
6. Compiles CCminer (takes 10-20 minutes)
7. Creates configuration file with your settings
8. Sets up easy start script and reconfigure script

## 📊 Recommended Settings

### Thread Count by Device
- **Budget phones** (4-6 cores): 2-4 threads
- **Mid-range phones** (6-8 cores): 4-6 threads  
- **Flagship phones** (8+ cores): 6-8 threads

### Popular Verus Mining Pools

For the most up-to-date list of pools with current hashrates and stats, visit:
**[Mining Pool Stats - Verus](https://miningpoolstats.stream/veruscoin)**

Some popular options:
- **bobfarm**: `stratum+tcp://vrsc.bobfarm.icu:9998` - [Pool Info](https://vrsc.bobfarm.icu/#/home)
- **verus.farm**: `stratum+tcp://verus.farm:9999`
- **vipor.net (US)**: `stratum+tcp://us.vipor.net:5040`
- **luckpool**: `stratum+tcp://luckpool.net:3956`

## 🛠️ Managing Your Miner

### Reconfigure Settings (Easy Way)
To change pools, wallet, threads, or other settings:
```bash
cd ~/ccminer
./reconfigure.sh
```

This will let you update:
- Wallet address
- Worker name
- Thread count
- Primary pool
- Secondary pool
- Mining algorithm (for future coins on same algo)

### Edit Configuration Manually
```bash
nano ~/ccminer/config.json
```

### Start Mining
```bash
cd ~/ccminer
./start.sh
```

### Stop Mining
Press `Ctrl + C` in the Termux window

### View Mining Stats
Stats are displayed in real-time in the Termux window, including:
- Hashrate
- Accepted/rejected shares
- Pool connection status

### Keep Mining After Closing Termux
To keep mining when Termux is in the background:
1. Acquire wakelock: `termux-wake-lock`
2. Start mining: `./start.sh`
3. Close Termux (mining continues)

To stop:
1. Open Termux
2. Press `Ctrl + C`
3. Release wakelock: `termux-wake-unlock`

## ⚠️ Important Notes

### Battery & Heat
- Mining is CPU-intensive and will drain battery quickly
- Keep your phone plugged in
- Monitor temperature - stop if device gets too hot
- Consider removing phone case for better cooling
- Avoid mining on devices with poor cooling

### Performance Tips
- Close other apps while mining
- Enable "Performance" mode in phone settings if available
- Use a cooling pad or fan if available
- Start with fewer threads and increase gradually

### Troubleshooting

**Build fails:**
- Ensure you have enough storage (2GB+ free)
- Try running `pkg update && pkg upgrade` first
- Check internet connection stability

**Low hashrate:**
- Reduce thread count
- Check if phone is thermal throttling
- Try different CPU priority settings

**Miner won't start:**
- Verify config.json syntax: `cat ~/ccminer/config.json`
- Check pool URLs are correct
- Ensure wallet address is valid

**Connection issues:**
- Verify pool addresses are correct
- Try backup pool
- Check firewall/network restrictions

## 📁 File Structure

```
~/ccminer/
├── ccminer              # Main miner executable
├── config.json          # Mining configuration
├── start.sh             # Easy start script
├── reconfigure.sh       # Reconfiguration script
├── build.sh             # Build script
└── configure.sh         # Configuration script
```

## 🔄 Updating

To update CCminer to the latest version:

```bash
cd ~/ccminer
git pull
./build.sh
```

## 🆘 Support & Resources

- **GitHub Repository**: [https://github.com/scratcher14/CCminer-Android](https://github.com/scratcher14/CCminer-Android)
- **Verus Community**: [https://verus.io](https://verus.io)
- **Cell Hasher**: [https://cellhasher.com/](https://cellhasher.com/) - Mobile mining community, resources, and [Discord server](https://discord.gg/ncCpaAEN)
- **VaultFarm YouTube**: [Tutorial videos and mining guides](https://youtube.com/@vaultfarm?si=CY_Vt_PhnMqvhx8P)
- **CCminer Repository**: [Darktron/ccminer](https://github.com/Darktron/ccminer)

## ⚖️ Disclaimer

Mining cryptocurrency consumes significant power and generates heat. Use at your own risk. Monitor your device temperature and battery health. This setup is for educational purposes - mining profitability varies based on hardware, electricity costs, and market conditions.

## 📝 License

This setup script is provided as-is for the Verus mining community. CCminer is open source - check the original repository for license details.

---

**Happy Mining! ⛏️**
