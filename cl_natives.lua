GetCurrentVehicle = function()
    return GetVehiclePedIsIn(PlayerPedId(), false)
end

GetCurrentWeapon = function()
    return GetSelectedPedWeapon(PlayerPedId())
end