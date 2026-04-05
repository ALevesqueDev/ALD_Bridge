--[[---------------------------------------------------------
    ALD_Bridge — FiveM Resource Manifest
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge
-----------------------------------------------------------]]
---@diagnostic disable: undefined-global, missing-parameter
-- ^ FiveM manifest globals (fx_version, server_exports, etc.) are unknown to the Lua LSP — safe to ignore

fx_version 'cerulean'
game      'gta5'
lua54     'yes'

name        'ALD_Bridge'
author      'ALevesqueDev'
version     '1.0.0'
description 'Universal ESX / QBCore framework bridge — free dependency for all ALD_ scripts.'
repository  'https://github.com/ALevesqueDev/ALD_Bridge'

--[[ Load order:
     1. config    — shared, loaded first on both sides
     2. server    — detection runs at boot, then adapters
     3. client    — adapters loaded after detection
--]]

shared_scripts {
    'config/config.lua',
}

server_scripts {
    'server/main.lua',          -- framework detection (must be first)
    'bridge/server/esx.lua',    -- ESX server-side adapter
    'bridge/server/qb.lua',     -- QBCore server-side adapter
}

client_scripts {
    'client/main.lua',          -- client init
    'bridge/client/esx.lua',    -- ESX client-side adapter
    'bridge/client/qb.lua',     -- QBCore client-side adapter
}

--[[ Server-side exports — consumed by ALD_ scripts via:
     exports['ALD_Bridge']:FunctionName()
--]]
server_exports {
    'GetPlayer',
    'GetIdentifier',
    'GetJob',
    'AddItem',
    'RemoveItem',
    'Notify',
    'NotifyAll',
}

--[[ Client-side exports — consumed by ALD_ scripts via:
     exports['ALD_Bridge']:FunctionName()
--]]
exports {
    'GetPlayerData',
    'Notify',
    'ProgressBar',
    'CancelProgressBar',
    'HasItem',
    'GetInventory',
}
