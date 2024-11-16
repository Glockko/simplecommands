function Round(num, dp)
    local mult = 10 ^ (dp or 0)
    return math.floor(num * mult + 0.5) / mult
end


-- Get position coords
RegisterCommand("getpos", function(source, args)
    local playerCoords = GetEntityCoords(PlayerPedId())

    TriggerEvent('chat:addMessage', {
        args = { "Coords", Round(playerCoords.x, 4) .. "   " .. Round(playerCoords.y, 4) .. "   " .. Round(playerCoords.z, 4) }
    })
end, false)

RegisterCommand("getrot", function(source, args)
    local camRotation = GetGameplayCamRot(0)

    TriggerEvent('chat:addMessage', {
        args = { "CamRotation", Round(camRotation.x, 4) .. "   " .. Round(camRotation.y, 4) .. "   " .. Round(camRotation.z, 4) }
    })
end, false)


--change Ped
RegisterCommand("ped", function(source, args)
    print(source)
    local model = args[1]
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end
end, false)


-- Set Time
RegisterCommand("time", function(source, args)
    local hour = args[1] or 12
    local min = args[2] or 00
    local sec = args[3] or 00
    NetworkOverrideClockTime(tonumber(hour), tonumber(min), tonumber(sec))
end, false)


-- Speedometer and Fuel level HUD
if true --[[Config.EnableHUD]] then
    local function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, jus)
        SetTextFont(font)
        SetTextProportional(0)
        SetTextScale(sc, sc)
        N_0x4e096588b13ffeca(jus)
        SetTextColour(r, g, b, a)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x - 0.1 + w, y - 0.02 + h)
    end

    local mph = 0
    local kmh = 0
    local fuel = 0
    local displayHud = false

    local x = -0.370
    local y = -0.190

    Citizen.CreateThread(function()
        while true do
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped) --[[and not (Config.RemoveHUDForBlacklistedVehicle and inBlacklisted)]] then
                local vehicle = GetVehiclePedIsIn(ped)
                local speed = GetEntitySpeed(vehicle)

                mph = tostring(math.ceil(speed * 2.236936))
                kmh = tostring(math.ceil(speed * 3.6))
                fuel = tostring(math.ceil(GetVehicleFuelLevel(vehicle)))

                displayHud = true
            else
                displayHud = false

                Citizen.Wait(500)
            end

            Citizen.Wait(50)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            if displayHud then
                local color = getColorFromValue(mph)
                DrawAdvancedText(0.130 - x, 0.77 - y, 0.005, 0.0028, 0.8, mph, color[1], color[2], color[3], 255, 6, 1)
                DrawAdvancedText(0.200 - x, 0.77 - y, 0.005, 0.0028, 0.8, kmh, color[1], color[2], color[3], 255, 6, 1)
                DrawAdvancedText(0.273 - x, 0.77 - y, 0.005, 0.0028, 0.8, fuel, 255, 255, 255, 255, 6, 1)
                DrawAdvancedText(0.155 - x, 0.7765 - y, 0.005, 0.0028, 0.6, "mp/h               km/h               Fuel",
                    255, 255, 255, 255, 6, 1)
            else
                Citizen.Wait(750)
            end

            Citizen.Wait(0)
        end
    end)
end

-- Function to interpolate between two colors
function interpolateColor(value, minVal, maxVal, colorStart, colorEnd)
    local t = (value - minVal) / (maxVal - minVal)
    t = math.max(0, math.min(1, t)) -- Clamp 't' between 0 and 1

    local r = math.floor(colorStart[1] + (colorEnd[1] - colorStart[1]) * t)
    local g = math.floor(colorStart[2] + (colorEnd[2] - colorStart[2]) * t)
    local b = math.floor(colorStart[3] + (colorEnd[3] - colorStart[3]) * t)

    return { r, g, b }
end

-- Function to get RGB color based on the integer
function getColorFromValue(value)
    value = tonumber(value)
    if value < 100 then
        return { 255, 255, 255 }                                               -- White
    else
        return interpolateColor(value, 100, 150, { 255, 255, 0 }, { 255, 0, 0 }) -- Yellow to Red
    end
end

-- Minimap zoom
Citizen.CreateThread(function()
    local zoomToggle = false
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(2, 20) then
            zoomToggle = not zoomToggle
            SetBigmapActive(zoomToggle, false)
        end
    end
end)

-- Minimap Full map
local bigToggle = false
RegisterCommand("bigmap", function()
    bigToggle = not bigToggle
    SetBigmapActive(bigToggle, bigToggle)
end)
