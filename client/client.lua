--[[
═══════════════════════════════════════════════════════════════════════════════
    The Land of Wolves - LXRCore Delivery System
    Client-Side Script
    
    Developer: iBoss
    Website: www.wolves.land
    
    This script handles:
    - Delivery menu interactions
    - Wagon spawning and GPS routing
    - Delivery completion detection
    - Client-side anti-exploit measures
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Delivery State Variables
local isDeliveryStarted = false    -- Is a delivery currently active?
local isWagonDelivered = false     -- Has wagon reached destination?
local wagonSpawned = false         -- Is wagon currently spawned?
local wagonmodel = nil             -- Reference to spawned wagon entity
local endcoords = nil              -- Destination coordinates for active delivery
local deliveryBlip = nil           -- Blip marker for delivery destination
local tempdata2 = nil              -- Temporary delivery data storage
local tempamount = nil             -- Temporary reward amount storage
local isCompleting = false         -- Is delivery completion in progress?
local lastDeliveryAttempt = 0      -- Timestamp of last delivery start attempt

-- Draw floating 3D text in the game world
-- @param x, y, z: World coordinates where text should appear
-- @param text: String to display
function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

--[[
    Calculate Delivery Reward
    Determines payment based on distance or fixed price configuration
    @param data1: Main location data (NPC location, cart spawn, etc.)
    @param data2: Specific delivery route data (destination, rewards, etc.)
    @return: Calculated reward amount or nil if invalid
]]--
local function calculateMoney(data1, data2)
    if not data1 or not data2 or not data2.reward then
        return nil
    end

    if data2.reward.priceByDistance and data2.reward.priceByDistance.activation then
        local cartvec = vector3(data1.cartSpawn.x, data1.cartSpawn.y, data1.cartSpawn.z)
        local endvec = vector3(data2.deliveryLoc.x, data2.deliveryLoc.y, data2.deliveryLoc.z)
        local distance = #(cartvec - endvec)
        return ((math.floor(distance) / 100) * data2.reward.priceByDistance.multiplier)
    elseif data2.reward.priceByConfig and data2.reward.priceByConfig.activation then
        return data2.reward.priceByConfig.price
    end

    return nil
end

--[[
    Spawn Cart/Wagon with GPS Mission
    Creates the delivery wagon at the designated spawn point and sets up GPS routing
    @param data1: Main location data (cart spawn coordinates, etc.)
    @param data2: Delivery route data (wagon model, cargo, destination, etc.)
    @return: true if successful, false otherwise
]]--
local function spawn_cart_with_gps_mission(data1, data2)
    local cartHash = joaat(data2.wagonModel)
    local cargoHash = joaat(data2.cargo)
    local lightHash = joaat(data2.light)
    local cartcoords = vector3(data1.cartSpawn.x, data1.cartSpawn.y, data1.cartSpawn.z)
    local cartheading = data1.cartSpawn.w
    
    -- Request models from game
    RequestModel(cartHash, cargoHash, lightHash)
    while not HasModelLoaded(cartHash, cargoHash, lightHash) do
        RequestModel(cartHash, cargoHash, lightHash)
        Wait(0)
    end
    
    -- Spawn the cart with cargo and lights attached
    local cart = CreateVehicle(cartHash, cartcoords, cartheading, true, false)
    SetVehicleOnGroundProperly(cart)
    
    -- Configure vehicle to be driveable and prevent despawn
    SetEntityAsMissionEntity(cart, true, true)           -- Mark as mission entity (prevents auto-despawn)
    SetVehicleHasBeenOwnedByPlayer(cart, true)          -- Mark as player-owned (enables full interaction)
    SetVehicleNeedsToBeHotwired(cart, false)            -- Disable hotwiring requirement
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, cart, true) -- SetVehicleExclusiveDriver (allows player control)
    Wait(200)
    SetModelAsNoLongerNeeded(cartHash)
    
    -- Attach cargo and light props to the wagon
    Citizen.InvokeNative(0xD80FAF919A2E56EA, cart, cargoHash)
    Citizen.InvokeNative(0xC0F0417A90402742, cart, lightHash)
    
    -- Update state variables
    wagonmodel = cart
    wagonSpawned = true
    isDeliveryStarted = true
    endcoords = vector3(data2.deliveryLoc.x, data2.deliveryLoc.y, data2.deliveryLoc.z)
    
    -- Create destination blip on map
    -- Native 0x554D9D53F696D002 = BlipAddForCoords
    -- Parameter 1664425300 = blip hash for coordinate-based blips
    deliveryBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, endcoords.x, endcoords.y, endcoords.z)
    SetBlipSprite(deliveryBlip, joaat(Config.Blip.deliveryBlipSprite), true)
    SetBlipScale(deliveryBlip, Config.Blip.deliveryBlipScale)
    Citizen.InvokeNative(0x9CB1A1623062F402, deliveryBlip, Config.Blip.deliveryBlipName)  -- SetBlipName
    
    -- Set up GPS route to destination
    StartGpsMultiRoute(GetHashKey("COLOR_RED"), true, true)
    AddPointToGpsMultiRoute(endcoords)
    SetGpsMultiRouteRender(true)
    
    return true
end


--[[
    Open Delivery Menu
    Displays the main delivery selection menu to the player
    Handles random delivery mode if enabled
]]--
RegisterNetEvent("stx-wagondeliveries:client:open_delivery_menu", function(deliverydata)
    lib.registerContext({
        id = 'stx_wagonDeliveries_main_Menu',
        title = deliverydata.label,
        options = {
            {
                title = "Deliver Cart",
                description = "Delivery is paid automatically when you park the cart at the delivery point.",
                disabled = true,
            },
            {
                title = "Start Delivery",
                description = "A random destination will be assigned.",
                disabled = isDeliveryStarted,
                onSelect = function()
                    if isDeliveryStarted then
                        Config.Notify_Client("Delivery", "A delivery is already in progress.", "error", 3500)
                        return
                    end

                    -- Check client-side rate limit
                    local now = GetGameTimer()
                    local timeSinceLastAttempt = (now - lastDeliveryAttempt) / 1000
                    if timeSinceLastAttempt < Config.AntiSpam.serverRateLimit then
                        local waitTime = math.ceil(Config.AntiSpam.serverRateLimit - timeSinceLastAttempt)
                        Config.Notify_Client("Delivery", "Please wait " .. waitTime .. " seconds before starting another delivery.", "error", 3500)
                        return
                    end

                    lastDeliveryAttempt = now

                    TriggerEvent("stx-wagondeliveries:client:startDelivery", deliverydata, nil)
                    lib.hideContext(true)
                end
            }
        },
    })

    lib.showContext('stx_wagonDeliveries_main_Menu')
end)


--[[
    Start Delivery
    Initiates a new delivery job with random or selected route
    Includes server-side validation to prevent exploits
]]--
RegisterNetEvent("stx-wagondeliveries:client:startDelivery", function(MainLocationData, MainLocationDeliveryData)

    -- Random Mode: Choose route randomly if enabled and not already selected
    if Config.RandomDelivery then
        local list = (MainLocationData and MainLocationData.deliveries) or nil
        if not list or #list == 0 then
            Config.Notify_Client("Delivery", "No deliveries configured for this location.", "error", 4000)
            return
        end

        -- If route wasn't provided, force random selection
        if not MainLocationDeliveryData then
            MainLocationDeliveryData = list[math.random(1, #list)]
        end
    end

    -- Spawn wagon and start delivery
    if spawn_cart_with_gps_mission(MainLocationData, MainLocationDeliveryData) then
        -- Register this delivery server-side (prevents reward spam/exploits)
        local payload = {
            npc = MainLocationData.npccoords,
            cartSpawn = MainLocationData.cartSpawn,
            deliveryLoc = MainLocationDeliveryData.deliveryLoc,
            wagonModel = MainLocationDeliveryData.wagonModel,
        }

        local serverReward = lib.callback.await('stx-wagondeliveries:server:callback:startDelivery', false, payload)
        if not serverReward then
            -- Server refused (already has an active delivery or config mismatch)
            Config.Notify_Client("Delivery", "You already have an active delivery or this route is invalid.", "error", 5000)
            TriggerEvent("stx-wagondeliveries:client:cancelDelivery", true)
            return
        end

        -- Notify player delivery started (no destination info if hidden mode enabled)
        Config.Notify_Client("Delivery", "Delivery started. Follow the route.", "info", 5000)

        -- Monitor delivery progress in a loop
        CreateThread(function()
            local sleep = 750
            while true do
                -- Exit if wagon destroyed or delivery cancelled
                if not wagonSpawned or not isDeliveryStarted or not DoesEntityExist(wagonmodel) or not endcoords then
                    break
                end

                local vehpos = GetEntityCoords(wagonmodel, true)
                local dist = #(vehpos - endcoords)

                -- When close to destination, show delivery marker
                if dist < 250.0 then
                    sleep = 0
                    DrawText3D(endcoords.x, endcoords.y, endcoords.z + 0.98, "DELIVERY POINT")

                    -- Complete delivery when wagon reaches destination
                    if dist < 3.0 and not isCompleting then
                        isCompleting = true
                        isWagonDelivered = true

                        -- Request server to complete delivery and pay rewards
                        local ok = lib.callback.await('stx-wagondeliveries:server:callback:completeDelivery', false)
                        if ok then
                            -- Success: Clean up and reset mission
                            Config.Notify_Client("Delivery", "Delivery completed. Payment received.", "success", 5000)
                            ClearGpsMultiRoute(endcoords)
                            if deliveryBlip then
                                RemoveBlip(deliveryBlip)
                                deliveryBlip = nil
                            end
                            endcoords = nil
                            if DoesEntityExist(wagonmodel) then
                                DeleteVehicle(wagonmodel)
                            end
                            wagonmodel = nil
                            wagonSpawned = false
                            isDeliveryStarted = false
                            isWagonDelivered = false
                            tempdata2 = nil
                            tempamount = nil
                        else
                            -- Server refused (already paid or invalid)
                            Config.Notify_Client("Delivery", "Delivery could not be completed (already paid / invalid).", "error", 5000)
                        end

                        isCompleting = false
                        break
                    end
                else
                    sleep = 750
                end

                Wait(sleep)
            end
        end)
    end

end)


--[[
    Cancel Delivery
    Cancels active delivery and cleans up wagon/mission state
    @param check: If true, force cancel. If false, only cancel if delivered
]]--
RegisterNetEvent("stx-wagondeliveries:client:cancelDelivery", function(check)
    if check then
        if wagonSpawned and isDeliveryStarted then
            TriggerServerEvent('stx-wagondeliveries:server:cancelDelivery')
            Config.Notify_Client("Delivery", "Mission Cancelled", "error", 5000)
            ClearGpsMultiRoute(endcoords)
            if deliveryBlip then
                RemoveBlip(deliveryBlip)
                deliveryBlip = nil
            end
            endcoords = nil
            DeleteVehicle(wagonmodel)
            wagonSpawned = false
            isDeliveryStarted = false
            isWagonDelivered = false
            tempdata2 = nil
            tempamount = nil
        else
            Config.Notify_Client("Delivery", "Either Cart isn't spawned or Mission isn't started.", "error", 5000)
        end
    else
        if wagonSpawned and isDeliveryStarted and isWagonDelivered then
            TriggerServerEvent('stx-wagondeliveries:server:cancelDelivery')
            Config.Notify_Client("Delivery", "Cart Delivered...", "success", 5000)
            ClearGpsMultiRoute(endcoords)
            if deliveryBlip then
                RemoveBlip(deliveryBlip)
                deliveryBlip = nil
            end
            endcoords = nil
            DeleteVehicle(wagonmodel)
            wagonSpawned = false
            isDeliveryStarted = false
            isWagonDelivered = false
            tempdata2 = nil
            tempamount = nil
        else
            Config.Notify_Client("Delivery", "Cart isn't delivered....", "error", 5000)
        end

    end

end)


-- Register command to cancel delivery
RegisterCommand(Config.CancelDelivery_Command, function()
    TriggerEvent("stx-wagondeliveries:client:cancelDelivery", true)
end)