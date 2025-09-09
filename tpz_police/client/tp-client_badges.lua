
local BadgeData = {

    EntityObject    = nil,
    IsEquipped      = false,
    MaleBoneIndex   = 458,
    FemaleBoneIndex = 500,

    Coords = nil,
    X      = 0.17,
    Y      = -0.19,
    Z      = -0.25,
    R      = 30.0,

    Duration = 0,

    IsAdjusting = false,
}

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local HasRequiredJobToEquipBadge = function(currentJob, currentJobGrade)

    local hasJob, hasJobGrade = false, false
    local hasJobGrade = false
    local jobPositionIndex = 0
    local object = nil

    for badgeObject, data in pairs(Config.Badges) do

        for _, job in pairs(data.Jobs) do 

            if job == currentJob then 
                hasJob, jobPositionIndex = true, _
                break 
            end
        end

        if hasJob and data.Grades[jobPositionIndex] then

            for _, jobGrade in pairs(data.Grades[jobPositionIndex]) do

                if jobGrade == currentJobGrade then
                    hasJobGrade = true
                    break
                end

            end

        end

        if hasJob and hasJobGrade then
            object = badgeObject
            break
        end
        
    end

    return object

end


local function AdjustBadgeAttachmentPosition()
    local playerPed = PlayerPedId()

    if BadgeData.IsEquipped then

        if not BadgeData.IsAdjusting then
            BadgeData.IsAdjusting = true

            while true do

                Wait(4)

                if not BadgeData.IsAdjusting or not BadgeData.IsEquipped then
                    break
                end

                local Prompt, PromptList = GetBadgePromptData()
                local label = CreateVarString(10, 'LITERAL_STRING', Locales['BADGE_ADJUST_PROMPT_FOOTER'] )
                PromptSetActiveGroupThisFrame(Prompt, label)

                if IsPedMale(playerPed) then
                    AttachEntityToEntity(BadgeData.EntityObject, playerPed, BadgeData.MaleBoneIndex, BadgeData.X, BadgeData.Y, BadgeData.Z, -15.0, 0.0, BadgeData.R, true, true, false, true, 1, true)
                else
                    AttachEntityToEntity(BadgeData.EntityObject, playerPed, BadgeData.FemaleBoneIndex, BadgeData.X, BadgeData.Y, BadgeData.Z, -15.0, 0.0, BadgeData.R, true, true, false, true, 1, true)
                end
                
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['UP_DOWN'].key1]) then
                    BadgeData.Z = BadgeData.Z + 0.01
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['UP_DOWN'].key2]) then
                    BadgeData.Z = BadgeData.Z - 0.01
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['LEFT_RIGHT'].key1]) then
                    BadgeData.X = BadgeData.X + 0.01
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['LEFT_RIGHT'].key2]) then
                    BadgeData.X = BadgeData.X - 0.01
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['IN_OUT'].key1]) then
                    BadgeData.Y = BadgeData.Y + 0.01
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['IN_OUT'].key2]) then
                    BadgeData.Y = BadgeData.Y - 0.01
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['ROTATE'].key1]) then
                    BadgeData.R = BadgeData.R + 2.0
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['ROTATE'].key2]) then
                    BadgeData.R = BadgeData.R - 2.0
                end
                if IsControlJustReleased(0, Config.Keys[Config.BadgePrompts['CONFIRM'].key1]) then
                    BadgeData.IsAdjusting = false
                end
            end

        else
            BadgeData.IsAdjusting = false
        end

    else
        -- not equipped
    end

end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    if BadgeData.IsEquipped then
        DeleteObject(BadgeData.EntityObject)
    end

end)

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_police:client:use_badge")
AddEventHandler("tpz_police:client:use_badge", function(job, jobgrade)
    local playerPed      = PlayerPedId()
    local getBadgeObject = HasRequiredJobToEquipBadge(job, jobgrade)

    if getBadgeObject == nil then
        SendNotification(nil, Locales['NOT_REQUIRED_JOB'], "error")
        return
    end

    if BadgeData.IsEquipped then
        DeleteObject(BadgeData.EntityObject)
        BadgeData.IsEquipped = false

    else

        LoadModel(getBadgeObject)

        BadgeData.EntityObject = CreateObject(GetHashKey(getBadgeObject), BadgeData.X, BadgeData.Y, BadgeData.Z + 0.2, true, false, false)
        
        if IsPedMale(playerPed) == 1 then
            AttachEntityToEntity(BadgeData.EntityObject, playerPed, BadgeData.MaleBoneIndex, BadgeData.X, BadgeData.Y, BadgeData.Z, -15.0, 0.0, BadgeData.R, true, true, false, true, 1, true)
        else
            AttachEntityToEntity(BadgeData.EntityObject, playerPed, BadgeData.FemaleBoneIndex, BadgeData.X, BadgeData.Y, BadgeData.Z, -15.0, 0.0, 30.0, false, true, false, true, 1, true)
        end

        BadgeData.Coords = GetEntityCoords(BadgeData.EntityObject)
        BadgeData.IsEquipped = true

        if Config.AdjustBadge.HelpText.Enabled then

            local HelpText = Config.AdjustBadge.HelpText
            SendNotification(nil, HelpText.Text, "info", 1000 * HelpText.DisplayDuration)

        end

    end
end)

-----------------------------------------------------------
--[[ Commands ]]--
-----------------------------------------------------------

if Config.EquipBadgeCommand.Enabled then

    RegisterCommand(Config.EquipBadgeCommand.Command, function(source, args)
        local PlayerData = GetPlayerData()

        TriggerEvent("tpz_police:client:use_badge", PlayerData.Job, PlayerData.JobGrade)
    end)

end

RegisterCommand(Config.AdjustBadge.Command, function(source, args)
    local PlayerData = GetPlayerData()

    AdjustBadgeAttachmentPosition()
end)

Citizen.CreateThread(function()
    RegisterBadgePrompts()
end)
