
local Prompts, WagonPrompts       = GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff)
local PromptList, WagonPromptList = {}, {}

--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

	Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompts) -- UiPromptDelete
    Citizen.InvokeNative(0x00EDE88D4D13CF59, WagonPrompts) -- UiPromptDelete

	local PlayerData = GetPlayerData()

	if PlayerData.IsLocationBusy then

		local LocationData = Config.Locations[PlayerData.LocationIndex]

		if LocationData.vehicleHandler then
			DeleteVehicle(LocationData.vehicleHandler)
			SetEntityAsNoLongerNeeded(LocationData.vehicleHandler )
		end
		
		DestroyAllCams(true)
		TaskStandStill(PlayerPedId(), 1)
		DoScreenFadeIn(2000)

		DisplayRadar(true)
	end
end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

RegisterActionPrompt = function()
    local str  =  Config.PromptAction.label
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, Config.Keys[Config.PromptAction.key])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, 1)
    PromptSetVisible(prompt, 1)
    PromptSetStandardMode(prompt, 1)
    PromptSetHoldMode(prompt, Config.PromptAction.hold)
    PromptSetGroup(prompt, Prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
    PromptRegisterEnd(prompt)

    PromptList = prompt
end

GetPromptData = function ()
    return Prompts, PromptList
end


local WagonPromptsList = {
    [1] = {
        Type = "PREVIOUS"
    },

    [2] = {

        Type = "NEXT"
    },

    [3] = {

        Type = "SELECT"
    },

    [4] = {

        Type = "EXIT"
    },

}

RegisterWagonActionPrompts = function()

    for index, tprompt in pairs (WagonPromptsList) do

        local str      = Config.WagonPrompts[tprompt.Type].label
        local keyPress = Config.Keys[Config.WagonPrompts[tprompt.Type].key]
    
        local dPrompt = PromptRegisterBegin()
        PromptSetControlAction(dPrompt, keyPress)
        str = CreateVarString(10, 'LITERAL_STRING', str)

        PromptSetText(dPrompt, str)
        PromptSetEnabled(dPrompt, 1)

        PromptSetStandardMode(dPrompt, 1)
        PromptSetHoldMode(dPrompt, Config.WagonPrompts[tprompt.Type].hold)

        PromptSetGroup(dPrompt, WagonPrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
        PromptRegisterEnd(dPrompt)
    
        table.insert(WagonPromptList, {prompt = dPrompt, type = tprompt.Type })
    end
end

GetWagonsPromptData = function ()
    return WagonPrompts, WagonPromptList
end

--[[-------------------------------------------------------
 General Functions
]]---------------------------------------------------------

LoadModel = function(inputModel)
    local model = GetHashKey(inputModel)
 
    RequestModel(model)
 
    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(10)
    end
end

RemoveEntityProperly = function(entity, objectHash)
	DeleteEntity(entity)
	DeletePed(entity)
	SetEntityAsNoLongerNeeded( entity )

	if objectHash then
		SetModelAsNoLongerNeeded(objectHash)
	end
end

GetNearestVehicles = function(coords, radius, allowlistedVehicleEntity)
	local closestVehicles = {}

    local vehiclePool = GetGamePool('CVehicle') -- Get the list of vehicles (entities) from the pool
    for i = 1, #vehiclePool do -- loop through each vehicle (entity)

        if vehiclePool[i] ~= allowlistedVehicleEntity then

            local targetCoords = GetEntityCoords(vehiclePool[i])
            local coordsDist   = vector3(targetCoords.x, targetCoords.y, targetCoords.z)
    
            local distance     = #(coordsDist - coords)

            if distance < radius then
                table.insert(closestVehicles, vehiclePool[i])
            end

        end

    end

	return closestVehicles
end

ShowNotification = function(_message, rgbData, timer)

    if timer == nil or timer == 0 then
        timer = 200
    end
    local r, g, b, a = 161, 3, 0, 255

    if rgbData then
        r, g, b, a = rgbData.r, rgbData.g, rgbData.b, rgbData.a
    end

	while timer > 0 do
		DisplayHelp(_message, 0.50, 0.90, 0.6, 0.6, true, r, g, b, a, true)

		timer = timer - 1
		Citizen.Wait(0)
	end

end

DisplayHelp = function(_message, x, y, w, h, enableShadow, col1, col2, col3, a, centre)

	local str = CreateVarString(10, "LITERAL_STRING", _message, Citizen.ResultAsLong())

	SetTextScale(w, h)
	SetTextColor(col1, col2, col3, a)

	SetTextCentre(centre)

	if enableShadow then
		SetTextDropshadow(1, 0, 0, 0, 255)
	end

	Citizen.InvokeNative(0xADA9255D, 10);

	DisplayText(str, x, y)

end