
-- =====================================================================
--  LXR Delivery SUPREME — Content Pack (Additive Only)
--  Appends a large set of deliveries and boards. Does not remove/modify originals.
-- =====================================================================

local function nearly(a, b) return #(a - b) < 5.0 end

local function riskByDistance(d)
    if d < 1200.0 then return 'low' end
    if d < 2600.0 then return 'medium' end
    if d < 4200.0 then return 'high' end
    return 'extreme'
end

local function wagonForRisk(risk)
    if risk == 'low' or risk == 'medium' then return 'standard' end
    return 'armored'
end

local function boardByName(name)
    for i, b in ipairs(Config.Boards or {}) do
        if (b.name == name) then return b end
    end
end

local function boardByCoords(pos)
    for i, b in ipairs(Config.Boards or {}) do
        if nearly(b.coords, pos) then return b end
    end
end

local function ensureBoard(name, pos, pedModel, heading)
    local b = boardByName(name) or boardByCoords(pos)
    if b then return b end
    b = {
        name = name,
        ped = { model = pedModel or "S_M_M_BankClerk_01", heading = heading or 90.0 },
        coords = pos,
        cartSpawn = vector4(pos.x, pos.y, pos.z, heading or 90.0),
        deliveries = {}
    }
    Config.Boards[#Config.Boards+1] = b
    return b
end

local function hasDuplicate(board, idOrLabel)
    for _, d in ipairs(board.deliveries or {}) do
        if d.id == idOrLabel or d.label == idOrLabel then
            return true
        end
    end
end

local function addDelivery(board, data)
    if not board.deliveries then board.deliveries = {} end
    local key = data.id or data.label
    if key and hasDuplicate(board, key) then return false end
    table.insert(board.deliveries, data)
    return true
end

local flavors = {
    "Timber Run", "Moonshine Haul", "Medical Supplies", "Ranch Goods",
    "Workshop Tools", "Cotton Bales", "Ore & Coal", "Provisions",
    "Frontier Staples", "Fresh Produce", "General Goods", "Lumber & Nails",
    "Mail & Parcels", "Black Market Rumor"
}

CreateThread(function()

    -- Short list of cities we want to massively connect (must exist in Cities table)
    local CityNames = {
        "Valentine","Strawberry","Blackwater","Rhodes","SaintDenis",
        "Annesburg","VanHorn","EmeraldRanch","Armadillo","Tumbleweed",
        "MacFarlanes","BenedictPoint","RiggsStation","WallaceStation","Colter"
    }

    -- Ensure a board per city and wire ~8+ routes each
    for _, src in ipairs(CityNames) do
        local S = Cities[src]
        if S and S.pos then
            local board = ensureBoard(("%s Freight"):format(src), S.pos)
            local added = 0
            for __, dst in ipairs(CityNames) do
                if dst ~= src then
                    local D = Cities[dst]
                    if D and D.pos then
                        local distance = #(S.pos - D.pos)
                        local risk = riskByDistance(distance)
                        local wagon = wagonForRisk(risk)
                        local stealth = (math.random() < 0.33) -- ~33% stealth flavor
                        local flavor = flavors[math.random(1, #flavors)]
                        local id = ("cp_%s_to_%s_%d"):format(src:lower(), dst:lower(), math.random(1000,9999))

                        local ok = addDelivery(board, {
                            id = id,
                            label = ("CP: %s → %s – %s"):format(src, dst, flavor),
                            desc = ("Freight run from %s to %s."):format(src, dst),
                            risk = risk,
                            wagon = wagon,
                            to = D.pos,
                            stealth = stealth,
                            allowedHours = stealth and {21, 5} or nil
                        })
                        if ok then
                            added = added + 1
                        end
                        if added >= 12 then -- cap per board to avoid infinite growth
                            -- You can raise this cap to 18/24 for truly massive lists.
                            -- We keep it sane by default.
                            break
                        end
                    end
                end
            end
        end
    end

    -- Thematic frontier boards (additive)
    local frontierBoards = {
        { name="Colter Outpost",        key="Colter",        toList={"Valentine","WallaceStation","Annesburg","VanHorn"} },
        { name="MacFarlane Shipping",   key="MacFarlanes",   toList={"Armadillo","Tumbleweed","Blackwater","BenedictPoint"} },
        { name="Benedict Freight",      key="BenedictPoint", toList={"Tumbleweed","MacFarlanes","Armadillo","Blackwater"} },
        { name="Riggs Transfer",        key="RiggsStation",  toList={"Valentine","Blackwater","Strawberry","EmeraldRanch"} },
        { name="Wallace Station Yard",  key="WallaceStation",toList={"Valentine","Strawberry","Annesburg","VanHorn"} },
    }

    for _, fb in ipairs(frontierBoards) do
        local C = Cities[fb.key]
        if C and C.pos then
            local board = ensureBoard(fb.name, C.pos)
            for _, dest in ipairs(fb.toList or {}) do
                local D = Cities[dest]
                if D and D.pos then
                    local dist = #(C.pos - D.pos)
                    local risk = riskByDistance(dist)
                    local wagon = wagonForRisk(risk)
                    local stealth = (math.random() < 0.25)
                    local flavor = flavors[math.random(1, #flavors)]
                    addDelivery(board, {
                        id = ("cp_%s_to_%s_%d"):format(fb.key:lower(), dest:lower(), math.random(1000,9999)),
                        label = ("CP: %s → %s – %s"):format(fb.key, dest, flavor),
                        desc = ("Frontier run from %s to %s."):format(fb.key, dest),
                        risk = risk, wagon = wagon, to = D.pos, stealth = stealth,
                        allowedHours = stealth and {22, 5} or nil
                    })
                end
            end
        end
    end

end)
