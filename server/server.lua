--[[
═══════════════════════════════════════════════════════════════════════════════
 ██╗     ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║     ╚██╗██╔╝██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ██║      ╚███╔╝ ██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██║      ██╔██╗ ██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ███████╗██╔╝ ██╗██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 Server-Side Validation - Secure Delivery Processing
═══════════════════════════════════════════════════════════════════════════════
 
 This server script provides secure validation and processing for delivery jobs,
 implementing anti-exploit delivery sessions (one active per player), reward
 calculations and distribution, multi-framework integration (LXR/RSG/VORP),
 rate limiting, and comprehensive spam prevention measures.
 
════════════════════════════════ Server Information ════════════════════════════
 Server:     The Land of Wolves 🐺 | www.wolves.land
 Community:  Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
 Tagline:    ისტორია ცოცხლდება აქ! (History Lives Here!)
 Type:       Serious Hardcore Roleplay
 Access:     Discord & Whitelisted
 Website:    https://www.wolves.land
 Discord:    https://discord.gg/CrKcWdfd3A
 GitHub:     https://github.com/iBoss21
 Store:      https://theluxempire.tebex.io
 Listing:    https://servers.redm.net/servers/detail/8gj7eb
 Developer:  iBoss21 / The Lux Empire
════════════════════════════════════════════════════════════════════════════════
 Version:    2.1.0
 Performance: Optimized for RedM (60+ FPS target)
 Tags:       Delivery Job, Server Logic, Anti-Exploit, Economy, Security
════════════════════════════════════════════════════════════════════════════════
 Framework Support (in priority order):
 ✓ LXR-Core (Primary)   - The Land of Wolves custom framework
 ✓ RSG-Core (Primary)   - RedM Script Group core framework
 ✓ VORP Core (Supported) - Vintage Outlaw Roleplay framework
════════════════════════════════════════════════════════════════════════════════
 Credits:
 - Original System Creator: RexShack (rsg-delivery)
 - Base Concept & Logic: Muhammad Abdullah Shurjeel (stx-wagondeliveries)
 - Framework Adaptation & Enhancement: iBoss21 (The Lux Empire)
 - Land of Wolves Branding: iBoss21
════════════════════════════════════════════════════════════════════════════════
 Copyright (c) 2024-2026 The Lux Empire / iBoss21
 Licensed under: MIT - wolves.land
═══════════════════════════════════════════════════════════════════════════════
]]--

math.randomseed(GetGameTimer())

-- Delivery session tracking (per-player)
-- Prevents exploits: only ONE active delivery per player, paid ONCE at completion
local Sessions = {}

-- Track last delivery start attempt per player (for rate limiting)
local LastDeliveryAttempt = {}

-- Helper: Create vector3 from x,y,z values
local function v3(x, y, z)
    return vector3(tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0)
end

-- Helper: Check if two positions are within tolerance distance
-- @param a, b: Positions to compare (must have x, y, z fields)
-- @param tol: Tolerance distance (default 0.25)
-- @return: true if positions match within tolerance
local function closeEnough(a, b, tol)
    tol = tol or 0.25
    return #(v3(a.x, a.y, a.z) - v3(b.x, b.y, b.z)) <= tol
end

--[[
    Find Configured Route
    Validates that the client's delivery request matches a real configured route
    This prevents clients from inventing fake routes or manipulating rewards
    @param payload: Client-provided delivery data (npc, cartSpawn, deliveryLoc, wagonModel)
    @return: Main location config, Route config (or nil, nil if invalid)
]]--
local function findConfiguredRoute(payload)
    if not payload or not payload.npc or not payload.cartSpawn or not payload.deliveryLoc or not payload.wagonModel then
        return nil, nil
    end

    for _, loc in pairs(Config.Deliveries or {}) do
        if closeEnough(loc.npccoords, payload.npc, 1.0) and closeEnough(loc.cartSpawn, payload.cartSpawn, 1.0) then
            for _, route in pairs(loc.deliveries or {}) do
                if route.wagonModel == payload.wagonModel and closeEnough(route.deliveryLoc, payload.deliveryLoc, 1.0) then
                    return loc, route
                end
            end
        end
    end

    return nil, nil
end

--[[
    Calculate Reward
    Determines payment amount based on distance or fixed price config
    @param loc: Main location config
    @param route: Specific route config
    @return: Reward amount or nil if invalid
]]--
local function calculateReward(loc, route)
    if not loc or not route or not route.reward then return nil end

    if route.reward.priceByDistance and route.reward.priceByDistance.activation then
        local cartvec = v3(loc.cartSpawn.x, loc.cartSpawn.y, loc.cartSpawn.z)
        local endvec = v3(route.deliveryLoc.x, route.deliveryLoc.y, route.deliveryLoc.z)
        local distance = #(cartvec - endvec)
        return ((math.floor(distance) / 100) * route.reward.priceByDistance.multiplier)
    elseif route.reward.priceByConfig and route.reward.priceByConfig.activation then
        return route.reward.priceByConfig.price
    end

    return nil
end

--[[
    Check if route has active item rewards
    @param route: Route configuration
    @return: true if item rewards are configured and active, false otherwise
]]--
local function hasItemReward(route)
    return route and route.reward and route.reward.itemreward and route.reward.itemreward.activation == true
end

--[[
    Check if there is at least one valid reward (money or items)
    @param money: Money amount (can be nil, 0, or positive)
    @param route: Route configuration
    @return: true if at least one reward type is valid, false otherwise
]]--
local function hasValidReward(money, route)
    -- Valid if money > 0 OR item rewards are configured
    return (money and money > 0) or hasItemReward(route)
end

--[[
    Give Rewards
    Distributes money and item rewards to player based on framework
    Supports both RSGCore and VORP frameworks
    @param src: Player server ID
    @param money: Money amount to give
    @param route: Route config (contains item reward info)
    @return: true if successful, false otherwise
]]--
local function giveRewards(src, money, route)
    -- Need at least money or item reward
    if not hasValidReward(money, route) then 
        return false 
    end

    -- RSGCore Framework Integration
    if Config.Core == "RSG" then
        local RSGCore = exports['rsg-core']:GetCoreObject()
        local Player = RSGCore.Functions.GetPlayer(src)
        if not Player then return false end

        -- Give money reward if amount is greater than 0
        if money and money > 0 then
            Player.Functions.AddMoney(Config.Reward_Money_Account, money, 'Delivery Wagon Payment')
        end

        -- Give item reward if configured
        if hasItemReward(route) then
            local item = route.reward.itemreward
            local function addItem()
                Player.Functions.AddItem(item.itemname, item.itemamount)
                local label = (RSGCore.Shared.Items[item.itemname] and RSGCore.Shared.Items[item.itemname].label) or item.itemname
                Config.Notify_Server(src, "Delivery", ("You received an item reward : %sx %s"):format(item.itemamount, label))
            end

            -- Check if chance-based reward
            if item.chance ~= nil then
                local chance = math.random(1, 100)
                if chance >= item.chance then
                    addItem()
                end
            else
                addItem() -- Guaranteed reward
            end
        end

        return true

    -- VORP Framework Integration
    elseif Config.Core == "VORP" then
        local Core = exports.vorp_core:GetCore()
        local inventory = exports.vorp_inventory
        local User = Core.getUser(src)
        if not User then return false end
        local Character = User.getUsedCharacter
        if not Character then return false end

        -- Give money reward if amount is greater than 0
        if money and money > 0 then
            Character.addCurrency(Config.Reward_Money_Account, money)
        end

        -- Give item reward if configured
        if hasItemReward(route) then
            local item = route.reward.itemreward
            local function addItem()
                inventory:addItem(src, item.itemname, item.itemamount)
                Config.Notify_Server(src, "Delivery", ("You received an item reward : %sx %s"):format(item.itemamount, item.itemname))
            end

            -- Check if chance-based reward
            if item.chance ~= nil then
                local chance = math.random(1, 100)
                if chance >= item.chance then
                    addItem()
                end
            else
                addItem() -- Guaranteed reward
            end
        end

        return true
    end

    return false
end

--[[
    Start Delivery Callback
    Called when client starts a delivery (right after spawning the wagon)
    Validates request, enforces rate limits, creates delivery session
    @param source: Player server ID
    @param payload: Client-provided delivery data
    @return: Reward amount if valid, false if rejected
]]--
lib.callback.register('stx-wagondeliveries:server:callback:startDelivery', function(source, payload)
    local src = source
    local now = os.time()

    -- Check server-side rate limit
    if LastDeliveryAttempt[src] then
        local timeSinceLastAttempt = now - LastDeliveryAttempt[src]
        if timeSinceLastAttempt < Config.AntiSpam.serverRateLimit then
            if Config.Debug then
                print(("^3[DELIVERY] Player %d attempted to start delivery too quickly (%.1fs since last attempt)^0"):format(src, timeSinceLastAttempt))
            end
            return false
        end
    end

    -- Already in a delivery? refuse.
    if Sessions[src] and Sessions[src].active then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d already has an active delivery^0"):format(src))
        end
        return false
    end

    local loc, route = findConfiguredRoute(payload)
    if not loc or not route then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d sent invalid delivery configuration^0"):format(src))
        end
        return false
    end

    local reward = calculateReward(loc, route)
    
    -- Check for valid reward configuration
    -- calculateReward returns nil if the route reward config is invalid
    if not reward then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d has invalid reward configuration^0"):format(src))
        end
        return false
    end
    
    -- Check if there's at least some reward (money OR items)
    if not hasValidReward(reward, route) then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d has no rewards configured (no money or item rewards)^0"):format(src))
        end
        return false
    end

    -- Update rate limit tracker
    LastDeliveryAttempt[src] = now

    Sessions[src] = {
        active = true,
        paid = false,
        reward = reward,
        route = route,
        startedAt = now,
    }

    if Config.Debug then
        print(("^2[DELIVERY] Player %d started delivery - Reward: $%.2f^0"):format(src, reward))
    end

    return reward
end)

--[[
    Complete Delivery Callback
    Called when client parks wagon at the delivery point
    Validates session, checks timing, distributes rewards
    @param source: Player server ID
    @return: true if successful and paid, false if rejected
]]--
lib.callback.register('stx-wagondeliveries:server:callback:completeDelivery', function(source)
    local src = source
    local s = Sessions[src]
    
    if not s or not s.active then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d attempted to complete delivery without active session^0"):format(src))
        end
        return false
    end
    
    if s.paid then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d attempted to complete already-paid delivery (exploit attempt blocked)^0"):format(src))
        end
        return false
    end

    -- Additional validation: check if enough time has passed since start
    local deliveryDuration = os.time() - s.startedAt
    if deliveryDuration < Config.AntiSpam.minDeliveryDuration then
        if Config.Debug then
            print(("^3[DELIVERY] Player %d completed delivery too quickly (%.1fs) - possible exploit^0"):format(src, deliveryDuration))
        end
        return false
    end

    s.paid = true

    local ok = giveRewards(src, s.reward, s.route)

    if Config.Debug then
        if ok then
            print(("^2[DELIVERY] Player %d completed delivery - Paid: $%.2f - Duration: %ds^0"):format(src, s.reward, deliveryDuration))
        else
            print(("^1[DELIVERY] Player %d failed to receive rewards^0"):format(src))
        end
    end

    -- Always end the session after a completion attempt to prevent replays.
    Sessions[src] = nil

    return ok
end)

--[[
    Cancel Delivery Event
    Explicit cancel from client - cleans up delivery session
]]--
RegisterNetEvent('stx-wagondeliveries:server:cancelDelivery', function()
    local src = source
    if Config.Debug and Sessions[src] then
        print(("^3[DELIVERY] Player %d cancelled delivery^0"):format(src))
    end
    Sessions[src] = nil
end)

--[[
    Player Disconnect Handler
    Cleanup on disconnect to prevent ethernet abuse / reconnect payout exploits
]]--
AddEventHandler('playerDropped', function()
    local src = source
    if Config.Debug and Sessions[src] then
        print(("^3[DELIVERY] Player %d disconnected with active delivery - session cleaned up^0"):format(src))
    end
    Sessions[src] = nil
    LastDeliveryAttempt[src] = nil
end)
