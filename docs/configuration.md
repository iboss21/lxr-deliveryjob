```
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 CONFIGURATION REFERENCE - Delivery Job System
═══════════════════════════════════════════════════════════════════════════════
```

## 📋 Table of Contents

1. [Configuration File Overview](#configuration-file-overview)
2. [Framework Settings](#framework-settings)
3. [General Settings](#general-settings)
4. [NPC Configuration](#npc-configuration)
5. [Map Blips & Markers](#map-blips--markers)
6. [Economy & Rewards](#economy--rewards)
7. [Delivery System Modes](#delivery-system-modes)
8. [Security & Anti-Exploit](#security--anti-exploit)
9. [Performance Settings](#performance-settings)
10. [Notification System](#notification-system)
11. [Delivery Locations](#delivery-locations)
12. [Reward Configuration](#reward-configuration)

---

## 📁 Configuration File Overview

**Location**: `shared/config.lua`  
**Size**: 73.5 KB (1604 lines)  
**Scope**: Shared (loaded on both client and server)

The configuration file is the heart of the delivery system, controlling every aspect from framework detection to reward distribution.

---

## 🔧 Framework Settings

### Framework Detection

```lua
-- Auto-detect or manually specify framework
Config.Framework = 'auto' -- Options: 'auto', 'LXR', 'RSG', 'VORP'
```

**Options**:
- `'auto'`: Automatically detects framework (recommended)
- `'LXR'`: Force LXR-Core
- `'RSG'`: Force RSG-Core
- `'VORP'`: Force VORP Core

**Detection Priority**: LXR-Core → RSG-Core → VORP Core

### Framework Resource Names

Configure resource names for each framework:

```lua
Config.FrameworkSettings = {
    LXR = {
        resourceName = 'lxr-core', -- LXR-Core resource name
        events = {
            playerLoaded = 'lxr-core:client:player:loaded',
            playerUnload = 'lxr-core:client:player:unloaded',
            jobUpdate = 'lxr-core:client:job:update',
        },
        callbacks = {
            hasItem = 'lxr-core:server:hasItem',
        }
    },
    RSG = {
        resourceName = 'rsg-core', -- RSG-Core resource name
        events = {
            playerLoaded = 'RSGCore:Client:OnPlayerLoaded',
            playerUnload = 'RSGCore:Client:OnPlayerUnload',
            jobUpdate = 'RSGCore:Client:OnJobUpdate',
        },
        callbacks = {
            hasItem = 'RSGCore:Server:HasItem',
        }
    },
    VORP = {
        resourceName = 'vorp_core', -- VORP Core resource name
        coreExport = 'vorp_core:GetCore',
        events = {
            playerLoaded = 'vorp:SelectedCharacter',
            playerUnload = 'vorp:PlayerLogout',
        }
    }
}
```

**When to Modify**:
- If your framework resource has a different name (e.g., `my-lxr-core`)
- If your framework uses custom events
- If callback names differ from standard

---

## ⚙️ General Settings

### Debug Mode

```lua
Config.Debug = false -- Enable verbose console logging
```

**When to Enable**:
- Troubleshooting delivery issues
- Diagnosing reward problems
- Tracking player interactions

**Output Example**:
```
[LXR-Delivery] Player 1 started delivery: Valentine → Blackwater
[LXR-Delivery] Wagon spawned: cart01 at -347.99, 815.53, 116.72
[LXR-Delivery] Distance to destination: 1234.56 units
```

### Legacy Core Setting

```lua
Config.Core = "RSG" -- Options: "RSG", "VORP"
```

> ⚠️ **Deprecated**: Use `Config.Framework` instead. Kept for backward compatibility.

### Interaction System

```lua
Config.Interact = "murphy_interact" -- Options: "prompt", "murphy_interact", "target" (WIP)
```

**Options**:
- `"prompt"`: Native RedM interaction prompts (no dependencies)
- `"murphy_interact"`: murphy_interact system (requires murphy_interact resource)
- `"target"`: Target system integration (work in progress)

---

## 👤 NPC Configuration

### NPC Spawn Distance

```lua
Config.DistanceSpawn = 30.0 -- Distance (units) at which NPCs spawn around player
```

**Recommendations**:
- **Low-end servers**: 20.0 (better performance)
- **Standard**: 30.0 (default)
- **High-end**: 50.0 (more immersive)

### Fade-In Effect

```lua
Config.FadeIn = true -- Enable smooth fade-in when NPCs spawn/despawn
```

**Impact**:
- `true`: Smooth visual effect, slightly more processing
- `false`: Instant spawn, better performance

---

## 🗺️ Map Blips & Markers

### Delivery Hub Blip

```lua
Config.Blip = {
    -- NPC/hub location marker
    blipName = 'Wolves Hauling',        -- Name shown on map
    blipSprite = 'blip_ambient_coach',  -- Icon sprite
    blipScale = 0.2,                     -- Size (0.1-1.0)
    
    -- Active delivery destination marker
    deliveryBlipSprite = 'blip_destination', -- Destination icon
    deliveryBlipScale = 0.2,                  -- Destination size
    deliveryBlipName = 'Delivery Point'       -- Destination name
}
```

**Common Blip Sprites**:
- `blip_ambient_coach`: Coach/wagon icon (default for hubs)
- `blip_destination`: Target/destination icon
- `blip_shop_stable`: Stable icon
- `blip_shop_doctor`: Doctor icon (custom usage)

**Customization Tips**:
- Use thematic icons matching your server's style
- Adjust scale based on map clutter
- Rename blips to match your server's lore

---

## 💰 Economy & Rewards

### Money Account Configuration

```lua
Config.Reward_Money_Account = "cash" -- Account type for money rewards
```

**Framework-Specific Values**:

| Framework | Valid Options | Description |
|-----------|--------------|-------------|
| **LXR-Core** | `"cash"`, `"bank"` | String-based accounts |
| **RSG-Core** | `"cash"`, `"bank"` | String-based accounts |
| **VORP** | `0`, `1` | Numeric accounts (0=cash, 1=gold) |

### Reward Preview in Menu

```lua
Config.Show_Reward_Money_inMenu = false -- Show payment amounts in delivery menu
```

**When to Enable**:
- `true`: Players see reward before accepting (transparent economy)
- `false`: Reward is a surprise (more immersive, prevents cherry-picking)

---

## 🎲 Delivery System Modes

### Random Delivery Mode

```lua
Config.RandomDelivery = true -- Random destination assignment
```

**How It Works**:
- `true`: System randomly selects destination from available routes
- `false`: Player chooses specific destination from menu

**Benefits of Random Mode**:
- Prevents players from always picking highest-paying routes
- Creates economy balance
- Adds variety and unpredictability
- Reduces exploitation

### Hide Destination Information

```lua
Config.RandomDelivery_HideDestinationText = true -- Hide destination name in UI
```

**Mystery Mode**:
- `true`: Destination name hidden ("Mystery Destination")
- `false`: Destination shown ("Deliver to Blackwater")

### Hide Reward Preview

```lua
Config.RandomDelivery_HideRewardPreview = true -- Hide reward amount before completion
```

**Surprise Rewards**:
- `true`: Payment unknown until delivery complete
- `false`: Reward amount shown before accepting

### Combined Random Mode Example

```lua
-- Full mystery mode (recommended for immersive servers)
Config.RandomDelivery = true
Config.RandomDelivery_HideDestinationText = true
Config.RandomDelivery_HideRewardPreview = true
Config.Show_Reward_Money_inMenu = false

-- Transparent mode (player knows everything)
Config.RandomDelivery = false
Config.RandomDelivery_HideDestinationText = false
Config.RandomDelivery_HideRewardPreview = false
Config.Show_Reward_Money_inMenu = true
```

---

## 🛡️ Security & Anti-Exploit

### Anti-Spam Configuration

```lua
Config.AntiSpam = {
    -- Menu spam protection
    maxMenuOpens = 3,         -- Max menu opens within detection window
    detectionWindow = 10,      -- Time window (seconds) for spam detection
    cooldownDuration = 60,     -- Cooldown (seconds) after spam detected
    
    -- Delivery rate limiting
    serverRateLimit = 5,       -- Minimum seconds between delivery starts
    
    -- Exploit prevention
    minDeliveryDuration = 10,  -- Minimum seconds to complete delivery
}
```

**Configuration Guide**:

#### Menu Spam Protection
- **maxMenuOpens**: Players can open menu this many times...
- **detectionWindow**: ...within this time window before triggering cooldown
- **cooldownDuration**: Penalty duration when spam detected

**Example**: 3 opens within 10 seconds = 60-second cooldown

**Recommendations**:
- **Strict**: `maxMenuOpens = 2`, `detectionWindow = 15`, `cooldownDuration = 120`
- **Standard**: `maxMenuOpens = 3`, `detectionWindow = 10`, `cooldownDuration = 60`
- **Relaxed**: `maxMenuOpens = 5`, `detectionWindow = 20`, `cooldownDuration = 30`

#### Delivery Rate Limiting
- **serverRateLimit**: Minimum seconds between starting deliveries
- Prevents rapid-fire delivery exploits

**Recommendations**:
- **Fast-paced servers**: 3 seconds
- **Standard**: 5 seconds
- **Realistic RP**: 10 seconds

#### Minimum Duration Check
- **minDeliveryDuration**: Minimum time to complete valid delivery
- Prevents teleport/instant completion exploits

**How to Calculate**:
1. Test fastest legitimate delivery in-game
2. Set minimum to 50-70% of that time
3. Examples:
   - Fastest route takes 30 seconds → set 15-20 seconds
   - Fastest route takes 120 seconds → set 60-80 seconds

### Additional Security Settings

```lua
Config.Security = {
    -- Server-side validation
    validateLocations = true,      -- Verify locations match configured routes
    
    -- Completion requirements
    maxDeliveryDistance = 10.0,    -- Max distance from wagon to complete (units)
    requireOnFoot = false,         -- Require player on foot (not in vehicle)
    
    -- Logging
    logSuspiciousActivity = true,  -- Log exploit attempts to console
}
```

**validateLocations**:
- `true`: Server validates all coordinates against config (prevents fake deliveries)
- `false`: Trust client data (NOT RECOMMENDED - security risk)

**maxDeliveryDistance**:
- Distance player must be from wagon to complete delivery
- Prevents "abandon wagon and teleport" exploits
- Recommended: 10.0 for realism, 50.0 for convenience

**requireOnFoot**:
- `true`: Player must be on foot near wagon (realistic)
- `false`: Player can be in vehicle (convenient)

**logSuspiciousActivity**:
- Logs to server console when validation fails
- Useful for identifying cheaters/exploiters

---

## 🚀 Performance Settings

```lua
Config.Performance = {
    -- Distance check optimization
    distanceCheckInterval = 500,    -- Milliseconds between distance checks
    
    -- Player data caching
    cachePlayerData = true,         -- Cache framework calls
    cacheDuration = 60,             -- Cache lifetime (seconds)
    
    -- Server-wide limits
    maxActiveDeliveries = 0,        -- Max simultaneous deliveries (0 = unlimited)
}
```

### Distance Check Interval

**Impact**: Frequency of "are we at destination?" checks

| Value | Performance | Responsiveness | Recommended For |
|-------|------------|----------------|-----------------|
| 250ms | Lower FPS | Very responsive | High-end servers |
| 500ms | Balanced | Good | Standard servers (default) |
| 1000ms | Higher FPS | Acceptable | Low-end servers |
| 2000ms | Best FPS | Sluggish | Last resort |

### Player Data Caching

**Purpose**: Reduces framework API calls for better performance

- **cachePlayerData**: Enable/disable caching
- **cacheDuration**: How long to cache player data before refreshing

**Recommendations**:
- Enable for servers with 30+ players
- Increase duration for higher player counts
- Disable if player data changes frequently (e.g., fast-paced job systems)

### Max Active Deliveries

**Purpose**: Limit simultaneous deliveries server-wide

- `0`: Unlimited (default, recommended for most servers)
- `10`: Only 10 players can have active deliveries at once
- `50`: Limit for high-population servers

**When to Use**:
- Prevent entity overload on low-end servers
- Limit economic impact (restrict money flow)
- Manage resource usage

---

## 🔔 Notification System

The system uses BLN_NOTIFY for notifications. Customize these functions to use your preferred notification system.

### Client-Side Notifications

```lua
Config.Notify_Client = function(title, text, notitype, duration)
    TriggerEvent('bln_notify:send', {
        title = title or '',
        description = text or '',
        duration = duration or 3500,
        placement = 'top-right',
        type = notitype or 'info',
    }, _blnTemplateFromType(notitype))
end
```

### Server-Side Notifications

```lua
Config.Notify_Server = function(id, title, text, notitype, duration)
    TriggerClientEvent('bln_notify:send', id, {
        title = title or '',
        description = text or '',
        duration = duration or 3500,
        placement = 'top-right',
        type = notitype or 'info',
    }, _blnTemplateFromType(notitype))
end
```

### Customization for Other Systems

#### OX Lib Notifications
```lua
Config.Notify_Client = function(title, text, notitype, duration)
    lib.notify({
        title = title,
        description = text,
        type = notitype,
        duration = duration
    })
end
```

#### RSG-Core / LXR-Core Notifications
```lua
Config.Notify_Client = function(title, text, notitype, duration)
    Framework.Object.Functions.Notify(text, notitype, duration)
end
```

#### VORP Notifications
```lua
Config.Notify_Client = function(title, text, notitype, duration)
    TriggerEvent("vorp:TipRight", text, duration)
end
```

---

## 📍 Delivery Locations

Delivery locations are defined in `Config.Deliveries` array. Each location is a delivery hub with multiple routes.

### Location Structure

```lua
Config.Deliveries = {
    {
        -- Hub identification
        label = "Valentine Deliveries",              -- Hub display name
        
        -- NPC configuration
        npcmodel = "MP_U_M_M_TRADER_01",           -- Ped model hash
        npccoords = vector4(-340.58, 816.31, 116.93, 136.78), -- x, y, z, heading
        
        -- Wagon spawn point
        cartSpawn = vector4(-347.99, 815.53, 116.72, 168.63), -- x, y, z, heading
        
        -- Available routes from this hub
        deliveries = {
            -- Individual routes (see Reward Configuration below)
        }
    },
    -- Add more hubs here...
}
```

### Adding New Hub Location

1. **Find Coordinates**: Use in-game tools to get coordinates
2. **Choose NPC Model**: Select from RedM ped models
3. **Position Wagon Spawn**: Clear area near NPC (10-20 units away)
4. **Add to Config**:

```lua
{
    label = "Blackwater Deliveries",
    npcmodel = "U_M_M_UNIDUSTERJAIL_01",
    npccoords = vector4(-813.23, -1324.56, 43.63, 90.0),
    cartSpawn = vector4(-820.45, -1320.12, 43.50, 85.0),
    deliveries = {
        -- Add routes here
    }
},
```

---

## 💎 Reward Configuration

Each delivery route in a hub's `deliveries` array has a reward configuration.

### Complete Route Example

```lua
{
    -- Route identification
    label = "Blackwater Delivery",                -- Route name
    description = "From Valentine to Blackwater", -- Route description
    
    -- Wagon configuration
    wagonModel = "cart01",                        -- Wagon model hash
    cargo = "pg_teamster_cart01_breakables",      -- Cargo prop
    light = "pg_teamster_cart01_lightupgrade3",   -- Light prop
    
    -- Destination
    deliveryLoc = vector3(-750.20, -1206.24, 43.33), -- x, y, z
    
    -- Reward system (see below)
    reward = {
        -- Choose ONE price method
        priceByDistance = { ... },
        priceByConfig = { ... },
        
        -- Optional item reward
        itemreward = { ... },
    },
},
```

### Reward Methods

#### Method 1: Distance-Based Rewards (Recommended)

```lua
reward = {
    priceByDistance = {
        activation = true,    -- Enable distance-based payment
        multiplier = 0.05,    -- $ per 100 units of distance
    },
    priceByConfig = {
        activation = false,   -- Disable fixed price
        price = 0,
    },
}
```

**How It Works**:
- System calculates distance from cart spawn to delivery location
- Payment = (distance / 100) × multiplier

**Example Calculations**:
- Distance: 1000 units, Multiplier: 0.05 → $50.00
- Distance: 2500 units, Multiplier: 0.10 → $250.00
- Distance: 500 units, Multiplier: 0.02 → $10.00

**Recommended Multipliers**:
- **Economy-focused**: 0.01 - 0.03 (low rewards)
- **Balanced**: 0.05 - 0.10 (default)
- **Generous**: 0.15 - 0.25 (high rewards)

#### Method 2: Fixed Price Rewards

```lua
reward = {
    priceByDistance = {
        activation = false,   -- Disable distance-based
        multiplier = 0,
    },
    priceByConfig = {
        activation = true,    -- Enable fixed price
        price = 75.0,         -- Flat payment amount
    },
}
```

**When to Use**:
- Consistent reward amounts
- Simplified economy balancing
- Special premium routes

#### Method 3: Item Rewards

```lua
reward = {
    priceByDistance = {
        activation = true,
        multiplier = 0.0,     -- 0.0 = no money reward
    },
    priceByConfig = {
        activation = false,
    },
    itemreward = {
        activation = true,              -- Enable item rewards
        itemname = "dollar",            -- Item to give
        itemamount = math.random(7, 11), -- Random amount (7-11)
        chance = nil,                   -- nil = always, number = % chance
    },
}
```

**Item Reward Options**:

**Fixed Amount**:
```lua
itemamount = 10, -- Always 10 items
```

**Random Amount**:
```lua
itemamount = math.random(5, 15), -- 5-15 items (random)
```

**Chance-Based**:
```lua
chance = 50, -- 50% chance to receive items
```

**Common Items**:
- `"dollar"`: Currency item
- `"goldbar"`: Valuable item
- `"provisions"`: Supply item
- Custom items from your server

#### Method 4: Hybrid (Money + Items)

```lua
reward = {
    priceByDistance = {
        activation = true,
        multiplier = 0.03,    -- Base money reward
    },
    priceByConfig = {
        activation = false,
    },
    itemreward = {
        activation = true,
        itemname = "goldbar",
        itemamount = 1,
        chance = 25,          -- 25% bonus item chance
    },
}
```

**Use Cases**:
- Premium routes (money + rare item chance)
- Progression systems (guaranteed pay + random bonus)
- Event deliveries (special rewards)

---

## 🎯 Example Configurations

### Economy Server (Low Rewards)

```lua
Config.RandomDelivery = true
Config.Reward_Money_Account = "cash"

-- In route reward
reward = {
    priceByDistance = {
        activation = true,
        multiplier = 0.02, -- Low multiplier
    },
    priceByConfig = { activation = false, price = 0 },
}
```

### Balanced Server (Default)

```lua
Config.RandomDelivery = true
Config.RandomDelivery_HideRewardPreview = true

-- In route reward
reward = {
    priceByDistance = {
        activation = true,
        multiplier = 0.05,
    },
    priceByConfig = { activation = false, price = 0 },
    itemreward = {
        activation = true,
        itemname = "dollar",
        itemamount = math.random(7, 11),
    },
}
```

### Generous Server (High Rewards)

```lua
Config.Show_Reward_Money_inMenu = true
Config.RandomDelivery = false -- Player choice

-- In route reward
reward = {
    priceByConfig = {
        activation = true,
        price = 150.0, -- High fixed price
    },
    priceByDistance = { activation = false, multiplier = 0 },
}
```

---

## 📚 Next Steps

- Read **security.md** for detailed anti-exploit configuration
- Check **performance.md** for optimization tips
- Review **frameworks.md** for framework-specific features

---

*Configuration Guide v2.1.0 | Built with ❤️ by The Land of Wolves 🐺*
