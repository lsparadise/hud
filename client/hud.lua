local seatbeltCallback = function() return false end
local speedLimitCallback = function() return 0 end

AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkPlayerEnteredVehicle' then
        local player, vehicle = table.unpack(data)
        if player == PlayerId() then
            local vehicleModel = GetEntityModel(vehicle)
            local isElectric = GetVehicleHasFlag(vehicle, 43)
            if not IsThisModelABicycle(vehicleModel) then
                SendNUIMessage({
                    action = 'open'
                })
                CreateThread(function()
                    local hide = false
                    local maxSpeed = GetVehicleModelEstimatedMaxSpeed(vehicleModel) * 1.2
                    local maxFuel = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
                    if isElectric then
                        maxFuel = 0
                    end
                    while true do
                        if not hide and IsPauseMenuActive() then
                            SendNUIMessage({
                                action = 'close'
                            })
                            hide = true
                        elseif hide and not IsPauseMenuActive() then
                            SendNUIMessage({
                                action = 'open'
                            })
                            hide = false
                        end
                        local playerPed = PlayerPedId()
                        if not IsPedInAnyVehicle(playerPed) then
                            SendNUIMessage({
                                action = 'close'
                            })
                            return
                        end
                        local safeZone = ((1.0 - GetSafeZoneSize()) / 2)
                        local offset = IsMinimapRendering() and 0.152 or 0.0
                        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                            local tiresAlert = false
                            for _, wheelId in ipairs({ 0, 1, 2, 3, 4, 5, 45, 47 }) do
                                if IsVehicleTyreBurst(vehicle, wheelId) then
                                    tiresAlert = true
                                end
                            end
                            local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
                            SendNUIMessage({
                                passenger = false,
                                doors = GetVehicleDoorLockStatus(vehicle),
                                blinkers = GetVehicleIndicatorLights(vehicle),
                                tires = tiresAlert,
                                engine = GetVehicleEngineHealth(vehicle),
                                speed = GetEntitySpeed(vehicle),
                                maxSpeed = maxSpeed,
                                lights = lightsOn,
                                highbeams = highbeamsOn,
                                fuel = GetVehicleFuelLevel(vehicle) * 100 / maxFuel,
                                maxFuel = maxFuel,
                                seatbelt = seatbeltCallback(),
                                speedLimit = speedLimitCallback(),
                                pos = {
                                    x = safeZone + offset,
                                    y = safeZone
                                }
                            })
                        else
                            SendNUIMessage({
                                passenger = true,
                                doors = GetVehicleDoorLockStatus(vehicle),
                                seatbelt = seatbeltCallback(),
                                pos = {
                                    x = safeZone + offset,
                                    y = safeZone
                                }
                            })
                        end
                        Wait(50)
                    end
                end)
            end
        end
    end
end)

function registerSeatbeltFunction(callback)
    seatbeltCallback = callback
end

function registerSpeedLimitFunction(callback)
    speedLimitCallback = callback
end
