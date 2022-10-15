ESX.RegisterServerCallback("FlyScanner:GetJob", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()
    cb(job)
end)



ESX.RegisterServerCallback("FlyScanner:CheckPlate", function(source, cb, plate)
    if Config.UseFlyGarage then
        MySQL.query('SELECT * FROM fly_garage WHERE plate = @id', {["@id"] = plate}, function(result)
            if result ~= nil then
                if #result > 0 then
                    local owner = result[1].owner
                    local xPlayer = ESX.GetPlayerFromIdentifier(owner)
                    local name = xPlayer.getName()
                    cb(_U('owned_by', name))
                else
                    cb(_U('owned_by_nobody'))
                end
            else
                cb(_U('owned_by_nobody'))
            end
        end)
    else
        MySQL.query('SELECT * FROM owned_vehicles WHERE plate = @id', {["@id"] = plate}, function(result)
            if result ~= nil then
                if #result > 0 then
                    local owner = result[1].owner
                    local xPlayer = ESX.GetPlayerFromIdentifier(owner)
                    local name = xPlayer.getName()
                    cb(_U('owned_by', name))
                else
                    cb(_U('owned_by_nobody'))
                end
            else
                cb(_U('owned_by_nobody'))
            end
        end)
    end
end)

ESX.RegisterServerCallback("FlyScanner:GetName", function(source, cb, id)
    local xPlayer = ESX.GetPlayerFromId(id)
    local name = xPlayer.getName()
    cb(name)
end)

RegisterNetEvent("FlyScanner:SaveLog", function(id, speed, price)
    local xPlayer = ESX.GetPlayerFromId(id)
    local Identifier = xPlayer.getIdentifier()
    local Name = xPlayer.getName()
    local years, months, days, hours, minutes, seconds = tonumber(os.date("%y")), tonumber(os.date("%m")), tonumber(os.date("%d")), tonumber(os.date("%H")), tonumber(os.date("%M")), tonumber(os.date("%S"))
    local date = days.."."..months.."."..years.." | "..hours..":"..minutes..":"..seconds
    MySQL.Async.fetchAll('INSERT INTO fly_platescanner (date, Name, Speed, Price, Identifier, id) VALUES (@date, @Name, @Speed, @price, @Identifier, NULL)',{["@Name"] = Name, ["@Identifier"] = Identifier, ["@price"] = tostring(price), ["@date"] = date, ["@Speed"] = tostring(speed)}, function(result)
        xPlayer.showNotification(_U('got_fine', price), true, true)
    end)
end)

ESX.RegisterServerCallback("FlyScanner:GetPlates", function(source, cb)
    MySQL.query('SELECT * FROM fly_platescanner', {}, function(result)
        if result ~= nil then
            cb(result)
        end
    end)
end)

ESX.RegisterServerCallback("FlyScanner:GetBills", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.query('SELECT * FROM fly_platescanner WHERE Identifier = @id', {["@id"] = identifier}, function(result)
        if result ~= nil then
            cb(result)
        end
    end)
end)

RegisterNetEvent("FlyScanner:Revoke", function(id)
    local src = source
    MySQL.Async.fetchAll('DELETE FROM fly_platescanner WHERE id = @id',{["@id"] = id}, function(result)
        if result ~= nil then
            Wait(10)
            MySQL.query('SELECT * FROM fly_platescanner', {}, function(result)
                if result ~= nil then
                    Wait(10)
                    TriggerClientEvent("FlyScanner:SendPlate", tonumber(src), result)
                end
            end)
        else
            print("error")
        end
    end)
end)

RegisterNetEvent("FlyScanner:PayBill", function(id, money)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.removeMoney(tonumber(money))
    MySQL.Async.fetchAll('DELETE FROM fly_platescanner WHERE id = @id',{["@id"] = id}, function(result)
        if result ~= nil then
            print("worked")
        else
            print("error")
        end
    end)
end)