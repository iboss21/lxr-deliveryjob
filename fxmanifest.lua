fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
author 'iBoss'
description 'LXRsupreme: Mega mission-based delivery system with narrative, dynamic events, co-op, factions, escorts, stealth, reputation, demand, and black market.'
lua54 'yes'
shared_scripts {'@ox_lib/init.lua','shared/constants.lua','shared/cities.lua','shared/config.lua','shared/framework.lua'
    'shared/content_pack.lua',
}
client_scripts {'client/interactions.lua','client/board.lua','client/mission_flow.lua','client/wagon.lua','client/ambush.lua','client/stealth.lua','client/wildlife.lua','client/law.lua','client/escort.lua','client/coop.lua','client/blackmarket.lua','client/blips.lua','client/debug.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','server/utils.lua','server/logger.lua','server/state.lua','server/progression.lua','server/reputation.lua','server/demand.lua','server/payouts.lua','server/missions.lua','server/escorts.lua','server/blackmarket.lua','server/main.lua'}
files {'locales/*.lua'}
