Framework={name='UNKNOWN',obj=nil}
local function res(n) return GetResourceState(n)=='started' end
local function detect()
    if Config.Core=='RSG' or (Config.Core=='AUTO' and res('rsg-core')) then Framework.name='RSG';Framework.obj=exports['rsg-core']:GetCoreObject();return end
    if Config.Core=='VORP' or (Config.Core=='AUTO' and (res('vorp') or res('vorp_core'))) then Framework.name='VORP';Framework.obj=exports.vorp_core and exports.vorp_core:GetCore() or exports['vorp_core']:getCore();return end
    if Config.Core=='LXR' or (Config.Core=='AUTO' and (res('lxr-core') or res('lxrcore'))) then Framework.name='LXR';Framework.obj=exports['lxr-core'] and exports['lxr-core']:GetCoreObject() or nil;return end
end
detect()
function Framework.identifier(src)
    if Framework.name=='RSG' then local P=Framework.obj.Functions.GetPlayer(src);return P and P.PlayerData.citizenid or tostring(src)
    elseif Framework.name=='VORP' then local U=Framework.obj.getUser(src);if not U then return tostring(src) end local C=U.getUsedCharacter;return C and C.identifier or tostring(src)
    elseif Framework.name=='LXR' then return tostring(src) end return tostring(src) end
function Framework.addMoney(src,account,amount,reason)
    if Config.DevGodMode then return end
    if Framework.name=='RSG' then local P=Framework.obj.Functions.GetPlayer(src);if P then P.Functions.AddMoney(account or Config.MoneyAccount,amount,reason or 'Delivery') end return
    elseif Framework.name=='VORP' then local U=Framework.obj.getUser(src);if not U then return end local C=U.getUsedCharacter;C.addCurrency(account or Config.MoneyAccount,amount);return
    elseif Framework.name=='LXR' then local ok=pcall(function() exports['lxr-core']:AddMoney(src,account or Config.MoneyAccount,amount) end);if not ok then print('[lxr-supreme] Map LXR AddMoney') end return end
    pcall(function() exports.ox_inventory:AddItem(src,'cash',math.floor(amount)) end) end
function Framework.addItem(src,name,amount)
    if Framework.name=='RSG' then local P=Framework.obj.Functions.GetPlayer(src);if P then P.Functions.AddItem(name,amount or 1) end return
    elseif Framework.name=='VORP' then exports.vorp_inventory:addItem(src,name,amount or 1);return
    elseif Framework.name=='LXR' then local ok=pcall(function() exports.ox_inventory:AddItem(src,name,amount or 1) end);if not ok then print('[lxr-supreme] Map LXR AddItem') end return end
    pcall(function() exports.ox_inventory:AddItem(src,name,amount or 1) end) end
Storage={}
if Config.Progression.storage=='oxmysql' then
function Storage.get(id) local r=MySQL.single.await('SELECT level,xp,reputation FROM lxr_supreme WHERE identifier=?',{id}); if r then return r.level or 0,r.xp or 0,r.reputation or 0 end return 0,0,0 end
function Storage.set(id,level,xp,reputation) MySQL.insert.await('INSERT INTO lxr_supreme (identifier,level,xp,reputation) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE level=?,xp=?,reputation=?',{id,level,xp,reputation,level,xp,reputation}) end
else
function Storage.get(id) local s=GetResourceKvpString(Config.Progression.kvpPrefix..id); if not s then return 0,0,0 end local ok,t=pcall(json.decode,s); if not ok or not t then return 0,0,0 end return t.level or 0,t.xp or 0,t.rep or 0 end
function Storage.set(id,level,xp,reputation) SetResourceKvp(Config.Progression.kvpPrefix..id,json.encode({level=level,xp=xp,rep=reputation})) end end
