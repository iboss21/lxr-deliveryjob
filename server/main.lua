local Notify = Config.Notify

-- authoritative mission state
local MissionState = {}

RegisterNetEvent("lux:delivery:startMission", function(boardIndex, missionIndex)
    local src = source
    if not Config.Boards[boardIndex] or not Config.Boards[boardIndex].missions[missionIndex] then
        return Notify.Server(src, "Invalid mission selection", "error")
    end

    -- cooldown & concurrency
    MissionState[src] = MissionState[src] or {}
    if MissionState[src].active then
        return Notify.Server(src, "You already have an active delivery.", "error")
    end
    if MissionState[src].cooldown and MissionState[src].cooldown > os.time() then
        return Notify.Server(src, ("You must wait %ds."):format(MissionState[src].cooldown - os.time()), "error")
    end

    local board = Config.Boards[boardIndex]
    local m = board.missions[missionIndex]
    MissionState[src] = {
        active = true,
        boardIndex = boardIndex,
        missionIndex = missionIndex,
        damage = 0.0,
        startedAt = os.time(),
        risk = m.risk,
        stealth = m.stealth or false,
        wagonType = m.wagon
    }

    TriggerClientEvent("lux:delivery:client:begin", src, boardIndex, missionIndex, m)
end)

RegisterNetEvent("lux:delivery:reportDamage", function(amount)
    local src = source
    if MissionState[src] and MissionState[src].active then
        MissionState[src].damage = math.max(0.0, math.min(1.0, MissionState[src].damage + amount))
    end
end)

RegisterNetEvent("lux:delivery:abort", function(reason)
    local src = source
    if MissionState[src] and MissionState[src].active then
        MissionState[src] = { active = false, cooldown = os.time() + Config.CooldownSeconds }
        TriggerClientEvent("lux:delivery:client:cleanup", src, reason or "aborted")
        Notify.Server(src, "Delivery aborted.", "error")
    end
end)

RegisterNetEvent("lux:delivery:complete", function(distanceKm)
    local src = source
    local st = MissionState[src]
    if not (st and st.active) then return end
    st.active = false
    st.cooldown = os.time() + Config.CooldownSeconds

    local riskMul = Config.RiskMultipliers[st.risk or "low"] or 1.0
    local demandMul = 1.0 -- optional: compute by destination id
    local base = (Config.BasePayPerKm * (distanceKm or 1.0)) * riskMul * demandMul

    local damagePenalty = Config.DamagePenaltyCurve(st.damage or 0.0)
    local reward = math.floor(base * damagePenalty)

    Framework.addMoney(src, Config.MoneyAccount, reward, "Delivery Payment")

    if Config.ItemRewards.enabled then
        local chance = math.random(1,100)
        if chance <= Config.ItemRewards.chance then
            local choice = Config.ItemRewards.pool[math.random(1, #Config.ItemRewards.pool)]
            local amt = math.random(choice.min, choice.max)
            Framework.addItem(src, choice.item, amt)
        end
    end

    -- progression
    local ok, lvl, xp = pcall(function() return exports["lux-mission-delivery"]:awardXP(src, true) end)
    if not ok then
        -- internal fallback
        local id = Framework.getIdentifier(src)
        local level, current = Storage.get(id)
        local gain = Config.Progression.xpPerMission.success
        local new = current + gain
        local nextLevel = level
        for i=1,#Config.Progression.levels do
            if new >= Config.Progression.levels[i] then nextLevel = i end
        end
        Storage.set(id, nextLevel, new)
        lvl, xp = nextLevel, new
    end

    TriggerClientEvent("lux:delivery:client:cleanup", src, "complete", reward, st.damage, lvl, xp)
    Notify.Server(src, ("Delivery complete! Earned $%d."):format(reward), "success")
end)

AddEventHandler("playerDropped", function()
    local src = source
    if MissionState[src] and MissionState[src].active then
        MissionState[src] = nil
    end
end)
