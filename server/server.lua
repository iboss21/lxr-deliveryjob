math.randomseed(GetGameTimer())

-- Anti-exploit delivery sessions (per-player)
-- Goal: keep the same UI / interaction, but only pay ONCE, at the delivery point.
local Sessions = {}

local function v3(x, y, z)
    return vector3(tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0)
end

local function closeEnough(a, b, tol)
    tol = tol or 0.25
    return #(v3(a.x, a.y, a.z) - v3(b.x, b.y, b.z)) <= tol
end

-- Find the exact configured main location + delivery route from the payload.
-- This prevents clients from inventing routes/rewards.
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

local function giveRewards(src, money, route)
    if not money or money <= 0 then return false end

    if Config.Core == "RSG" then
        local RSGCore = exports['rsg-core']:GetCoreObject()
        local Player = RSGCore.Functions.GetPlayer(src)
        if not Player then return false end

        Player.Functions.AddMoney(Config.Reward_Money_Account, money, 'Delivery Wagon Payment')

        if route and route.reward and route.reward.itemreward and route.reward.itemreward.activation then
            local item = route.reward.itemreward
            local function addItem()
                Player.Functions.AddItem(item.itemname, item.itemamount)
                local label = (RSGCore.Shared.Items[item.itemname] and RSGCore.Shared.Items[item.itemname].label) or item.itemname
                Config.Notify_Server(src, "Delivery", ("You received an item reward : %sx %s"):format(item.itemamount, label))
            end

            if item.chance ~= nil then
                local chance = math.random(1, 100)
                if chance >= item.chance then
                    addItem()
                end
            else
                addItem()
            end
        end

        return true

    elseif Config.Core == "VORP" then
        local Core = exports.vorp_core:GetCore()
        local inventory = exports.vorp_inventory
        local User = Core.getUser(src)
        if not User then return false end
        local Character = User.getUsedCharacter
        if not Character then return false end

        Character.addCurrency(Config.Reward_Money_Account, money)

        if route and route.reward and route.reward.itemreward and route.reward.itemreward.activation then
            local item = route.reward.itemreward
            local function addItem()
                inventory:addItem(src, item.itemname, item.itemamount)
                Config.Notify_Server(src, "Delivery", ("You received an item reward : %sx %s"):format(item.itemamount, item.itemname))
            end

            if item.chance ~= nil then
                local chance = math.random(1, 100)
                if chance >= item.chance then
                    addItem()
                end
            else
                addItem()
            end
        end

        return true
    end

    return false
end

-- Called when client starts a delivery (right after spawning the wagon)
lib.callback.register('stx-wagondeliveries:server:callback:startDelivery', function(source, payload)
    local src = source

    -- Already in a delivery? refuse.
    if Sessions[src] and Sessions[src].active then
        return false
    end

    local loc, route = findConfiguredRoute(payload)
    if not loc or not route then
        return false
    end

    local reward = calculateReward(loc, route)
    if not reward or reward <= 0 then
        return false
    end

    Sessions[src] = {
        active = true,
        paid = false,
        reward = reward,
        route = route,
        startedAt = os.time(),
    }

    return reward
end)

-- Called when client parks wagon at the delivery point
lib.callback.register('stx-wagondeliveries:server:callback:completeDelivery', function(source)
    local src = source
    local s = Sessions[src]
    if not s or not s.active then
        return false
    end
    if s.paid then
        return false
    end

    s.paid = true

    local ok = giveRewards(src, s.reward, s.route)

    -- Always end the session after a completion attempt to prevent replays.
    Sessions[src] = nil

    return ok
end)

-- Explicit cancel from client
RegisterNetEvent('stx-wagondeliveries:server:cancelDelivery', function()
    local src = source
    Sessions[src] = nil
end)

-- Cleanup on disconnect (prevents ethernet abuse / reconnect payout)
AddEventHandler('playerDropped', function()
    local src = source
    Sessions[src] = nil
end)
