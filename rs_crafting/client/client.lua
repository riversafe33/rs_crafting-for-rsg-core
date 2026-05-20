local AnimationHandler = {}
local primaryProp
local secondaryProp
local AnimationsConfig = Config.Anim

CreateThread(function()
    if Config.ShowBlip then 
        for i = 1, #Config.BlipZone do 
            local zone = Config.BlipZone[i]
            if zone.blips and type(zone.blips) == "number" then
                local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, zone.coords.x, zone.coords.y, zone.coords.z) 
                SetBlipSprite(blip, zone.blips, 1)
                SetBlipScale(blip, 0.8)
                Citizen.InvokeNative(0x9CB1A1623062F402, blip, zone.blipsName)
                Citizen.InvokeNative(0x662D364ABF16DE2F, blip, GetHashKey("BLIP_MODIFIER_MP_COLOR_32"))
            end
        end
    end
end)

local Prompt

-- ============ THREAD: Zonas de crafting ============
Citizen.CreateThread(function()

    Prompt = Uiprompt:new(Config.Prompt.key, Config.Prompt.text)
    Prompt:setEnabledAndVisible(false)

    -- Cachear coords para evitar recorrer Config todo el tiempo
    local allZoneCoords = {}

    for zoneId, zone in pairs(Config.CraftingZones) do
        for _, coord in ipairs(zone.coords) do
            table.insert(allZoneCoords, {
                zoneId = zoneId,
                coords = vector3(coord.x, coord.y, coord.z)
            })
        end
    end

    local lastZone = nil

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local currentZone = nil
        local maxDistSq = 1.5 * 1.5

        -- Buscar zona cercana
        for _, entry in ipairs(allZoneCoords) do
            local distSq = #(playerCoords - entry.coords)^2

            if distSq < maxDistSq then
                currentZone = entry.zoneId
                break
            end
        end

        -- Solo actualizar prompt si cambia de estado
        if currentZone ~= lastZone then
            lastZone = currentZone

            if currentZone then
                Prompt:setEnabledAndVisible(true)

                Prompt:setOnControlJustPressed(function()
                    TriggerServerEvent('rs_crafting:getCraftableItems', currentZone)
                end)
            else
                Prompt:setEnabledAndVisible(false)
            end
        end

        Citizen.Wait(currentZone and 200 or 800)
    end
end)

UipromptManager:startEventThread()

RegisterNetEvent('rs_crafting:openMenuClient')
AddEventHandler('rs_crafting:openMenuClient', function(allItems, playerjob)
    local groupedItems = {}
    local uncategorizedItems = {}
    local hasAllowedItems = false

    for _, craft in ipairs(allItems) do
        local allowedJobs = craft.Job or false
        local category = craft.Category

        local isAllowed = allowedJobs == false
            or (type(allowedJobs) == "string" and allowedJobs == playerjob)
            or (type(allowedJobs) == "table" and table.contains(allowedJobs, playerjob))

        if isAllowed then
            hasAllowedItems = true

            -- Imagen del reward (usando el nombre del ítem)
            local rewardImage = craft.Reward and craft.Reward[1] and (craft.Reward[1].name .. ".png") or "default.png"

            local element = {
                label = craft.Text,
                value = craft,
                image = "nui://rsg-inventory/html/images/" .. rewardImage,
                descriptionimages = {}
            }

            for _, item in ipairs(craft.Items) do
                table.insert(element.descriptionimages, {
                    src = "nui://rsg-inventory/html/images/" .. item.name .. ".png",
                    text = item.label,
                    count = " x " .. item.count,
                })
            end

            -- Agrupa por categoría o sin categoría
            if category == false or category == nil then
                table.insert(uncategorizedItems, element)
            else
                groupedItems[category] = groupedItems[category] or {}
                table.insert(groupedItems[category], element)
            end
        end
    end

    -- Si hay ítems permitidos, muestra el menú
    if hasAllowedItems then
        if #uncategorizedItems > 0 then
            SendNUIMessage({
                type = "openCraftingMenuDirect",
                items = uncategorizedItems,
                prompt = Config.Texts
            })
        else
            local firstCategory = nil
            for catName, _ in pairs(groupedItems) do
                firstCategory = catName
                break
            end

            SendNUIMessage({
                type = "openCraftingMenuGrouped",
                categories = groupedItems,
                prompt = Config.Texts,
                defaultCategory = firstCategory
            })
        end
        SetNuiFocus(true, true)
    else
        exports['rs_crafting']:ShowAdvancedNotification( Config.Texts.Notify.crafting, Config.Texts.Notify.notjob, "menu_textures", "cross", 4000, "COLOR_RED")
    end
end)

RegisterNUICallback("craftItem", function(data, cb)
    local selectedItem = data.item
    local quantity = tonumber(data.quantity)

    if quantity and quantity > 0 then
        TriggerServerEvent('rs_crafting:startCrafting', selectedItem, quantity)
    else
        TriggerEvent("vorp:TipRight", "Cantidad inválida", 3000)
    end

    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("closeMenu", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

------------ Crafteos desde un Prop ----------
local Prompt2

-- ============ THREAD: Props ============
Citizen.CreateThread(function()

    Prompt2 = Uiprompt:new(Config.Prompt2.key, Config.Prompt2.text)
    Prompt2:setEnabledAndVisible(false)

    -- Cachear props únicos
    local allProps = {}
    local propCache = {}

    for _, category in pairs(Config.CraftingProps) do
        for _, item in pairs(category.Items) do
            for _, prop in ipairs(item.props) do

                if not propCache[prop] then
                    propCache[prop] = true

                    table.insert(allProps, {
                        name = prop,
                        hash = GetHashKey(prop)
                    })
                end
            end
        end
    end

    local lastEntity = nil

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local foundEntity = nil
        local foundProp = nil

        -- Solo 1 búsqueda por prop único
        for _, propData in ipairs(allProps) do

            local entity = GetClosestObjectOfType(
                playerCoords,
                3.0,
                propData.hash,
                false,
                false,
                false
            )

            if DoesEntityExist(entity) then
                local entityCoords = GetEntityCoords(entity)

                if #(playerCoords - entityCoords) < 3.0 then
                    foundEntity = entity
                    foundProp = propData.name
                    break
                end
            end
        end

        -- Solo actualizar si cambia el entity
        if foundEntity ~= lastEntity then
            lastEntity = foundEntity

            if foundEntity then
                Prompt2:setEnabledAndVisible(true)

                Prompt2:setOnControlJustPressed(function()
                    TriggerServerEvent('rs_crafting:requestPropMenu', foundProp)
                end)
            else
                Prompt2:setEnabledAndVisible(false)
            end
        end

        Citizen.Wait(foundEntity and 200 or 800)
    end
end)

RegisterNetEvent('rs_crafting:openPropMenu')
AddEventHandler('rs_crafting:openPropMenu', function(_, propToCheck, playerJob)
    local groupedItems = {}
    local directItems = {}
    local hasAllowedItems = false

    for _, category in ipairs(Config.CraftingProps) do
        for _, item in ipairs(category.Items) do
            if table.contains(item.props, propToCheck) then
                local allowedJobs = item.Job or false
                local isAllowed =
                    allowedJobs == false or
                    (type(allowedJobs) == "string" and allowedJobs == playerJob) or
                    (type(allowedJobs) == "table" and table.contains(allowedJobs, playerJob))

                if isAllowed then
                    hasAllowedItems = true

                    -- Imagen del reward (usando el nombre del ítem de recompensa)
                    local rewardImage = item.Reward and item.Reward[1] and (item.Reward[1].name .. ".png") or "default.png"

                    local formattedItem = {
                        label = item.Text or "Sin nombre",
                        value = item,
                        image = "nui://rsg-inventory/html/images/" .. rewardImage,
                        descriptionimages = {}
                    }

                    -- Agrega los ítems requeridos con su imagen y cantidad
                    for _, reqItem in ipairs(item.Items or {}) do
                        table.insert(formattedItem.descriptionimages, {
                            src = "nui://rsg-inventory/html/images/" .. reqItem.name .. ".png",
                            text = reqItem.label or "Desconocido",
                            count = " x " .. tostring(reqItem.count or 0),
                        })
                    end

                    -- Agrupa o coloca directo según categoría
                    if item.Category == false or item.Category == nil then
                        table.insert(directItems, formattedItem)
                    else
                        groupedItems[item.Category] = groupedItems[item.Category] or {}
                        table.insert(groupedItems[item.Category], formattedItem)
                    end
                end
            end
        end
    end

    -- Si no hay ítems válidos, notificar
    if not hasAllowedItems then
        exports['rs_crafting']:ShowAdvancedNotification( Config.Texts.Notify.crafting, Config.Texts.Notify.notjob, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    -- Abrir menú directo o agrupado
    if #directItems > 0 then
        SendNUIMessage({
            type = "openCraftingMenuDirect",
            items = directItems,
            prompt = Config.Texts
        })
    else
        local firstCategory = nil
        for catName, _ in pairs(groupedItems) do
            firstCategory = catName
            break
        end

        SendNUIMessage({
            type = "openCraftingMenuGrouped",
            categories = groupedItems,
            prompt = Config.Texts,
            defaultCategory = firstCategory
        })
    end

    SetNuiFocus(true, true)
end)


AnimationHandler.play = function(ped, animKey)
    local animData = AnimationsConfig[animKey]
    if not DoesAnimDictExist(animData.dict) then return end

    if animData.prop then
        local pedCoords = GetEntityCoords(ped)
        primaryProp = CreateObject(animData.prop.model, pedCoords.x, pedCoords.y, pedCoords.z, true, true, false, false, true)
        local bone = GetEntityBoneIndexByName(ped, animData.prop.bone)

        AttachEntityToEntity(primaryProp, ped, bone,
            animData.prop.coords.x, animData.prop.coords.y, animData.prop.coords.z,
            animData.prop.coords.xr, animData.prop.coords.yr, animData.prop.coords.zr,
            true, true, false, true, 1, true, false, false)

        if animData.prop.subprop then
            local subCoords = GetEntityCoords(secondaryProp)
            secondaryProp = CreateObject(animData.prop.subprop.model, subCoords.x, subCoords.y, subCoords.z, true, true, false, false, true)

            AttachEntityToEntity(secondaryProp, ped, bone,
                animData.prop.subprop.coords.x, animData.prop.subprop.coords.y, animData.prop.subprop.coords.z,
                animData.prop.subprop.coords.xr, animData.prop.subprop.coords.yr, animData.prop.subprop.coords.zr,
                true, true, false, true, 1, true, false, false)
        end
    end

    if animData.type == 'scenario' then
        TaskStartScenarioInPlaceHash(ped, GetHashKey(animData.hash), 12000, true, 0, 0, false)
    elseif animData.type == 'standard' then
        RequestAnimDict(animData.dict)
        while not HasAnimDictLoaded(animData.dict) do Wait(0) end

        TaskPlayAnim(ped, animData.dict, animData.name, 1.0, 1.0, -1, animData.flag, 1.0, false, 0, false, '', false)
    end
end

AnimationHandler.stop = function(animKey)
    local animData = AnimationsConfig[animKey]
    RemoveAnimDict(animData.dict)
    StopAnimTask(PlayerPedId(), animData.dict, animData.name, 1.0)

    if primaryProp then DeleteObject(primaryProp) end
    if secondaryProp then DeleteObject(secondaryProp) end
end

AnimationHandler.stopAll = function()
    ClearPedTasksImmediately(PlayerPedId())
end

AnimationHandler.forceScenarioRest = function(value)
    Citizen.InvokeNative(0xE5A3DD2FF84E1A4B, value)
end

RegisterNetEvent("rs_crafting:craftable")
AddEventHandler("rs_crafting:craftable", function(animation, craftable, countz)
    local playerPed = PlayerPedId()
    iscrafting = true

    animation = animation or "craft"
    AnimationHandler.play(playerPed, animation)

    local duration = Config.CraftTime

    SendNUIMessage({
        type = "showProgressBar",
        duration = duration,
        text = Config.Texts.crafting
    })

    Citizen.SetTimeout(duration, function()
        AnimationHandler.stop(animation)
        iscrafting = false

        SendNUIMessage({ type = "hideProgressBar" })

        TriggerServerEvent("rs_crafting:animationComplete", craftable, countz)
    end)
end)


RegisterNetEvent('rs_crafting:client:ShowAdvancedNotification', function(title, subTitle, dict, icon, duration, color)
    exports['rs_crafting']:ShowAdvancedNotification(title, subTitle, dict, icon, duration, color)
end)


RegisterNetEvent('rs_crafting:ShowTopNotification')
AddEventHandler('rs_crafting:ShowTopNotification',
                function(tittle, subtitle, duration)
    exports.rs_crafting:ShowTopNotification(tostring(tittle),
                                                    tostring(subtitle),
                                                    tonumber(duration))
end)

RegisterNetEvent('rs_crafting:ShowAdvancedRightNotification')
AddEventHandler('rs_crafting:ShowAdvancedRightNotification',
                function(text, dict, icon, text_color, duration)
    local _dict = dict
    local _icon = icon
    if not LoadTexture(_dict) then
        _dict = "honor_display "
        LoadTexture(_dict)
        _icon = "honor_bad"
    end
    exports.rs_crafting:ShowAdvancedRightNotification(tostring(text),
                                                              tostring(_dict),
                                                              tostring(_icon),
                                                              tostring(
                                                                  text_color),
                                                              tonumber(duration))
end)

RegisterNetEvent('rs_crafting:ShowAdvancedLeftNotification')
AddEventHandler('rs_crafting:ShowAdvancedLeftNotification', function(text, dict, icon, color, duration)
    exports.rs_crafting:ShowAdvancedLeftNotification(text, dict, icon, color, duration)
end)



local function LoadTexture(dict)
    if Citizen.InvokeNative(0x7332461FC59EB7EC, dict) then
        RequestStreamedTextureDict(dict, true)
        while not HasStreamedTextureDictLoaded(dict) do
            Wait(1)
        end
        return true
    end
    return false
end

local function bigInt(text)
    local buf = DataView.ArrayBuffer(16)
    buf:SetInt64(0, text)
    return buf:GetInt64(0)
end

exports("ShowAdvancedRightNotification", function(text, dict, icon, text_color, duration)
    local _text = CreateVarString(10, "LITERAL_STRING", text)
    local _dict = CreateVarString(10, "LITERAL_STRING", dict or "generic_textures")
    local _soundDict = CreateVarString(10, "LITERAL_STRING", "Transaction_Feed_Sounds")
    local _sound = CreateVarString(10, "LITERAL_STRING", "Transaction_Positive")

    local struct1 = DataView.ArrayBuffer(8 * 7)
    struct1:SetInt32(0, duration or 3000)
    struct1:SetInt64(8 * 1, bigInt(_soundDict))
    struct1:SetInt64(8 * 2, bigInt(_sound))

    local struct2 = DataView.ArrayBuffer(8 * 10)
    struct2:SetInt64(8 * 1, bigInt(_text))
    struct2:SetInt64(8 * 2, bigInt(_dict))
    struct2:SetInt64(8 * 3, bigInt(GetHashKey(icon or "tick")))
    struct2:SetInt64(8 * 5, bigInt(GetHashKey(text_color or "COLOR_WHITE")))

    Citizen.InvokeNative(0xB249EBCB30DD88E0, struct1:Buffer(), struct2:Buffer(), 1)
end)

exports("ShowAdvancedLeftNotification", function(text, dict, icon, text_color, duration)
    local _dict = dict or "generic_textures"
    local _icon = icon or "tick"

    if not LoadTexture(_dict) then
        _dict = "generic_textures"
        _icon = "tick"
    end

    local _text = CreateVarString(10, "LITERAL_STRING", text)

    local struct1 = DataView.ArrayBuffer(8 * 7)
    local struct2 = DataView.ArrayBuffer(8 * 8)

    struct1:SetInt32(0, duration or 3000)

    struct2:SetInt64(8 * 1, bigInt(_text))
    struct2:SetInt32(8 * 3, 0)
    struct2:SetInt64(8 * 4, bigInt(GetHashKey(_dict)))
    struct2:SetInt64(8 * 5, bigInt(GetHashKey(_icon)))
    struct2:SetInt64(8 * 6, bigInt(GetHashKey(text_color or "COLOR_WHITE")))

    Citizen.InvokeNative(0x26E87218390E6729, struct1:Buffer(), struct2:Buffer(), 1, 1)
end)

exports("ShowTopNotification", function(title, subtitle, duration)
    local struct1 = DataView.ArrayBuffer(8 * 7)
    struct1:SetInt32(0, duration or 3000)

    local _title = CreateVarString(10, "LITERAL_STRING", title)
    local _subtitle = CreateVarString(10, "LITERAL_STRING", subtitle)

    local struct2 = DataView.ArrayBuffer(8 * 7)
    struct2:SetInt64(8 * 1, bigInt(_title))
    struct2:SetInt64(8 * 2, bigInt(_subtitle))

    Citizen.InvokeNative(0xA6F4216AB10EB08E, struct1:Buffer(), struct2:Buffer(), 1, 1)
end)

exports("ShowObjective", function(text, duration)
    Citizen.InvokeNative(0xDD1232B332CBB9E7, 3, 1, 0)

    local _text = CreateVarString(10, "LITERAL_STRING", text)

    local struct1 = DataView.ArrayBuffer(8 * 7)
    local struct2 = DataView.ArrayBuffer(8 * 3)

    struct1:SetInt32(0, duration or 3000)
    struct2:SetInt64(8 * 1, bigInt(_text))

    Citizen.InvokeNative(0xCEDBF17EFCC0E4A4, struct1:Buffer(), struct2:Buffer(), 1)
end)
