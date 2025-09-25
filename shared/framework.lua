Framework = {}
Framework.name = "UNKNOWN"

local function res(state) return GetResourceState(state) == "started" end

local function detectCore()
    if Config.Core == "RSG" or (Config.Core == "AUTO" and res("rsg-core")) then
        Framework.name = "RSG"
        Framework.obj = exports['rsg-core']:GetCoreObject()
        return
    end
    if Config.Core == "VORP" or (Config.Core == "AUTO" and (res("vorp") or res("vorp_core"))) then
        Framework.name = "VORP"
        Framework.obj = exports.vorp_core and exports.vorp_core:GetCore() or exports["vorp_core"]:getCore()
        return
    end
    if Config.Core == "LXR" or (Config.Core == "AUTO" and (res("lxr-core") or res("lxrcore"))) then
        Framework.name = "LXR"
        -- TODO: set your accessor here if different in your build:
        Framework.obj = exports['lxr-core'] and exports['lxr-core']:GetCoreObject() or nil
        return
    end
end
detectCore()

-- ============= MONEY / ITEMS / META WRAPPERS =============
function Framework.addMoney(src, account, amount, reason)
    if Framework.name == "RSG" then
        local Player = Framework.obj.Functions.GetPlayer(src)
        if Player then Player.Functions.AddMoney(account or Config.MoneyAccount, amount, reason or "Delivery") end
        return
    elseif Framework.name == "VORP" then
        local User = Framework.obj.getUser(src); if not User then return end
        local Character = User.getUsedCharacter
        Character.addCurrency(account or Config.MoneyAccount, amount)
        return
    elseif Framework.name == "LXR" then
        -- Implement according to your LXRCore API:
        -- Example placeholder:
        local ok, err = pcall(function()
            exports["lxr-core"]:AddMoney(src, account or Config.MoneyAccount, amount)
        end)
        if not ok then print("[lux-delivery] LXR addMoney missing, please map in shared/framework.lua") end
        return
    end
    -- Fallback: deposit via ox_inventory cash item
    local ok, _ = pcall(function() exports.ox_inventory:AddItem(src, "cash", math.floor(amount)) end)
    if not ok then TriggerClientEvent("chat:addMessage", src, {args={"[Delivery]", ("+$%s (stub)"):format(amount)}}) end
end

function Framework.addItem(src, name, amount)
    if Framework.name == "RSG" then
        local Player = Framework.obj.Functions.GetPlayer(src); if not Player then return end
        Player.Functions.AddItem(name, amount or 1)
        return
    elseif Framework.name == "VORP" then
        exports.vorp_inventory:addItem(src, name, amount or 1)
        return
    elseif Framework.name == "LXR" then
        -- Implement for your inventory (e.g., lxr-inventory or ox_inventory on LXRCore)
        local ok, _ = pcall(function() exports.ox_inventory:AddItem(src, name, amount or 1) end)
        if not ok then print("[lux-delivery] LXR addItem not mapped; please adapt.") end
        return
    end
    local ok, _ = pcall(function() exports.ox_inventory:AddItem(src, name, amount or 1) end)
    if not ok then print("[lux-delivery] No inventory found for fallback addItem") end
end

function Framework.getIdentifier(src)
    if Framework.name == "RSG" then
        local Player = Framework.obj.Functions.GetPlayer(src); return Player and Player.PlayerData.citizenid or tostring(src)
    elseif Framework.name == "VORP" then
        local User = Framework.obj.getUser(src); if not User then return tostring(src) end
        local Character = User.getUsedCharacter
        return Character and Character.identifier or tostring(src)
    elseif Framework.name == "LXR" then
        -- Map your preferred identifier here:
        return tostring(src)
    end
    return tostring(src)
end

-- ============= STORAGE (oxmysql or KVP) =============
Storage = {}

if Config.Progression.storageMode == "oxmysql" then
    function Storage.get(identifier)
        local q = MySQL.single.await("SELECT level, xp FROM lux_delivery WHERE identifier = ?", {identifier})
        if q then return q.level or 0, q.xp or 0 end
        return 0, 0
    end
    function Storage.set(identifier, level, xp)
        MySQL.insert.await("INSERT INTO lux_delivery (identifier, level, xp) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE level=?, xp=?", {identifier, level, xp, level, xp})
    end
else
    local prefix = Config.Progression.kvpPrefix
    function Storage.get(identifier)
        local kv = GetResourceKvpString(prefix .. identifier)
        if not kv then return 0, 0 end
        local ok, data = pcall(json.decode, kv)
        if ok and data then return data.level or 0, data.xp or 0 end
        return 0, 0
    end
    function Storage.set(identifier, level, xp)
        SetResourceKvp(prefix .. identifier, json.encode({ level = level, xp = xp }))
    end
end
