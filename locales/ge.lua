local phrases = {
    open_board = "დააჭირე ENTER-ს მიწოდების დაფის გასახსნელად",
    mission_started = "მიწოდება დაწყებულია: %s",
    mission_complete = "მიწოდება დასრულდა! თქვენ მიიღეთ $%s",
    mission_aborted = "მიწოდება გაუქმდა.",
    mission_type_stealth = "ფარული მიწოდება"
}
function locale(key, ...)
    local s = phrases[key] or key
    if select('#', ...) > 0 then
        s = s:format(...)
    end
    return s
end
