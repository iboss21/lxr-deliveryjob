```
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 SYSTEM OVERVIEW - Delivery Job System
═══════════════════════════════════════════════════════════════════════════════
```

## 📜 Introduction

**LXR Delivery Job System** is a comprehensive, production-ready wagon/cart delivery job resource for RedM servers. Designed and developed by **The Land of Wolves** (iBoss21 / The Lux Empire), this system provides an immersive frontier economy experience where players transport goods across the map using period-accurate wagons.

### 🌟 Key Highlights

- **Multi-Framework Support**: Works seamlessly with LXR-Core, RSG-Core, and VORP Core
- **Anti-Exploit Architecture**: Server-side validation, rate limiting, and spam prevention
- **Random Assignments**: Prevents route cherry-picking for balanced economy
- **Flexible Rewards**: Distance-based payments, fixed prices, or item rewards
- **Performance Optimized**: 60+ FPS target with minimal resource usage
- **Production Tested**: Battle-tested on The Land of Wolves server

---

## 🎯 Core Features

### 🚛 Delivery System
- **Interactive NPCs**: Players interact with delivery NPCs at designated hubs
- **Dynamic Wagon Spawning**: Spawns wagons with attached cargo and lighting props
- **GPS Routing**: Automatic waypoint creation for delivery destinations
- **Completion Detection**: Validates player proximity to destination with wagon

### 💰 Economy Integration
- **Distance-Based Rewards**: Pay scales with delivery distance
- **Fixed Price Option**: Set specific amounts per route
- **Item Rewards**: Give items instead of or alongside money
- **Configurable Accounts**: Cash, bank, or gold payments (framework-dependent)

### 🛡️ Security & Anti-Exploit
- **Server-Side Validation**: All rewards and progress validated on server
- **Session Tracking**: One active delivery per player maximum
- **Rate Limiting**: Prevents spam and rapid-fire exploits
- **Location Validation**: Ensures deliveries match configured routes
- **Minimum Duration Check**: Prevents instant completion exploits

### 🎨 User Experience
- **Random Delivery Mode**: Auto-assigns destinations for variety
- **Mystery Destinations**: Optional hidden destination names/rewards
- **Cooldown System**: Prevents delivery spam with configurable timers
- **Cancellation Support**: Players can cancel active deliveries via command

---

## 🏗️ System Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT-SIDE LAYER                        │
├─────────────────────────────────────────────────────────────┤
│  • client/client.lua      → Main delivery flow logic        │
│  • client/interaction.lua → NPC interaction system          │
│  • client/npcs.lua        → NPC spawning & management       │
│  • UI/Menu Integration    → OX Lib / murphy_interact        │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                   FRAMEWORK ADAPTER                         │
├─────────────────────────────────────────────────────────────┤
│  • shared/framework.lua   → Multi-framework bridge          │
│  • Auto-Detection         → LXR → RSG → VORP priority       │
│  • Unified API            → GetPlayer, AddMoney, etc.       │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                    SERVER-SIDE LAYER                        │
├─────────────────────────────────────────────────────────────┤
│  • server/server.lua      → Validation & reward logic       │
│  • Session Management     → Track active deliveries         │
│  • Anti-Exploit Checks    → Rate limits, spam detection     │
│  • Reward Distribution    → Money & item dispensing         │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      CONFIGURATION                          │
├─────────────────────────────────────────────────────────────┤
│  • shared/config.lua      → All settings & delivery routes  │
│  • 73.5 KB Configuration  → Extensive customization         │
│  • Delivery Locations     → Multiple hubs & routes          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎮 How It Works

### Player Experience Flow

1. **Interaction**: Player approaches delivery NPC at hub (e.g., Valentine)
2. **Assignment**: System selects delivery destination (random or player choice)
3. **Wagon Spawn**: Cart/wagon spawns with cargo at designated spawn point
4. **GPS Routing**: Waypoint appears on map showing delivery location
5. **Transport**: Player drives wagon to destination
6. **Completion**: Upon arrival, system validates and distributes rewards
7. **Cleanup**: Wagon despawns, blip removed, session cleared

### Behind the Scenes

#### Client-Side
```lua
-- Delivery state tracking
isDeliveryStarted = false
wagonSpawned = false
endcoords = nil
deliveryBlip = nil

-- Wagon spawning with GPS
spawn_cart_with_gps_mission(locationData, routeData)
  ↓ Request & spawn wagon model
  ↓ Attach cargo/lighting props
  ↓ Create destination blip
  ↓ Enable GPS waypoint
```

#### Server-Side
```lua
-- Session tracking (anti-exploit)
Sessions[playerId] = {
  startTime = timestamp,
  route = routeConfig,
  completed = false
}

-- Validation on completion
ValidateLocation() → ValidateDuration() → DistributeRewards()
```

---

## 🔑 Key Components

### 1. Framework Adapter (`shared/framework.lua`)

**Purpose**: Provides unified API across LXR-Core, RSG-Core, and VORP Core.

**Capabilities**:
- Automatic framework detection (priority order: LXR → RSG → VORP)
- Unified player data access
- Cross-framework money management
- Inventory operations (add/remove items)
- Notification system abstraction

**Example**:
```lua
-- Works on any supported framework
Framework.AddMoney(source, 50, "cash", "Delivery Reward")
Framework.Notify(source, "Success", "Delivery completed!", "success", 3500)
```

### 2. Configuration System (`shared/config.lua`)

**Size**: 73.5 KB / 1604 lines  
**Purpose**: Centralized configuration for all system aspects.

**Key Sections**:
- Framework settings (resource names, events, callbacks)
- Delivery locations (NPCs, spawn points, routes)
- Reward systems (distance-based, fixed, item rewards)
- Security settings (rate limits, validation, cooldowns)
- Performance tuning (tick intervals, cache settings)

### 3. Client Scripts

**`client/client.lua`** (Main Logic)
- Delivery state management
- Wagon spawning and GPS routing
- Distance checking for completion
- Menu system integration
- Server communication

**`client/interaction.lua`** (NPC Interaction)
- murphy_interact or native prompt integration
- Menu opening triggers
- Interaction range detection

**`client/npcs.lua`** (NPC Management)
- NPC spawning within player range
- Fade-in effects
- NPC cleanup on player disconnect

### 4. Server Script (`server/server.lua`)

**Core Responsibilities**:
- **Session Management**: Tracks active deliveries per player
- **Route Validation**: Ensures client requests match configured routes
- **Reward Calculation**: Determines payment based on distance/config
- **Anti-Exploit**: Rate limiting, minimum duration checks
- **Framework Integration**: Distributes rewards via framework APIs

**Security Measures**:
```lua
-- One delivery per player
if Sessions[source] then
  return -- Already has active delivery
end

-- Rate limiting
if lastAttempt + rateLimit > currentTime then
  return -- Too soon, prevent spam
end

-- Duration validation
if completionTime - startTime < minDuration then
  return -- Suspiciously fast, likely exploit
end
```

---

## 📊 Technical Specifications

### Resource Information
- **Name**: lxr-deliveryjob (MUST use exact name)
- **Version**: 2.1.0
- **FX Version**: cerulean
- **Game**: RedM (rdr3)
- **Lua Version**: 5.4
- **Dependencies**: OneSync (required), ox_lib (optional)

### Performance Metrics
- **Target FPS**: 60+ (optimized for RedM)
- **Tick Usage**: Minimal (event-driven architecture)
- **Distance Checks**: 500ms intervals (configurable)
- **Resource Usage**: Low (< 0.01ms typical)

### File Structure
```
lxr-deliveryjob/
├── fxmanifest.lua           # Resource manifest
├── shared/
│   ├── config.lua           # Main configuration (73.5 KB)
│   └── framework.lua        # Framework adapter layer
├── client/
│   ├── client.lua           # Main client logic
│   ├── interaction.lua      # NPC interaction system
│   └── npcs.lua             # NPC spawning & management
├── server/
│   └── server.lua           # Server validation & rewards
├── docs/
│   ├── overview.md          # This file
│   ├── installation.md      # Setup guide
│   ├── configuration.md     # Config documentation
│   ├── frameworks.md        # Framework support details
│   ├── events.md            # Event reference
│   ├── security.md          # Security features
│   ├── performance.md       # Optimization guide
│   └── screenshots.md       # Media requirements
└── README.md                # Quick reference
```

---

## 🌍 Server Information

### The Land of Wolves 🐺

**Developer**: iBoss21 / The Lux Empire  
**Server Type**: Serious Hardcore Roleplay  
**Community**: Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!  
**Tagline**: ისტორია ცოცხლდება აქ! (History Lives Here!)

**Links**:
- 🌐 Website: [www.wolves.land](https://www.wolves.land)
- 💬 Discord: [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)
- 🛒 Store: [theluxempire.tebex.io](https://theluxempire.tebex.io)
- 🔗 GitHub: [github.com/iBoss21](https://github.com/iBoss21)
- 📋 Server Listing: [servers.redm.net](https://servers.redm.net/servers/detail/8gj7eb)

---

## 📖 Credits & Attribution

### Original Creators
- **RexShack**: Original rsg-delivery system creator
- **Muhammad Abdullah Shurjeel**: Base concept & stx-wagondeliveries logic
- **iBoss21** (The Lux Empire): Framework adaptation, enhancement, and Land of Wolves branding

### Framework Support
- **LXR-Core**: The Land of Wolves custom framework (primary)
- **RSG-Core**: RedM Script Group core framework (co-primary)
- **VORP Core**: Vintage Outlaw Roleplay framework (supported)

---

## 📚 Documentation Map

| Document | Description |
|----------|-------------|
| **overview.md** (this file) | System overview, architecture, and key features |
| **installation.md** | Step-by-step setup guide and dependencies |
| **configuration.md** | Detailed configuration options reference |
| **frameworks.md** | Multi-framework support and adapter system |
| **events.md** | Client/server events and API reference |
| **security.md** | Anti-exploit features and best practices |
| **performance.md** | Optimization guide and resource usage |
| **screenshots.md** | Media requirements and screenshot list |

---

## ⚖️ License

```
Copyright (c) 2024-2026 The Lux Empire / iBoss21
Licensed under: MIT License
wolves.land
```

---

## 🚀 Next Steps

1. Read **installation.md** for setup instructions
2. Review **configuration.md** to customize delivery routes
3. Check **frameworks.md** for your specific framework setup
4. Explore **security.md** for anti-exploit configuration

---

*Built with ❤️ by The Land of Wolves 🐺*  
*Version 2.1.0 | Last Updated: 2024*
