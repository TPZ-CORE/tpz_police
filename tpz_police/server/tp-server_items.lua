local TPZ    = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()

	for _, item in pairs (Config.Items) do

		TPZInv.registerUsableItem(item.Item, "tpz_police", function(data)

			local _source = data.source

			if _ == 'HANDCUFFS_KEY' then
				cb = { data.itemId }

			elseif _ == 'DETECTIVE_KIT' then

				if item.RemoveDurability.Enabled and data.durability <= 0 then
					SendNotification(_source, Locales['NOT_DURABILITY'])
					return
				end

				cb = { data.itemId }

			end

			TriggerClientEvent("tpz_police:client:item", _, cb) -- item index.
		end)	

	end

end)

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_police:server:onItemUpdate")
AddEventHandler("tpz_police:server:onItemUpdate", function(itemIndex, data)
	local _source = source
	local xPlayer = TPZ.GetPlayer(_source)

	if Config.Items[itemIndex] == nil then
		return
	end

	local item = Config.Items[itemIndex]

	if itemIndex == 'HANDCUFFS' then

		local canCarryItem = xPlayer.canCarryItem(item.Item, 1)

		if not canCarryItem then
			SendNotification(_source, Locales['CANNOT_HANDCUFF_NOT_ENOUGH_INVENTORY_SPACE'], "error")
			return
		end

		local itemId   = os.time()
		local metadata = { itemId = itemId, durability = -1 }

		xPlayer.addItem(Config.Items['HANDCUFFS_KEY'].Item, 1, metadata)
		xPlayer.removeItem(item.Item, 1)

		TriggerClientEvent("tpz_police:client:setHandcuffsState", tonumber(data[1]), true, itemId)

	elseif itemIndex == 'HANDCUFFS_KEY' then

		xPlayer.removeItem(item.Item, 1, data[1])

		TriggerClientEvent("tpz_police:client:setHandcuffsState", _source, false, false)
		
	elseif itemIndex == 'DETECTIVE_KIT' then

		if item.RemoveDurability then
			xPlayer.removeItemDurability(item.Item, item.RemoveDurability.Value, data[1], item.RemoveDurability.Destroy)
		end
		
	elseif itemIndex == 'BADGE' then


	end

end)