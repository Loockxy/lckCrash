local player = {}

AddEventHandler('playerJoining', function(source)
    local license = GetPlayerIdentifierByType(source, "license")
    if player[license] then
        print("Data Loaded", json.encode(player[license], {indent = true}))
        TriggerClientEvent('lckCrash:client:rejoin', source, player[license])
        player[license] = nil
    end
end)

RegisterServerEvent('lckCrash:enteredVehicle', function(vehicle, seat)
    local source = source
    local license = GetPlayerIdentifierByType(source, "license")
    Wait(100)
    local vehicleNet = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source), false))
    
    player[license] = {vehicle = vehicle, seat = seat, vehicleNet = vehicleNet}
    print("Data Saved", json.encode(player[license], {indent = true}))
end)

RegisterServerEvent('lckCrash:leftVehicle', function(vehicle, seat)
    local source = source
    local license = GetPlayerIdentifierByType(source, "license")
    player[license] = nil
    print("Data Deleted", json.encode(player[license], {indent = true}))
end)

RegisterServerEvent('lckCrash:rejoined', function(vehicleNet)
    local source = source
    SetEntityCoords(GetPlayerPed(source), GetEntityCoords(NetworkGetEntityFromNetworkId(vehicleNet)).x, GetEntityCoords(NetworkGetEntityFromNetworkId(vehicleNet)).y, GetEntityCoords(NetworkGetEntityFromNetworkId(vehicleNet)).z - 10)
end)