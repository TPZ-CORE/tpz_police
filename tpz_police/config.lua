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
--[[ Jail Rooms ]]--
---------------------------------------------------------------

Config.Jails = {

    { 
        Town = 'VALENTINE', 
        JailInCoords = { x = -273.484, y = 811.2916, z = 118.37, h = 109.93661 }, 
        JailOutCoords = { x = -269.902, y = 809.6586, z = 118.24, h = 281.648 } 
    }, -- CELL #1

    { 
        Town = 'RHODES', 
        JailInCoords = { x = 1355.316, y = -1303.33, z = 76.759, h = 260.1018 }, 
        JailOutCoords = { x = 1358.903, y = -1295.14, z = 75.796, h = 37.31795 } 
    }, -- CELL #1

    { 
        Town = 'VALENTINE', 
        JailInCoords = { x = -271.658, y = 807.4848, z = 118.37, h = 106.4754 }, 
        JailOutCoords = { x = -269.902, y = 809.6586, z = 118.24, h = 281.648 } 
    }, -- CELL #2

    { 
        Town = 'SAINT DENIS', 
        JailInCoords = { x = 2504.254, y = -1311.39, z = 47.953, h = 20.4542312 }, 
        JailOutCoords = { x = 2492.141, y = -1308.86, z = 47.865, h = 109.191932 } 
    }, -- CELL #1

    { 
        Town = 'SAINT DENIS', 
        JailInCoords = { x = 2500.021, y = -1311.53, z = 47.953, h = 8.85217 }, 
        JailOutCoords = { x = 2492.141, y = -1308.86, z = 47.865, h = 109.191932 } 
    }, -- CELL #2

    { 
        Town = 'SAINT DENIS', 
        JailInCoords = { x = 2498.187, y = -1306.38, z = 47.953, h = 181.2178 }, 
        JailOutCoords = { x = 2492.141, y = -1308.86, z = 47.865, h = 109.191932 } 
    }, -- CELL #3

    { 
        Town = 'SAINT DENIS', 
        JailInCoords = { x = 2502.010, y = -1306.47, z = 47.953, h = 181.0465 }, 
        JailOutCoords = { x = 2492.141, y = -1308.86, z = 47.865, h = 109.191932 } 
    }, -- CELL #4

    { 
        Town = 'STRAWBERRY', 
        JailInCoords = { x = -1810.11, y = -351.762, z = 160.43, h = 70.15028 }, 
        JailOutCoords = { x = -1806.66, y = -353.258, z = 163.14, h = 295.525 } 
    }, -- CELL #1

    { 
        Town = 'STRAWBERRY', 
        JailInCoords = { x = -1812.88, y = -355.549, z = 160.44, h = 43.160144 }, 
        JailOutCoords = { x = -1806.66, y = -353.258, z = 163.14, h = 295.525 } 
    }, -- CELL #2

    { 
        Town = 'BLACKWATER', 
        JailInCoords = { x = -762.858, y = -1264.21, z = 43.024, h = 9.2488 }, 
        JailOutCoords = { x = -770.330, y = -1273.28, z = 42.549, h = 188.9837 } 
    }, -- CELL #1

    { 
        Town = 'BLACKWATER', 
        JailInCoords = { x = -766.557, y = -1263.01, z = 43.024, h = 177.86 }, 
        JailOutCoords = { x = -770.330, y = -1273.28, z = 42.549, h = 188.9837 } 
    }, -- CELL #2

    { 
        Town = 'ANNESBURG', 
        JailInCoords = { x = 2903.195, y = 1314.463, z = 43.934, h = 315.4950 }, 
        JailOutCoords = { x = 2910.889, y = 1303.941, z = 43.750, h = 268.58511 } 
    }, -- CELL #1

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
        CommandHelpTips = { { name = "Id", help = 'Player ID' },  { name = "Duration", help = 'Insert the duration in minutes' } },

        Webhooking = {
            Enable = false, 
            Url    = "", 
            Color  = 10038562
        },

    },

    { 
        ActionType = "JAIL_OUT", -- DO NOT TOUCH
        Suggestion = "Execute this command to un-jail the selected player.",

        PermittedDiscordRoles  = { 111111111111111111, 2222222222222222222 },
        PermittedGroups = { 'admin' },
        PermittedJobs   = { 'police' },

        Command = 'unjail', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { { name = "Id", help = 'Player ID' } },

        Webhooking = {
            Enable = false, 
            Url    = "", 
            Color  = 10038562
        },

    },

    { 
        ActionType = "CHECK_TARGET_JAIL_DURATION", -- DO NOT TOUCH
        Suggestion = "Execute this command to check the jail duration of the selected player.",

        PermittedDiscordRoles  = { 111111111111111111, 2222222222222222222 },
        PermittedGroups = { 'admin' },
        PermittedJobs   = { 'police' },

        Command = 'checkjailtime', -- SET TO FALSE TO DISABLE IT.
        CommandHelpTips = { { name = "Id", help = 'Player ID' } },

        Webhooking = {
            Enable = false, 
            Url    = "", 
            Color  = 10038562
        },

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

        Webhooking = {
            Enable = false, 
            Url    = "", 
            Color  = 10038562
        },

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
