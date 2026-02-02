```
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 MULTI-FRAMEWORK SUPPORT - Framework Adapter System
═══════════════════════════════════════════════════════════════════════════════
```

## 📋 Table of Contents

1. [Overview](#overview)
2. [Supported Frameworks](#supported-frameworks)
3. [Auto-Detection System](#auto-detection-system)
4. [Framework Adapter Layer](#framework-adapter-layer)
5. [Unified API Reference](#unified-api-reference)
6. [Framework-Specific Details](#framework-specific-details)
7. [Custom Framework Integration](#custom-framework-integration)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The LXR Delivery Job System features a **sophisticated framework adapter layer** that provides seamless compatibility across multiple RedM frameworks without requiring core code changes.

### Key Features

- **Automatic Framework Detection**: Detects LXR-Core, RSG-Core, or VORP Core on startup
- **Unified API**: Single set of functions works across all frameworks
- **Priority System**: Framework detection follows priority order (LXR → RSG → VORP)
- **Zero Code Duplication**: One codebase for all frameworks
- **Future-Proof**: Easy to add support for new frameworks

---

## 🏆 Supported Frameworks

### Primary Frameworks

| Framework | Version | Support Level | Priority |
|-----------|---------|---------------|----------|
| **LXR-Core** | Latest | Full | 1st (Primary) |
| **RSG-Core** | Latest | Full | 2nd (Co-Primary) |
| **VORP Core** | Latest | Full | 3rd (Supported) |

### Support Levels

- **Full**: All features implemented and tested
- **Partial**: Core features work, some limitations
- **Experimental**: Under development

---

## 🔍 Auto-Detection System

### How It Works

The framework adapter automatically detects which framework is running when the resource starts.

```lua
-- From shared/framework.lua (lines 54-75)

local function DetectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework -- Manual override
    end
    
    -- Try LXR-Core first (priority framework)
    if GetResourceState('lxr-core') == 'started' then
        return 'LXR'
    end
    
    -- Try RSG-Core second (co-primary framework)
    if GetResourceState('rsg-core') == 'started' then
        return 'RSG'
    end
    
    -- Try VORP (supported legacy framework)
    if GetResourceState('vorp_core') == 'started' then
        return 'VORP'
    end
    
    return nil -- No framework detected
end
```

### Detection Priority

**Order**: LXR-Core → RSG-Core → VORP Core

**Why This Order?**
1. **LXR-Core**: Primary framework for The Land of Wolves server
2. **RSG-Core**: Most common RedM framework, co-primary support
3. **VORP Core**: Legacy framework, widely used in community

### Manual Override

If auto-detection fails or you want to force a specific framework:

```lua
-- In shared/config.lua
Config.Framework = 'RSG' -- Force RSG-Core
-- Options: 'auto', 'LXR', 'RSG', 'VORP'
```

### Initialization Output

When successful, you'll see in server console:

```
════════════════════════════════════════════════════════════════════════════
  🐺 Framework Adapter Loaded
  Multi-Framework Bridge: Ready
  Supported: LXR-Core, RSG-Core, VORP Core
════════════════════════════════════════════════════════════════════════════
[LXR-Delivery] Framework: RSG-Core initialized successfully!
```

---

## 🏗️ Framework Adapter Layer

**Location**: `shared/framework.lua`  
**Purpose**: Provides unified API across all frameworks

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│           DELIVERY SYSTEM CODE                             │
│  (Uses Framework.XXX() calls - framework-agnostic)         │
└────────────────────────────────────────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────────────┐
│              FRAMEWORK ADAPTER LAYER                       │
│  shared/framework.lua - Translates calls to framework API  │
└────────────────────────────────────────────────────────────┘
                         ↓
        ┌────────────────┴────────────────┐
        ↓                ↓                 ↓
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  LXR-Core    │ │  RSG-Core    │ │  VORP Core   │
│  Functions   │ │  Functions   │ │  Functions   │
└──────────────┘ └──────────────┘ └──────────────┘
```

### Global Objects

```lua
Framework = {}
Framework.Name = nil     -- Detected framework name ('LXR', 'RSG', 'VORP')
Framework.Object = nil   -- Framework core object
```

### Initialization

```lua
Citizen.CreateThread(function()
    Framework.Name = DetectFramework()
    
    if not Framework.Name then
        print("^1[LXR-Delivery] ^7WARNING: No supported framework detected!")
        return
    end
    
    -- Initialize framework object
    if Framework.Name == 'LXR' then
        Framework.Object = exports['lxr-core']:GetCoreObject()
    elseif Framework.Name == 'RSG' then
        Framework.Object = exports['rsg-core']:GetCoreObject()
    elseif Framework.Name == 'VORP' then
        Framework.Object = exports.vorp_core:GetCore()
    end
end)
```

---

## 📚 Unified API Reference

The adapter provides a consistent API regardless of underlying framework.

### Client-Side API

#### Framework.Notify()

Send notification to player.

```lua
Framework.Notify(title, message, type, duration)
```

**Parameters**:
- `title` (string): Notification title
- `message` (string): Notification message
- `type` (string): Type ("success", "error", "info", "warning")
- `duration` (number): Duration in milliseconds

**Example**:
```lua
Framework.Notify("Delivery", "Wagon spawned!", "success", 3500)
```

#### Framework.GetPlayerJob()

Get player's current job information.

```lua
local job = Framework.GetPlayerJob()
```

**Returns**: Table with job data
```lua
{
    name = "unemployed",
    grade = 0,
    label = "Unemployed"
}
```

**Example**:
```lua
local job = Framework.GetPlayerJob()
if job.name == "deliverydriver" then
    print("You're a delivery driver!")
end
```

#### Framework.HasItem()

Check if player has specific item (client-side callback).

```lua
local hasItem = Framework.HasItem(itemName, amount)
```

**Parameters**:
- `itemName` (string): Item name to check
- `amount` (number): Required amount (default: 1)

**Returns**: boolean

**Example**:
```lua
if Framework.HasItem("deliverylicense", 1) then
    -- Allow delivery
end
```

---

### Server-Side API

#### Framework.Notify()

Send notification to specific player (server → client).

```lua
Framework.Notify(source, title, message, type, duration)
```

**Parameters**:
- `source` (number): Player server ID
- `title` (string): Notification title
- `message` (string): Notification message
- `type` (string): Type ("success", "error", "info", "warning")
- `duration` (number): Duration in milliseconds

**Example**:
```lua
Framework.Notify(source, "Reward", "You earned $50!", "success", 3500)
```

#### Framework.GetPlayer()

Get player data from framework.

```lua
local Player = Framework.GetPlayer(source)
```

**Parameters**:
- `source` (number): Player server ID

**Returns**: Framework player object or nil

**Example**:
```lua
local Player = Framework.GetPlayer(source)
if Player then
    -- Work with player data
end
```

#### Framework.AddMoney()

Add money to player account.

```lua
local success = Framework.AddMoney(source, amount, account, reason)
```

**Parameters**:
- `source` (number): Player server ID
- `amount` (number): Amount to add
- `account` (string): Account type ("cash", "bank", "gold" or 0/1 for VORP)
- `reason` (string): Optional reason for logs

**Returns**: boolean (success)

**Example**:
```lua
local success = Framework.AddMoney(source, 75, "cash", "Delivery Reward")
if success then
    print("Reward given successfully")
end
```

#### Framework.RemoveMoney()

Remove money from player account.

```lua
local success = Framework.RemoveMoney(source, amount, account, reason)
```

**Parameters**: Same as AddMoney

**Example**:
```lua
Framework.RemoveMoney(source, 10, "cash", "Delivery Deposit")
```

#### Framework.AddItem()

Add item to player inventory.

```lua
local success = Framework.AddItem(source, item, amount, metadata)
```

**Parameters**:
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number): Amount to add (default: 1)
- `metadata` (table): Optional item metadata

**Returns**: boolean (success)

**Example**:
```lua
Framework.AddItem(source, "dollar", 10, {
    description = "Delivery Reward"
})
```

#### Framework.RemoveItem()

Remove item from player inventory.

```lua
local success = Framework.RemoveItem(source, item, amount)
```

**Parameters**:
- `source` (number): Player server ID
- `item` (string): Item name
- `amount` (number): Amount to remove (default: 1)

**Example**:
```lua
Framework.RemoveItem(source, "deliverylicense", 1)
```

#### Framework.GetPlayerJob()

Get player's current job (server-side).

```lua
local job = Framework.GetPlayerJob(source)
```

**Returns**: Job data table

**Example**:
```lua
local job = Framework.GetPlayerJob(source)
if job.name == "police" then
    -- Special handling for police
end
```

#### Framework.HasItem()

Check if player has specific item (server-side).

```lua
local hasItem = Framework.HasItem(source, item, amount)
```

**Returns**: boolean

---

## 🔧 Framework-Specific Details

### LXR-Core Integration

**Resource Name**: `lxr-core`  
**Priority**: 1st (Primary Framework)

**Configuration**:
```lua
Config.FrameworkSettings.LXR = {
    resourceName = 'lxr-core',
    events = {
        playerLoaded = 'lxr-core:client:player:loaded',
        playerUnload = 'lxr-core:client:player:unloaded',
        jobUpdate = 'lxr-core:client:job:update',
    },
    callbacks = {
        hasItem = 'lxr-core:server:hasItem',
    }
}
```

**Core Object Access**:
```lua
Framework.Object = exports['lxr-core']:GetCoreObject()
```

**Player Functions**:
```lua
-- Get player
local Player = Framework.Object.Functions.GetPlayer(source)

-- Add money
Player.Functions.AddMoney('cash', 50, "Delivery Reward")

-- Add item
Player.Functions.AddItem('dollar', 10, false, {})

-- Get player job
local PlayerData = Player.PlayerData
local job = PlayerData.job
```

**Account Types**:
- `"cash"`: Cash money
- `"bank"`: Bank money

---

### RSG-Core Integration

**Resource Name**: `rsg-core`  
**Priority**: 2nd (Co-Primary Framework)

**Configuration**:
```lua
Config.FrameworkSettings.RSG = {
    resourceName = 'rsg-core',
    events = {
        playerLoaded = 'RSGCore:Client:OnPlayerLoaded',
        playerUnload = 'RSGCore:Client:OnPlayerUnload',
        jobUpdate = 'RSGCore:Client:OnJobUpdate',
    },
    callbacks = {
        hasItem = 'RSGCore:Server:HasItem',
    }
}
```

**Core Object Access**:
```lua
Framework.Object = exports['rsg-core']:GetCoreObject()
```

**Player Functions**:
```lua
-- Get player
local Player = Framework.Object.Functions.GetPlayer(source)

-- Add money
Player.Functions.AddMoney('cash', 50, "Delivery Reward")

-- Add item
Player.Functions.AddItem('dollar', 10, false, {})

-- Get player job
local PlayerData = Player.PlayerData
local job = PlayerData.job
```

**Account Types**:
- `"cash"`: Cash money
- `"bank"`: Bank money

**Compatibility**: Near 100% compatible with LXR-Core (same API structure)

---

### VORP Core Integration

**Resource Name**: `vorp_core`  
**Priority**: 3rd (Supported Legacy Framework)

**Configuration**:
```lua
Config.FrameworkSettings.VORP = {
    resourceName = 'vorp_core',
    coreExport = 'vorp_core:GetCore',
    events = {
        playerLoaded = 'vorp:SelectedCharacter',
        playerUnload = 'vorp:PlayerLogout',
    }
}
```

**Core Object Access**:
```lua
Framework.Object = exports.vorp_core:GetCore()
```

**Player Functions**:
```lua
-- Get user (VORP uses 'User' not 'Player')
local User = Framework.Object.getUser(source)
local Character = User.getUsedCharacter

-- Add money (VORP uses numeric account IDs)
Character.addCurrency(0, 50) -- 0 = cash
Character.addCurrency(1, 5)  -- 1 = gold

-- Add item (requires vorp_inventory)
exports.vorp_inventory:addItem(source, 'dollar', 10)

-- Get player job
local job = Character.job
local jobGrade = Character.jobGrade
```

**Account Types**:
- `0`: Cash
- `1`: Gold

**Special Notes**:
- Uses `vorp_inventory` export for item management
- Character-based system (User → Character)
- Different event naming conventions

---

## 🛠️ Custom Framework Integration

Want to add support for another framework? Follow this guide:

### Step 1: Add Framework Configuration

Edit `shared/config.lua`:

```lua
Config.FrameworkSettings.YOURFRAMEWORK = {
    resourceName = 'your-framework',
    events = {
        playerLoaded = 'yourframework:player:loaded',
        playerUnload = 'yourframework:player:unload',
        jobUpdate = 'yourframework:job:update',
    },
    callbacks = {
        hasItem = 'yourframework:hasItem',
    }
}
```

### Step 2: Add Detection Logic

Edit `shared/framework.lua` in `DetectFramework()`:

```lua
-- Add before 'return nil' line
if GetResourceState(Config.FrameworkSettings.YOURFRAMEWORK.resourceName) == 'started' then
    return 'YOURFRAMEWORK'
end
```

### Step 3: Add Initialization

In `Citizen.CreateThread()` initialization:

```lua
elseif Framework.Name == 'YOURFRAMEWORK' then
    Framework.Object = exports['your-framework']:GetCore()
    print("^2[LXR-Delivery] ^7Framework: ^5YourFramework ^7initialized successfully!")
```

### Step 4: Implement Unified API Functions

For each API function, add framework-specific implementation:

**Example - Framework.AddMoney()**:

```lua
function Framework.AddMoney(source, amount, account, reason)
    -- ... existing LXR/RSG/VORP code ...
    
    elseif Framework.Name == 'YOURFRAMEWORK' then
        local Player = Framework.GetPlayer(source)
        Player.YourFrameworkAddMoneyFunction(account, amount)
        return true
    end
    
    return false
end
```

### Step 5: Test Thoroughly

- Test player detection
- Test money transactions
- Test item management
- Test notifications
- Test job detection

---

## 🐛 Troubleshooting

### Framework Not Detected

**Symptoms**:
```
[LXR-Delivery] WARNING: No supported framework detected!
```

**Solutions**:
1. Verify framework resource is started in server.cfg
2. Check resource name matches config:
   ```lua
   Config.FrameworkSettings.RSG.resourceName = 'rsg-core' -- Must match actual name
   ```
3. Force manual detection:
   ```lua
   Config.Framework = 'RSG' -- Force RSG-Core
   ```
4. Check server console for framework loading errors

---

### Wrong Framework Detected

**Symptoms**: System detects wrong framework (e.g., detects RSG when using LXR)

**Solutions**:
1. Check load order in server.cfg (framework must load first)
2. Verify only one framework is running
3. Force correct framework:
   ```lua
   Config.Framework = 'LXR' -- Force LXR-Core
   ```

---

### Money Not Adding

**Symptoms**: Deliveries complete but no money received

**Solutions**:

**For LXR/RSG**:
1. Verify account type is string:
   ```lua
   Config.Reward_Money_Account = "cash" -- Not 0 or 1
   ```
2. Check player has valid character loaded
3. Test with manual command:
   ```lua
   RegisterCommand('testmoney', function(source)
       Framework.AddMoney(source, 100, "cash", "Test")
   end)
   ```

**For VORP**:
1. Verify account type is numeric:
   ```lua
   Config.Reward_Money_Account = 0 -- Not "cash"
   ```
2. Ensure character is selected (not just user logged in)
3. Check VORP character system is working

---

### Items Not Adding

**Symptoms**: Item rewards configured but not received

**Solutions**:

**For LXR/RSG**:
1. Verify item exists in `shared/items.lua`:
   ```lua
   ["dollar"] = {
       name = "dollar",
       label = "Dollar",
       -- ... rest of config
   }
   ```
2. Check inventory system is working
3. Test with manual give item command

**For VORP**:
1. Verify `vorp_inventory` is running
2. Check item exists in VORP items database
3. Test with VORP give item command:
   ```lua
   /giveitem [id] dollar 10
   ```

---

### Events Not Triggering

**Symptoms**: Player load events not detected

**Solutions**:
1. Check event names in config match framework:
   ```lua
   -- RSG-Core uses:
   events = {
       playerLoaded = 'RSGCore:Client:OnPlayerLoaded',
       -- Must match exactly
   }
   ```
2. Verify framework version (older versions may use different events)
3. Check framework documentation for correct event names

---

## 📚 Additional Resources

- **LXR-Core Documentation**: Contact The Land of Wolves team
- **RSG-Core Documentation**: [github.com/Rexshack-RedM/rsg-core](https://github.com/Rexshack-RedM/rsg-core)
- **VORP Core Documentation**: [github.com/VORPCORE](https://github.com/VORPCORE)

---

## 🌍 Server Information

**Developer**: iBoss21 / The Lux Empire  
**Server**: The Land of Wolves 🐺  
**Discord**: [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)  
**Website**: [www.wolves.land](https://www.wolves.land)

---

*Framework Guide v2.1.0 | Built with ❤️ by The Land of Wolves 🐺*
