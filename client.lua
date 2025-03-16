local loadingscreen = false
local ready = false

AddEventHandler('esx:loadingScreenOff', function()
    loadingscreen = true
    while not DoesEntityExist(PlayerPedId()) do
        Wait(100)
    end
    ready = true
end)

RegisterNetEvent('lckCrash:client:rejoin', function(data)
    while not loadingscreen or not ready do
        Wait(100)
    end

    local vehicle = NetworkGetEntityFromNetworkId(data.vehicleNet)
    local seat = -1
    
    print("Data Received", json.encode(data, {indent = true}))

    Wait(200)

    TriggerServerEvent("lckCrash:rejoined", data.vehicleNet)

    Wait(200)

    if DoesEntityExist(vehicle) then
        local inside = false
        while not inside do
            SetEntityCoords(PlayerPedId(), GetEntityCoords(vehicle).x, GetEntityCoords(vehicle).y, GetEntityCoords(vehicle).z - 10)
            if IsVehicleSeatFree(vehicle, seat) then
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, seat)
                inside = true
            elseif seat < 6 then
                seat = seat + 1
            elseif seat > 6 then
                return print("Aucune place libre dans le véhicule")
            end
            Wait(500)
        end
    end
end)

local isEnteringVehicle = false
local isInVehicle = false
local currentVehicle = 0
local currentSeat = 0

CreateThread(function()
    while true do
        local ped = PlayerPedId()

		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
                local seat = -1
                for i = 1, GetVehicleMaxNumberOfPassengers(currentVehicle) do
                    if GetPedInVehicleSeat(currentVehicle, i) == ped then
                        currentSeat = seat + i
                        break
                    end
                end
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerServerEvent('lckCrash:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
				-- bye, vehicle
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerServerEvent('lckCrash:leftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end
        Wait(1000)
    end
end)