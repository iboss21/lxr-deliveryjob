--[[
═══════════════════════════════════════════════════════════════════════════════
    The Land of Wolves - LXRCore Delivery System
    Configuration File
    
    Developer: iBoss
    Website: www.wolves.land
    Discord: discord.gg/fPjSxEHFMt
    
    Original Creator: Muhammad Abdullah Shurjeel (stx-wagondeliveries)
    Based on: RexShack's rsg-delivery
═══════════════════════════════════════════════════════════════════════════════
]]--

Config = {}

--[[
═══════════════════════════════════════════════════════════════════════════════
    GENERAL SETTINGS
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Enable debug mode for console logging (useful for troubleshooting)
Config.Debug = false

-- Framework Selection: Choose your server framework
-- Options: "RSG" (RSGCore) or "VORP" (VORP Framework)
Config.Core = "RSG"

-- Interaction System: Choose how players interact with delivery NPCs
-- Options: "prompt" (native RedM prompts) | "murphy_interact" (Murphy Interaction) | "target" (WIP - not yet implemented)
Config.Interact = "murphy_interact"

--[[
═══════════════════════════════════════════════════════════════════════════════
    NPC SETTINGS
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Distance at which NPCs will spawn around the player (in game units)
Config.DistanceSpawn = 30.0

-- Enable smooth fade-in effect when NPCs spawn/despawn
Config.FadeIn = true

--[[
═══════════════════════════════════════════════════════════════════════════════
    BLIP (MAP MARKER) SETTINGS
═══════════════════════════════════════════════════════════════════════════════
]]--

Config.Blip = {
    -- Name displayed on the map for delivery locations
    -- Note: Kept concise to prevent UI truncation
    blipName = 'Wolves Hauling',
    
    -- Sprite/icon used for the blip on the map
    blipSprite = 'blip_ambient_coach',
    
    -- Size of the blip icon (0.1 = small, 1.0 = large)
    blipScale = 0.2
}

--[[
═══════════════════════════════════════════════════════════════════════════════
    NOTIFICATION SYSTEM
    
    This section handles all in-game notifications to players.
    Uses BLN_NOTIFY system for consistent messaging across the server.
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Internal helper function to convert notification types to BLN templates
local function _blnTemplateFromType(notitype)
    notitype = (notitype or "info"):lower()
    if notitype == "success" then return "SUCCESS" end
    if notitype == "error" then return "ERROR" end
    if notitype == "warning" then return "INFO" end
    return "INFO"
end

-- Client-side notification function
-- @param title: Notification title
-- @param text: Notification message content
-- @param notitype: Type of notification ("success", "error", "warning", "info")
-- @param duration: How long notification displays (in milliseconds)
Config.Notify_Client = function(title, text, notitype, duration)
    TriggerEvent('bln_notify:send', {
        title = title or '',
        description = text or '',
        duration = duration or 3500,
        placement = 'top-right',
        type = notitype or 'info',
    }, _blnTemplateFromType(notitype))
end

-- Server-side notification function (sends to specific player)
-- @param id: Player server ID to send notification to
-- @param title: Notification title
-- @param text: Notification message content
-- @param notitype: Type of notification ("success", "error", "warning", "info")
-- @param duration: How long notification displays (in milliseconds)
Config.Notify_Server = function(id, title, text, notitype, duration)
    TriggerClientEvent('bln_notify:send', id, {
        title = title or '',
        description = text or '',
        duration = duration or 3500,
        placement = 'top-right',
        type = notitype or 'info',
    }, _blnTemplateFromType(notitype))
end

--[[
═══════════════════════════════════════════════════════════════════════════════
    DELIVERY SYSTEM CONFIGURATION
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Account type for money rewards
-- RSG options: "cash", "bank"
-- VORP options: 0 (cash), 1 (gold)
Config.Reward_Money_Account = "cash"

-- Command players can use to cancel active deliveries
Config.CancelDelivery_Command = "canceldelivery"

-- Show reward amount in the delivery selection menu
-- Set to false to hide payment amounts from players
Config.Show_Reward_Money_inMenu = false

--[[
═══════════════════════════════════════════════════════════════════════════════
    RANDOM DELIVERY MODE
    
    When enabled, destinations are randomly assigned instead of player choice.
    This creates more variety and prevents players from always choosing the 
    highest-paying routes.
═══════════════════════════════════════════════════════════════════════════════
]]--

-- Enable random destination assignment (players cannot choose)
Config.RandomDelivery = true

-- Hide destination names in menus and notifications
Config.RandomDelivery_HideDestinationText = true

-- Hide reward amount previews before delivery completion
Config.RandomDelivery_HideRewardPreview = true

--[[
═══════════════════════════════════════════════════════════════════════════════
    ANTI-SPAM & ANTI-EXPLOIT SETTINGS
    
    These settings prevent players from abusing the delivery system through:
    - Menu spam attacks
    - Rapid delivery completion exploits
    - Instant teleport/completion cheats
    - Server load from excessive requests
═══════════════════════════════════════════════════════════════════════════════
]]--

Config.AntiSpam = {
    -- Maximum number of times a player can open the delivery menu within the detection window
    -- If exceeded, player is put on cooldown
    maxMenuOpens = 3,
    
    -- Time window (in seconds) to track menu open attempts
    -- Example: 3 menu opens within 10 seconds = spam detected
    detectionWindow = 10,
    
    -- Cooldown duration (in seconds) after spam is detected
    -- Player cannot open menu again until cooldown expires
    cooldownDuration = 60,
    
    -- Server-side rate limit for starting deliveries (seconds between attempts)
    -- Prevents rapid-fire delivery starts that could exploit the system
    serverRateLimit = 5,
    
    -- Minimum time (in seconds) a delivery must take to be valid
    -- Prevents instant completion exploits (teleporting to destination)
    -- Adjust based on your map size and typical delivery times
    minDeliveryDuration = 10,
}

--[[
═══════════════════════════════════════════════════════════════════════════════
    DELIVERY LOCATIONS & ROUTES CONFIGURATION
    
    This is where you define all delivery locations, NPCs, and routes.
    
    STRUCTURE:
    - Each main location has its own NPC and cart spawn point
    - Each location can have multiple delivery routes to other towns
    - Rewards can be based on distance OR fixed prices
    - Item rewards can be given with optional chance percentage
    
    REWARD SYSTEM EXPLAINED:
    
    priceByDistance: 
        - activation: true/false (enable distance-based rewards)
        - multiplier: Payment per 100 units of distance
        - Example: 1000 units @ 0.01 multiplier = $10
    
    priceByConfig:
        - activation: true/false (enable fixed price rewards)
        - price: Fixed amount paid for completing delivery
    
    itemreward:
        - activation: true/false (enable item rewards)
        - itemname: Item to give (must exist in your framework)
        - itemamount: Number of items to give (can use math.random for variety)
        - chance: Percentage chance (1-100), or nil for guaranteed reward
        
    NOTE: Only ONE price method should be active at a time (distance OR config)
═══════════════════════════════════════════════════════════════════════════════
]]--

Config.Deliveries = {
    --[[
        VALENTINE DELIVERY HUB
        Main delivery location in Valentine with routes to multiple towns
    ]]--
    {
        -- Display name for this delivery hub
        label = "Valentine Deliveries",
        
        -- NPC model that players interact with
        npcmodel = "MP_U_M_M_TRADER_01",
        
        -- NPC spawn coordinates (x, y, z, heading)
        npccoords = vector4(-340.5837, 816.3152, 116.9300, 136.7859),
        
        -- Where the delivery cart/wagon spawns
        cartSpawn = vector4(-347.9996, 815.5305, 116.7226, 168.6349),
        
        -- Available delivery routes from this location
        deliveries = {
            {
                -- Route display name
                label = "Blackwater Delivery",
                
                -- Route description
                description = "From Valentine to Blackwater",
                
                -- Reward configuration
                reward = {
                    -- Distance-based payment (recommended for realistic economy)
                    priceByDistance = {
                        activation = true,  -- Enable distance-based payment
                        multiplier = 0.0,   -- $ per 100 units (0.0 = disabled in favor of item rewards)
                    },
                    -- Fixed price payment (alternative to distance-based)
                    priceByConfig = {
                        activation = false, -- Disabled (using distance or items instead)
                        price = 1.0,
                    },
                    -- Item reward (alternative or additional to money)
                    itemreward = {
                        activation = true,           -- Enable item rewards
                        itemname = "dollar",         -- Item to give (must exist in your items config)
                        itemamount = math.random(7, 11), -- Random amount between 7-11
                        chance = nil,                -- nil = always give, number = % chance
                    },
                },
                
                -- Cart/wagon model to spawn
                wagonModel = "cart01",
                
                -- Cargo prop attached to wagon
                cargo = "pg_teamster_cart01_breakables",
                
                -- Light upgrade prop attached to wagon
                light = "pg_teamster_cart01_lightupgrade3",
                
                -- Delivery destination coordinates (where player must deliver)
                deliveryLoc = vector3(-750.20, -1206.24, 43.33),
            },
            {
                label = "Strawberry Delivery",
                description = "From Valentine to Strawberry",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(5, 8),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-1791.80, -429.82, 155.54),
            },
            {
                label = "Mcfarlands Ranch Delivery",
                description = "From Valentine to Mcfarlands Ranch",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(12, 18),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-2365.02, -2371.00, 62.24),
            },
            {
                label = "Tumbleweed Delivery",
                description = "From Valentine to Tumbleweed",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(24, 33),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-5531.12, -2939.58, -1.80),
            },
            {
                label = "Annesburg Delivery",
                description = "From Valentine to Annesburg",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(17, 21),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(3017.0349, 1438.4769, 46.421833),
            },
            {
                label = "SaintDenis Delivery",
                description = "From Valentine to SaintDenis",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(17, 21),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(2899.98, -1161.30, 45.90),
            },
        },
    },
    {
        label = "Blackwater Deliveries",
        npcmodel = "MP_U_M_M_TRADER_01",
        npccoords = vector4(-743.7046, -1218.822, 43.29129, 94.302909),
        cartSpawn = vector4(-757.1296, -1225.244, 43.54446, 0.8211954),
        deliveries = {
            {
                label = "Valentine Delivery",
                description = "From Blackwater to Valentine",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(8, 11),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-345.08, 821.49, 117.00),
            },
            {
                label = "Strawberry Delivery",
                description = "From Blackwater to Strawberry",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(5, 8),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-1791.80, -429.82, 155.54),
            },
            {
                label = "Mcfarlands Ranch Delivery",
                description = "From Blackwater to Mcfarlands Ranch",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(8, 12),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-2365.02, -2371.00, 62.24),
            },
            {
                label = "Tumbleweed Delivery",
                description = "From Blackwater to Tumbleweed",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(25, 31),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-5531.12, -2939.58, -1.80),
            },
            {
                label = "Annesburg Delivery",
                description = "From Blackwater to Annesburg",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(23, 31),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(3017.0349, 1438.4769, 46.421833),
            },
            {
                label = "SaintDenis Delivery",
                description = "From Blackwater to SaintDenis",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(16, 22),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(2899.98, -1161.30, 45.90),
            },
        },
    },
    {
        label = "Strawberry Deliveries",
        npcmodel = "MP_U_M_M_TRADER_01",
        npccoords = vector4(-1798.899, -425.6275, 156.37739, 352.46316),
        cartSpawn = vector4(-1788.618, -439.5259, 155.18444, 80.844512),
        deliveries = {
            {
                label = "Blackwater Delivery",
                description = "From Strawberry to Blackwater",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(7, 10),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-747.65, -1209.74, 43.36),
            },
            {
                label = "Valentine Delivery",
                description = "From Strawberry to Valentine",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(7, 11),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-345.08, 821.49, 117.00),
            },
            {
                label = "Mcfarlands Ranch Delivery",
                description = "From Strawberry to Mcfarlands Ranch",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(8, 12),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-2365.02, -2371.00, 62.24),
            },
            {
                label = "Tumbleweed Delivery",
                description = "From Strawberry to Tumbleweed",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(24, 33),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-5531.12, -2939.58, -1.80),
            },
            {
                label = "Annesburg Delivery",
                description = "From Strawberry to Annesburg",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(26, 33),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(3017.0349, 1438.4769, 46.421833),
            },
            {
                label = "SaintDenis Delivery",
                description = "From Strawberry to SaintDenis",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(21, 25),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(2899.98, -1161.30, 45.90),
            },
        },
    },
    {
        label = "Mcfarlands Deliveries",
        npcmodel = "MP_U_M_M_TRADER_01",
        npccoords = vector4(-2357.585, -2367.583, 62.18066, 168.52516),
        cartSpawn = vector4(-2352.572, -2398.797, 62.061191, 175.71217),
        deliveries = {
            {
                label = "Blackwater Delivery",
                description = "From Mcfarlands Ranch to Blackwater",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(7, 11),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-747.65, -1209.74, 43.36),
            },
            {
                label = "Strawberry Delivery",
                description = "From Mcfarlands Ranch to Strawberry",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(9, 12),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-1791.80, -429.82, 155.54),
            },
            {
                label = "Valentine Delivery",
                description = "From Mcfarlands Ranch to Valentine",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(15, 19),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-345.08, 821.49, 117.00),
            },
            {
                label = "Tumbleweed Delivery",
                description = "From Mcfarlands Ranch to Tumbleweed",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(9, 13),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-5531.12, -2939.58, -1.80),
            },
            {
                label = "Annesburg Delivery",
                description = "From Mcfarlands Ranch to Annesburg",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(25, 31),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(3017.0349, 1438.4769, 46.421833),
            },
            {
                label = "SaintDenis Delivery",
                description = "From Mcfarlands Ranch to SaintDenis",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(24, 25),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(2899.98, -1161.30, 45.90),
            },
        },
    },
    {
        label = "Tumbleweed Deliveries",
        npcmodel = "A_M_M_SDDockForeman_01",
        npccoords = vector4(-5529.143, -2932.52, -1.95342, 212.60365),
        cartSpawn = vector4(-5523.004, -2936.102, -2.007142, 255.0812),
        deliveries = {
            {
                label = "Blackwater Delivery",
                description = "From Tumbleweed to Blackwater",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(19, 27),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-747.65, -1209.74, 43.36),
            },
            {
                label = "Strawberry Delivery",
                description = "From Tumbleweed to Strawberry",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(20, 27),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-1791.80, -429.82, 155.54),
            },
            {
                label = "Mcfarlands Ranch Delivery",
                description = "From Tumbleweed to Mcfarlands Ranch",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(7, 11),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-2365.02, -2371.00, 62.24),
            },
            {
                label = "Valentine Delivery",
                description = "From Tumbleweed to Valentine",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(24, 32),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-345.08, 821.49, 117.00),
            },
            {
                label = "Annesburg Delivery",
                description = "From Tumbleweed to Annesburg",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(35, 45),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(3017.0349, 1438.4769, 46.421833),
            },
            {
                label = "SaintDenis Delivery",
                description = "From Tumbleweed to SaintDenis",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(28, 37),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(2899.98, -1161.30, 45.90),
            },
        },
    },
    {
        label = "Annesburg Deliveries",
        npcmodel = "MP_U_M_M_TRADER_01",
        npccoords = vector4(3022.6753, 1441.2214, 46.9519, 73.7268),
        cartSpawn = vector4(3009.5029, 1450.3727, 46.9537, 73.7677),
        deliveries = {
            {
                label = "Blackwater Delivery",
                description = "From Annesburg to Blackwater",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(17, 24),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-747.65, -1209.74, 43.36),
            },
            {
                label = "Strawberry Delivery",
                description = "From Annesburg to Strawberry",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(23, 31),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-1791.80, -429.82, 155.54),
            },
            {
                label = "Mcfarlands Ranch Delivery",
                description = "From Annesburg to Mcfarlands Ranch",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(26, 30),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-2365.02, -2371.00, 62.24),
            },
            {
                label = "Tumbleweed Delivery",
                description = "From Annesburg to Tumbleweed",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(40, 43),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-5531.12, -2939.58, -1.80),
            },
            {
                label = "Valentine Delivery",
                description = "From Annesburg to Valentine",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(13, 19),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-345.08, 821.49, 117.00),
            },
            {
                label = "SaintDenis Delivery",
                description = "From Annesburg to SaintDenis",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(11, 16),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(2899.98, -1161.30, 45.90),
            },
        },
    },
    {
        label = "SaintDenis Deliveries",
        npcmodel = "A_M_M_SDDockForeman_01",
        npccoords = vector4(2904.1989, -1169.292, 46.112228, 96.722068),
        cartSpawn = vector4(2898.8957, -1169.942, 46.093143, 100.06992),
        deliveries = {
            {
                label = "Blackwater Delivery",
                description = "From SaintDenis to Blackwater",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(14, 19),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-747.65, -1209.74, 43.36),
            },
            {
                label = "Strawberry Delivery",
                description = "From SaintDenis to Strawberry",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(16, 24),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-1791.80, -429.82, 155.54),
            },
            {
                label = "Mcfarlands Ranch Delivery",
                description = "From SaintDenis to Mcfarlands Ranch",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(18, 26),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-2365.02, -2371.00, 62.24),
            },
            {
                label = "Tumbleweed Delivery",
                description = "From SaintDenis to Tumbleweed",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(32, 42),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-5531.12, -2939.58, -1.80),
            },
            {
                label = "Annesburg Delivery",
                description = "From SaintDenis to Annesburg",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(13, 15),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(3017.0349, 1438.4769, 46.421833),
            },
            {
                label = "Valentine Delivery",
                description = "From SaintDenis to Valentine",
                reward = {
                    priceByDistance = {
                        activation = true,
                        multiplier = 0.0,
                    },
                    priceByConfig = {
                        activation = false,
                        price = 1.0,
                    },
                    itemreward = {
                        activation = true,
                        itemname = "dollar",
                        itemamount = math.random(15, 21),
                        chance = nil,
                    },
                },
                wagonModel = "cart01",
                cargo = "pg_teamster_cart01_breakables",
                light = "pg_teamster_cart01_lightupgrade3",
                deliveryLoc = vector3(-345.08, 821.49, 117.00),
            },
        },
    },
}






