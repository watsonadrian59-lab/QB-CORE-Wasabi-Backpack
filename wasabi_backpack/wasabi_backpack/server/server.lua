local QBCore = exports['qb-core']:GetCoreObject()

-- Serial generators
local function GenerateSerial()
    local str
    repeat
        local chars = {}
        for i = 1, 3 do
            chars[i] = string.char(math.random(65, 90))
        end
        str = table.concat(chars)
    until str ~= 'POL' and str ~= 'EMS'

    return ('%s%s%s'):format(math.random(100000,999999), str, math.random(100000,999999))
end

local function GenerateMaterialBinSerial()
    return ('%s%s%s'):format(math.random(100000,999999), 'MAT', math.random(100000,999999))
end

-- Persistent stash ID generator
local function ForcePersistentID(player, itemName, isMaterialBin, cb)
    local citizenid = player.PlayerData.citizenid

    exports.oxmysql:scalar(
        [[SELECT identifier FROM persistent_stashes WHERE citizenid = ? AND itemname = ?]],
        { citizenid, itemName },
        function(result)
            local identifier = result

            if not identifier then
                local id = isMaterialBin and GenerateMaterialBinSerial() or GenerateSerial()
                identifier = string.format("%s_%s", citizenid, id)

                exports.oxmysql:execute(
                    [[INSERT INTO persistent_stashes (citizenid, itemname, identifier) VALUES (?, ?, ?)]],
                    { citizenid, itemName, identifier }
                )
            end

            for _, it in pairs(player.PlayerData.items) do
                if it.name == itemName then
                    if not it.metadata then it.metadata = {} end
                    it.metadata.identifier = identifier

                    exports['qb-inventory']:SetItemData(
                        player.PlayerData.source,
                        it.name,
                        'metadata',
                        it.metadata,
                        it.slot
                    )
                    break
                end
            end

            if cb then cb(identifier) end
        end
    )
end

-- Usable items
QBCore.Functions.CreateUseableItem("backpack", function(source, item)
    TriggerClientEvent("wasabi_backpack:openBackpack", source, item)
end)

QBCore.Functions.CreateUseableItem("materialbin", function(source, item)
    TriggerClientEvent("wasabi_backpack:openMaterialBin", source, item)
end)

local function SetCustomStash(identifier, slots, weight)
    exports['qb-inventory']:CreateStash(identifier, {
        maxweight = weight,
        slots = slots
    })
end

-- Open backpack event
RegisterNetEvent('wasabi_backpack:openBackpackServer', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    ForcePersistentID(Player, 'backpack', false, function(identifier)
        if identifier then
            exports['qb-inventory']:OpenInventory(src, identifier, {
                displayName = "Backpack",
                maxweight = 50000,
                slots = 25
            })
        end
    end)
end)

-- Open material bin event
RegisterNetEvent('wasabi_backpack:openMaterialBinServer', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    ForcePersistentID(Player, 'materialbin', true, function(identifier)
        if identifier then
            exports['qb-inventory']:OpenInventory(src, identifier, {
                displayName = "Material Container",
                maxweight = 250000,
                slots = 50
            })
        end
    end)
end)


