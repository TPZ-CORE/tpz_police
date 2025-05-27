Config = {}

Config.DevMode = true

Config.Keys = {
    ['G'] = 0x760A9C6F,["B"] = 0x4CC0E2FE,['S'] = 0xD27782E3,['W'] = 0x8FD015D8,['H'] = 0x24978A28,
    ['U'] = 0xD8F73058,["R"] = 0xE30CD707,["ENTER"] = 0xC7B5340A,['E'] = 0xCEFD9220,["J"] = 0xF3830D8E,
    ['F'] = 0xB2F377E8, ['C'] = 0x9959A6F0,
    ['L'] = 0x80F28E95, ['BACKSPACE'] = 0x156F7119,["DOWN"] = 0x05CA7C52,["UP"] = 0x6319DB71,["LEFT"] = 0xA65EBAB4,
    ["RIGHT"] = 0xDEB34313, ["SPACEBAR"] = 0xD9D0E1C0, ["DEL"] = 0x4AF4D473,
}

Config.PromptAction = { label = "Press", key = 'G', hold = 1000 }

Config.WagonPrompts = {
    ['PREVIOUS']    = { label = 'Previous', key = 'LEFT',      hold = 500  },
    ['NEXT']        = { label = 'Next',     key = 'RIGHT',     hold = 500  },
    ['SELECT']      = { label = 'Select',   key = 'ENTER',     hold = 1000 },
    ['EXIT']        = { label = 'Exit',     key = 'BACKSPACE', hold = 1000 },
}

---------------------------------------------------------------
--[[ General Settings ]]--
---------------------------------------------------------------

Config.PoliceJobs = { 'police', 'detective' } -- (!) ADD ALL THE AVAILABLE POLICE JOB NAMES! OTHERWISE A POLICE JOB NAME WON'T BE FUNCTIONAL.

-- Would you like the police to buy specific items?
-- You can implement that directly from tpz_stores.

---------------------------------------------------------------
--[[ Usable Items ]]--
---------------------------------------------------------------

Config.Items = {

    ['HANDCUFFS'] = { 
        Item = "handcuffs", -- ONE-TIME USE!

        RequiresPlayerNearby = true, -- DO NOT TOUCH
        PlayerNearestDistance = 1.5,

    },-- A handcuffs item
  
    ['HANDCUFFS_KEY'] = { 
        Item = "handcuffs_key", -- THIS ITEM SHOULD BE A NOT-STACKABLE ON ITEMS!

        RequiresPlayerNearby = false,  -- DO NOT TOUCH
    },-- A handcuffs key item

    ['DETECTIVE_KIT'] = { 
        Item = "detective_kit", -- THIS ITEM SHOULD BE A NOT-STACKABLE ON ITEMS!

        RequiresPlayerNearby = true,  -- DO NOT TOUCH
        PlayerNearestDistance = 1.5,

        RemoveDurability = { Enabled = true, Value = 20, Destroy = false },

        Inspect = {
            Anim = 'bandage_add_start', -- Animation selected from dictionary for inspecting.
            Dict = 'mini_games@story@mob4@heal_jules@bandage@arthur', -- Dictionary Anim for inspecting.
        },

        Duration = 10,
        ProgressText = "Inspecting..",

    }, -- Detective kit to check dead bodies and their causes.

}

---------------------------------------------------------------
--[[ Wagon Spawn - Select Locations ]]--
---------------------------------------------------------------

Config.SpawnWagons = true -- Set to false if you don't want the police to spawn - select any wagons.

-- Prevent players to spawn a wagon when another wagon is nearby.
Config.CheckNearbyVehicles = 3.0

Config.StoreVehicle = { 
    TotalTime = 10, -- Time in seconds
    Label     = "Stay another %s seconds for the coach to be stored.", 
    RGBA      = { r = 255, g = 0, b = 0, a = 150 } -- 3DTEXT
}

Config.Locations = {

    ['VALENTINE'] = {

        PoliceJobs   = { 'police' },

        Coords       = { x = -272.920, y = 814.4931, z = 118.29, h = 226.71411 },

        Marker = { -- To display the location for selecting the wagons.
            Enabled = true,

            DisplayDistance = 5.0,
            RGBA = {r = 255, g = 255, b = 255, a = 50, scale_x = 1.5, scale_y = 1.5, scale_z = 0.5}, 
        },

        ActionDistance = 1.5,
        
        CameraCoords = { x = -274.186, y = 835.6177, z = 119.80, rotx = 0.0, roty = 0.0, rotz = 135.08, fov = 45.0}, -- SPAWNING THE MODEL FOR SELECTION CAMERA OVERVIEW.

        SelectVehicleCoords = { x = -281.68115234375, y = 828.732666015625, z = 119.43851470947266, h = -80.43148040771484 }, -- SPAWNING THE MODEL FOR SELECTION.
        SpawnVehicleCoords  = { x = -281.68115234375, y = 828.732666015625, z = 119.43851470947266, h = -80.43148040771484 }, -- SPAWNING THE MODEL - WAGON AFTER SELECTION.

        -- The specified location is displayed only when being nearby and inside a wagon.
        StoreVehicle = {  -- STORE THE WAGON.

            StoreVehicleDistance = 5.0, -- BASED ON scale_x, scale_y
    
            Coords = { x = -289.675, y = 828.4080, z = 118.74},
    
            Marker = { 
                Enabled = true,
    
                DisplayDistance = 30.0,
    
                RGBA = {r = 255, g = 0, b = 0, a = 50, scale_x = 5.0, scale_y = 5.0, scale_z = 1.0}, 
            },
            
        },

        Wagons = {
            {
                Model = "policewagon01x", -- WAGON MODEL
                Label = "Police Wagon", -- NAME FOR WAGON MODEL

                PermittedJobGrades = { 
                    ['police'] = { 1 },
                },

            },
        
            {
                Model = "wagonPrison01x", -- WAGON MODEL (ONLY FOR THIS MODEL YOU CAN JAIL A PERSON)
                Label = "Prison Wagon", -- NAME FOR WAGON MODEL

                PermittedJobGrades = { 
                    ['police'] = { 1 },
                },

            },
        
            {
                Model = "ArmySupplyWagon", -- WAGON MODEL (ONLY THIS MODEL HAVE PERSONAL INVENTORY!)
                Label = "Army Supply Wagon", -- NAME FOR WAGON MODEL

                PermittedJobGrades = { 
                    ['police'] = { 1 },
                },

            },
        
            {
                Model = "wagonarmoured01x", -- WAGON MODEL
                Label = "Armoured Wagon", -- NAME FOR WAGON MODEL

                PermittedJobGrades = { 
                    ['police'] = { 1 },
                },

            },

        },

    }
}

---------------------------------------------------------------
--[[ Commands ]]--
---------------------------------------------------------------

Config.Commands = {

    { 
        ActionType = "JAIL", -- DO NOT TOUCH
        Suggestion = "Execute this command to jail the selected player.",

        PermittedDiscordRoles  = { 111111111111111111, 2222222222222222222 },
        PermittedGroups = { 'admin' },
        PermittedJobs   = { 'police' },

        Command = 'jail', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { { name = "Id", help = 'Player ID' },  { name = "Duration", help = 'Insert the duration in hours' } },
    },

    { 
        ActionType = "JAIL_OUT", -- DO NOT TOUCH
        Suggestion = "Execute this command to un-jail the selected player.",

        PermittedDiscordRoles  = { 111111111111111111, 2222222222222222222 },
        PermittedGroups = { 'admin' },
        PermittedJobs   = { 'police' },

        Command = 'unjail', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { { name = "Id", help = 'Player ID' } },
    },

    { 
        ActionType = "CHECK_TARGET_JAIL_DURATION", -- DO NOT TOUCH
        Suggestion = "Execute this command to check the jail duration of the selected player.",

        PermittedDiscordRoles  = { 111111111111111111, 2222222222222222222 },
        PermittedGroups = { 'admin' },
        PermittedJobs   = { 'police' },

        Command = 'checkjailtime', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { { name = "Id", help = 'Player ID' } },
    },

    { 
        ActionType = "CHECK_JAIL_DURATION", -- DO NOT TOUCH
        Suggestion = "Execute this command to check the jail duration of the selected player.",

        Command = 'myjailtime', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { },
    },

    
    { 
        ActionType = "BREAK_HANDCUFFS", -- DO NOT TOUCH
        Suggestion = "Execute this command to break handcuffs of the selected player in case its bugged.",

        PermittedDiscordRoles  = { 111111111111111111, 2222222222222222222 },
        PermittedGroups = { 'admin' },
        PermittedJobs   = { 'police' },

        Command = 'breakhandcuffs', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { { name = "Id", help = 'Player ID' } },
    },

    { 
        ActionType = "ALERT_POLICE", -- DO NOT TOUCH
        Suggestion = "Execute this command to show your badge to the closest players.",

        Command = 'alertpolice', -- SET TO FALSE TO DISABLE IT.

        AlertJobs = {'police', 'detective' },
        OnlyUnconsious = true, -- Set to true if you want only unconsious players to alert police.

        Cooldown = 10, -- Time in minutes
    },

}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source : The source always null when called from client.
-- @param type   : returns "error", "success", "info"
function SendNotification(source, message, type)
    local duration = 3000

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, duration)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, duration)
    end
  
end

---------------------------------------------------------------
--[[ Discord Webhooking ]]--
---------------------------------------------------------------

Config.DiscordWebhooking = {
    Enable = false, 
    Url    = "", 
    Color  = 10038562
}
