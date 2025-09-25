local BoardIndex, MissionIndex = nil, nil
local WagonEntity = nil
local DistanceTraveled = 0.0
local LastPos = nil
local MissionActive = false
local Notify = Config.Notify

RegisterNetEvent("lux:delivery:notify", function(msg, t) Config.Notify.Client(msg, t) end)

-- Begin mission from server
RegisterNetEvent("lux:delivery:client:begin", function(boardIndex, missionIndex, missionData)
    BoardIndex, MissionIndex = boardIndex, missionIndex
    MissionActive = true
    DistanceTraveled = 0.0
    LastPos = GetEntityCoords(PlayerPedId())

    -- spawn wagon
    local wagonConfig = Config.Wagons[missionData.wagon] or Config.Wagons.standard
    local model = GetHashKey(wagonConfig.model)
    RequestModel(model); while not HasModelLoaded(model) do Wait(10) end

    WagonEntity = CreateVehicle(model, missionData.from.x, missionData.from.y, missionData.from.z, 0.0, true, false)
    SetEntityAsMissionEntity(WagonEntity, true, true)
    SetVehicleHasBeenOwnedByPlayer(WagonEntity, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), WagonEntity, -1)

    Notify.Client(locale('mission_started', missionData.label), "success")
end)

CreateThread(function()
    while true do
        if MissionActive and WagonEntity and DoesEntityExist(WagonEntity) then
            -- distance tracking
            local pos = GetEntityCoords(WagonEntity)
            if LastPos then
                local d = #(pos - LastPos)
                DistanceTraveled = DistanceTraveled + d
            end
            LastPos = pos

            -- poor-man's damage sampling
            if IsEntityInWater(WagonEntity) then
                TriggerServerEvent("lux:delivery:reportDamage", Config.CargoDamage.major)
            elseif IsVehicleDamaged(WagonEntity) then
                TriggerServerEvent("lux:delivery:reportDamage", Config.CargoDamage.minor)
            end

            -- arrival check
            local board = Config.Boards[BoardIndex]
            local mission = board and board.missions[MissionIndex] or nil
            if mission then
                local dist = #(pos - mission.to)
                if dist < 8.0 then
                    local km = DistanceTraveled / 1000.0
                    TriggerServerEvent("lux:delivery:complete", km)
                    MissionActive = false
                end
            end
        end
        Wait(Config.TickRateMs)
    end
end)

RegisterNetEvent("lux:delivery:client:cleanup", function(reason, reward, damage, level, xp)
    if WagonEntity and DoesEntityExist(WagonEntity) then
        SetEntityAsMissionEntity(WagonEntity, true, true)
        DeleteVehicle(WagonEntity)
        WagonEntity = nil
    end
    BoardIndex, MissionIndex = nil, nil
    MissionActive = false

    if reason == "complete" then
        Notify.Client(locale('mission_complete', reward or 0), "success")
    elseif reason == "aborted" then
        Notify.Client(locale('mission_aborted'), "error")
    end
end)

-- command
RegisterCommand(Config.Commands.cancel, function()
    TriggerServerEvent("lux:delivery:abort", "player_cancel")
end, false)
