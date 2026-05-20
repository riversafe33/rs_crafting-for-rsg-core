local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('rs_crafting:getCraftableItems', function(zoneId)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local playerjob = Player.PlayerData.job.name

    local allCraftableItems = {}

    local zone = Config.CraftingZones[zoneId]

    if zone then
        for _, category in ipairs(zone.craftingItems) do
            for _, craft in ipairs(category.Items) do
                table.insert(allCraftableItems, craft)
            end
        end
    end

    TriggerClientEvent('rs_crafting:openMenuClient', _source, allCraftableItems, playerjob)
end)

RegisterNetEvent('rs_crafting:startCrafting', function(craftable, countz)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local playerjob = Player.PlayerData.job.name

    local canCraft = false
    local allowedJobs = craftable.Job

    if allowedJobs == false then
        canCraft = true
    elseif type(allowedJobs) == "string" and allowedJobs == playerjob then
        canCraft = true
    elseif type(allowedJobs) == "table" then
        for _, job in ipairs(allowedJobs) do
            if job == playerjob then
                canCraft = true
                break
            end
        end
    end

    if not canCraft then
        TriggerClientEvent('rs_crafting:client:ShowAdvancedNotification', _source, Config.Texts.Notify.crafting, Config.Texts.Notify.notjob, "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    for _, item in ipairs(craftable.Items) do
        local hasItem = exports['rsg-inventory']:HasItem(_source, item.name, item.count * countz)
        if not hasItem then
            TriggerClientEvent('rs_crafting:client:ShowAdvancedNotification', _source, Config.Texts.Notify.crafting, Config.Texts.Notify.notmaterials, "menu_textures", "cross", 3000, "COLOR_RED")
            return
        end
    end

    for _, reward in ipairs(craftable.Reward) do
        local canAdd = exports['rsg-inventory']:CanAddItem(_source, reward.name, reward.count * countz)
        if not canAdd then
            TriggerClientEvent('rs_crafting:client:ShowAdvancedNotification', _source, Config.Texts.Notify.crafting, Config.Texts.Notify.space, "menu_textures", "cross", 3000, "COLOR_RED")
            return
        end
    end

    for _, item in ipairs(craftable.Items) do
        exports['rsg-inventory']:RemoveItem(_source, item.name, item.count * countz, nil, 'crafting')
    end

    TriggerClientEvent("rs_crafting:craftable", _source, craftable.Animation, craftable, countz)
end)

RegisterNetEvent("rs_crafting:finishCrafting")
AddEventHandler("rs_crafting:finishCrafting", function(craftable, countz)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    if not Player then return end

    for _, reward in ipairs(craftable.Reward) do
        exports['rsg-inventory']:AddItem(_source, reward.name, reward.count * countz, nil, nil, 'crafting')
    end

    TriggerClientEvent('rs_crafting:client:ShowAdvancedNotification', _source, Config.Texts.Notify.crafting, Config.Texts.Notify.success, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

RegisterNetEvent("rs_crafting:animationComplete")
AddEventHandler("rs_crafting:animationComplete", function(craftable, countz)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    if not Player then return end

    for _, reward in ipairs(craftable.Reward) do
        exports['rsg-inventory']:AddItem(_source, reward.name, reward.count * countz, nil, nil, 'crafting')
    end

    TriggerClientEvent('rs_crafting:client:ShowAdvancedNotification', _source, Config.Texts.Notify.crafting, Config.Texts.Notify.success, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

RegisterServerEvent('rs_crafting:requestPropMenu')
AddEventHandler('rs_crafting:requestPropMenu', function(propToCheck)
    local _source = source
    local Player = RSGCore.Functions.GetPlayer(_source)
    local playerjob = Player.PlayerData.job.name
    TriggerClientEvent('rs_crafting:openPropMenu', _source, nil, propToCheck, playerjob)
end)