fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

-- The Land of Wolves - LXRCore Delivery System
author  "iBoss (The Land of Wolves)"
description "LXRCore Wagon Delivery System - Deliver wagons across the frontier. Website: www.wolves.land"
version "2.0.0"

-- Original Creator: Muhammad Abdullah Shurjeel (stx-wagondeliveries)
-- Based on: RexShack's rsg-delivery system
-- Enhanced by: iBoss for The Land of Wolves community

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

lua54 'yes'