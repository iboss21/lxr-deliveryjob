local phrases = {
    open_board = "Press ENTER to open Delivery Board",
    mission_started = "Delivery started: %s",
    mission_complete = "Delivery complete! Earned $%s",
    mission_aborted = "Delivery aborted.",
    mission_type_stealth = "Stealth delivery"
}
function locale(key, ...)
    local s = phrases[key] or key
    if select('#', ...) > 0 then
        s = s:format(...)
    end
    return s
end
