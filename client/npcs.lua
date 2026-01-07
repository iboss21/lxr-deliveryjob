--[[
═══════════════════════════════════════════════════════════════════════════════
    The Land of Wolves - LXRCore Delivery System
    NPC Management
    
    Developer: iBoss
    Website: www.wolves.land
    
    This script handles:
    - Dynamic NPC spawning/despawning based on player distance
    - Map blip creation for delivery locations
    - Smooth fade-in/out effects for NPCs
    - Resource cleanup on stop
═══════════════════════════════════════════════════════════════════════════════
]]--

local spawnedPeds = {}  -- Track spawned NPCs
local blipEntries = {}  -- Track map blips

--[[
    NPC Spawn/Despawn Management Loop
    Dynamically spawns NPCs when player is near, despawns when far away
    Optimizes performance by only keeping nearby NPCs loaded
]]--
CreateThread(function()
    while true do
        Wait(500)
        for k,coords in pairs(Config.Deliveries) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - coords.npccoords.xyz)

            -- Spawn NPC if player is close and NPC not already spawned
            if distance < Config.DistanceSpawn and not spawnedPeds[k] then
                local spawnedPed = NearPed(coords.npcmodel, coords.npccoords, false)
                spawnedPeds[k] = { spawnedPed = spawnedPed }
            end
            
            -- Despawn NPC if player is far away
            if distance >= Config.DistanceSpawn and spawnedPeds[k] then
                -- Fade out effect if enabled
                if Config.FadeIn then
                    for i = 255, 0, -51 do
                        Citizen.Wait(50)
                        SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
                    end
                end
                DeletePed(spawnedPeds[k].spawnedPed)
                spawnedPeds[k] = nil
            end
        end
    end
end)

--[[
    Map Blip Creation
    Creates map markers for all delivery locations on startup
]]--
CreateThread(function()
    for k, coords in pairs(Config.Deliveries) do
        local Blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.npccoords.xyz)
        SetBlipSprite(Blip, joaat(Config.Blip.blipSprite), true)
        SetBlipScale(Blip, Config.Blip.blipScale)
        Citizen.InvokeNative(0x9CB1A1623062F402, Blip, Config.Blip.blipName)
        blipEntries[#blipEntries + 1] = {Blip = Blip }
    end
end)

--[[
    NPC Creation Function
    Spawns an NPC at specified location with proper configuration
    @param npcmodel: Model hash/name of the NPC
    @param npccoords: Spawn coordinates (x, y, z, heading)
    @param trader: Currently unused (reserved for future trader flag)
    @return: Spawned NPC entity
]]--
function NearPed(npcmodel, npccoords, trader)
    RequestModel(npcmodel)
    while not HasModelLoaded(npcmodel) do
        Citizen.Wait(50)
    end
    
    -- Create the NPC
    spawnedPed = CreatePed(npcmodel, npccoords.x, npccoords.y, npccoords.z - 1.0, npccoords.w, false, false, 0, 0)
    SetEntityAlpha(spawnedPed, 0, false)
    
    -- Configure NPC properties
    Citizen.InvokeNative(0x283978A15512B2FE, spawnedPed, true)  -- Set as persistent
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    
    -- Set relationship group between NPC and player (friendly)
    Citizen.InvokeNative(0xC80A74AC829DDD92, spawnedPed, GetPedRelationshipGroupHash(spawnedPed))
    Citizen.InvokeNative(0xBF25EB89375A37AD, 1, GetPedRelationshipGroupHash(spawnedPed), `PLAYER`)
    
    if Config.Debug then
        local relationship = Citizen.InvokeNative(0x9E6B70061662AE5C, GetPedRelationshipGroupHash(spawnedPed), `PLAYER`)
        print(relationship)
    end
    
    -- Fade in effect if enabled
    if Config.FadeIn then
        for i = 0, 255, 51 do
            Citizen.Wait(50)
            SetEntityAlpha(spawnedPed, i, false)
        end
    end
    return spawnedPed
end

--[[
    Resource Cleanup Handler
    Removes all spawned NPCs, blips, and interactions when resource stops
]]--
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete all spawned NPCs
    for k,v in pairs(spawnedPeds) do
        DeletePed(spawnedPeds[k].spawnedPed)
        spawnedPeds[k] = nil
    end
    
    -- Remove all map blips
    for i = 1, #blipEntries do
        RemoveBlip(blipEntries[i].Blip)
    end
    
    -- Remove Murphy interactions if used
    if Config.Interact == "murphy_interact" then
        for _, loc in pairs(Config.Deliveries) do 
            exports.murphy_interact:RemoveInteraction('DeliveryID'.. _)
        end
    end
end)
