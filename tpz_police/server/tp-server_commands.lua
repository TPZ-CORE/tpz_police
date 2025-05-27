local TPZ = exports.tpz_core:getCoreAPI()


local HasRequiredJob = function(currentJob, jobs)

  for index, job in pairs (jobs) do

    if currentJob == job then
      return true
    end

  end

  return false

end

-----------------------------------------------------------
--[[ Command Registrations ]]--
-----------------------------------------------------------

RegisterCommand(Config.Commands[4].Command, function(source, args, rawCommand) -- CHECK_JAIL_DURATION
  local _source        = source
  local xPlayer        = TPZ.GetPlayer(_source)
  local charIdentifier = xPlayer.getCharacterIdentifier()

  local Jailist = GetJailData()

  if Jailist[charIdentifier] == nil then
    SendNotification(_source, Locales['YOU_ARE_NOT_IN_JAIL'], "error")
    return
  end

  local remaining       = GetCharacterJailTime(_source)
  local durationDisplay = convertSecondsToText(remaining)

  SendNotification(_source, string.format(Locales['JAIL_TIME_LEFT'], durationDisplay), "info")
end)

-- ALL COMMANDS THROUGH CONFIG.COMMANDS
Citizen.CreateThread(function()

  for index, command in pairs (Config.Commands) do

    if command.ActionType ~= 'ALERT_POLICE' and command.ActionType ~= 'CHECK_JAIL_DURATION' then
  
      RegisterCommand(command.Command, function(source, args, rawCommand)
        local _source = source
        local xPlayer = TPZ.GetPlayer(_source)
        local job     = xPlayer.getJob()

        local hasPermittedJob             = HasRequiredJob(job, command.PermittedJobs)
        local hasAcePermissions           = hasPermittedJob

        if not hasPermittedJob then
          hasAcePermissions = xPlayer.hasPermissionsByAce("tpzcore.police." .. string.lower(command.ActionType)) or xPlayer.hasPermissionsByAce("tpzcore.police.all")
        end

        local hasAdministratorPermissions = hasAcePermissions
      
        if not hasAcePermissions then
            hasAdministratorPermissions = xPlayer.hasAdministratorPermissions(command.PermittedGroups, command.PermittedDiscordRoles)
        end
      
        if hasAcePermissions or hasAdministratorPermissions then

          local target = args[1]

          if target == nil or target == '' then
            SendNotification(_source,  "~e~ERROR: Use Correct Sintaxis", "error")
            return
          end

          target = tonumber(target)

          local targetSteamName = GetPlayerName(target)

          if targetSteamName == nil then
            SendNotification(_source, Locales['NOT_ONLINE'], "error")
            return
          end

          local tPlayer = TPZ.GetPlayer(tonumber(target))

          if not tPlayer.loaded() then
            SendNotification(_source, Locales['PLAYER_IS_ON_SESSION'], "error")
            return
          end

          if command.ActionType == 'JAIL' then

            local duration = args[2]

            print(duration)
            if (duration == nil or duration == '' or tonumber(duration) == nil or tonumber(duration) <= 0 ) then
              SendNotification(_source, "~e~ERROR: Use Correct Sintaxis", "error")
              return
            end

            duration = tonumber(duration)

            local charIdentifier = tPlayer.getCharacterIdentifier()

            local Jailist = GetJailData()

            if Jailist[charIdentifier] then
              SendNotification(_source, Locales['CHARACTER_ALREADY_JAILED'], "success")
              return
            end

            SetCharacterJailed(target, ( duration * 60 * 60 ) )

            SendNotification(_source, string.format(Locales['CHARACTER_JAILED_SUCCESS'], duration), "success")
            SendNotification(target, string.format(Locales['CHARACTER_TARGET_JAILED'], duration), "info")

          else

            if command.ActionType == 'JAIL_OUT' then

              local charIdentifier = tPlayer.getCharacterIdentifier()

              local Jailist = GetJailData()
  
              if Jailist[charIdentifier] == nil then
                SendNotification(_source, Locales['CHARACTER_NOT_JAILED'], "error")
                return
              end

              SetCharacterUnJailed(target)

              SendNotification(_source, string.format(Locales['CHARACTER_UN_JAILED_SUCCESS'], duration), "success")
              SendNotification(target, string.format(Locales['CHARACTER_TARGET_UN_JAILED'], duration), "success")

            elseif command.ActionType == 'CHECK_TARGET_JAIL_DURATION' then

              local charIdentifier = tPlayer.getCharacterIdentifier()

              local Jailist = GetJailData()

              if Jailist[charIdentifier] == nil then
                SendNotification(_source, Locales['CHARACTER_NOT_JAILED'], "error")
                return
              end

              local remaining = GetCharacterJailTime(target)

              local durationDisplay = convertSecondsToText(remaining)
              SendNotification(_source, string.format(Locales['JAIL_TIME_LEFT'], durationDisplay), "info")

            elseif command.ActionType == 'BREAK_HANDCUFFS' then

              TriggerClientEvent("tpz_police:client:setHandcuffsState", target, false, false)
              SendNotification(_source, Locales['HANDCUFFS_BROKE'], "success")
            end


          end

        else
          SendNotification(_source, Locales['NOT_PERMITTED'], "error")
        end
  
      end)
  
    end
  
  end

end)


-----------------------------------------------------------
--[[ Chat Suggestion Registrations ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_police:server:addChatSuggestions")
AddEventHandler("tpz_police:server:addChatSuggestions", function()
  local _source = source

  for index, command in pairs (Config.Commands) do

    if command.Command ~= false then

      local displayTip = command.CommandHelpTips 

      if not displayTip then
        displayTip = {}
      end
  
      TriggerClientEvent("chat:addSuggestion", _source, "/" .. command.Command, command.Suggestion, command.CommandHelpTips )

    end

  end

end)
