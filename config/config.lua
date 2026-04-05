--[[---------------------------------------------------------
    ALD_Bridge — Configuration
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge
-----------------------------------------------------------]]

Config = {}

--[[---------------------------------------------------------
    FRAMEWORK
    Controls which framework ALD_Bridge will talk to.

    Valid values:
      'auto' — detects ESX or QBCore automatically at boot (recommended)
      'esx'  — force ESX, skips detection
      'qb'   — force QBCore, skips detection

    Only change this if auto-detection fails on your server.
-----------------------------------------------------------]]
Config.Framework = 'auto'
