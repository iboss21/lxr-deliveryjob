--[[
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 Framework Adapter Layer - Multi-Framework Support Bridge
═══════════════════════════════════════════════════════════════════════════════
 
 This adapter provides unified API for multiple RedM frameworks, allowing the
 delivery system to work seamlessly across LXR-Core, RSG-Core, and VORP without
 changing core logic.
 
════════════════════════════════ Server Information ════════════════════════════
 Server:     The Land of Wolves 🐺 | www.wolves.land
 Community:  Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
 Discord:    https://discord.gg/CrKcWdfd3A
 Developer:  iBoss21 / The Lux Empire
 GitHub:     https://github.com/iBoss21
════════════════════════════════════════════════════════════════════════════════
 Version:    2.1.0
 Performance: Optimized for RedM (60+ FPS)
 Tags:       Framework Bridge, Multi-Core Support, Delivery System
════════════════════════════════════════════════════════════════════════════════
 Framework Support:
 ✓ LXR-Core (Primary)   - The Land of Wolves custom framework
 ✓ RSG-Core (Primary)   - RedM Script Group core framework
 ✓ VORP Core (Supported) - Vintage Outlaw Roleplay framework
════════════════════════════════════════════════════════════════════════════════
 Credits:
 - Original Delivery System: RexShack (rsg-delivery)
 - Base Concept: Muhammad Abdullah Shurjeel
 - Framework Adapter & Enhancement: iBoss21
════════════════════════════════════════════════════════════════════════════════
 Copyright (c) 2024-2026 The Lux Empire / iBoss21
 Licensed under: MIT - wolves.land
═══════════════════════════════════════════════════════════════════════════════
]]--

Framework = {}
Framework.Name = nil
Framework.Object = nil

-- ════════════════════════════════════════════════════════════════════════════
-- █████ FRAMEWORK DETECTION & INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════

--- Auto-detect which framework is running
--- Priority: LXR-Core > RSG-Core > VORP > Manual Config
--- @return string|nil Framework name or nil if none detected
local function DetectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end
    
    -- Try LXR-Core first (priority framework)
    if GetResourceState(Config.FrameworkSettings.LXR.resourceName) == 'started' then
        return 'LXR'
    end
    
    -- Try RSG-Core second (co-primary framework)
    if GetResourceState(Config.FrameworkSettings.RSG.resourceName) == 'started' then
        return 'RSG'
    end
    
    -- Try VORP (supported legacy framework)
    if GetResourceState(Config.FrameworkSettings.VORP.resourceName) == 'started' then
        return 'VORP'
    end
    
    return nil
end

--- Initialize framework bridge based on detection
--- Sets up Framework.Object with the appropriate core object
Citizen.CreateThread(function()
    Framework.Name = DetectFramework()
    
    if not Framework.Name then
        print("^1[LXR-Delivery] ^7WARNING: No supported framework detected!")
        print("^1[LXR-Delivery] ^7Supported frameworks: LXR-Core, RSG-Core, VORP")
        print("^1[LXR-Delivery] ^7Please ensure one framework is started before this resource.")
        return
    end
    
    -- Initialize framework object based on detected framework
    if Framework.Name == 'LXR' then
        -- LXR-Core initialization
        Framework.Object = exports[Config.FrameworkSettings.LXR.resourceName]:GetCoreObject()
        print("^2[LXR-Delivery] ^7Framework: ^5LXR-Core ^7initialized successfully!")
        
    elseif Framework.Name == 'RSG' then
        -- RSG-Core initialization
        Framework.Object = exports[Config.FrameworkSettings.RSG.resourceName]:GetCoreObject()
        print("^2[LXR-Delivery] ^7Framework: ^5RSG-Core ^7initialized successfully!")
        
    elseif Framework.Name == 'VORP' then
        -- VORP initialization
        Framework.Object = exports[Config.FrameworkSettings.VORP.coreExport]:GetCore()
        print("^2[LXR-Delivery] ^7Framework: ^5VORP Core ^7initialized successfully!")
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
-- █████ CLIENT-SIDE UNIFIED API
-- ════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() == 0 then -- Client side only
    
    --- Send notification to player
    --- @param title string Notification title
    --- @param message string Notification message
    --- @param type string Notification type (success, error, info, warning)
    --- @param duration number Duration in milliseconds
    function Framework.Notify(title, message, type, duration)
        Config.Notify_Client(title, message, type, duration)
    end
    
    --- Get player's current job information
    --- @return table Job data {name, grade, label}
    function Framework.GetPlayerJob()
        if not Framework.Object then return {name = 'unemployed', grade = 0, label = 'Unemployed'} end
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            local PlayerData = Framework.Object.Functions.GetPlayerData()
            return PlayerData.job or {name = 'unemployed', grade = 0, label = 'Unemployed'}
            
        elseif Framework.Name == 'VORP' then
            local character = LocalPlayer.state.Character
            if character then
                return {
                    name = character.job or 'unemployed',
                    grade = character.jobGrade or 0,
                    label = character.jobLabel or 'Unemployed'
                }
            end
        end
        
        return {name = 'unemployed', grade = 0, label = 'Unemployed'}
    end
    
    --- Check if player has specific item
    --- @param item string Item name
    --- @param amount number Required amount
    --- @return boolean Has item
    function Framework.HasItem(item, amount)
        if not Framework.Object then return false end
        
        amount = amount or 1
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            -- Use framework callback to check inventory
            local hasItem = false
            Framework.Object.Functions.TriggerCallback('lxr-delivery:server:hasItem', function(result)
                hasItem = result
            end, item, amount)
            
            -- Wait for callback
            while hasItem == false do
                Wait(10)
            end
            
            return hasItem
            
        elseif Framework.Name == 'VORP' then
            -- VORP inventory check would go here
            return true -- Placeholder for VORP
        end
        
        return false
    end
    
end

-- ════════════════════════════════════════════════════════════════════════════
-- █████ SERVER-SIDE UNIFIED API
-- ════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() == 1 then -- Server side only
    
    --- Send notification to specific player
    --- @param source number Player server ID
    --- @param title string Notification title
    --- @param message string Notification message
    --- @param type string Notification type (success, error, info, warning)
    --- @param duration number Duration in milliseconds
    function Framework.Notify(source, title, message, type, duration)
        Config.Notify_Server(source, title, message, type, duration)
    end
    
    --- Get player data from framework
    --- @param source number Player server ID
    --- @return table|nil Player data object
    function Framework.GetPlayer(source)
        if not Framework.Object then return nil end
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            return Framework.Object.Functions.GetPlayer(source)
            
        elseif Framework.Name == 'VORP' then
            return Framework.Object.getUser(source)
        end
        
        return nil
    end
    
    --- Add money to player account
    --- @param source number Player server ID
    --- @param amount number Amount to add
    --- @param account string Account type (cash, bank, gold)
    --- @param reason string Optional reason for logs
    --- @return boolean Success
    function Framework.AddMoney(source, amount, account, reason)
        if not Framework.Object then return false end
        
        local Player = Framework.GetPlayer(source)
        if not Player then return false end
        
        account = account or Config.Reward_Money_Account
        reason = reason or "Delivery Job Reward"
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            Player.Functions.AddMoney(account, amount, reason)
            return true
            
        elseif Framework.Name == 'VORP' then
            local Character = Player.getUsedCharacter
            if account == "cash" or account == 0 then
                Character.addCurrency(0, amount) -- VORP: 0 = cash
            elseif account == "gold" or account == 1 then
                Character.addCurrency(1, amount) -- VORP: 1 = gold
            end
            return true
        end
        
        return false
    end
    
    --- Remove money from player account
    --- @param source number Player server ID
    --- @param amount number Amount to remove
    --- @param account string Account type (cash, bank, gold)
    --- @param reason string Optional reason for logs
    --- @return boolean Success
    function Framework.RemoveMoney(source, amount, account, reason)
        if not Framework.Object then return false end
        
        local Player = Framework.GetPlayer(source)
        if not Player then return false end
        
        account = account or Config.Reward_Money_Account
        reason = reason or "Delivery Job Cost"
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            Player.Functions.RemoveMoney(account, amount, reason)
            return true
            
        elseif Framework.Name == 'VORP' then
            local Character = Player.getUsedCharacter
            if account == "cash" or account == 0 then
                Character.removeCurrency(0, amount)
            elseif account == "gold" or account == 1 then
                Character.removeCurrency(1, amount)
            end
            return true
        end
        
        return false
    end
    
    --- Add item to player inventory
    --- @param source number Player server ID
    --- @param item string Item name
    --- @param amount number Amount to add
    --- @param metadata table Optional item metadata
    --- @return boolean Success
    function Framework.AddItem(source, item, amount, metadata)
        if not Framework.Object then return false end
        
        local Player = Framework.GetPlayer(source)
        if not Player then return false end
        
        amount = amount or 1
        metadata = metadata or {}
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            return Player.Functions.AddItem(item, amount, false, metadata)
            
        elseif Framework.Name == 'VORP' then
            local Character = Player.getUsedCharacter
            exports.vorp_inventory:addItem(source, item, amount)
            return true
        end
        
        return false
    end
    
    --- Remove item from player inventory
    --- @param source number Player server ID
    --- @param item string Item name
    --- @param amount number Amount to remove
    --- @return boolean Success
    function Framework.RemoveItem(source, item, amount)
        if not Framework.Object then return false end
        
        local Player = Framework.GetPlayer(source)
        if not Player then return false end
        
        amount = amount or 1
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            return Player.Functions.RemoveItem(item, amount)
            
        elseif Framework.Name == 'VORP' then
            exports.vorp_inventory:subItem(source, item, amount)
            return true
        end
        
        return false
    end
    
    --- Get player's current job
    --- @param source number Player server ID
    --- @return table Job data {name, grade, label}
    function Framework.GetPlayerJob(source)
        if not Framework.Object then return {name = 'unemployed', grade = 0} end
        
        local Player = Framework.GetPlayer(source)
        if not Player then return {name = 'unemployed', grade = 0} end
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            local PlayerData = Player.PlayerData
            return PlayerData.job or {name = 'unemployed', grade = 0, label = 'Unemployed'}
            
        elseif Framework.Name == 'VORP' then
            local Character = Player.getUsedCharacter
            return {
                name = Character.job or 'unemployed',
                grade = Character.jobGrade or 0,
                label = Character.jobLabel or 'Unemployed'
            }
        end
        
        return {name = 'unemployed', grade = 0, label = 'Unemployed'}
    end
    
    --- Check if player has specific item
    --- @param source number Player server ID
    --- @param item string Item name
    --- @param amount number Required amount
    --- @return boolean Has item
    function Framework.HasItem(source, item, amount)
        if not Framework.Object then return false end
        
        local Player = Framework.GetPlayer(source)
        if not Player then return false end
        
        amount = amount or 1
        
        if Framework.Name == 'LXR' or Framework.Name == 'RSG' then
            local playerItem = Player.Functions.GetItemByName(item)
            if playerItem then
                return playerItem.amount >= amount
            end
            return false
            
        elseif Framework.Name == 'VORP' then
            local itemCount = exports.vorp_inventory:getItemCount(source, nil, item)
            return itemCount >= amount
        end
        
        return false
    end
    
end

-- ════════════════════════════════════════════════════════════════════════════
-- █████ END OF FRAMEWORK ADAPTER
-- ════════════════════════════════════════════════════════════════════════════

print([[
^5════════════════════════════════════════════════════════════════════════════
^7  🐺 ^5Framework Adapter Loaded
^7  Multi-Framework Bridge: ^2Ready
^7  Supported: ^5LXR-Core^7, ^5RSG-Core^7, ^5VORP Core
^5════════════════════════════════════════════════════════════════════════════
^7]])
