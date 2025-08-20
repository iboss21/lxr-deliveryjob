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
                local label = CreateVarString(10, 'LITERAL_STRING', labelText)
                UiPromptSetActiveGroupThisFrame(promptGroup, label)
                if UiPromptHasHoldModeCompleted(prompt) then
                    TriggerEvent('stx-wagondeliveries:client:open_delivery_menu', dataDelivery)
                    Wait(1000) -- prevent spamming
                end
            end
        end
    end)
end