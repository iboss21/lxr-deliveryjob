```
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 INSTALLATION GUIDE - Delivery Job System
═══════════════════════════════════════════════════════════════════════════════
```

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Dependencies](#dependencies)
3. [Installation Steps](#installation-steps)
4. [Framework-Specific Setup](#framework-specific-setup)
5. [Quick Start Configuration](#quick-start-configuration)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

### Minimum Requirements

- **Server**: RedM server (latest artifact build recommended)
- **FX Version**: cerulean or later
- **Lua Version**: 5.4 (automatic with cerulean)
- **OneSync**: Required (enabled in server.cfg)
- **Framework**: One of the following:
  - LXR-Core
  - RSG-Core
  - VORP Core

### Recommended Specifications

- **Server RAM**: 4GB minimum, 8GB recommended
- **RedM Build**: Latest stable artifact
- **Players**: Tested with 32-128 players
- **OneSync Mode**: OneSync Infinity or Legacy

---

## 📦 Dependencies

### Required Dependencies

| Dependency | Purpose | Source |
|------------|---------|--------|
| **OneSync** | Entity synchronization | Built into RedM server |
| **Framework** | Core economy/player system | LXR-Core / RSG-Core / VORP |

### Optional Dependencies

| Dependency | Purpose | Required For |
|------------|---------|--------------|
| **ox_lib** | Menu system | Menu-based UI (recommended) |
| **murphy_interact** | Alternative interaction | NPC interaction system |
| **bln_notify** | Notifications | Current notification system |

> **Note**: The system includes a framework adapter that auto-detects your framework. No manual framework configuration needed unless forcing a specific framework.

---

## 🚀 Installation Steps

### Step 1: Download the Resource

```bash
# Clone from GitHub (recommended)
cd resources/[jobs]
git clone https://github.com/iBoss21/lxr-deliveryjob.git

# OR download ZIP and extract
# Ensure the folder is named exactly: lxr-deliveryjob
```

> ⚠️ **CRITICAL**: The resource folder MUST be named `lxr-deliveryjob`. The system enforces this name for proper event routing and framework integration.

### Step 2: Verify File Structure

Ensure your installation matches this structure:

```
resources/[jobs]/lxr-deliveryjob/
├── fxmanifest.lua
├── shared/
│   ├── config.lua
│   └── framework.lua
├── client/
│   ├── client.lua
│   ├── interaction.lua
│   └── npcs.lua
├── server/
│   └── server.lua
├── docs/
│   └── (documentation files)
└── README.md
```

### Step 3: Install Dependencies

#### OneSync (Required)
Add to your `server.cfg`:
```cfg
# Enable OneSync (required for entity sync)
onesync on
```

#### OX Lib (Recommended)
```bash
cd resources/[dependencies]
git clone https://github.com/overextended/ox_lib.git
```

Add to `server.cfg`:
```cfg
ensure ox_lib
```

#### murphy_interact (Optional)
If using murphy_interact instead of native prompts:
```bash
cd resources/[dependencies]
# Download murphy_interact from your preferred source
```

### Step 4: Configure Framework Detection

Open `shared/config.lua` and verify framework settings:

```lua
-- Auto-detect framework (recommended)
Config.Framework = 'auto' -- Options: 'auto', 'LXR', 'RSG', 'VORP'

-- Framework resource names (adjust if you renamed your framework)
Config.FrameworkSettings = {
    LXR = {
        resourceName = 'lxr-core', -- Change if your LXR-Core has different name
        -- ... rest of settings
    },
    RSG = {
        resourceName = 'rsg-core', -- Change if your RSG-Core has different name
        -- ... rest of settings
    },
    VORP = {
        resourceName = 'vorp_core', -- Change if your VORP has different name
        -- ... rest of settings
    }
}
```

### Step 5: Add to server.cfg

Add the resource to your `server.cfg` in the appropriate load order:

```cfg
# Core Framework (ensure one of these is loaded)
ensure lxr-core      # OR rsg-core OR vorp_core

# Dependencies
ensure ox_lib        # If using OX Lib menus

# Jobs Category
ensure lxr-deliveryjob
```

**Load Order Matters**:
1. Framework (LXR/RSG/VORP)
2. ox_lib (if used)
3. lxr-deliveryjob

### Step 6: Configure Items (If Using Item Rewards)

If your configuration uses item rewards (default: "dollar" item), ensure the item exists in your framework.

#### For RSG-Core / LXR-Core
Edit `shared/items.lua` in your core resource:

```lua
-- Ensure 'dollar' item exists (or whatever item you configured)
["dollar"] = {
    ["name"] = "dollar",
    ["label"] = "Dollar",
    ["weight"] = 0,
    ["type"] = "item",
    ["image"] = "dollar.png",
    ["unique"] = false,
    ["useable"] = false,
    ["shouldClose"] = false,
    ["combinable"] = nil,
    ["description"] = "Paper money for transactions"
},
```

#### For VORP Core
Ensure the item is defined in your VORP items database/configuration.

### Step 7: Restart Server

```bash
# Stop server
# Start server
# OR use restart command
restart lxr-deliveryjob
```

---

## 🔧 Framework-Specific Setup

### LXR-Core Setup

1. **Verify Resource Name**: Ensure your LXR-Core resource is named `lxr-core` (or update config)
2. **Check Events**: Default events:
   - `lxr-core:client:player:loaded`
   - `lxr-core:client:player:unloaded`
   - `lxr-core:client:job:update`

3. **Inventory System**: Ensure your inventory supports item metadata (for future features)

### RSG-Core Setup

1. **Verify Resource Name**: Ensure your RSG-Core resource is named `rsg-core` (or update config)
2. **Check Events**: Default events:
   - `RSGCore:Client:OnPlayerLoaded`
   - `RSGCore:Client:OnPlayerUnload`
   - `RSGCore:Client:OnJobUpdate`

3. **Inventory Integration**: Standard RSG-Core inventory should work out of the box

### VORP Core Setup

1. **Verify Resource Name**: Ensure VORP Core is named `vorp_core` (or update config)
2. **Export Configuration**: Default export: `vorp_core:GetCore`
3. **Inventory**: Ensure `vorp_inventory` is running for item rewards
4. **Character System**: System uses `vorp:SelectedCharacter` event for player loading

---

## ⚡ Quick Start Configuration

### Minimal Configuration (Get Running Fast)

1. **Set Framework Mode** (if auto-detect fails):
```lua
Config.Framework = 'RSG' -- Or 'LXR', 'VORP'
```

2. **Choose Interaction System**:
```lua
Config.Interact = "murphy_interact" -- Or "prompt" for native
```

3. **Enable/Disable Random Deliveries**:
```lua
Config.RandomDelivery = true -- Random assignment
Config.RandomDelivery = false -- Player choice
```

4. **Set Reward Account**:
```lua
Config.Reward_Money_Account = "cash" -- Or "bank" for frameworks, 0/1 for VORP
```

### Test Delivery Location

The default config includes Valentine deliveries. Test with:

1. Go to Valentine (coordinates: -340.58, 816.31, 116.93)
2. Look for the NPC near the general store
3. Interact with NPC (press prompt or use murphy_interact)
4. Accept a delivery
5. Drive wagon to destination
6. Complete delivery

---

## ✔️ Verification

### Checklist

- [ ] Resource folder named exactly `lxr-deliveryjob`
- [ ] OneSync enabled in server.cfg
- [ ] Framework resource loaded before lxr-deliveryjob
- [ ] ox_lib loaded (if using menus)
- [ ] Server starts without errors
- [ ] Check server console for framework detection message:

```
════════════════════════════════════════════════════════════════════════════
  🐺 Framework Adapter Loaded
  Multi-Framework Bridge: Ready
  Supported: LXR-Core, RSG-Core, VORP Core
════════════════════════════════════════════════════════════════════════════
[LXR-Delivery] Framework: LXR-Core initialized successfully!
```

### In-Game Testing

1. **Join Server**: Connect to your RedM server
2. **Navigate to Hub**: Go to delivery location (default: Valentine)
3. **Check Blip**: Look for "Wolves Hauling" blip on map
4. **Find NPC**: Locate delivery NPC at coordinates
5. **Interaction**: Test interaction system (prompt/murphy_interact)
6. **Start Delivery**: Accept delivery and check wagon spawn
7. **GPS Check**: Verify destination waypoint appears
8. **Complete**: Drive to destination and test completion
9. **Reward**: Verify you receive configured reward

---

## 🔧 Troubleshooting

### Common Issues

#### ❌ Error: "RESOURCE NAME MISMATCH ERROR"

**Problem**: Resource folder not named `lxr-deliveryjob`

**Solution**: 
```bash
cd resources/[jobs]
mv your-current-folder-name lxr-deliveryjob
```

Restart the resource.

---

#### ❌ Error: "No supported framework detected"

**Problem**: Framework not detected or not started

**Solution**:
1. Verify framework is running: `ensure lxr-core` (or rsg-core/vorp_core) in server.cfg
2. Check framework resource name matches config:
   ```lua
   Config.FrameworkSettings.LXR.resourceName = 'lxr-core' -- Must match actual name
   ```
3. Manual override if auto-detect fails:
   ```lua
   Config.Framework = 'RSG' -- Force specific framework
   ```

---

#### ❌ NPCs Not Spawning

**Problem**: Delivery NPCs not visible in game

**Solution**:
1. Check spawn distance setting:
   ```lua
   Config.DistanceSpawn = 30.0 -- Increase if needed
   ```
2. Verify NPC model exists: `MP_U_M_M_TRADER_01`
3. Check client console (F8) for errors
4. Ensure player is near configured location

---

#### ❌ Wagon Not Spawning

**Problem**: Delivery accepted but wagon doesn't appear

**Solution**:
1. Verify wagon model in config: `cart01` (must be valid RedM model)
2. Check cargo/light props: `pg_teamster_cart01_breakables`
3. Ensure spawn coordinates are valid (not underground/in buildings)
4. Check client console (F8) for model loading errors

---

#### ❌ Rewards Not Given

**Problem**: Completed delivery but no reward

**Solution**:
1. Check server console for validation errors
2. Verify reward configuration:
   ```lua
   -- Ensure ONE reward type is enabled
   priceByDistance = { activation = true, multiplier = 0.05 }
   -- OR
   priceByConfig = { activation = true, price = 25.0 }
   -- OR
   itemreward = { activation = true, itemname = "dollar", itemamount = 10 }
   ```
3. Check if item exists in framework (for item rewards)
4. Verify account type matches framework:
   ```lua
   Config.Reward_Money_Account = "cash" -- RSG/LXR
   Config.Reward_Money_Account = 0 -- VORP (cash)
   ```

---

#### ❌ Menu Not Opening

**Problem**: Interaction prompt works but menu doesn't open

**Solution**:
1. Ensure ox_lib is installed and started
2. Check ox_lib version compatibility
3. Verify @ox_lib is in shared_scripts:
   ```lua
   shared_scripts {
       '@ox_lib/init.lua', -- Must be present
       -- ...
   }
   ```
4. Check client console (F8) for ox_lib errors

---

#### ❌ Exploit: Players Getting Rewards Multiple Times

**Problem**: Players exploiting delivery system

**Solution**:
1. Enable server-side validation (should be on by default):
   ```lua
   Config.Security.validateLocations = true
   Config.Security.logSuspiciousActivity = true
   ```
2. Adjust anti-spam settings:
   ```lua
   Config.AntiSpam = {
       maxMenuOpens = 3,
       detectionWindow = 10,
       cooldownDuration = 60,
       serverRateLimit = 5,
       minDeliveryDuration = 10, -- Increase if needed
   }
   ```
3. Check server console for logged suspicious activity
4. Review `server/server.lua` session tracking

---

### Performance Issues

#### 🐌 Low FPS During Deliveries

**Solutions**:
1. Increase distance check interval:
   ```lua
   Config.Performance.distanceCheckInterval = 1000 -- Higher = better FPS
   ```
2. Limit active deliveries:
   ```lua
   Config.Performance.maxActiveDeliveries = 10 -- 0 = unlimited
   ```
3. Disable fade-in effects:
   ```lua
   Config.FadeIn = false
   ```

---

### Getting Help

If issues persist:

1. **Check Logs**: Review server console and client console (F8) for errors
2. **Enable Debug**: Set `Config.Debug = true` for verbose logging
3. **Discord Support**: Join [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)
4. **GitHub Issues**: Report bugs at [github.com/iBoss21/lxr-deliveryjob](https://github.com/iBoss21/lxr-deliveryjob)

---

## 📚 Next Steps

Now that installation is complete:

1. Read **configuration.md** to customize delivery routes and rewards
2. Review **security.md** to configure anti-exploit settings
3. Check **frameworks.md** for framework-specific features
4. Explore **events.md** to integrate with other resources

---

## 🌍 Server Information

**Developer**: iBoss21 / The Lux Empire  
**Server**: The Land of Wolves 🐺  
**Discord**: [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)  
**Website**: [www.wolves.land](https://www.wolves.land)  
**Store**: [theluxempire.tebex.io](https://theluxempire.tebex.io)

---

*Installation Guide v2.1.0 | Built with ❤️ by The Land of Wolves 🐺*
