Config = {}

-- ======================================
-- CORE & INTEGRATIONS
-- ======================================
-- AUTO tries to detect installed framework; override if needed
-- Options: "AUTO", "LXR", "RSG", "VORP"
Config.Core = "AUTO"

-- Interaction layer: "prompt" (native helptext), "murphy" (Murphy Interaction), "ox_target" (ox_target)
Config.Interaction = "prompt"

-- Locale (see /locales). Ships with 'en' and 'ge' for Georgian.
Config.Locale = "en"

-- Discord webhook (nil to disable)
Config.Discord = {
    deliveries_webhook = nil,
    levelup_webhook = nil
}

-- ======================================
-- PERFORMANCE & DEBUG
-- ======================================
Config.Debug = false
Config.TickRateMs = 750         -- main client loop
Config.StreamDistance = 120.0   -- for ambient spawns
Config.MaxConcurrentMissionsPerPlayer = 1
Config.CooldownSeconds = 90     -- per-player mission cooldown

-- ======================================
-- ECONOMY & PAYOUTS
-- ======================================
Config.MoneyAccount = "cash"    -- RSG/VORP use account keys; LXR wrapper adapts
Config.BasePayPerKm = 7.5       -- base rate before modifiers
Config.RiskMultipliers = {
    low = 1.0,
    medium = 1.35,
    high = 1.75,
    extreme = 2.25
}
-- Optional dynamic supply/demand by destination
Config.DynamicDemand = {
    enabled = true,
    floor = 0.8,  -- 80%
    ceil  = 1.4,  -- 140%
    updateMinutes = 30
}

-- Damage → penalty: 0.0 (no damage) to 1.0 (destroyed)
Config.DamagePenaltyCurve = function(damageRatio)
    -- gentle first half, harsher late losses
    if damageRatio <= 0.3 then
        return 1.0 - (damageRatio * 0.5)
    elseif damageRatio <= 0.7 then
        return 0.85 - (damageRatio - 0.3) * 0.6
    else
        return 0.61 - (damageRatio - 0.7) * 1.5
    end
end

-- Optional item rewards
Config.ItemRewards = {
    enabled = true,
    chance = 18,             -- % chance
    pool = {
        { item = "whiskey_bottle", min = 1, max = 2, label = "Whiskey Bottle" },
        { item = "ammo_varmint",   min = 10, max = 30, label = "Varmint Rounds" },
        { item = "repair_kit",     min = 1, max = 1,  label = "Wagon Repair Kit" }
    }
}

-- ======================================
-- PROGRESSION
-- ======================================
Config.Progression = {
    storageMode = "kvp", -- "oxmysql" | "kvp"
    kvpPrefix   = "lux_delivery_",

    xpPerMission = { success = 60, fail = 15 },
    levels = {
        -- xp required total for each level (cumulative)
        0, 100, 230, 400, 600, 850, 1150
    },
    perks = {
        -- unlock index by level; actual behavior applied on server
        [2] = { armoredWagon = true },
        [3] = { fasterHitch = true },
        [4] = { hireAIescort = true },
        [5] = { blackMarket = true },
        [6] = { extraRewardChance = 0.15 }
    }
}

-- ======================================
-- WAGONS & CARGO
-- ======================================
Config.Wagons = {
    standard = { model = "CART01", cargoPtfx = "pg_teamster_cart01_breakables", light = "pg_teamster_cart01_lightupgrade3" },
    armored  = { model = "WAGON03X", cargoPtfx = "pg_re_coachrobbery_mission_cargo", light = "pg_teamster_cart01_lightupgrade3" },
    stealth  = { model = "WAGON05X", cargoPtfx = "pg_delivery_stealth_sacks",      light = "pg_teamster_cart01_lightupgrade1" }
}

-- how much collision/horse fall etc contributes to cargo damage per hit
Config.CargoDamage = {
    minor = 0.03,
    medium = 0.10,
    major = 0.22
}

-- ======================================
-- EVENTS & WORLD REACTIVITY
-- ======================================
Config.Events = {
    ambushChancePerSegment = 22,  -- percent chance at each path segment
    lawDetectionStealth = { lightOn = 45, speedOver = 30 }, -- % chance check when breaking stealth rules
    weatherImpact = {
        rain = { handlingMultiplier = 0.9 },
        storm = { handlingMultiplier = 0.8 },
        fog = { visibility = 0.6 }
    },
    wildlifeThreats = {
        enabled = true, chance = 8, models = { "A_C_Wolf_01", "A_C_Bear_01" }
    }
}

-- ======================================
-- FACTIONS (for ambush/escort flavor)
-- ======================================
Config.Factions = {
    bandits = {
        models = { "MP_G_M_M_UniGrays_01", "G_M_M_UniBanditos_01" },
        weapons = { "WEAPON_REPEATER_CARBINE", "WEAPON_REVOLVER_CATTLEMAN" }
    },
    law = {
        models = { "S_M_M_DispatchLawRural_01" },
        weapons = { "WEAPON_REPEATER_HENRY" }
    }
}

-- ======================================
-- MISSION BOARD(S) & TEMPLATES
-- ======================================
Config.Boards = {
    {
        name = "Saint Denis Freight Guild",
        blip = { sprite = "blip_ambient_delivery", color = 2 },
        ped = { model = "S_M_M_BankClerk_01", heading = 120.0 },
        coords = vec3(2648.9, -1290.5, 52.3),
        missions = {
            { id = "whiskey_run",     label = "Whiskey Run",     risk = "low",    wagon = "standard", from = vec3(2645.6, -1292.0, 52.3), to = vec3(1330.2, -1375.1, 80.4), stealth = false, requiresPosse = false },
            { id = "ore_escort",      label = "Ore Escort",      risk = "high",   wagon = "armored",  from = vec3(2637.7, -1287.4, 52.3), to = vec3(-687.4, -1249.2, 44.2), stealth = false, requiresPosse = true  },
            { id = "moonshine_night", label = "Moonshine Night", risk = "medium", wagon = "stealth",  from = vec3(2638.8, -1299.1, 52.1), to = vec3(2828.3, 219.9, 51.0),  stealth = true,  requiresPosse = false, allowedHours = {22, 5} }
        }
    }
}

-- ======================================
-- COMMANDS / KEYS
-- ======================================
Config.Commands = {
    cancel = "canceldelivery",
    debug  = "luxdeldebug"
}

-- ======================================
-- NOTIFICATIONS (server + client)
-- Replace with your preferred notify functions if desired.
-- ======================================
Config.Notify = {}

-- simple notify wrappers (ox_lib if available, else chat)
Config.Notify.Client = function(msg, type)
    if lib and lib.notify then
        lib.notify({ title = "Delivery", description = msg, type = type or "inform" })
    else
        TriggerEvent("chat:addMessage", { args = { "[Delivery]", msg } })
    end
end

Config.Notify.Server = function(src, msg, type)
    TriggerClientEvent('lux:delivery:notify', src, msg, type)
end
