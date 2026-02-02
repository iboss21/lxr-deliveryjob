```
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 SECURITY & ANTI-EXPLOIT - Delivery Job System
═══════════════════════════════════════════════════════════════════════════════
```

## 📋 Table of Contents

1. [Security Philosophy](#security-philosophy)
2. [Anti-Exploit Features](#anti-exploit-features)
3. [Server-Side Validation](#server-side-validation)
4. [Rate Limiting](#rate-limiting)
5. [Session Management](#session-management)
6. [Configuration Guide](#configuration-guide)
7. [Common Exploits & Prevention](#common-exploits--prevention)
8. [Best Practices](#best-practices)
9. [Monitoring & Logging](#monitoring--logging)

---

## 🛡️ Security Philosophy

The LXR Delivery Job System follows **"Never Trust the Client"** security principles:

### Core Principles

1. **Server Authority**: All critical decisions made server-side
2. **Zero Trust Client**: Client requests are always validated
3. **Session Tracking**: Single source of truth on server
4. **Validation Layers**: Multiple validation checkpoints
5. **Rate Limiting**: Prevent spam and rapid-fire exploits

### Security Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    CLIENT SIDE                           │
│  • UI/UX only                                           │
│  • Cannot manipulate rewards                            │
│  • Cannot fake locations                                │
│  • Sends REQUESTS only                                  │
└───────────────────┬──────────────────────────────────────┘
                    │ (Untrusted Requests)
                    ↓
┌──────────────────────────────────────────────────────────┐
│                 VALIDATION LAYER                         │
│  ✓ Rate limit check                                     │
│  ✓ Active session check                                 │
│  ✓ Location validation                                  │
│  ✓ Duration validation                                  │
│  ✓ Reward calculation (server-side)                     │
└───────────────────┬──────────────────────────────────────┘
                    │ (Validated Data)
                    ↓
┌──────────────────────────────────────────────────────────┐
│                 SERVER AUTHORITY                         │
│  • Maintains session state                              │
│  • Calculates rewards                                   │
│  • Distributes money/items                              │
│  • Logs suspicious activity                             │
└──────────────────────────────────────────────────────────┘
```

---

## 🔒 Anti-Exploit Features

### 1. Single Active Delivery Enforcement

**Problem**: Players starting multiple deliveries to exploit rewards  
**Solution**: Server-side session tracking

```lua
-- server/server.lua
local Sessions = {}

RegisterNetEvent('lxr-delivery:server:StartDelivery', function(payload)
    local source = source
    
    -- Check for existing active delivery
    if Sessions[source] then
        Framework.Notify(source, "Error", "You already have an active delivery!", "error", 3500)
        return
    end
    
    -- Create new session
    Sessions[source] = {
        startTime = GetGameTimer(),
        route = payload.routeData,
        location = payload.locationData
    }
end)
```

**Result**: Only ONE delivery per player at any time

---

### 2. Menu Spam Protection

**Problem**: Players spam-opening menu to cause lag or find exploits  
**Solution**: Client-side tracking with server-side cooldown

```lua
-- Configuration
Config.AntiSpam = {
    maxMenuOpens = 3,         -- Max opens within window
    detectionWindow = 10,      -- Time window (seconds)
    cooldownDuration = 60,     -- Cooldown after spam (seconds)
}
```

**How It Works**:
1. Client tracks menu open attempts in time window
2. If exceeds `maxMenuOpens` within `detectionWindow`, trigger cooldown
3. Player cannot interact for `cooldownDuration` seconds

**Example**:
- Player opens menu 3 times within 10 seconds
- System detects spam behavior
- 60-second cooldown applied
- Notification: "Stop spamming! Wait 60 seconds."

---

### 3. Rate Limiting

**Problem**: Players rapidly starting/completing deliveries  
**Solution**: Server-side rate limit enforcement

```lua
-- Configuration
Config.AntiSpam.serverRateLimit = 5 -- Minimum seconds between starts
```

```lua
-- server/server.lua
local LastDeliveryAttempt = {}

RegisterNetEvent('lxr-delivery:server:StartDelivery', function(payload)
    local source = source
    local currentTime = GetGameTimer() / 1000
    
    -- Check rate limit
    if LastDeliveryAttempt[source] then
        local timeSinceLast = currentTime - LastDeliveryAttempt[source]
        if timeSinceLast < Config.AntiSpam.serverRateLimit then
            Framework.Notify(source, "Slow Down", "Wait before starting another delivery!", "warning", 3500)
            return
        end
    end
    
    LastDeliveryAttempt[source] = currentTime
    -- Continue with delivery start...
end)
```

**Result**: Prevents rapid-fire delivery starts

---

### 4. Minimum Duration Check

**Problem**: Players teleporting to destination for instant completion  
**Solution**: Server validates delivery took reasonable time

```lua
-- Configuration
Config.AntiSpam.minDeliveryDuration = 10 -- Minimum seconds
```

```lua
-- server/server.lua
RegisterNetEvent('lxr-delivery:server:CompleteDelivery', function(payload)
    local source = source
    local session = Sessions[source]
    
    if not session then return end
    
    -- Calculate delivery duration
    local duration = (GetGameTimer() - session.startTime) / 1000
    
    -- Check minimum duration
    if duration < Config.AntiSpam.minDeliveryDuration then
        -- Suspicious: Too fast
        if Config.Security.logSuspiciousActivity then
            print(string.format("^1[EXPLOIT] Player %s completed delivery in %s seconds (min: %s)^0",
                GetPlayerName(source), duration, Config.AntiSpam.minDeliveryDuration))
        end
        
        Framework.Notify(source, "Error", "Invalid delivery completion", "error", 3500)
        Sessions[source] = nil
        return
    end
    
    -- Valid completion, continue...
end)
```

**Configuration Tips**:
- Test fastest legitimate delivery time
- Set minimum to 50-70% of that time
- Example: Fastest route = 30 seconds → Set minimum = 15-20 seconds

---

### 5. Location Validation

**Problem**: Client sends fake coordinates for higher rewards  
**Solution**: Server validates locations against config

```lua
-- Configuration
Config.Security.validateLocations = true
```

```lua
-- server/server.lua
local function findConfiguredRoute(payload)
    -- Check payload has required fields
    if not payload or not payload.npc or not payload.cartSpawn 
       or not payload.deliveryLoc or not payload.wagonModel then
        return nil, nil
    end
    
    -- Search config for matching location
    for _, loc in pairs(Config.Deliveries or {}) do
        -- Validate NPC and cart spawn match (within tolerance)
        if closeEnough(loc.npccoords, payload.npc, 1.0) 
           and closeEnough(loc.cartSpawn, payload.cartSpawn, 1.0) then
            
            -- Validate route exists in this location
            for _, route in pairs(loc.deliveries or {}) do
                if route.wagonModel == payload.wagonModel 
                   and closeEnough(route.deliveryLoc, payload.deliveryLoc, 1.0) then
                    return loc, route -- Valid route found
                end
            end
        end
    end
    
    return nil, nil -- Invalid: Not in config
end
```

**Result**: Prevents fabricated deliveries with inflated rewards

---

### 6. Reward Calculation (Server-Side)

**Problem**: Client manipulates reward amounts  
**Solution**: Server calculates all rewards

```lua
-- server/server.lua
local function calculateReward(loc, route)
    if not loc or not route or not route.reward then 
        return nil 
    end
    
    -- Distance-based calculation (server-controlled)
    if route.reward.priceByDistance and route.reward.priceByDistance.activation then
        local cartvec = v3(loc.cartSpawn.x, loc.cartSpawn.y, loc.cartSpawn.z)
        local endvec = v3(route.deliveryLoc.x, route.deliveryLoc.y, route.deliveryLoc.z)
        local distance = #(cartvec - endvec)
        return ((math.floor(distance) / 100) * route.reward.priceByDistance.multiplier)
    
    -- Fixed price (server-controlled)
    elseif route.reward.priceByConfig and route.reward.priceByConfig.activation then
        return route.reward.priceByConfig.price
    end
    
    return nil
end
```

**Result**: Client cannot manipulate payment amounts

---

## ✅ Server-Side Validation

### Validation Layers

All delivery operations go through multiple validation checks:

#### Layer 1: Request Validation
```lua
-- Validate request structure
if not payload or type(payload) ~= "table" then
    return -- Invalid request format
end

-- Validate required fields exist
if not payload.npc or not payload.deliveryLoc then
    return -- Missing required data
end
```

#### Layer 2: Session Validation
```lua
-- Check for existing session (start)
if Sessions[source] then
    Framework.Notify(source, "Error", "Already have active delivery", "error", 3500)
    return
end

-- Check session exists (complete/cancel)
if not Sessions[source] then
    Framework.Notify(source, "Error", "No active delivery", "error", 3500)
    return
end
```

#### Layer 3: Configuration Validation
```lua
-- Validate against server config
local loc, route = findConfiguredRoute(payload)
if not loc or not route then
    if Config.Security.logSuspiciousActivity then
        print(string.format("^1[EXPLOIT] Player %s sent invalid route data^0", GetPlayerName(source)))
    end
    return
end
```

#### Layer 4: Timing Validation
```lua
-- Check rate limits
local timeSinceLast = currentTime - (LastDeliveryAttempt[source] or 0)
if timeSinceLast < Config.AntiSpam.serverRateLimit then
    return -- Too soon
end

-- Check minimum duration
local duration = (GetGameTimer() - session.startTime) / 1000
if duration < Config.AntiSpam.minDeliveryDuration then
    return -- Suspiciously fast
end
```

#### Layer 5: Reward Validation
```lua
-- Validate reward is valid
local reward = calculateReward(loc, route)
if not reward or reward <= 0 then
    return -- Invalid reward
end

-- Check player can receive reward
local Player = Framework.GetPlayer(source)
if not Player then
    return -- Player not found
end
```

---

## ⏱️ Rate Limiting

### Purpose

Rate limiting prevents:
- Spam attacks on server
- Rapid-fire delivery exploits
- Resource exhaustion
- Menu spam

### Configuration

```lua
Config.AntiSpam = {
    -- Client-side menu spam
    maxMenuOpens = 3,          -- Attempts before cooldown
    detectionWindow = 10,       -- Time window (seconds)
    cooldownDuration = 60,      -- Cooldown duration (seconds)
    
    -- Server-side rate limiting
    serverRateLimit = 5,        -- Min seconds between starts
    minDeliveryDuration = 10,   -- Min delivery duration
}
```

### Rate Limit Strategies

#### Strategy 1: Fixed Window
```lua
-- Current implementation
if timeSinceLast < serverRateLimit then
    return -- Reject
end
```

**Pros**: Simple, effective  
**Cons**: Can be gamed at window boundaries

#### Strategy 2: Sliding Window (Advanced)
```lua
-- Track all attempts in last N seconds
local function checkSlidingWindow(source, windowSize, maxAttempts)
    local attempts = DeliveryAttempts[source] or {}
    local currentTime = GetGameTimer() / 1000
    
    -- Remove old attempts
    for i = #attempts, 1, -1 do
        if currentTime - attempts[i] > windowSize then
            table.remove(attempts, i)
        end
    end
    
    -- Check if over limit
    if #attempts >= maxAttempts then
        return false -- Too many attempts
    end
    
    table.insert(attempts, currentTime)
    DeliveryAttempts[source] = attempts
    return true
end
```

**Pros**: More accurate, harder to exploit  
**Cons**: More complex

---

## 📊 Session Management

### Session Structure

```lua
Sessions[playerId] = {
    startTime = GetGameTimer(),     -- When delivery started
    route = {                        -- Route configuration
        label = "Blackwater Delivery",
        wagonModel = "cart01",
        deliveryLoc = vector3(...),
        reward = {...}
    },
    location = {                     -- Location configuration
        label = "Valentine Deliveries",
        npccoords = vector4(...),
        cartSpawn = vector4(...)
    }
}
```

### Session Lifecycle

```
┌─────────────┐
│   START     │ ← Player initiates delivery
└──────┬──────┘
       │
       ↓
┌─────────────────────────────────────┐
│  SESSION CREATED                    │
│  Sessions[playerId] = { ... }       │
│  - Start time recorded              │
│  - Route data stored                │
│  - Location data stored             │
└──────┬──────────────────────────────┘
       │
       ↓
┌─────────────────────────────────────┐
│  ACTIVE DELIVERY                    │
│  - Player has wagon                 │
│  - Session exists on server         │
│  - Client tracking progress         │
└──────┬──────────────────────────────┘
       │
       ├─────────────┬─────────────┐
       ↓             ↓             ↓
┌─────────────┐ ┌──────────┐ ┌─────────────┐
│  COMPLETE   │ │  CANCEL  │ │  TIMEOUT    │
└──────┬──────┘ └────┬─────┘ └──────┬──────┘
       │             │              │
       ↓             ↓              ↓
┌─────────────────────────────────────┐
│  SESSION CLEARED                    │
│  Sessions[playerId] = nil           │
│  - Rewards given (if completed)     │
│  - Cooldown applied (if canceled)   │
│  - Client cleanup triggered         │
└─────────────────────────────────────┘
```

### Session Cleanup

**On Completion**:
```lua
-- Distribute rewards
Framework.AddMoney(source, reward, account, "Delivery Reward")

-- Clear session
Sessions[source] = nil
```

**On Cancellation**:
```lua
-- Apply cooldown
LastDeliveryAttempt[source] = GetGameTimer() / 1000 + Config.Cooldowns.deliveryCancel

-- Clear session
Sessions[source] = nil
```

**On Player Disconnect**:
```lua
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Clear any active session
    if Sessions[source] then
        Sessions[source] = nil
    end
    
    -- Clear rate limit tracking
    if LastDeliveryAttempt[source] then
        LastDeliveryAttempt[source] = nil
    end
end)
```

---

## ⚙️ Configuration Guide

### Recommended Settings by Server Type

#### High-Security Server (Strict RP)
```lua
Config.AntiSpam = {
    maxMenuOpens = 2,
    detectionWindow = 15,
    cooldownDuration = 120,
    serverRateLimit = 10,
    minDeliveryDuration = 30,
}

Config.Security = {
    validateLocations = true,
    maxDeliveryDistance = 10.0,
    requireOnFoot = true,
    logSuspiciousActivity = true,
}
```

#### Balanced Server (Standard)
```lua
Config.AntiSpam = {
    maxMenuOpens = 3,
    detectionWindow = 10,
    cooldownDuration = 60,
    serverRateLimit = 5,
    minDeliveryDuration = 10,
}

Config.Security = {
    validateLocations = true,
    maxDeliveryDistance = 10.0,
    requireOnFoot = false,
    logSuspiciousActivity = true,
}
```

#### Casual Server (Relaxed)
```lua
Config.AntiSpam = {
    maxMenuOpens = 5,
    detectionWindow = 20,
    cooldownDuration = 30,
    serverRateLimit = 3,
    minDeliveryDuration = 5,
}

Config.Security = {
    validateLocations = true,
    maxDeliveryDistance = 25.0,
    requireOnFoot = false,
    logSuspiciousActivity = false,
}
```

---

## 🚨 Common Exploits & Prevention

### Exploit 1: Teleport Completion

**Method**: Player uses teleport menu to instantly arrive at destination

**Prevention**:
```lua
Config.AntiSpam.minDeliveryDuration = 10 -- Adjust based on map size
```

**Detection**:
```lua
if duration < Config.AntiSpam.minDeliveryDuration then
    print("^1[EXPLOIT] Instant completion detected^0")
    -- Deny reward, log player
end
```

---

### Exploit 2: Duplicate Delivery

**Method**: Player starts multiple deliveries simultaneously

**Prevention**:
```lua
if Sessions[source] then
    return -- Already has active delivery
end
```

**Result**: Only one delivery allowed at a time

---

### Exploit 3: Menu Spam Lag

**Method**: Player rapidly opens/closes menu to cause server lag

**Prevention**:
```lua
Config.AntiSpam.maxMenuOpens = 3
Config.AntiSpam.detectionWindow = 10
Config.AntiSpam.cooldownDuration = 60
```

**Result**: Automatic cooldown after spam detected

---

### Exploit 4: Fake Location Data

**Method**: Player sends modified coordinates for higher rewards

**Prevention**:
```lua
local loc, route = findConfiguredRoute(payload)
if not loc or not route then
    return -- Invalid location, deny
end
```

**Result**: Only configured routes accepted

---

### Exploit 5: Reward Manipulation

**Method**: Player modifies client-side reward calculation

**Prevention**: All reward calculation done server-side
```lua
-- Server calculates reward, client cannot override
local reward = calculateReward(loc, route)
Framework.AddMoney(source, reward, account, reason)
```

**Result**: Client has no control over rewards

---

### Exploit 6: Session Hijacking

**Method**: Player sends completion for another player's delivery

**Prevention**: Session tied to specific player
```lua
-- Session is keyed by player source
if not Sessions[source] then
    return -- No session for THIS player
end
```

**Result**: Players cannot complete other players' deliveries

---

## 📝 Best Practices

### For Server Administrators

1. **Enable All Validation**
   ```lua
   Config.Security.validateLocations = true
   Config.Security.logSuspiciousActivity = true
   ```

2. **Monitor Logs**
   - Check server console for exploit attempts
   - Log format: `^1[EXPLOIT] Player X did Y^0`

3. **Adjust Rate Limits**
   - Start conservative, relax if needed
   - Monitor player complaints vs. exploit attempts

4. **Regular Config Review**
   - Review delivery routes for balance
   - Check minimum duration vs. legitimate times

5. **Keep Updated**
   - Update resource for security patches
   - Check GitHub for new versions

### For Developers

1. **Never Trust Client Data**
   - Always validate on server
   - Recalculate don't relay

2. **Use Server Events**
   - Critical operations via RegisterNetEvent
   - Validate sender source

3. **Log Suspicious Activity**
   ```lua
   if suspicious then
       print(string.format("^1[EXPLOIT] %s: %s^0", GetPlayerName(source), reason))
   end
   ```

4. **Test Exploits**
   - Try to break your own system
   - Have players beta test

5. **Document Changes**
   - Note security implications
   - Update documentation

---

## 📊 Monitoring & Logging

### Enable Logging

```lua
Config.Security.logSuspiciousActivity = true
Config.Debug = true -- For verbose logging
```

### Log Examples

**Legitimate Activity**:
```
[LXR-Delivery] Player John_Doe started delivery: Valentine → Blackwater
[LXR-Delivery] Player John_Doe completed delivery in 45.2 seconds (reward: $75)
```

**Suspicious Activity**:
```
^1[EXPLOIT] Player Cheater_123 completed delivery in 2.1 seconds (min: 10)^0
^1[EXPLOIT] Player Hacker_456 sent invalid route data^0
^1[EXPLOIT] Player Spammer_789 exceeded menu open limit^0
```

### Custom Logging System

For advanced logging to database:

```lua
-- In server/server.lua
local function LogDeliveryAttempt(source, eventType, details)
    if not Config.Security.logSuspiciousActivity then return end
    
    local playerName = GetPlayerName(source)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    
    -- Log to console
    print(string.format("^3[DELIVERY-LOG] %s | %s | %s | %s^0", 
        timestamp, playerName, eventType, details))
    
    -- Optional: Log to database
    -- MySQL.insert('INSERT INTO delivery_logs (...) VALUES (...)', {...})
end

-- Usage
LogDeliveryAttempt(source, "EXPLOIT", "Instant completion detected")
```

---

## 🔒 Security Checklist

Before going live, verify:

- [ ] Server-side validation enabled (`validateLocations = true`)
- [ ] Rate limiting configured appropriately
- [ ] Minimum delivery duration set
- [ ] Suspicious activity logging enabled
- [ ] Session management tested
- [ ] Reward calculation server-side
- [ ] No client-side reward manipulation possible
- [ ] Player disconnect handling implemented
- [ ] Menu spam protection active
- [ ] All exploits tested and prevented

---

## 🌍 Server Information

**Developer**: iBoss21 / The Lux Empire  
**Server**: The Land of Wolves 🐺  
**Discord**: [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)  
**Website**: [www.wolves.land](https://www.wolves.land)

---

*Security Guide v2.1.0 | Built with ❤️ by The Land of Wolves 🐺*
