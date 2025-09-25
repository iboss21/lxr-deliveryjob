local Notify = Config.Notify

local function drawHelp(msg)
    SetTextScale(0.5, 0.5)
    SetTextFontForCurrentCommand(1)
    DisplayHelpTextThisFrame(msg, false)
end

-- simple prompt interaction for boards
CreateThread(function()
    while true do
        local sleep = 1000
        for i, board in ipairs(Config.Boards) do
            local p = GetEntityCoords(PlayerPedId())
            local dist = #(p - board.coords)
            if dist < 25.0 then
                sleep = 0
                DrawMarker(1, board.coords.x, board.coords.y, board.coords.z-1.0, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.6,0.6,0.3, 255,255,255,100, false,false,2,false,nil,nil,false)
                if dist < 1.8 then
                    drawHelp(locale('open_board'))
                    if IsControlJustPressed(0, 0xC7B5340A) then -- ENTER
                        -- build context with ox_lib if present
                        if lib and lib.registerContext then
                            local opts = {}
                            for idx, m in ipairs(board.missions) do
                                table.insert(opts, { title = m.label, description = (m.stealth and locale('mission_type_stealth') or ""), icon = "truck", onSelect = function()
                                    TriggerServerEvent("lux:delivery:startMission", i, idx)
                                end })
                            end
                            lib.registerContext({ id = "lux_board_"..i, title = board.name, options = opts })
                            lib.showContext("lux_board_"..i)
                        else
                            -- fallback: start first mission
                            TriggerServerEvent("lux:delivery:startMission", i, 1)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
