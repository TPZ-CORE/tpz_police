local TPZ = exports.tpz_core:getCoreAPI()

local DEATH_CAUSE_HASHES_LIST = {
    [37266233]    = "WOLF KILL",
    [-655377385]  = "SNAKE BITE",
    [148160082]   = "FEROCIOUS ANIMAL",
    [515998169]   = "BEAR KILL",
    [-1245325071] = "CROCODILE BITE",
    [-2002235300] = "BOWS",
    [115405099]   = "BOWS",
    [-1569615261] = "UNARMED",
    [-544306709]  = "BURNED",
    [-842959696]  = "FALLING",
    [-1553120962] = "VEHICLES",
    [-1949138268] = "HORSES",
    [-628784915]  = "GATLING GUN",
    [-1193642378] = "TURRET",
    [1609145491]  = "CANNON",
    [-1829236809] = "CANNON",
    [-618550132]  = "KNIFE",
    [-631972525]  = "KNIFE CIVIL WAR",
    [205894366]   = "KNIFE MINER",
    [277270593]   = "KNIFE JAWBONE",
    [349436237]   = "KNIFE VAMPIRE",
    [494733111]   = "KNIFE JOHN",
    [734080218]   = "KNIFE BEAR",
    [-1221986448] = "KNIFE HORROR",
    [165751297]   = "HATCHET",
    [567069252]   = "ANCIENT HATCHET",
    [710736342]   = "HATCHET HUNTER",
    [-1894785522] = "HATCHET DOUBLE BIT RUSTED",
    [-1127860381] = "HATCHET DOUBLE BIT",
    [469927692]   = "HATCHET HEWING",
    [1960591597]  = "HATCHET VIKING",
    [-462374995]  = "HATCHET HUNTER RUSTED",
    [-281894307]  = "CLEAVER",
    [680856689]   = "MACHETE",
    [2075992054]  = "REVOLVER SCHOFIELD",
    [-510274983]  = "REVOLVER SCHOFIELD",
    [38266755]    = "REVOLVER SCHOFIELD CALLOWAY",
    [1529685685]  = "REVOLVER LEMAT",
    [600245965]   = "REVOLVER DOUBLEACTION",
    [36703333]    = "REVOLVER DOUBLEACTION",
    [127400949]   = "REVOLVER DOUBLEACTION",
    [-2082646505] = "REVOLVER DOUBLEACTION GAMBLER",
    [-169598849]  = "REVOLVER CATTLEMAN",
    [379542007]   = "REVOLVER CATTLEMAN",
    [383145463]   = "REVOLVER CATTLEMAN MEXICAN",
    [-916314281]  = "REVOLVER CATTLEMAN JOHN",
    [34411519]    = "PISTOL VOLCANIC",
    [1701864918]  = "PISTOL SEMIAUTO",
    [1252941818]  = "PISTOL MAUSER",
    [1534638301]  = "PISTOL M1899",
    [-2055158210] = "PISTOL MAUSER",
    [1402226560]  = "SNIPERRIFLE CARCANO",
    [1311933014]  = "SNIPERRIFLE ROLLINGBLOCK",
    [-506285289]  = "SNIPERRIFLE ROLLINGBLOCK",
    [1676963302]  = "RIFLE SPRINGFIELD",
    [-570967010]  = "RIFLE VARMINT",
    [1999408598]  = "RIFLE BOLTACTION",
    [-1783478894] = "REPEATER HENRY",
    [-183018591]  = "REPEATER CARBINE",
    [1905553950]  = "REPEATER EVANS",
    [-1471716628] = "REPEATER WINCHESTER",
    [834124286]   = "SHOTGUN PUMP",
    [575725904]   = "SHOTGUN DOUBLEBARREL",
    [1838922096]  = "SHOTGUN SEMIAUTO",
    [392538360]   = "SHOTGUN SAWEDOFF",
    [1845102363]  = "SHOTGUN DOUBLEBARREL",
    [1674213418]  = "SHOTGUN REPEATING",
    [-764310200]  = "THROWING KNIVES",
    [-1511427369] = "TOMAHAWK",
    [2133046983]  = "TOMAHAWK ANCIENT",
    [1885857703]  = "MOLOTOV",
    [-1504859554] = "DYNAMITE",
    [-1415022764] = "FISHINGROD",
    [2055893578]  = "LASSO",
    [1742487518]  = "TORCH",
    [966099553]   = "OBJECT",
    [827679807]   = "LANTERN ELECTRIC",
    [-1361787316] = "MOONSHINEJUG",
    [-295349450]  = "HAMMER",
    [-1013236292] = "KNIFE RUSTIC",
    [-1448818329] = "KNIFE TRADER",
    [-1774451313] = "MACHETE COLLECTOR",
    [1953585457]  = "MACHETE HORROR ",
    [132728264]   = "REVOLVER NAVY",
    [389133414]   = "REVOLVER NAVY CROSSOVER",
    [-1717423096] = "RIFLE ELEPHANT",
    [-577893115]  = "POISON BOTTLE",
}


-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

local SetHandcuffState = function(cb)
    local playerPed  = PlayerPedId()

    if not cb then
        UncuffPed(playerPed)
    else
        FreezeEntityPosition(playerPed, true)
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
    end

    SetEnableHandcuffs(playerPed, cb)
    
    if not cb then
        ClearPedSecondaryTask(playerPed)
    end

    DisablePlayerFiring(playerPed, cb)
    SetPedCanPlayGestureAnims(playerPed, not cb)

    if cb then
        Wait(3000)
        FreezeEntityPosition(playerPed, false)
    end

end


-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    local PlayerData = GetPlayerData()

    if PlayerData.IsHandcuffed then
        SetHandcuffState(false)
    end

end)


AddEventHandler("tpz_core:isPlayerRespawned", function()
    local PlayerData = GetPlayerData()

    if PlayerData.IsHandcuffed then
        SetHandcuffState(false)
        PlayerData.IsHandcuffed = false
    end

end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_police:client:item")
AddEventHandler("tpz_police:client:item", function(itemIndex, data)
    local PlayerData = GetPlayerData()

    if Config.Items[itemIndex] == nil then
        return
    end

    local item = Config.Items[itemIndex]

    local isPermitted, wait   = false, true
    
    local foundTargetSourceId = 0
    local notifyWarning       = nil

    if item.RequiresPlayerNearby then
        local nearestPlayers = TPZ.getNearestPlayers(Config.Items[itemIndex].PlayerNearestDistance)

        if GetTableLength(nearestPlayers) > 0 then
    
            local targetPlayer    = nearestPlayers[1] -- We get the first result.
            local targetPlayerPed = GetPlayerPed(targetPlayer)
    
            foundTargetSourceId   = targetPlayer
    
            if (itemIndex ~= 'DETECTIVE_KIT') or (itemIndex == 'DETECTIVE_KIT' and IsPedDeadOrDying(targetPlayerPed, 1)) then
                isPermitted = true
                wait        = false
            else
    
                notifyWarning = Locales['NO_PLAYER_DEAD']
                isPermitted = false
                wait        = false
            end
    
        else
    
            notifyWarning = Locales['NO_PLAYER_NEARBY']
    
            isPermitted = false
            wait        = false
        end

    else
        isPermitted = true
        wait = false
    end
    
    while wait do
        Wait(50)
    end

    if not isPermitted then
        SendNotification(nil, notifyWarning, "error")
        return
    end
    
    if Config.Items[itemIndex] == 'DETECTIVE_KIT' then

        local playerPed       = PlayerPedId()

        local targetPlayerPed = GetPlayerPed(foundTargetSourceId)
        local causeofDeath    = Citizen.InvokeNative(0x16FFE42AB2D2DC59, targetPlayer)

        FreezeEntityPosition(playerPed, true)

        Anim(playerPed, Config.Items['DETECTIVE_KIT'].Inspect.Dict, Config.Items['DETECTIVE_KIT'].Inspect.Anim, -1, 30)

        TPZ.DisplayProgressBar( 1000 * Config.Items['DETECTIVE_KIT'].Duration, 1000 * Config.Items['DETECTIVE_KIT'].ProgressText)

        RemoveAnimDict(Config.Items['DETECTIVE_KIT'].Inspect.Dict)

        FreezeEntityPosition(playerPed, false)
        ClearPedTasks(playerPed)

        if DEATH_CAUSE_HASHES_LIST[causeofDeath] then

            local deathCause = DEATH_CAUSE_HASHES_LIST[causeofDeath]

            SendNotification(nil, deathCause, "info")

            TriggerServeEvent("tpz_police:server:onItemUpdate", itemIndex, data) -- remove durability.
        else

            SendNotification(nil, Locales['UNKNOWN_DEATH_CAUSE'], "error") -- unknown death cause.
        end
        
    elseif Config.Items[itemIndex] == 'HANDCUFFS' then 

        local targetPlayerPed = GetPlayerPed(foundTargetSourceId)

        if IsPedDeadOrDying(targetPlayerPed, 1) then
            SendNotification(nil, Locales['PLAYER_IS_UNCONSIOUS'], "error")
            return
        end

        data = { foundTargetSourceId }

        TriggerServeEvent("tpz_police:server:onItemUpdate", itemIndex, data) -- remove handcuffs item.

    elseif Config.Items[itemIndex] == 'HANDCUFFS_KEY' then 

        if PlayerData.IsHandcuffed == false then
            SendNotification(nil, Locales['NOT_HANDCUFFED'], "error")
            return
        end

        if data == nil or data and PlayerData.IsHandcuffed ~= data[1] then
            SendNotification(nil, Locales['NOT_CORRECT_HANDCUFF_KEYS'], "error")
            return
        end

        TriggerServeEvent("tpz_police:server:onItemUpdate", itemIndex, data) -- removes handcuff keys.
    end

end)

RegisterNetEvent("tpz_police:client:setHandcuffsState")
AddEventHandler("tpz_police:client:setHandcuffsState", function(cb, uniqueId)
    local PlayerData = GetPlayerData()

    SetHandcuffState(cb)
    PlayerData.IsHandcuffed = uniqueId
end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

-- Handcuffed players, repeat and set the player as handcuffs enabled in cause for any abuses.
Citizen.CreateThread(function()
    while true do

        Wait(3000)

        local PlayerData = GetPlayerData()

        if PlayerData.IsHandcuffed ~= false then    
            SetEnableHandcuffs(PlayerPedId(), true)
        end        

    end

end)
