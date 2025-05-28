local TPZ = exports.tpz_core:getCoreAPI()

local PlayerData = { 
    IsBusy    = false,

    IsLocationBusy           = false,
    LocationIndex            = 0, -- Config.Locations

    SelectedVehicleIndex     = 1,
	SelectedVehicleNameIndex = nil,

    VehicleEntity            = nil,
	VehicleEntityModel       = nil,
    CameraHandler            = nil,

    Job                      = nil,
    JobGrade                 = 0,

    IsHandcuffed             = false,
    IsShowingBadge           = false,

    ThreadsRunning           = false,

    LocationIndex            = nil,

    IsJailed                 = false,

    Loaded                   = false,
}

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local DoesHavePermittedJob = function()
	local PlayerData  = GetPlayerData()

	for _, job in pairs (Config.PoliceJobs) do

        if PlayerData.Job == job then
            return true
        end

	end

	return false

end

local GetNearbyJail = function()
    local player          = PlayerPedId()
    local coords          = GetEntityCoords(player)
    local closestDistance = math.huge
    local closestLocation = nil

    for _, location in pairs(Config.Jails) do

        local locationCoords = vector3(location.JailInCoords.x, location.JailInCoords.y, location.JailInCoords.z)
        local currentDistance = #(coords - locationCoords)
    
        if currentDistance <= closestDistance then

            closestDistance = currentDistance
            closestLocation = location

        end

    end

    if closestLocation then
        return closestLocation
    else
        return false
    end

end

-----------------------------------------------------------
--[[ Public Functions ]]--
-----------------------------------------------------------

GetPlayerData = function()
    return PlayerData
end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

-- Requests the player data when the player is loaded.
AddEventHandler("tpz_core:isPlayerReady", function()
    Wait(2000)

    local data = TPZ.GetPlayerClientData()

    if data == nil then
        return
    end

    PlayerData.Job = data.job
    PlayerData.JobGrade = data.jobGrade

    TriggerServerEvent("tpz_police:server:requestJailTime")
    TriggerServerEvent("tpz_police:server:addChatSuggestions")

    -- The specified code checks if wagons are enabled and if player belongs to a police job.
    -- If the player belongs to a police job, we enable the threads.
    if Config.SpawnWagons then

        if DoesHavePermittedJob() and not PlayerData.ThreadsRunning then
            StartPoliceWagonThreads()
        end

    end

    PlayerData.Loaded = true

end)

if Config.DevMode then

    Citizen.CreateThread(function ()
        Wait(2000)

        local data = TPZ.GetPlayerClientData()

        if data == nil then
            return
        end
    
        PlayerData.Job = data.job
        PlayerData.JobGrade = data.jobGrade

        TriggerServerEvent("tpz_police:server:requestJailTime")
        TriggerServerEvent("tpz_police:server:addChatSuggestions")

        -- The specified code checks if wagons are enabled and if player belongs to a police job.
        -- If the player belongs to a police job, we enable the threads.
        if Config.SpawnWagons then

            if DoesHavePermittedJob() and not PlayerData.ThreadsRunning then
                StartPoliceWagonThreads()
            end

        end

        PlayerData.Loaded = true

    end)

end

-- Updates the player job.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    PlayerData.Job = data.job

    if data.jobGrade ~= nil then
        PlayerData.JobGrade = data.jobGrade
    end
    
    -- The specified code checks if wagons are enabled and if player belongs to a police job.
    -- If the player belongs to a police job, we enable the threads.
    if Config.SpawnWagons then

        if DoesHavePermittedJob() and not PlayerData.ThreadsRunning then
            StartPoliceWagonThreads()
        end
    
        -- In case player no longer belongs to a police job and has threads running, we cancel them.
        if not DoesHavePermittedJob() and PlayerData.ThreadsRunning then
            PlayerData.ThreadsRunning = false
        end

    end
    
end)

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_police:client:setCharacterAsJailed")
AddEventHandler("tpz_police:client:setCharacterAsJailed", function(isJailed)
    local player = PlayerPedId()

    if (not PlayerData.IsJailed and not isJailed) or ( PlayerData.IsJailed and isJailed) then
        return
    end

    local NearbyJail = GetNearbyJail()

    if not NearbyJail then
        return
    end

    
    while not IsScreenFadedOut() do
        Wait(50)
        DoScreenFadeOut(2000)
    end

    TaskStandStill(player, -1)

    PlayerData.IsJailed = isJailed

    if not isJailed then
        TPZ.TeleportToCoords(NearbyJail.JailOutCoords.x, NearbyJail.JailOutCoords.y, NearbyJail.JailOutCoords.z, NearbyJail.JailOutCoords.h)
    else
        TPZ.TeleportToCoords(NearbyJail.JailInCoords.x, NearbyJail.JailInCoords.y, NearbyJail.JailInCoords.z, NearbyJail.JailInCoords.h)
        OnJailedCharacterThread()
    end

    Wait(4000)
    DoScreenFadeIn(2000)
    Wait(1000)
    TaskStandStill(player, 1)
end)


-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

function OnJailedCharacterThread()

    Citizen.CreateThread(function()

        while true do

            Wait(60000)

            if not PlayerData.IsJailed then
                break
            end

            TriggerServerEvent("tpz_police:server:requestJailTime")
        end
    
    end)

end
