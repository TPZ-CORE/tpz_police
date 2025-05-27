local TPZ = exports.tpz_core:getCoreAPI()

local VehicleStoreTimeCooldown = -1

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local DoesHavePermittedJob = function(locationIndex)
	local PlayerData  = GetPlayerData()
    local LocationData = Config.Locations[locationIndex]

	-- Check if the player's JobGrade is in the wagon's permitted grades
	for _, job in pairs (LocationData.PoliceJobs) do

        if PlayerData.Job == job then
            return true
        end

	end

	return false

end

local GetLocationWagonsList = function(locationIndex)
	local PlayerData = GetPlayerData()
	local cb         = {}

    -- First we get all the wagons by the location.
	local locationWagonsList = Config.Locations[locationIndex].Wagons

	-- Second, we load all the available vehicles by job and grade.
	for index, wagon in pairs (locationWagonsList) do

        for job, grades in pairs(wagon.PermittedJobGrades) do

            for _, grade in pairs (grades) do

                if PlayerData.Job == job and tonumber(grade) == tonumber(PlayerData.JobGrade) then
                    table.insert(cb, wagon)
                end

            end

        end

    end

	-- Returns all the available transport wagons and coaches properly on a table.
	return cb
end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)

	if resource ~= GetCurrentResourceName() then
		return
	end

    local PlayerData = GetPlayerData()

	if PlayerData.VehicleEntity then
		DeleteVehicle(PlayerData.VehicleEntity)
		SetEntityAsNoLongerNeeded(PlayerData.VehicleEntity )
		SetModelAsNoLongerNeeded(GetHashKey(PlayerData.VehicleEntityModel))
	end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

    function StartPoliceWagonThreads()

        local PlayerData = GetPlayerData()

        PlayerData.ThreadsRunning = true

        Citizen.CreateThread(function()

            RegisterActionPrompt()
        
            while true do
                Wait(0)
        
                local sleep      = true
                local PlayerData = GetPlayerData()

                if not PlayerData.ThreadsRunning then
                    break
                end
        
                if PlayerData.Loaded then
        
                    local player     = PlayerPedId()
                    local coords     = GetEntityCoords(player)
                    local coordsDist = vector3(coords.x, coords.y, coords.z)
        
                    for index, location in pairs(Config.Locations) do
        
                        local locationCoords = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
                        local distance       = #(coordsDist - locationCoords)

                        if location.Marker.Enabled and distance <= location.Marker.DisplayDistance then 
                            sleep = false
                            
                            local MarkerData = location.Marker
                            local dr, dg, db, da, scale_x, scale_y, scale_z = MarkerData.RGBA.r, MarkerData.RGBA.g, MarkerData.RGBA.b, MarkerData.RGBA.a, MarkerData.RGBA.scale_x, MarkerData.RGBA.scale_y, MarkerData.RGBA.scale_z
                            Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, location.Coords.x, location.Coords.y, location.Coords.z, 0, 0, 0, 0, 0, 0, scale_x, scale_y, scale_z, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)
                        end

                        if distance <= location.ActionDistance and not PlayerData.IsBusy and not PlayerData.IsLocationBusy and not IsEntityDead(player) then
                            sleep = false

                            local PromptGroup, PromptList = GetPromptData()
        
                            local label = CreateVarString(10, 'LITERAL_STRING', Locales['PROMPT_ACTION'])
                            PromptSetActiveGroupThisFrame(PromptGroup, label)
        
                            if PromptHasHoldModeCompleted(PromptList) then

                                local nearVehicles = GetNearestVehicles(vector3(location.SelectVehicleCoords.x, location.SelectVehicleCoords.y, location.SelectVehicleCoords.z), Config.CheckNearbyVehicles, nil)
                                
                                if TPZ.GetTableLength(nearVehicles) <= 0 then
    
                                    PlayerData.SelectedVehicleIndex = 1
                                    PlayerData.LocationIndex        = index
        
                                    local availableWagons = GetLocationWagonsList(PlayerData.LocationIndex)
        
                                    if TPZ.GetTableLength(availableWagons) > 0 then
        
                                        PlayerData.IsLocationBusy = true
                                        
                                        while not IsScreenFadedOut() do
                                            Wait(50)
                                            DoScreenFadeOut(2000)
                                        end
                                        
                                        TaskStandStill(player, -1)
            
                                        local cameraCoords   = location.CameraCoords
                                        local handler = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.fov, false, 2)
                                    
                                        SetCamActive(handler, true)
                                        RenderScriptCams(true, false, 0, true, true, 0)
            
                                        PlayerData.CameraHandler = handler
                                        PlayerData.IsBusy        = true
            
                                        local WagonData = availableWagons[1]  -- Accessing the first element in the table
            
                                        PlayerData.SelectedVehicleNameIndex = availableWagons[1]
            
                                        LoadModel(WagonData.Model)
            
                                        local vehicle = CreateVehicle(GetHashKey(WagonData.Model), location.SelectVehicleCoords.x,  location.SelectVehicleCoords.y,  location.SelectVehicleCoords.z,  location.SelectVehicleCoords.h, false, false, false, false)
                                        SetVehicleOnGroundProperly(vehicle)
                                        FreezeEntityPosition(vehicle, true)
                                        SetEntityCollision(vehicle, false, true)
            
                                        Config.Locations[index].vehicleHandler = vehicle
            
                                        Wait(4000)
                                        DoScreenFadeIn(2000)
                                        Wait(1000)
                                            
                                    else
                                        SendNotification(nil, Locales['NO_WAGONS'], "error")
                                    end
    
                                else
                                    SendNotification(nil, Locales['CANNOT_SPAWN_SELECTED_VEHICLE'], "error")
                                end
    
                                Wait(1000)
    
                            end
                        end

                    end
        
                end
        
                if sleep then
                    Citizen.Wait(1000)
                end
        
            end
        
        end)
    
        Citizen.CreateThread(function()
    
            RegisterWagonActionPrompts()
        
            while true do
                Wait(0)
        
                local sleep = true
        
                local PlayerData = GetPlayerData()

                if not PlayerData.ThreadsRunning then
                    break
                end
        
                if PlayerData.IsLocationBusy then
                    sleep = false
        
                    local PromptGroup, PromptList = GetWagonsPromptData()
        
                    local label = CreateVarString(10, 'LITERAL_STRING', "#" .. PlayerData.SelectedVehicleIndex .. ' ' .. Config.Locations[PlayerData.LocationIndex].Wagons[PlayerData.SelectedVehicleIndex].Label) 
                    PromptSetActiveGroupThisFrame(PromptGroup, label)
        
                    for index, prompt in pairs (PromptList) do
                            
                        if PromptHasHoldModeCompleted(prompt.prompt) then
        
                            local availableWagons = GetLocationWagonsList(PlayerData.LocationIndex)
                            
                            local LocationData    = Config.Locations[PlayerData.LocationIndex]
                            local WagonData       = availableWagons[PlayerData.SelectedVehicleIndex] 
    
                            if prompt.type == 'NEXT' or prompt.type == 'PREVIOUS' then
        
                                DeleteVehicle(LocationData.vehicleHandler)
                                SetEntityAsNoLongerNeeded(LocationData.vehicleHandler )
                                SetModelAsNoLongerNeeded(GetHashKey(WagonData.Model))
        
                                if prompt.type == 'NEXT' then
        
                                    PlayerData.SelectedVehicleIndex = PlayerData.SelectedVehicleIndex + 1
        
                                    if availableWagons[PlayerData.SelectedVehicleIndex] == nil then
                                        PlayerData.SelectedVehicleIndex = 1
                                    end
        
                                else
        
                                    PlayerData.SelectedVehicleIndex = PlayerData.SelectedVehicleIndex - 1
        
                                    if PlayerData.SelectedVehicleIndex <= 0 then
                                        PlayerData.SelectedVehicleIndex = TPZ.GetTableLength(availableWagons)
                                    end
        
                                end
        
                                PlayerData.SelectedVehicleNameIndex = availableWagons[PlayerData.SelectedVehicleIndex]
        
                                local WagonData = availableWagons[PlayerData.SelectedVehicleIndex]
        
                                LoadModel(WagonData.Model)
                                
                                Wait(500)
        
                                local vehicle = CreateVehicle(GetHashKey(WagonData.Model), LocationData.SelectVehicleCoords.x, LocationData.SelectVehicleCoords.y, LocationData.SelectVehicleCoords.z, LocationData.SelectVehicleCoords.h, false, false, false, false)
        
                                SetVehicleOnGroundProperly(vehicle)
                                FreezeEntityPosition(vehicle, true)
                                SetEntityCollision(vehicle, false, true)
        
                                LocationData.vehicleHandler = vehicle
        
                            elseif prompt.type == 'SELECT' then
        
                                if PlayerData.VehicleEntity == nil then 
        
                                    local spawnVehicleCoords = vector3(LocationData.SpawnVehicleCoords.x, LocationData.SpawnVehicleCoords.y, LocationData.SpawnVehicleCoords.z)
                                    local nearVehicles       = GetNearestVehicles(spawnVehicleCoords, Config.CheckNearbyVehicles, LocationData.vehicleHandler)
                                
                                    if TPZ.GetTableLength(nearVehicles) <= 0 then
        
                                        while not IsScreenFadedOut() do
                                            Wait(50)
                                            DoScreenFadeOut(2000)
                                        end
    
                                        DeleteVehicle(LocationData.vehicleHandler)
                                        SetEntityAsNoLongerNeeded(LocationData.vehicleHandler )
                                        SetModelAsNoLongerNeeded(GetHashKey(WagonData.Model))
                
                                        DestroyAllCams(true)
                                        TaskStandStill(PlayerPedId(), 1)
            
                                        local vehicle = CreateVehicle(GetHashKey(WagonData.Model), LocationData.SpawnVehicleCoords.x, LocationData.SpawnVehicleCoords.y, LocationData.SpawnVehicleCoords.z, LocationData.SpawnVehicleCoords.h, true, false)
                                        SetVehicleOnGroundProperly(vehicle)
                                        SetModelAsNoLongerNeeded(GetHashKey(WagonData.Model))
            
                                        Citizen.InvokeNative(0x79811282A9D1AE56, vehicle)
                                        SetEntityHealth(vehicle, 1000, 0)
                                        Citizen.InvokeNative(0xAC2767ED8BDFAB15, vehicle, 1000)
                                        Citizen.InvokeNative(0x55CCAAE4F28C67A0, vehicle, 1000)
    
                                        Wait(1000)
                                        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
        
                                        Wait(4000)
                                        DoScreenFadeIn(2000)
                                        DisplayRadar(true)
    
                                        PlayerData.IsLocationBusy     = false
                                        PlayerData.IsBusy             = false
    
                                        PlayerData.VehicleEntity      = vehicle
                                        PlayerData.VehicleEntityModel = WagonData.Model
    
                                    else
                                        SendNotification(nil, Locales['CANNOT_SPAWN_SELECTED_VEHICLE'], "error")
                                    end
        
                                else
                                    SendNotification(nil, Locales['CANNOT_SPAWN_ALREADY_SPAWNED'], "error")
                                end
        
                            elseif prompt.type == 'EXIT' then
        
                                while not IsScreenFadedOut() do
                                    Wait(50)
                                    DoScreenFadeOut(2000)
                                end
        
                                DeleteVehicle(LocationData.vehicleHandler)
                                SetEntityAsNoLongerNeeded(LocationData.vehicleHandler )
                                SetModelAsNoLongerNeeded(GetHashKey(WagonData.Model))
        
                                PlayerData.IsLocationBusy = false
                                
                                DestroyAllCams(true)
                                TaskStandStill(PlayerPedId(), 1)
        
                                Wait(4000)
                                DoScreenFadeIn(2000)
                                DisplayRadar(true)
        
                            end
        
                            Citizen.Wait(1000)
                        end
        
        
                    end
        
        
                end
        
                if sleep then
                    Citizen.Wait(2000)
                end
        
            end
        
        end)
    
        Citizen.CreateThread(function()
    
            while true do
                Wait(0)
        
                local sleep = true
                local PlayerData = GetPlayerData()

                if not PlayerData.ThreadsRunning then
                    break
                end
        
                if PlayerData.Loaded and PlayerData.VehicleEntity then
                    
                    local player   = PlayerPedId()
                    local vehicle  = GetVehiclePedIsIn(player)
                    local driver   = GetPedInVehicleSeat(vehicle, -1)
        
                    if vehicle and vehicle == PlayerData.VehicleEntity and driver == player then
        
                        local coords         = GetEntityCoords(player)
                        local coordsDist     = vector3(coords.x, coords.y, coords.z)
        
                        for index, location in pairs(Config.Locations) do
        
                            local locationCoords = vector3(location.StoreVehicle.Coords.x, location.StoreVehicle.Coords.y, location.StoreVehicle.Coords.z)
                            local distance       = #(coordsDist - locationCoords)
        
                            if location.StoreVehicle.Marker.Enabled and distance <= location.StoreVehicle.Marker.DisplayDistance then 
                                sleep = false
                                
                                local MarkerData = location.StoreVehicle.Marker
                                local dr, dg, db, da, scale_x, scale_y, scale_z = MarkerData.RGBA.r, MarkerData.RGBA.g, MarkerData.RGBA.b, MarkerData.RGBA.a, MarkerData.RGBA.scale_x, MarkerData.RGBA.scale_y, MarkerData.RGBA.scale_z
                                Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, location.StoreVehicle.Coords.x, location.StoreVehicle.Coords.y, location.StoreVehicle.Coords.z, 0, 0, 0, 0, 0, 0, scale_x, scale_y, scale_z, dr, dg, db, da, 0, 0, 2, 0, 0, 0, 0)
                            end
        
                            -- STORE VEHICLE
                            if distance <= location.StoreVehicle.StoreVehicleDistance then
                                sleep = false
        
                                if VehicleStoreTimeCooldown == -1 then
                                    VehicleStoreTimeCooldown = Config.StoreVehicle.TotalTime
                                end
        
                                local r, g, b, a = Config.StoreVehicle.RGBA.r, Config.StoreVehicle.RGBA.g, Config.StoreVehicle.RGBA.b, Config.StoreVehicle.RGBA.a
                                DisplayHelp(string.format(Config.StoreVehicle.Label, tostring(VehicleStoreTimeCooldown)), 0.50, 0.90, 0.5, 0.5, true, r, g, b, a, true)
        
                                if VehicleStoreTimeCooldown <= 0 then
        
                                    while not IsScreenFadedOut() do
                                        Wait(50)
                                        DoScreenFadeOut(2000)
                                    end
    
                                    DeleteVehicle(PlayerData.VehicleEntity)		
                                    SetEntityAsNoLongerNeeded(PlayerData.VehicleEntity)
                                    SetModelAsNoLongerNeeded(GetHashKey(PlayerData.VehicleEntityModel))
        
                                    PlayerData.VehicleEntity      = nil
                                    PlayerData.VehicleEntityModel = nil
    
                                    SetEntityCoords(player, location.Coords.x, location.Coords.y, location.Coords.z, true)
                                    SetEntityHeading(player, location.Coords.h)
        
                                    Wait(2000)
                                    DoScreenFadeIn(2000)
    
                                    SendNotification(nil, Locales['STORED_SUCCESSFULLY'], "success") 
        
                                end
        
                            else
                                VehicleStoreTimeCooldown = -1
                            end
        
                        end
        
                    end
        
                end
        
                if sleep then
                    Citizen.Wait(1000)
                end
        
            end
        
        end)
    
        Citizen.CreateThread(function()
    
            while true do
                Wait(0)
        
                local PlayerData = GetPlayerData()
                
                if not PlayerData.ThreadsRunning then
                    break
                end

                if PlayerData.IsLocationBusy then
        
                    DisplayRadar(false)
        
                    if IsEntityDead(PlayerPedId()) then
        
                        local LocationData = Config.Locations[PlayerData.LocationIndex]
        
                        DeleteVehicle(LocationData.vehicleHandler)
                        SetEntityAsNoLongerNeeded(LocationData.vehicleHandler )
        
                        DestroyAllCams(true)
                        TaskStandStill(PlayerPedId(), 1)
                        DoScreenFadeIn(2000)
                
                        DisplayRadar(true)
        
                        PlayerData.IsLocationBusy = false
                    end
        
                else
                    Citizen.Wait(2000)
                end
        
            end
        
        end)
    
        
        Citizen.CreateThread(function()
    
            while true do
                Wait(1000)
        
                local PlayerData = GetPlayerData()

                if not PlayerData.ThreadsRunning then
                    break
                end
    
                if PlayerData.VehicleEntity then
    
                    if VehicleStoreTimeCooldown > -1 then
                        VehicleStoreTimeCooldown = VehicleStoreTimeCooldown - 1
                    end
    
                else
                    Wait(5000)
                end
    
            end
    
        end)

    end
    
