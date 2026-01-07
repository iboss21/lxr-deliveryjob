--[[
═══════════════════════════════════════════════════════════════════════════════
    The Land of Wolves - LXRCore Delivery System
    Interaction Handler
    
    Developer: iBoss
    Website: www.wolves.land
    
    This script handles:
    - Player interaction with delivery NPCs
    - Menu anti-spam protection
    - Support for multiple interaction methods (prompt/murphy_interact)
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Anti-spam tracking for menu interactions
local menuOpenAttempts = {}  -- Timestamps of recent menu open attempts
local menuCooldownUntil = 0  -- Timestamp when cooldown expires

-- Check if player is currently in cooldown
-- @return: true if in cooldown, false otherwise
local function isInCooldown()
    return GetGameTimer() < menuCooldownUntil
end

--[[
    Track Menu Open Attempt
    Monitors menu opening to detect spam behavior
    Implements a sliding window spam detection system
    @return: true if spam detected, false if OK
]]--
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

--[[
═══════════════════════════════════════════════════════════════════════════════
    NATIVE PROMPT INTERACTION SYSTEM
    Uses RedM's built-in prompt system for player interactions
═══════════════════════════════════════════════════════════════════════════════
]]--

if Config.Interact == "prompt" then
    local promptGroup = GetRandomIntInRange(0, 0x7FFFFFFF)
    local prompt
    local promptKey = 0xF3830D8E  -- 'J' key
    local labelText = "Check Deliveries"
    local promptRadius = 2.0

    -- Register prompt for delivery menu
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

    -- Main prompt loop
    CreateThread(function()
        prompt = registerPrompts()

        while true do
            Wait(0)

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local showPrompt = false
            local dataDelivery = nil

            -- Check if player is near any delivery NPC
            for _, loc in pairs(Config.Deliveries) do
                if #(coords - loc.npccoords.xyz) < promptRadius then
                    showPrompt = true
                    dataDelivery = loc
                    break
                end
            end

            -- Show prompt and handle interaction
            if showPrompt then
                UiPromptSetActiveGroupThisFrame(promptGroup)
                if UiPromptHasHoldModeCompleted(prompt) then
                    -- Check cooldown
                    if isInCooldown() then
                        local remainingSeconds = math.ceil((menuCooldownUntil - GetGameTimer()) / 1000)
                        Config.Notify_Client("Delivery", "Please wait " .. remainingSeconds .. " seconds before accessing the menu again.", "error", 3500)
                        Wait(1000)
                    else
                        -- Track this attempt for spam detection
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

--[[
═══════════════════════════════════════════════════════════════════════════════
    MURPHY INTERACTION SYSTEM
    Uses Murphy's Interaction script for 3D interactions
═══════════════════════════════════════════════════════════════════════════════
]]--

elseif Config.Interact == "murphy_interact" then
    CreateThread(function()
        -- Register interaction points for each delivery location
        for _, dataDelivery in pairs(Config.Deliveries) do
            exports.murphy_interact:AddInteraction({
                coords = dataDelivery.npccoords.xyz,
                distance = 3.0,      -- Detection distance
                interactDst = 2.0,   -- Interaction distance
                id = 'DeliveryID'.. _, 
                name = 'DeliveryJob'.. _,
                options = {
                    {
                        label = 'Check Deliveries',
                        action = function(entity, coords, args)
                            -- Check cooldown
                            if isInCooldown() then
                                    local remainingSeconds = math.ceil((menuCooldownUntil - GetGameTimer()) / 1000)
                                Config.Notify_Client("Delivery", "Please wait " .. remainingSeconds .. " seconds before accessing the menu again.", "error", 3500)
                            else
                                -- Track this attempt for spam detection
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
