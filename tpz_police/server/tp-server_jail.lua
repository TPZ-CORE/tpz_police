local TPZ = exports.tpz_core:getCoreAPI()

local Jailist = {}

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

convertSecondsToText = function(seconds)
    local secondsInMinute = 60
    local secondsInHour   = 60 * secondsInMinute
    local secondsInDay    = 24 * secondsInHour
    local secondsInMonth  = 30 * secondsInDay  -- Assuming 30-day months

    local months          = math.floor(seconds / secondsInMonth)
    local days            = math.floor((seconds % secondsInMonth) / secondsInDay)
    local hours           = math.floor((seconds % secondsInDay) / secondsInHour)
    local mins            = math.floor((seconds % secondsInHour) / secondsInMinute)

    local parts = {}

    if months > 0 then
        table.insert(parts, months .. " " .. (months ~= 1 and Locales['MONTHS'] or Locales['MONTH']))
    end

    if days > 0 then
        table.insert(parts, days .. " " .. (days ~= 1 and Locales['DAYS'] or Locales['DAY']))
    end

    if hours > 0 then
        table.insert(parts, hours .. " " .. (hours ~= 1 and Locales['HOURS'] or Locales['HOUR']))
    end

    if mins > 0 then
        table.insert(parts, mins .. " " .. (mins ~= 1 and Locales['MINUTES'] or Locales['MINUTE']))
    end

	if seconds < 60 then
		table.insert(parts, seconds .. " " .. (seconds ~= 1 and Locales['SECONDS'] or Locales['SECOND']))
	end

    return table.concat(parts, " " .. Locales['AND'] .. " ")
end

SetCharacterJailed = function(target, duration)
    target               = tonumber(target)
	local tPlayer        = TPZ.GetPlayer(target)
	local charIdentifier = tPlayer.getCharacterIdentifier()

    duration = os.time() + (duration)

	TriggerClientEvent("tpz_police:client:setCharacterAsJailed", target, true)

	local Parameters = {
		['charidentifier'] = charIdentifier,
		['jailed_until']   = duration,
	}

	exports.ghmattimysql:execute("UPDATE `characters` SET `jailed_until` = @jailed_until WHERE `charidentifier` = @charidentifier", Parameters )

	Jailist[charIdentifier] = { source = target, charIdentifier = charIdentifier }
end

SetCharacterUnJailed = function(target)
    target               = tonumber(target)
	local tPlayer        = TPZ.GetPlayer(target)
	local charIdentifier = tPlayer.getCharacterIdentifier()

	TriggerClientEvent("tpz_police:client:setCharacterAsJailed", target, false)

	exports.ghmattimysql:execute("UPDATE `characters` SET `jailed_until` = 0 WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charIdentifier } )
	Jailist[charIdentifier] = nil
end

GetCharacterJailTime = function(target)
	target               = tonumber(target)
	local tPlayer        = TPZ.GetPlayer(target)
	local charIdentifier = tPlayer.getCharacterIdentifier()

	local wait, remaining = true, 0

	exports.ghmattimysql:execute('SELECT `jailed_until` FROM `characters` WHERE `charidentifier` = @charidentifier', { ['@charidentifier'] = charIdentifier }, function(result)

		remaining = result[1].jailed_until - os.time()
		wait      = false
	end)

	while wait do
		Wait(50)
	end

	return remaining
end

GetJailData = function()
    return Jailist
end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
      
    Jailist = nil -- clearing all data
end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_police:server:requestJailTime")
AddEventHandler("tpz_police:server:requestJailTime", function()
	local _source = source
	local xPlayer = TPZ.GetPlayer(_source)

	if not xPlayer.loaded() then return end

	local charIdentifier = xPlayer.getCharacterIdentifier()

	exports.ghmattimysql:execute('SELECT `jailed_until` FROM `characters` WHERE `charidentifier` = @charidentifier', { ['@charidentifier'] = charIdentifier }, function(result)

		if (result and not result[1].jailed_until) then
			print('Attempt to request jailed_until from characters table. The specified table column not exist.')
			return
		end

		local remaining = result[1].jailed_until - os.time()

		if (result[1].jailed_until ~= 0) and (remaining <= -1 or os.time() >= result[1].jailed_until) then
			exports.ghmattimysql:execute("UPDATE `characters` SET `jailed_until` = 0 WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charIdentifier } )
		end

		if remaining > 0 and result[1].jailed_until > 0 then

			print('banned', remaining)

			local durationDisplay = convertSecondsToText(remaining)

			if Jailist[charIdentifier] == nil then

				Jailist[charIdentifier] = { 
					source = _source, 
					charIdentifier = tonumber(charIdentifier) 
				}

			else
				Jailist[charIdentifier].source   = _source
			end

			TriggerClientEvent("tpz_police:client:setCharacterAsJailed", _source, true)

		else
			TriggerClientEvent("tpz_police:client:setCharacterAsJailed", _source, false)
		end
		
	end)

end)
