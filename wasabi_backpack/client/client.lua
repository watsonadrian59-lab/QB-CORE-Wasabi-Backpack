local QBCore = exports['qb-core']:GetCoreObject()
local bagEquipped = false
local bagObj = nil
local hash = "p_michael_backpack_s"

-- Server usable item events
RegisterNetEvent('wasabi_backpack:openBackpack', function(item)
    exports['wasabi_backpack']:openBackpack(item)
end)

RegisterNetEvent('wasabi_backpack:openMaterialBin', function(item)
    exports['wasabi_backpack']:openMaterialBin(item)
end)

-- Ped utilities
local function GetPed()
    return PlayerPedId()
end

-- Backpack visual
local function PutOnBag()
    if bagEquipped then return end

    local ped = GetPed()
    local coords = GetEntityCoords(ped)
    lib.requestModel(hash, 100)

    bagObj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, true, false, false)
    AttachEntityToEntity(
        bagObj,
        ped,
        GetPedBoneIndex(ped, 24818),
        0.07, -0.11, -0.05,
        0.0, 90.0, 175.0,
        true, true, false, true, 1, true
    )

    bagEquipped = true
end

local function RemoveBag()
    if DoesEntityExist(bagObj) then DeleteObject(bagObj) end
    SetModelAsNoLongerNeeded(hash)
    bagObj = nil
    bagEquipped = false
end

-- Backpack check
local function CheckBackpack()
    local ped = GetPed()

    if IsPedInAnyVehicle(ped, false) then
        if bagEquipped then RemoveBag() end
        return
    end

    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData or not playerData.items then
        if bagEquipped then RemoveBag() end
        return
    end

    local backpackSlot = nil

    for _, item in pairs(playerData.items) do
        if item and item.name == 'backpack' and (item.amount == nil or item.amount > 0) then
            if item.slot then
                backpackSlot = tonumber(item.slot)
            end
            break
        end
    end

    if not backpackSlot then
        if bagEquipped then RemoveBag() end
        return
    end

    if backpackSlot >= 1 and backpackSlot <= 5 then
        if not bagEquipped then PutOnBag() end
    else
        if bagEquipped then RemoveBag() end
    end
end

-- Item removed
RegisterNetEvent('qb-inventory:client:ItemRemoved', function(item)
    if item and item.name == "backpack" then
        if bagEquipped then RemoveBag() end
    end
end)

-- Player loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    CheckBackpack()
end)

-- Inventory updated
RegisterNetEvent('qb-inventory:client:OnInventoryUpdate', function()
    Wait(200)
    CheckBackpack()
end)

-- Vehicle logic
lib.onCache('vehicle', function(vehicle)
    if vehicle and bagEquipped then
        RemoveBag()
    elseif not vehicle then
        CheckBackpack()
    end
end)

-- Polling
CreateThread(function()
    while true do
        Wait(1500)
        CheckBackpack()
    end
end)

-- Open Backpack
exports('openBackpack', function(item)
    TriggerServerEvent('wasabi_backpack:openBackpackServer', item)
end)

-- Open Material Bin
exports('openMaterialBin', function(item)
    TriggerServerEvent('wasabi_backpack:openMaterialBinServer', item)
end)
