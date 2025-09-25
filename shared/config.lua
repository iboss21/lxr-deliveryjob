Config={}
Config.Core='AUTO';Config.Interaction='prompt';Config.Locale='en';Config.Debug=false;Config.DevGodMode=false
Config.Discord={deliveries_webhook=nil,levelup_webhook=nil,reputation_webhook=nil,blackmarket_webhook=nil}
Config.TickRateMs=600;Config.StreamDistance=140.0;Config.MaxConcurrentMissionsPerPlayer=1;Config.CooldownSeconds=120
Config.MoneyAccount='cash';Config.BasePayPerKm=8.75
Config.RiskMultipliers={low=1.0,medium=1.3,high=1.7,extreme=2.3}
Config.Reputation={min=-200,max=400,curve=function(rep) if rep<0 then return 1.0+(rep/1000.0) end return 1.0+(rep/600.0) end,
failurePenalty=-6,successGain=3,ambushWinGain=2,stealthBonus=2}
Config.DamagePenaltyCurve=function(d) if d<=0.2 then return 1.0-d*0.25 end if d<=0.6 then return 0.95-(d-0.2)*0.65 end return 0.69-(d-0.6)*1.6 end
Config.DynamicDemand={enabled=true,floor=0.8,ceil=1.45,updateEveryMin=40,volatility=0.18}
Config.ItemRewards={enabled=true,chance=16,pool={{item='whiskey_bottle',min=1,max=2,label='Whiskey Bottle'},{item='repair_kit',min=1,max=1,label='Wagon Repair Kit'},{item='ammo_varmint',min=10,max=25,label='Varmint Rounds'}}}
Config.BlackMarket={enabled=true,cooldownMin=45,sellMultipliers={stolen=1.15,contraband=1.30},heatOnPoliceCall=12}
Config.CoOp={enabled=true,posseBonusPerMember=0.06,maxBonus=0.30,escortHire={enabled=true,price=25.0,model='S_M_M_AmbientLawRural_01'}}
Config.Stealth={lightForbidden=true,speedLimitNearPatrol=4.0,detectionChance=35}
Config.Wildlife={enabled=True,chancePerMinute=8,models={'A_C_Wolf_01','A_C_Bear_01'}}
Config.Ambush={enabled=true,baseChancePerMinute=16,banditModels={'MP_G_M_M_UniGrays_01','G_M_M_UniBanditos_01'},weapons={'WEAPON_REPEATER_CARBINE','WEAPON_REVOLVER_CATTLEMAN'},accuracy=22}
Config.Progression={storage='kvp',kvpPrefix='lxr_supreme_',xp={success=65,fail=15,ambushWin=25,stealthClean=20},levels={0,120,260,440,660,920,1220,1580},
perks={[2]={armoredWagon=true},[3]={fasterHitch=true},[4]={hireEscort=true},[5]={blackMarket=true},[6]={extraRewardChance=0.12},[7]={posseBonusCap=0.40}}}
Config.Wagons={standard={model='CART01',cargo='pg_teamster_cart01_breakables',light='pg_teamster_cart01_lightupgrade3'},
armored={model='WAGON03X',cargo='pg_re_coachrobbery_mission_cargo',light='pg_teamster_cart01_lightupgrade3'},
stealth={model='WAGON05X',cargo='pg_delivery_stealth_sacks',light='pg_teamster_cart01_lightupgrade1'}}
Config.CargoDamage={minor=0.02,medium=0.08,major=0.20}
Config.Boards={
{name='Valentine Freight',ped={model='S_M_M_BankClerk_01',heading=136.0},coords=Cities.Valentine.pos,cartSpawn=vector4(-348.0,815.5,116.7,168.6),
deliveries={{id='val_to_blackwater',label='Blackwater Delivery',desc='From Valentine to Blackwater',risk='medium',wagon='standard',to=Cities.Blackwater.pos},
{id='val_to_rhodes',label='Rhodes Delivery',desc='From Valentine to Rhodes',risk='low',wagon='standard',to=Cities.Rhodes.pos},
{id='val_to_stdenis',label='Saint Denis Delivery',desc='From Valentine to Saint Denis',risk='high',wagon='armored',to=Cities.SaintDenis.pos},
{id='val_stealth',label='Moonlight Bootleg',desc='Covert whiskey run at night',risk='medium',wagon='stealth',to=Cities.EmeraldRanch.pos,stealth=true,allowedHours={22,5}}}},
{name='Saint Denis Freight Guild',ped={model='S_M_M_BankClerk_01',heading=120.0},coords=Cities.SaintDenis.pos,cartSpawn=vector4(2639.2,-1294.0,52.1,60.0),
deliveries={{id='sd_to_rhodes',label='Rhodes Delivery',desc='From Saint Denis to Rhodes',risk='low',wagon='standard',to=Cities.Rhodes.pos},
{id='sd_to_bw',label='Blackwater Delivery',desc='From Saint Denis to Blackwater',risk='high',wagon='armored',to=Cities.Blackwater.pos},
{id='sd_to_ann',label='Annesburg Delivery',desc='From Saint Denis to Annesburg',risk='medium',wagon='standard',to=Cities.Annesburg.pos},
{id='sd_stealth',label='Night Contraband',desc='Silent contraband run',risk='medium',wagon='stealth',to=Cities.VanHorn.pos,stealth=true,allowedHours={21,5}}}},
{name='Blackwater Freight Office',ped={model='S_M_M_BankClerk_01',heading=180.0},coords=Cities.Blackwater.pos,cartSpawn=vector4(-885.2,-1360.0,43.5,90.0),
deliveries={{id='bw_to_val',label='Valentine Delivery',desc='From Blackwater to Valentine',risk='medium',wagon='standard',to=Cities.Valentine.pos},
{id='bw_to_stw',label='Strawberry Delivery',desc='From Blackwater to Strawberry',risk='low',wagon='standard',to=Cities.Strawberry.pos},
{id='bw_to_tw',label='Tumbleweed Delivery',desc='From Blackwater to Tumbleweed',risk='high',wagon='armored',to=Cities.Tumbleweed.pos}}},
{name='Van Horn Docks',ped={model='S_M_M_BankClerk_01',heading=44.0},coords=Cities.VanHorn.pos,cartSpawn=vector4(2964.2,570.0,44.3,180.0),
deliveries={{id='vh_to_ann',label='Annesburg Ore',desc='Tools and ore shipment',risk='low',wagon='standard',to=Cities.Annesburg.pos},
{id='vh_to_sd',label='Saint Denis Goods',desc='Crates to the port',risk='medium',wagon='standard',to=Cities.SaintDenis.pos},
{id='vh_stealth',label='Moonshine Run',desc='Quietly move barrels',risk='medium',wagon='stealth',to=Cities.Rhodes.pos,stealth=true,allowedHours={22,5}}}}}
Config.AutoRoutes={enabled=true,from={'Valentine','Strawberry','Blackwater','SaintDenis','Rhodes','Annesburg','VanHorn','EmeraldRanch','Armadillo','Tumbleweed','MacFarlanes'},
to={'SaintDenis','Rhodes','Blackwater','Valentine','Strawberry','EmeraldRanch','Tumbleweed','Armadillo','VanHorn','Annesburg'},riskByDistance=true,stealthChance=0.25,
useWagonByRisk={low='standard',medium='standard',high='armored',extreme='armored'}}
