-- Simple progression API (server-side)
-- Exports for awarding/fetching XP/levels cross-resource.

exports("awardXP", function(src, success)
    local id = Framework.getIdentifier(src)
    local level, current = Storage.get(id)

    local gain = success and Config.Progression.xpPerMission.success or Config.Progression.xpPerMission.fail
    local new = (current or 0) + gain

    local nextLevel = level or 0
    for i=1,#Config.Progression.levels do
        if new >= Config.Progression.levels[i] then nextLevel = i end
    end
    Storage.set(id, nextLevel, new)

    -- announce perk unlocks
    local perks = Config.Progression.perks[nextLevel]
    if perks then
        TriggerClientEvent("lux:delivery:perkUnlock", src, nextLevel, perks)
    end

    return nextLevel, new
end)

exports("getProgress", function(src)
    local id = Framework.getIdentifier(src)
    local level, xp = Storage.get(id)
    return level or 0, xp or 0
end)
