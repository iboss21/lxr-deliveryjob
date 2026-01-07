-- Anti-spam tracking for menu interactions
local menuOpenAttempts = {}
local menuCooldownUntil = 0

local function isInCooldown()
    return GetGameTimer() < menuCooldownUntil
end

local function trackMenuOpen()
    local now = GetGameTimer()
    local detectionWindowMs = Config.AntiSpam.detectionWindow * 1000
    
    -- Remove old attempts outside detection window
    local validAttempts = {}
    for _, timestamp in ipairs(menuOpenAttempts) do
        if now - timestamp < detectionWindowMs then
            table.insert(validAttempts, timestamp)
        end
    end
    menuOpenAttempts = validAttempts
    
    -- Add current attempt
    table.insert(menuOpenAttempts, now)
    
    -- Check if spam threshold exceeded
    if #menuOpenAttempts > Config.AntiSpam.maxMenuOpens then
        menuCooldownUntil = now + (Config.AntiSpam.cooldownDuration * 1000)
        menuOpenAttempts = {} -- Reset counter
        return true -- Spam detected
    end
    
    return false -- No spam
end

if Config.Interact == "prompt" then
    local promptGroup = GetRandomIntInRange(0, 0x7FFFFFFF)
    local prompt
    local promptKey = 0xF3830D8E  -- 'J' key
    local labelText = "Check Deliveries"
    local promptRadius = 2.0

    local function registerPrompts()
        local newPrompt = PromptRegisterBegin()
        PromptSetControlAction(newPrompt, promptKey)
        PromptSetText(newPrompt, CreateVarString(10, 'LITERAL_STRING', labelText))
        PromptSetEnabled(newPrompt, true)
        PromptSetVisible(newPrompt, true)
        PromptSetHoldMode(newPrompt, true)
        PromptSetGroup(newPrompt, promptGroup)
        PromptRegisterEnd(newPrompt)
        return newPrompt
    end

    CreateThread(function()
        prompt = registerPrompts()

        while true do
            Wait(0)

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local showPrompt = false
            local dataDelivery = nil

            for _, loc in pairs(Config.Deliveries) do
                if #(coords - loc.npccoords.xyz) < promptRadius then
                    showPrompt = true
                    dataDelivery = loc
                    break
                end
            end

            if showPrompt then
                UiPromptSetActiveGroupThisFrame(promptGroup)
                if UiPromptHasHoldModeCompleted(prompt) then
                    if isInCooldown() then
                        local remainingSeconds = math.ceil((menuCooldownUntil - GetGameTimer()) / 1000)
                        Config.Notify_Client("Delivery", "Please wait " .. remainingSeconds .. " seconds before accessing the menu again.", "error", 3500)
                        Wait(1000)
                    else
                        if trackMenuOpen() then
                            Config.Notify_Client("Delivery", "Spam detected! Menu access blocked for " .. Config.AntiSpam.cooldownDuration .. " seconds.", "error", 5000)
                            Wait(1000)
                        else
                            TriggerEvent('stx-wagondeliveries:client:open_delivery_menu', dataDelivery)
                            Wait(1000) -- prevent rapid re-opening
                        end
                    end
                end
            end
        end
    end)
elseif Config.Interact == "murphy_interact" then 
    CreateThread(function()
            for _, dataDelivery in pairs(Config.Deliveries) do 
                exports.murphy_interact:AddInteraction({
                    coords = dataDelivery.npccoords.xyz,
                    distance = 3.0, -- optional
                    interactDst = 2.0, -- optional
                    id = 'DeliveryID'.. _, -- needed for removing interactions
                    name = 'DeliveryJob'.. _, -- optional
                    options = {
                         {
                            label = 'Check Deliveries',
                            action = function(entity, coords, args)
                                if isInCooldown() then
                                    local remainingSeconds = math.ceil((menuCooldownUntil - GetGameTimer()) / 1000)
                                    Config.Notify_Client("Delivery", "Please wait " .. remainingSeconds .. " seconds before accessing the menu again.", "error", 3500)
                                else
                                    if trackMenuOpen() then
                                        Config.Notify_Client("Delivery", "Spam detected! Menu access blocked for " .. Config.AntiSpam.cooldownDuration .. " seconds.", "error", 5000)
                                    else
                                        TriggerEvent('stx-wagondeliveries:client:open_delivery_menu', dataDelivery)
                                    end
                                end
                            end,
                        },
                    }
                })
            end
    end)
end
