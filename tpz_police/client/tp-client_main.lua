local TPZ = exports.tpz_core:getCoreAPI()

local PlayerData = { 
    IsBusy    = false,

    IsLocationBusy       = false,
    LocationIndex        = 0, -- Config.Locations

    SelectedVehicleIndex = 1,
	SelectedVehicleNameIndex = nil,

    VehicleEntity        = nil,
	VehicleEntityModel   = nil,
    CameraHandler        = nil,

    Job       = nil,
    JobGrade  = 0,

    IsHandcuffed = false,
    IsShowingBadge = false,

    ThreadsRunning = false,

    LocationIndex = nil,

    Loaded    = true -- FIX!
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
