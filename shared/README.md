```
═══════════════════════════════════════════════════════════════════════════
 ██╗     ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║     ╚██╗██╔╝██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ██║      ╚███╔╝ ██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██║      ██╔██╗ ██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ███████╗██╔╝ ██╗██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════
                    🐺 SHARED CONFIGURATION & ADAPTERS 🐺
═══════════════════════════════════════════════════════════════════════════
```

# 📁 Shared Directory

## 🎯 Purpose

**Shared configuration and multi-framework adapter layer.**

This directory bridges the gap between different RedM frameworks (LXR-Core, RSG-Core, VORP) and provides centralized configuration for the entire delivery system. It enables framework-agnostic development by abstracting framework-specific implementations behind a unified API.

---

## 📄 File Descriptions

### `config.lua`
**Central configuration file for all script settings**

The single source of truth for all customizable aspects of the delivery job system. Both client and server scripts read from this configuration to maintain consistency.

#### 🔧 Configuration Sections

##### General Settings
```lua
Config.Framework = "RSG"        -- LXR, RSG, or VORP
Config.Debug = false            -- Debug logging
Config.Locale = "en"            -- Language (future use)
```

##### Interaction Settings
```lua
Config.UsePrompt = true         -- Native prompts vs murphy_interact
Config.PromptKey = 0x760A9C6F   -- G key default
Config.PromptLabel = "Delivery Job"
Config.InteractionDistance = 2.5
```

##### NPC Configuration
```lua
Config.NPCs = {
    {
        model = "U_M_M_BHT_BANDITOMINE",
        coords = vector4(x, y, z, heading),
        scenario = "WORLD_HUMAN_SMOKE_CIGARETTE",
        blip = {
            sprite = -1311220797,
            scale = 0.2,
            color = "BLIP_MODIFIER_MP_COLOR_32"
        }
    }
}
```

##### Delivery Locations
```lua
Config.Deliveries = {
    {
        name = "Valentine",
        coords = vector3(x, y, z),
        reward = 150,
        xp = 25
    }
}
```

##### Wagon Settings
```lua
Config.Wagons = {
    models = {
        "cart01",
        "cart02",
        "wagon01"
    },
    spawnOffset = 3.0,
    despawnDelay = 5000
}
```

##### Anti-Exploit Settings
```lua
Config.AntiSpam = {
    Enabled = true,
    MenuCooldown = 2000,        -- 2 seconds between menu opens
    JobCooldown = 5000,         -- 5 seconds between job starts
    CompletionCooldown = 1000   -- 1 second after completion
}
```

##### Reward Configuration
```lua
Config.Rewards = {
    Currency = "cash",          -- or "money", depends on framework
    MinReward = 50,
    MaxReward = 500,
    DistanceBased = true,
    DistanceMultiplier = 0.5,
    IncludeXP = true
}
```

##### Validation Settings
```lua
Config.Validation = {
    MaxDeliveryDistance = 5.0,  -- Completion zone radius
    RequireWagon = true,        -- Must be in wagon to complete
    CheckWagonOwnership = true, -- Verify wagon belongs to job
    MinCompletionTime = 30      -- Prevent instant completion
}
```

---

### `framework.lua`
**Multi-framework adapter and abstraction layer**

Provides a unified interface to interact with different RedM frameworks without changing core logic. Automatically detects which framework is running and initializes the appropriate adapter.

#### 🔌 Framework Support

##### Supported Frameworks (in priority order)

1. **LXR-Core** - The Land of Wolves custom framework
2. **RSG-Core** - RedM Script Group framework  
3. **VORP Core** - Vintage Outlaw Roleplay framework

#### 🏗️ Adapter Architecture

```lua
Framework = {
    Name = nil,           -- Detected framework name
    Object = nil,         -- Framework core object
    
    -- Unified API methods
    GetPlayer(source),    -- Get player object
    GetPlayerMoney(source, type),
    AddMoney(source, type, amount),
    RemoveMoney(source, type, amount),
    Notify(source, message, type),
    GetPlayerJob(source),
    -- ... additional methods
}
```

#### 🔄 Automatic Detection

The adapter automatically detects which framework is loaded:

```lua
-- Detection order
1. Check for LXRCore export
2. Check for RSGCore export
3. Check for VORPCORE global
4. Fallback error if none found
```

#### 📡 Unified API Examples

##### Get Player
```lua
-- Works across all frameworks
local Player = Framework.GetPlayer(source)
```

**Behind the scenes:**
- LXR: `LXRCore.Functions.GetPlayer(source)`
- RSG: `RSGCore.Functions.GetPlayer(source)`
- VORP: `VORPcore.getUser(source).getUsedCharacter`

##### Add Money
```lua
-- Consistent interface
Framework.AddMoney(source, 'cash', 150)
```

**Behind the scenes:**
- LXR: `Player.Functions.AddMoney('cash', 150)`
- RSG: `Player.Functions.AddMoney('cash', 150)`
- VORP: `Player.addCurrency(0, 150)` -- 0 = cash

##### Notify Player
```lua
-- Same call, different implementations
Framework.Notify(source, 'Delivery complete!', 'success')
```

**Behind the scenes:**
- LXR: Uses LXR notification system
- RSG: Uses RSG notification system
- VORP: Uses VORP notification system

---

## 🌉 How Framework Adapter Works

### Initialization Flow

```
┌─────────────────────────────────────────────────────────────┐
│              Resource Start (fxmanifest.lua)                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │  shared/config.lua  │  ← Load first
           │  (Config table)     │
           └─────────┬───────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │shared/framework.lua │  ← Load second
           └─────────┬───────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │ Detect Framework    │
           │ - Check LXRCore     │
           │ - Check RSGCore     │
           │ - Check VORPCORE    │
           └─────────┬───────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │Initialize Adapter   │
           │Set Framework.Name   │
           │Set Framework.Object │
           └─────────┬───────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │Create Unified API   │
           │Map framework methods│
           └─────────┬───────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │ Client/Server Load  │
           │ Use Framework API   │
           └─────────────────────┘
```

### Usage in Client/Server

```lua
-- In client.lua or server.lua
-- No need to check framework type!

-- Just use the unified API:
local Player = Framework.GetPlayer(source)
local money = Framework.GetPlayerMoney(source, 'cash')
Framework.AddMoney(source, 'cash', 150)
Framework.Notify(source, 'Job started!', 'info')
```

---

## 🎯 Benefits of Shared Approach

### 1. Centralized Configuration
- ✅ Single file to modify settings
- ✅ No need to edit multiple files
- ✅ Consistent values across client/server
- ✅ Easy to backup and restore

### 2. Framework Agnostic
- ✅ Write once, run on any framework
- ✅ Easy to add new framework support
- ✅ No conditional framework checks in logic
- ✅ Cleaner, more maintainable code

### 3. Easy Server Migration
- ✅ Change one line: `Config.Framework = "VORP"`
- ✅ No code changes needed
- ✅ Instant framework switching
- ✅ Perfect for server owners

### 4. Developer Friendly
- ✅ Intuitive configuration structure
- ✅ Well-commented examples
- ✅ Clear naming conventions
- ✅ Logical grouping of settings

---

## 🔧 Configuration Best Practices

### General Guidelines

1. **Always restart resource after config changes**
   ```bash
   restart lxr-deliveryjob
   ```

2. **Backup config before major changes**
   ```bash
   cp shared/config.lua shared/config.lua.backup
   ```

3. **Test changes on development server first**

4. **Use consistent coordinate formats**
   ```lua
   -- Good
   coords = vector3(x, y, z)
   -- Bad
   coords = {x = x, y = y, z = z}
   ```

5. **Keep framework setting correct**
   ```lua
   Config.Framework = "RSG"  -- Must match your actual framework!
   ```

### Common Configuration Tasks

#### Adding New Delivery Location
```lua
-- In Config.Deliveries table
{
    name = "Rhodes",
    coords = vector3(-1368.53, -2426.71, 42.98),
    reward = 200,
    xp = 30
}
```

#### Adding New NPC Location
```lua
-- In Config.NPCs table
{
    model = "U_M_M_BHT_BANDITOMINE",
    coords = vector4(-1368.53, -2426.71, 42.98, 180.0),
    scenario = "WORLD_HUMAN_SMOKE_CIGARETTE",
    blip = {
        sprite = -1311220797,
        scale = 0.2,
        color = "BLIP_MODIFIER_MP_COLOR_32"
    }
}
```

#### Adjusting Rewards
```lua
Config.Rewards = {
    MinReward = 75,          -- Increased from 50
    MaxReward = 750,         -- Increased from 500
    DistanceMultiplier = 1.0 -- Doubled rewards
}
```

#### Changing Interaction Method
```lua
-- Switch from prompts to Murphy Interact
Config.UsePrompt = false

-- Ensure murphy_interact is installed and started!
```

---

## 🧪 Testing Configuration Changes

### Test Checklist

- [ ] Syntax valid (no Lua errors on start)
- [ ] Framework detection works
- [ ] NPCs spawn at correct locations
- [ ] Delivery destinations accessible
- [ ] Rewards calculating correctly
- [ ] Anti-spam timers appropriate
- [ ] Blips appearing on map
- [ ] Interaction method functioning

---

## 📊 Configuration File Backups

Multiple backup files may exist:
- `config.lua` - Current active config
- `config.lua.backup` - Manual backup
- `config.lua.old` - Previous version
- `config_old.lua` - Legacy backup

**Best practice:** Keep only one backup and current version.

---

## 🔍 Debugging Configuration Issues

### Enable Debug Mode
```lua
Config.Debug = true
```

**Provides verbose output for:**
- Framework detection
- Config value loading
- Validation checks
- Reward calculations

### Common Issues

**Issue:** NPCs not spawning  
**Check:** `Config.NPCs` table, model names, coordinates

**Issue:** Rewards not given  
**Check:** `Config.Framework` matches your server, `Config.Rewards.Currency`

**Issue:** Blips not showing  
**Check:** `Config.NPCs[x].blip` settings, sprite hash correct

**Issue:** Anti-spam too aggressive  
**Check:** `Config.AntiSpam` cooldown values (in milliseconds)

---

## 🎓 Adding New Framework Support

Want to add support for a new framework? Edit `framework.lua`:

```lua
-- 1. Add detection
elseif GetResourceState('your-framework') == 'started' then
    Framework.Name = 'YourFramework'
    -- exports or globals
    
-- 2. Implement adapter methods
elseif Framework.Name == 'YourFramework' then
    function Framework.GetPlayer(source)
        -- Your framework's method
    end
    -- ... implement all required methods
```

---

## 📞 Support

**Configuration help?**

- Review this README thoroughly
- Check for Lua syntax errors
- Verify framework setting is correct
- Test with default config first
- Join Discord: [The Land of Wolves](https://discord.gg/CrKcWdfd3A)

---

**🐺 The Land of Wolves | Configuration Excellence**  
*One Config to Rule Them All*
