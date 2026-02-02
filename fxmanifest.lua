--[[
═══════════════════════════════════════════════════════════════════════════════
 ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║  ██║██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ███████║██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██╔══██║██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ██║  ██║██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════
 🐺 Delivery Job System - FiveM/RedM Resource Manifest
═══════════════════════════════════════════════════════════════════════════════
 
 Resource manifest for the LXR Delivery Job system. Defines metadata, scripts,
 dependencies, and runtime configuration for the wagon/cart delivery gameplay.
 
════════════════════════════════ Server Information ════════════════════════════
 Server:     The Land of Wolves 🐺 | www.wolves.land
 Community:  Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
 Discord:    https://discord.gg/CrKcWdfd3A
 Developer:  iBoss21 / The Lux Empire
 GitHub:     https://github.com/iBoss21
════════════════════════════════════════════════════════════════════════════════
 Version:    2.1.0
 Framework:  Multi-Framework (LXR-Core, RSG-Core, VORP)
════════════════════════════════════════════════════════════════════════════════
 Copyright (c) 2024-2026 The Lux Empire / iBoss21
═══════════════════════════════════════════════════════════════════════════════
]]--

-- ════════════════════════════════════════════════════════════════════════════
-- █████ FX VERSION & GAME SPECIFICATION
-- ════════════════════════════════════════════════════════════════════════════

fx_version 'cerulean'
game 'rdr3'

-- RedM prerelease acknowledgment (required for RedM resources)
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources WILL become incompatible once RedM ships.'

-- ════════════════════════════════════════════════════════════════════════════
-- █████ RESOURCE METADATA
-- ════════════════════════════════════════════════════════════════════════════

name 'LXR Delivery Job System'
author 'iBoss21 / The Lux Empire (The Land of Wolves)'
description 'Multi-framework wagon/cart delivery job system for RedM with anti-exploit protection, random assignments, and configurable rewards. Supports LXR-Core, RSG-Core, and VORP frameworks.'
version '2.1.0'
repository 'https://github.com/iBoss21/lxr-deliveryjob'

-- ════════════════════════════════════════════════════════════════════════════
-- █████ LUA VERSION
-- ════════════════════════════════════════════════════════════════════════════

lua54 'yes'

-- ════════════════════════════════════════════════════════════════════════════
-- █████ DEPENDENCIES (OPTIONAL RUNTIME DETECTION)
-- ════════════════════════════════════════════════════════════════════════════

--[[
    Framework dependencies are handled at runtime via auto-detection.
    The system checks for LXR-Core, RSG-Core, and VORP Core in priority order.
    
    Hard dependencies are avoided to allow flexibility, but ensure at least
    one supported framework is running before starting this resource.
]]--

dependencies {
    '/onesync',  -- Required for synchronized entities
}

-- Optional dependencies (enhance functionality if present)
-- Uncomment if you want to enforce these dependencies
-- dependency 'ox_lib'           -- UI library (menu system)
-- dependency 'murphy_interact'  -- Alternative interaction system

-- ════════════════════════════════════════════════════════════════════════════
-- █████ SHARED SCRIPTS (CLIENT + SERVER)
-- ════════════════════════════════════════════════════════════════════════════

--[[
    Shared scripts are loaded on both client and server.
    Load order matters: config must be loaded before framework adapter.
]]--

shared_scripts {
    '@ox_lib/init.lua',        -- OX Library initialization (if present)
    'shared/config.lua',       -- Main configuration file
    'shared/framework.lua',    -- Multi-framework adapter layer
}

-- ════════════════════════════════════════════════════════════════════════════
-- █████ CLIENT SCRIPTS (PLAYER-SIDE)
-- ════════════════════════════════════════════════════════════════════════════

--[[
    Client scripts handle:
    - Player interactions with delivery NPCs
    - Wagon spawning and GPS routing
    - UI/menu systems
    - Delivery completion detection
    - NPC spawning and management
]]--

client_scripts {
    'client/client.lua',       -- Main client logic (delivery flow)
    'client/interaction.lua',  -- Interaction system (prompt/murphy_interact)
    'client/npcs.lua',         -- NPC spawning and management
}

-- ════════════════════════════════════════════════════════════════════════════
-- █████ SERVER SCRIPTS (AUTHORITY/VALIDATION)
-- ════════════════════════════════════════════════════════════════════════════

--[[
    Server scripts handle:
    - Anti-exploit validation
    - Reward distribution (money/items)
    - Delivery session tracking
    - Rate limiting and spam prevention
    - Framework integration (player data, inventory, etc.)
]]--

server_scripts {
    'server/server.lua',       -- Main server logic (validation & rewards)
}

-- ════════════════════════════════════════════════════════════════════════════
-- █████ RESOURCE SCOPE & PERMISSIONS
-- ════════════════════════════════════════════════════════════════════════════

--[[
    This resource operates with standard permissions and does not require
    elevated privileges. All validation is done server-side to prevent exploits.
    
    Client scripts:
    - Handle UI/UX and player interactions
    - Cannot directly modify player data or rewards
    - Send requests to server for validation
    
    Server scripts:
    - Validate all client requests
    - Control reward distribution
    - Track active deliveries
    - Enforce rate limits and anti-spam
]]--

-- ════════════════════════════════════════════════════════════════════════════
-- █████ END OF MANIFEST
-- ════════════════════════════════════════════════════════════════════════════
