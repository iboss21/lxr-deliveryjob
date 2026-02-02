```
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 EVENTS & API REFERENCE - Delivery Job System
═══════════════════════════════════════════════════════════════════════════════
```

## 📋 Table of Contents

1. [Overview](#overview)
2. [Client Events](#client-events)
3. [Server Events](#server-events)
4. [Framework Events](#framework-events)
5. [Custom Events](#custom-events)
6. [Event Flow Diagrams](#event-flow-diagrams)
7. [Integration Examples](#integration-examples)

---

## 🎯 Overview

The LXR Delivery Job System uses an event-driven architecture for communication between client, server, and framework components.

### Event Categories

| Category | Purpose | Scope |
|----------|---------|-------|
| **Delivery Events** | Core delivery functionality | Client ↔ Server |
| **Framework Events** | Framework integration (player load, etc.) | Framework → System |
| **Custom Events** | Integration with other resources | External ↔ System |
| **Notification Events** | UI feedback | System → Player |

---

## 📡 Client Events

### Received by Client

#### `lxr-delivery:client:OpenMenu`

Opens the delivery menu for player.

**Trigger From**: Client or Server  
**Parameters**: `locationIndex` (number) - Index of delivery location in Config.Deliveries

**Example**:
```lua
-- Server-side trigger
TriggerClientEvent('lxr-delivery:client:OpenMenu', source, 1)

-- Client-side trigger
TriggerEvent('lxr-delivery:client:OpenMenu', 1)
```

**What It Does**:
1. Validates location exists
2. Checks for active delivery
3. Opens menu with available routes
4. Handles random delivery mode if enabled

---

#### `lxr-delivery:client:StartDelivery`

Initiates a delivery job.

**Trigger From**: Server (after validation)  
**Parameters**: 
- `locationData` (table) - Main location config
- `routeData` (table) - Selected route config

**Example**:
```lua
TriggerClientEvent('lxr-delivery:client:StartDelivery', source, locationData, routeData)
```

**What It Does**:
1. Spawns delivery wagon with cargo/lights
2. Creates GPS waypoint to destination
3. Creates destination blip on map
4. Starts distance monitoring loop

---

#### `lxr-delivery:client:CancelDelivery`

Cancels player's active delivery.

**Trigger From**: Server (after validation)  
**Parameters**: None

**Example**:
```lua
TriggerClientEvent('lxr-delivery:client:CancelDelivery', source)
```

**What It Does**:
1. Despawns wagon if exists
2. Removes destination blip
3. Clears GPS waypoint
4. Resets delivery state variables
5. Shows cancellation notification

---

### Triggered by Client

#### `lxr-delivery:server:StartDelivery`

Requests server to start a delivery.

**Trigger To**: Server  
**Parameters**: Delivery data payload (location, route, wagon info)

**Example**:
```lua
-- Internal use - called by menu system
TriggerServerEvent('lxr-delivery:server:StartDelivery', deliveryPayload)
```

**Payload Structure**:
```lua
{
    npc = {x, y, z},           -- NPC coordinates
    cartSpawn = {x, y, z, w},  -- Wagon spawn point
    deliveryLoc = {x, y, z},   -- Destination coordinates
    wagonModel = "cart01",     -- Wagon model
    cargo = "...",             -- Cargo prop
    light = "...",             -- Light prop
    locationData = {...},      -- Full location config
    routeData = {...}          -- Full route config
}
```

---

#### `lxr-delivery:server:CompleteDelivery`

Notifies server of delivery completion.

**Trigger To**: Server  
**Parameters**: Completion data (location, route, timestamp)

**Example**:
```lua
-- Internal use - called when player reaches destination
TriggerServerEvent('lxr-delivery:server:CompleteDelivery', completionPayload)
```

**Payload Structure**:
```lua
{
    npc = {x, y, z},
    cartSpawn = {x, y, z, w},
    deliveryLoc = {x, y, z},
    wagonModel = "cart01",
    locationData = {...},
    routeData = {...},
    completionTime = GetGameTimer()
}
```

---

#### `lxr-delivery:server:CancelDelivery`

Requests server to cancel active delivery.

**Trigger To**: Server  
**Parameters**: None

**Example**:
```lua
-- Triggered by /canceldelivery command
TriggerServerEvent('lxr-delivery:server:CancelDelivery')
```

---

## 🖥️ Server Events

### Received by Server

#### `lxr-delivery:server:StartDelivery`

Processes delivery start request from client.

**Handler**: `server/server.lua`

**Validation Steps**:
1. Check player has no active delivery
2. Rate limit check (prevent spam)
3. Validate location/route matches config
4. Create server-side session
5. Send confirmation to client

**Success Response**:
```lua
TriggerClientEvent('lxr-delivery:client:StartDelivery', source, locationData, routeData)
```

**Failure Response**:
```lua
Framework.Notify(source, "Error", "Reason for failure", "error", 3500)
```

---

#### `lxr-delivery:server:CompleteDelivery`

Processes delivery completion request from client.

**Handler**: `server/server.lua`

**Validation Steps**:
1. Verify active session exists
2. Validate location/route against session data
3. Check minimum delivery duration (anti-exploit)
4. Calculate rewards
5. Distribute money and/or items
6. Clear session
7. Send confirmation

**Reward Distribution**:
```lua
-- Money reward (if configured)
Framework.AddMoney(source, rewardAmount, accountType, "Delivery Reward")

-- Item reward (if configured and chance succeeds)
Framework.AddItem(source, itemName, itemAmount, {})
```

---

#### `lxr-delivery:server:CancelDelivery`

Processes delivery cancellation request.

**Handler**: `server/server.lua`

**Validation Steps**:
1. Check active session exists
2. Clear server-side session
3. Apply cancellation cooldown
4. Notify client to clean up

---

### Triggered by Server

#### Server → Client Notifications

All delivery notifications are sent via the configured notification system:

```lua
-- Success notification
Framework.Notify(source, "Delivery", "Delivery started!", "success", 3500)

-- Error notification
Framework.Notify(source, "Error", "No active delivery", "error", 3500)

-- Info notification
Framework.Notify(source, "Delivery", "Drive to destination", "info", 5000)
```

---

## 🔗 Framework Events

The system integrates with framework events for player lifecycle management.

### LXR-Core Events

```lua
-- Player loaded
AddEventHandler('lxr-core:client:player:loaded', function()
    -- Initialize player-specific data
    -- Can be used to restore interrupted deliveries
end)

-- Player unloaded
AddEventHandler('lxr-core:client:player:unloaded', function()
    -- Clean up active deliveries
    -- Despawn wagons
end)

-- Job updated
AddEventHandler('lxr-core:client:job:update', function(job)
    -- React to job changes if needed
    -- Could restrict deliveries to certain jobs
end)
```

### RSG-Core Events

```lua
-- Player loaded
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    -- Initialize player data
end)

-- Player unloaded
AddEventHandler('RSGCore:Client:OnPlayerUnload', function()
    -- Clean up deliveries
end)

-- Job updated
AddEventHandler('RSGCore:Client:OnJobUpdate', function(job)
    -- Handle job changes
end)
```

### VORP Core Events

```lua
-- Character selected
AddEventHandler('vorp:SelectedCharacter', function()
    -- Player character loaded
end)

-- Player logout
AddEventHandler('vorp:PlayerLogout', function()
    -- Clean up on logout
end)
```

---

## 🔌 Custom Events

### Integration Event Examples

#### Logging Deliveries

Hook into delivery completion for statistics tracking:

```lua
-- In your external logging resource
RegisterNetEvent('lxr-delivery:server:DeliveryCompleted', function(playerData, deliveryData, reward)
    -- Log to database
    MySQL.insert('INSERT INTO delivery_logs (player_id, destination, reward, timestamp) VALUES (?, ?, ?, ?)', {
        playerData.citizenid,
        deliveryData.destination,
        reward,
        os.time()
    })
end)
```

#### Economy Integration

Hook reward distribution for advanced economy systems:

```lua
-- In your economy resource
RegisterNetEvent('lxr-delivery:server:BeforeReward', function(source, amount)
    -- Apply bonuses, taxes, etc.
    local bonus = CalculateDeliveryBonus(source)
    local tax = CalculateTax(amount)
    local finalAmount = amount + bonus - tax
    
    TriggerEvent('lxr-delivery:server:ModifiedReward', source, finalAmount)
end)
```

#### Discord Logging

Log deliveries to Discord webhook:

```lua
-- In your Discord logging resource
RegisterNetEvent('lxr-delivery:server:LogToDiscord', function(playerName, destination, reward)
    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({
        embeds = {{
            title = "Delivery Completed",
            description = string.format("%s delivered to %s and earned $%s", playerName, destination, reward),
            color = 3066993
        }}
    }), { ['Content-Type'] = 'application/json' })
end)
```

---

## 📊 Event Flow Diagrams

### Starting a Delivery

```
┌─────────────┐                                    ┌─────────────┐
│   PLAYER    │                                    │   SERVER    │
└──────┬──────┘                                    └──────┬──────┘
       │                                                  │
       │ 1. Interact with NPC                            │
       ├─────────────────────────────────────────────────>
       │                                                  │
       │                                                  │ 2. Validate request
       │                                                  ├────────┐
       │                                                  │        │
       │                                                  <────────┘
       │                                                  │
       │ 3. Open menu with available routes              │
       <─────────────────────────────────────────────────┤
       │                                                  │
       │ 4. Select destination (or random assigned)      │
       │                                                  │
       │ 5. Send delivery start request                  │
       │    TriggerServerEvent('StartDelivery')          │
       ├─────────────────────────────────────────────────>
       │                                                  │
       │                                                  │ 6. Server validation:
       │                                                  │    - No active delivery
       │                                                  │    - Rate limit check
       │                                                  │    - Route exists
       │                                                  │    - Create session
       │                                                  ├────────┐
       │                                                  │        │
       │                                                  <────────┘
       │                                                  │
       │ 7. Spawn wagon & start delivery                 │
       │    TriggerClientEvent('StartDelivery')          │
       <─────────────────────────────────────────────────┤
       │                                                  │
       │ 8. Wagon spawned, GPS active                    │
       │    Distance checking begins                     │
       ├────────┐                                         │
       │        │                                         │
       <────────┘                                         │
       │                                                  │
```

### Completing a Delivery

```
┌─────────────┐                                    ┌─────────────┐
│   PLAYER    │                                    │   SERVER    │
└──────┬──────┘                                    └──────┬──────┘
       │                                                  │
       │ 1. Arrive at destination                        │
       │    (within detection radius)                    │
       ├────────┐                                         │
       │        │                                         │
       <────────┘                                         │
       │                                                  │
       │ 2. Send completion request                      │
       │    TriggerServerEvent('CompleteDelivery')       │
       ├─────────────────────────────────────────────────>
       │                                                  │
       │                                                  │ 3. Server validation:
       │                                                  │    - Session exists
       │                                                  │    - Route matches
       │                                                  │    - Min duration met
       │                                                  │    - Calculate reward
       │                                                  ├────────┐
       │                                                  │        │
       │                                                  <────────┘
       │                                                  │
       │                                                  │ 4. Distribute rewards:
       │                                                  │    - Add money
       │                                                  │    - Add items
       │                                                  │    - Clear session
       │                                                  ├────────┐
       │                                                  │        │
       │                                                  <────────┘
       │                                                  │
       │ 5. Completion notification                      │
       │    Framework.Notify("Success!")                 │
       <─────────────────────────────────────────────────┤
       │                                                  │
       │ 6. Cleanup client-side:                         │
       │    - Despawn wagon                              │
       │    - Remove blips                               │
       │    - Reset state                                │
       ├────────┐                                         │
       │        │                                         │
       <────────┘                                         │
       │                                                  │
```

### Canceling a Delivery

```
┌─────────────┐                                    ┌─────────────┐
│   PLAYER    │                                    │   SERVER    │
└──────┬──────┘                                    └──────┬──────┘
       │                                                  │
       │ 1. Execute /canceldelivery command              │
       │                                                  │
       │ 2. Send cancel request                          │
       │    TriggerServerEvent('CancelDelivery')         │
       ├─────────────────────────────────────────────────>
       │                                                  │
       │                                                  │ 3. Validate session
       │                                                  │    Clear session data
       │                                                  │    Apply cooldown
       │                                                  ├────────┐
       │                                                  │        │
       │                                                  <────────┘
       │                                                  │
       │ 4. Cancel confirmation                          │
       │    TriggerClientEvent('CancelDelivery')         │
       <─────────────────────────────────────────────────┤
       │                                                  │
       │ 5. Cleanup client:                              │
       │    - Despawn wagon                              │
       │    - Remove blips                               │
       │    - Reset state                                │
       ├────────┐                                         │
       │        │                                         │
       <────────┘                                         │
       │                                                  │
```

---

## 🔨 Integration Examples

### Example 1: Job Restriction

Restrict deliveries to specific jobs:

```lua
-- In client/interaction.lua or custom script
AddEventHandler('lxr-delivery:client:BeforeOpenMenu', function(locationIndex)
    local job = Framework.GetPlayerJob()
    
    if job.name ~= "deliverydriver" and job.name ~= "unemployed" then
        Framework.Notify("Access Denied", "You must be a delivery driver!", "error", 3500)
        CancelEvent() -- Prevent menu from opening
    end
end)
```

### Example 2: Reputation System

Add reputation/experience points for deliveries:

```lua
-- In server/server.lua or custom resource
RegisterNetEvent('lxr-delivery:server:CompleteDelivery', function()
    -- After reward distribution
    local Player = Framework.GetPlayer(source)
    
    -- Add reputation points
    local currentRep = Player.PlayerData.metadata.deliveryRep or 0
    Player.Functions.SetMetaData("deliveryRep", currentRep + 1)
    
    -- Check for rank-up
    if currentRep + 1 >= 100 then
        Framework.Notify(source, "Rank Up!", "You're now a Master Hauler!", "success", 5000)
    end
end)
```

### Example 3: Delivery Tracker UI

Create a custom UI that tracks active deliveries:

```lua
-- In your UI resource
RegisterNetEvent('lxr-delivery:client:UpdateTracker', function(data)
    -- Update UI with delivery progress
    SendNUIMessage({
        action = "updateDelivery",
        destination = data.destination,
        distance = data.distanceRemaining,
        reward = data.estimatedReward
    })
end)

-- Hook into delivery start
AddEventHandler('lxr-delivery:client:StartDelivery', function(locationData, routeData)
    -- Show tracker UI
    SendNUIMessage({
        action = "showTracker",
        destination = routeData.label,
        reward = CalculateReward(routeData)
    })
end)
```

### Example 4: Multiplayer Deliveries

Allow multiple players to work on same delivery:

```lua
-- Server-side coordination
local GroupDeliveries = {}

RegisterNetEvent('lxr-delivery:server:CreateGroup', function()
    local groupId = GenerateGroupId()
    GroupDeliveries[groupId] = {
        leader = source,
        members = {source},
        delivery = nil
    }
    
    TriggerClientEvent('lxr-delivery:client:GroupCreated', source, groupId)
end)

RegisterNetEvent('lxr-delivery:server:JoinGroup', function(groupId)
    if GroupDeliveries[groupId] then
        table.insert(GroupDeliveries[groupId].members, source)
        TriggerClientEvent('lxr-delivery:client:GroupJoined', source, groupId)
    end
end)
```

### Example 5: Dynamic Reward Multipliers

Apply time-of-day or weather multipliers:

```lua
-- Server-side reward calculation
local function GetDynamicMultiplier()
    local hour = GetClockHours()
    local weather = GetWeatherType()
    local multiplier = 1.0
    
    -- Night bonus (8 PM - 6 AM)
    if hour >= 20 or hour <= 6 then
        multiplier = multiplier * 1.25
    end
    
    -- Bad weather bonus
    if weather == "RAIN" or weather == "THUNDER" then
        multiplier = multiplier * 1.15
    end
    
    return multiplier
end

-- Hook into reward calculation
-- Modify server/server.lua reward calculation with multiplier
```

---

## 📚 Advanced Topics

### Creating Custom Events

To emit custom events for integration:

1. **Define the event** in your documentation
2. **Emit at appropriate time** in code
3. **Document parameters** for consumers

Example:
```lua
-- In server/server.lua after reward distribution
TriggerEvent('lxr-delivery:server:RewardDistributed', source, {
    amount = rewardAmount,
    destination = routeData.label,
    distance = calculatedDistance,
    timestamp = os.time()
})
```

### Event Security

Always validate server events:

```lua
RegisterNetEvent('lxr-delivery:server:SomeEvent', function(data)
    local source = source
    
    -- Validate source is valid player
    if not source or source == 0 then return end
    
    -- Validate player exists in framework
    local Player = Framework.GetPlayer(source)
    if not Player then return end
    
    -- Validate data structure
    if type(data) ~= "table" or not data.required_field then
        return
    end
    
    -- Process event...
end)
```

---

## 🌍 Server Information

**Developer**: iBoss21 / The Lux Empire  
**Server**: The Land of Wolves 🐺  
**Discord**: [discord.gg/CrKcWdfd3A](https://discord.gg/CrKcWdfd3A)  
**Website**: [www.wolves.land](https://www.wolves.land)

---

*Events Reference v2.1.0 | Built with ❤️ by The Land of Wolves 🐺*
