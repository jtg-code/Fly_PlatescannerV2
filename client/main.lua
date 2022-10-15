function ShowNotification(text)
    if Config.Notify == 1 then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    elseif Config.Notify == 2 then
        ESX.ShowNotification(text, "info", 3000)
    elseif Config.Notify == 3 then
        TriggerEvent("FlyPlatescanner:Notify")
    end
end

active = false
allowed = 50.0

blacklist = {}

displayLog = false

displayPlate = false

displaySpeed = false

CameraObj = 0


RegisterCommand(Config.SpeedMenu, function(source, args)
    OpenSpeedMenu(Config.NeedJob)
end, false)

RegisterCommand(Config.Billcommand, function(source, args)
    ESX.TriggerServerCallback("FlyScanner:GetBills", function(platelist)
        if #platelist > 0 then
            local elements = {}
            for k, v in pairs(platelist) do
                table.insert(elements, {label = v.Price.."€ | "..v.Speed.."KM/H", value = v.id, price = v.Price})
            end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billList', {
                title = _U('bills'),
                align = 'left',
                elements = elements
            },
            function(data, menu)
                if data.current then
                    TriggerServerEvent("FlyScanner:PayBill", data.current.value, data.current.price)
                    ShowNotification(_U('payed_bill', data.current.price))
                    menu.close()
                end
            end,
            function(data, menu)
                menu.close()
            end)
        else
            ShowNotification(_U('no_bills'))
        end
    end)
end)

RegisterNetEvent("FlyScanner:OpenSpeedMenu", function(needJob)
    OpenSpeedMenu(needJob)
end)
function OpenSpeedMenu(jobNeed)
    if jobNeed then
        ESX.TriggerServerCallback("FlyScanner:GetJob", function(cb) 
            if contain(Config.AllowedJobs, cb.name) then
                SpeedMenu()
            else
                ShowNotification(_U('no_perms'))
            end
        end)
    else
        SpeedMenu()
    end
end



function SpeedMenu()
    if Config.Menutype == 1 then
        ESX.UI.Menu.CloseAll()
        Wait(3)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'speedSettings', {
            title = _U('vehicles'),
            align = 'left',
            elements = {
                {label = _U('speed'), type = "slider", min = 1, max = 1000, value = 50, name = "speedSlider"},
                {label = _U('set_speed'), name = "set_speed"},
                {label = _U('toggle_speedcamera'), name = "toggle"}
            }
        },
        function(data, menu)
            if data.current then
                if data.current.name == "toggle" then

                    if active then
                        SpeedCamera(false)
                        
                    else
                        SpeedCamera(true)
                        
                    end
                elseif data.current.name == "set_speed" then
                    local speed = tonumber(data.elements[1].value)
                    allowed = speed + 0.1
                    ShowNotification(_U('set_speed_to', speed..".0"))
                end
            end
        end,
        function(data, menu)
            menu.close()
        end)
    elseif Config.Menutype == 2 then
        SetSpeedVisible(true)
    end
end

function SpeedCamera(state)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then
        local coords = GetEntityCoords(ped)
        if state then
            if not DoesEntityExist(CameraObj) then
                active = true
                PlayAnim('amb@prop_human_bum_bin@base', 'base',  Config.SetupTime)
                ShowNotification(_U('speed_camera_on'))
                local x, y, z = table.unpack(GetEntityForwardVector(ped) + coords)
                local objCoords = vector3(x, y, z - 1.0)
                ESX.Game.SpawnObject(Config.SpeedCamera, objCoords, function(obj)
                    CameraObj = obj
                    FreezeEntityPosition(CameraObj, true)
                end)
            else
                ShowNotification(_U('already_active'))
            end
        else
            if DoesEntityExist(CameraObj) then
                local dist = Vdist(GetEntityCoords(CameraObj), coords)
                if dist < 2.0 then
                    active = false
                    ShowNotification(_U('speed_camera_off'))
                    PlayAnim('amb@prop_human_bum_bin@base', 'base',  Config.SetupTime)
                    ESX.Game.DeleteObject(CameraObj)
                    CameraObj = 0
                else
                    ShowNotification(_U('out_range'))
                end
            else
                ShowNotification(_U('not_active'))
            end
        end
    end
end

CreateThread(function()
    local sleep = 4000
    local ped = PlayerPedId()
    while true do
        if active then
            if DoesEntityExist(CameraObj) then
                sleep = 15
                local coords = GetEntityCoords(CameraObj)
                local x, y, z = table.unpack(coords)
                coords = vector3(x, y, z - 0.25)
                local forward_vector = GetEntityForwardVector(CameraObj) * -1
                DrawLine(coords, coords+(forward_vector*30.0), 255,0,0,255) -- debug line to show LOS of cam
                local rayhandle = StartShapeTestRay(coords, coords + (forward_vector * 30.0), 10, CameraObj, 0)
                local _, _, _, _, entityHit = GetShapeTestResult(rayhandle)
                if entityHit ~= 0 and IsEntityAVehicle(entityHit) then
                    if GetEntitySpeed(entityHit) * 3.6 >= allowed then
                        BlitzerNotify(entityHit, GetEntitySpeed(entityHit) * 3.6)
                    end
                else
                    
                end
            end

        else
            sleep = 4000
        end
        Wait(sleep)
    end
end)

function PlayAnim(dict, name, time)
    local ped = PlayerPedId()
    local dictname = dict
    local animName = name
    RequestAnimDict(dictname)
    while not HasAnimDictLoaded(dictname) do
        Citizen.Wait(10)
    end
    TaskPlayAnimAdvanced(ped, dictname, animName, GetEntityCoords(ped), GetEntityRotation(ped), 8.0, 80.0, time, 1, 0.0, 0.0, nil, nil)
    Wait(time)
    RemoveAnimDict(animName)
end




RegisterCommand(Config.Checkplate, function(source, args)
    ESX.TriggerServerCallback("FlyScanner:CheckPlate", function(cb) 
        ShowNotification(cb)
    end, args[1])
end)


function BlitzerNotify(veh, speed)
    if not Contains(blacklist, veh) then
        if Config.SaveLog then
            AddToLog(veh, speed)
        end
        table.insert(blacklist, veh)
        local props = ESX.Game.GetVehicleProperties(veh)
        local ped = GetPedInVehicleSeat(veh, -1)
        local mugshot, mugshotStr = ESX.Game.GetPedMugshot(ped)
        local name = GetDisplayNameFromVehicleModel(props.model)
        ESX.ShowAdvancedNotification(_U('speed_camera'), name, _U('notify', tostring(props.plate), ((math.round((speed - allowed), 1)))), mugshotStr, 1)
        UnregisterPedheadshot(mugshot)
    else
        Wait(1 * 1000)
        RemoveValue(veh)
    end

end

function Contains(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function RemoveValue(value)
    for k, v in pairs(blacklist) do
        if v == value then
            table.remove(blacklist, k)
            break
        end
    end
end

function AddToLog(veh, tempo)
    local props = ESX.Game.GetVehicleProperties(veh)
    local driver = GetPedInVehicleSeat(veh, -1)
    if IsPedAPlayer(driver) then
        local players = GetActivePlayers()
        for k , v in pairs(players) do
            if GetPlayerPed(v) == driver then 
                local id = GetPlayerServerId(v)
                if Config.SaveLog then
                    TriggerServerEvent("FlyScanner:SaveLog", id, tostring(ESX.Math.Round((tempo - allowed))), ESX.Math.Round((tempo - allowed)) * Config.Fine)
                end
            end
        end
    else
        TriggerServerEvent("FlyScanner:SaveLog", _U('unknown'), tostring(ESX.Math.Round((tempo - allowed))), 0)
    end
end


RegisterCommand(Config.Platelog, function(source, args)
    if Config.NeedJob then
        ESX.TriggerServerCallback("FlyScanner:GetJob", function(cb) 
            if contain(Config.AllowedJobs, cb.name) then
                OpenPlateLog()
            else
                ShowNotification(_U('no_perms'))
            end
        end)
    else
        OpenPlateLog()
    end

end, false)

-- RegisterCommand("SaveInDB", function(source, args)
--     TriggerServerEvent("FlyScanner:SaveLog", _U('unknown'), "1", 1)
-- end)

function OpenPlateLog()
    ESX.UI.Menu.CloseAll()
    local elements = {}
    ESX.TriggerServerCallback("FlyScanner:GetPlates", function(platelist)
        if #platelist > 0 then
            for k, v in pairs(platelist) do
                table.insert(elements, {label = v.Name.." | "..v.Speed, date = v.date, value = v.id, speed = v.Speed, driver = v.Name})
            end
            if Config.Menutype == 1 then
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'plateloglist', {
                    title = _U('vehicles'),
                    align = 'left',
                    elements = elements
                },
                function(data, menu)
                    if data.current then
                        Extradata(data.current)
                        menu.close()
                    end
                end,
                function(data, menu)
                    menu.close()
                end)
            elseif Config.Menutype == 2 then
                if not displayLog then
                    if #platelist > 0 then
                        SetLogVisible(true)
                        Wait(3)
                        for k, v in pairs(platelist) do
                            SendNUIMessage({
                                type = "logAddEntry",
                                Name = tostring(v.Name),
                                Date = tostring(v.date),
                                Speed = tostring(v.Speed),
                                Fine = tostring(v.Price),
                                id = tostring(v.id)
                            })
                        end
                    else
                        ShowNotification(_U('no_log'))
                    end
    
                else
                    SetLogVisible(false)
                    SendNUIMessage({
                        type = "logReload"
                    })
                end
    
            end
        else
            ShowNotification(_U('no_log'))
        end
    end)
end

RegisterNUICallback("exit", function(data)
    SetLogVisible(false)
    SetSpeedVisible(false)
    SetPlateVisible(false)
end)

RegisterNUICallback("setActive", function(data)
    SpeedCamera(data.state)
end)

RegisterNUICallback("revoke", function(data)
    SendNUIMessage({
        type = "logReload"
    })
    Wait(100)
    TriggerServerEvent("FlyScanner:Revoke", data.id)
end)

RegisterNetEvent("FlyScanner:SendPlate", function(plates)
    Wait(100)
    for k, v in pairs(plates) do
        SendNUIMessage({
            type = "logAddEntry",
            Name = tostring(v.Name),
            Date = tostring(v.date),
            Speed = tostring(v.Speed),
            Fine = tostring(v.Price),
            id = tostring(v.id)
        })
    end
end)



RegisterNUICallback("setspeed", function(data)
    allowed = tonumber(data.speed)
    ShowNotification(_U('set_speed_to', allowed..".0"))
end)

function SetLogVisible(state)
    displayLog = state
    Wait(10)
    SetNuiFocus(state, state)
    SendNUIMessage({
        type = "logVisible",
        status = state,
    })
end

function SetSpeedVisible(state)
    displaySpeed = state
    Wait(10)
    SetNuiFocus(state, state)
    SendNUIMessage({
        type = "speedVisible",
        status = state,
    })
end

function Extradata(current)
    local element = {
        {label = current.driver},
        {label = current.speed.."KM/H"},
        {label = current.date},
        {label = _U('revoke'), value = "revoke"},
    }
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'data', {
        title = current.label,
        align = 'left',
        elements = element
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "revoke" then
                TriggerServerEvent("FlyScanner:Revoke", current.value)
                menu.close()
                Wait(500)
                OpenPlateLog()
            end
        end
    end,
    function(data, menu)
        menu.close()
        OpenPlateLog()
    end)
end



function contain(table, value)
    for k, v in pairs(Config.AllowedJobs) do
        if v == value then
            return true
        end
    end
    return false
end

function _contain(table, value)
    for k, v in pairs(Config.Cars) do
        if GetHashKey(v) == value then
            return true
        end
    end
    return false
end

RegisterCommand(Config.EnableScanner, function(source, args)
    if Config.NeedJob2 then
        ESX.TriggerServerCallback("FlyScanner:GetJob", function(cb) 
            if contain(Config.AllowedJobs, cb.name) then
                SetPlateVisible(not displayPlate)
            else
                ShowNotification(_U('no_perms'))
            end
        end)
    else
        SetPlateVisible(not displayPlate)
    end
end)

function SetPlateVisible(state)
    displayPlate = state
    Wait(10)
    SetNuiFocus(state, state)
    SendNUIMessage({
        type = "plateVisible",
        status = state,
    })
end