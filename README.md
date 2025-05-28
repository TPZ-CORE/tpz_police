# TPZ-CORE Police

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory: https://github.com/TPZ-CORE/tpz_inventory

# Installation

1. When opening the zip file, open `tpz_police-main` directory folder and inside there will be another directory folder which is called as `tpz_police`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_police` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

## Commands 

- `@param source` : The source is considered as the online Player ID.
- `@param duration` : Requires a duration for the player jail time in order to be decreased, increased or set.

| Command                          | Ace Permission                      | Description                                                                            |
|----------------------------------|-------------------------------------|----------------------------------------------------------------------------------------|
| jail [source] [duration]         | tpzcore.police.jail                 | Execute this command to jail the selected player.                                      |
| unjail [source]                  | tpzcore.police.jail_out             | Execute this command to un-jail the selected player.                                   |
| checkjailtime [source]           | tpzcore.police.check_target_jail_duration  | Execute this command to check the jail duration of the selected player.                |
| myjailtime                       | tpzcore.police.check_jail_duration  | Execute this command to check the jail duration of your player.                        |
| breakhandcuffs [source]          | tpzcore.police.break_handcuffs      | Execute this command to break the handcuffs of a player who is handcuffed in case its bugged. |

- The ace permission: `tpzcore.all` Gives permissioms to all commands and actions (FOR ALL OFFICIAL PUBLISHED FREE SCRIPTS).
- The ace permission: `tpzcore.police.all` Gives permissions to all actions or commands ONLY for this script.

## Features

- Usable items based on the police job such as handcuffs, handcuff keys and detective kit to find the cause of player death. 
- Jail system that works offline and online in case a player leaves or server restarts, the player will be teleported to the jail cell until his / her time is finished. 