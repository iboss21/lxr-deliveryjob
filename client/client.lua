local isDeliveryStarted = false
local isWagonDelivered = false
local wagonSpawned = false
local wagonmodel = nil
local endcoords = nil
local tempdata2 = nil
local tempamount = nil
local isCompleting = false

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

--- Function that returns job reward
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

---- Main Cart Spawn Function
local function spawn_cart_with_gps_mission(data1, data2)
    local cartHash = joaat(data2.wagonModel)
    local cargoHash = joaat(data2.cargo)
    local lightHash = joaat(data2.light)
    local cartcoords, cartheading = vector3(data1.cartSpawn.x, data1.cartSpawn.y, data1.cartSpawn.z) , data1.cartSpawn.w,
    RequestModel(cartHash, cargoHash, lightHash)
    while not HasModelLoaded(cartHash, cargoHash, lightHash) do
        RequestModel(cartHash, cargoHash, lightHash)
        Wait(0)
    end
    --- Cart Spawn Handling With Cargo and Light
    local cart = CreateVehicle(cartHash, cartcoords, cartheading, true, false)
    SetVehicleOnGroundProperly(cart)
    Wait(200)
    SetModelAsNoLongerNeeded(cartHash)
    Citizen.InvokeNative(0xD80FAF919A2E56EA, cart, cargoHash)
    Citizen.InvokeNative(0xC0F0417A90402742, cart, lightHash)
    --------------------------------------------------------------------------
    wagonmodel = cart
    wagonSpawned = true
    isDeliveryStarted = true
    endcoords = vector3(data2.deliveryLoc.x, data2.deliveryLoc.y, data2.deliveryLoc.z)
    --- GPS Natives 
    StartGpsMultiRoute(GetHashKey("COLOR_RED"), true, true)
    AddPointToGpsMultiRoute(endcoords)
    SetGpsMultiRouteRender(true)
    return true
end




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
                disabled = isDeliveryStarted, -- უკვე თუ დაწყებულია, აღარ აძლევს
                onSelect = function()
                    if isDeliveryStarted then
                        Config.Notify_Client("Delivery", "A delivery is already in progress.", "error", 3500)
                        return
                    end

                    -- ✅ IMPORTANT: we pass nil route to force random inside startDelivery
                    TriggerEvent("stx-wagondeliveries:client:startDelivery", deliverydata, nil)
                    lib.hideContext(true)
                end
            }
        },
    })

    lib.showContext('stx_wagonDeliveries_main_Menu')
end)



RegisterNetEvent("stx-wagondeliveries:client:startDelivery", function(MainLocationData, MainLocationDeliveryData)

    -- ✅ RANDOM MODE: choose route BEFORE calculating money / spawning
    if Config.RandomDelivery then
        local list = (MainLocationData and MainLocationData.deliveries) or nil
        if not list or #list == 0 then
            Config.Notify_Client("Delivery", "No deliveries configured for this location.", "error", 4000)
            return
        end

        -- if route wasn't provided, force random
        if not MainLocationDeliveryData then
            MainLocationDeliveryData = list[math.random(1, #list)]
        end
    end

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
            -- Server refused (already has an active delivery / config mismatch)
            Config.Notify_Client("Delivery", "You already have an active delivery or this route is invalid.", "error", 5000)
            TriggerEvent("stx-wagondeliveries:client:cancelDelivery", true)
            return
        end

        -- ✅ No destination info (fully hidden)
        Config.Notify_Client("Delivery", "Delivery started. Follow the route.", "info", 5000)

        CreateThread(function()
            local sleep = 750
            while true do
                if not wagonSpawned or not isDeliveryStarted or not DoesEntityExist(wagonmodel) or not endcoords then
                    break
                end

                local vehpos = GetEntityCoords(wagonmodel, true)
                local dist = #(vehpos - endcoords)

                if dist < 250.0 then
                    sleep = 0
                    DrawText3D(endcoords.x, endcoords.y, endcoords.z + 0.98, "DELIVERY POINT")

                    if dist < 3.0 and not isCompleting then
                        isCompleting = true
                        isWagonDelivered = true

                        local ok = lib.callback.await('stx-wagondeliveries:server:callback:completeDelivery', false)
                        if ok then
                            -- Despawn cart + reset mission locally
                            Config.Notify_Client("Delivery", "Delivery completed. Payment received.", "success", 5000)
                            ClearGpsMultiRoute(endcoords)
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
                            -- If server refused, keep mission active but stop spamming requests
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


RegisterNetEvent("stx-wagondeliveries:client:cancelDelivery", function(check)
    if check then
        if wagonSpawned and isDeliveryStarted then
            TriggerServerEvent('stx-wagondeliveries:server:cancelDelivery')
            Config.Notify_Client("Delivery", "Mission Cancelled", "error", 5000)
            ClearGpsMultiRoute(endcoords)
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


--- Command
RegisterCommand(Config.CancelDelivery_Command, function()
    TriggerEvent("stx-wagondeliveries:client:cancelDelivery", true)
end)