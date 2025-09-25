fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'iBoss + ChatGPT'
description 'Mission-based Delivery System for LXRCore / RSGCore / VORP with dynamic events, progression, and economy integration.'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/framework.lua',
    'locales/*.lua'
}

client_scripts {
    'client/board.lua',
    'client/events.lua',
    'client/ambush.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/missions.lua',
    'server/progression.lua',
    'server/main.lua'
}
