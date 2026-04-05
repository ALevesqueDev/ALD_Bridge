--[[---------------------------------------------------------
    ALD_Bridge — Server Bootstrap & Framework Detection
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge
-----------------------------------------------------------]]

-- Safe global init — preserves ALD table if already declared by another file
ALD = ALD or {}

--[[---------------------------------------------------------
    DetectFramework
    Reads Config.Framework and resolves which framework is
    active. Uses GetResourceState() only — safe to call at
    boot before any framework natives are available.
-----------------------------------------------------------]]
local function DetectFramework()
    if Config.Framework == 'esx' then
        -- Manual override — trust the server owner
        ALD.Framework = 'esx'

    elseif Config.Framework == 'qb' then
        -- Manual override — trust the server owner
        ALD.Framework = 'qb'

    elseif Config.Framework == 'auto' then
        -- Check ESX first, then QBCore
        if GetResourceState('es_extended') == 'started' then
            ALD.Framework = 'esx'

        elseif GetResourceState('qb-core') == 'started' then
            ALD.Framework = 'qb'

        else
            -- Neither found — bridge cannot function
            ALD.Framework = nil
            print('^1[ALD_Bridge] ERROR: No supported framework detected.')
            print('^1[ALD_Bridge] Make sure es_extended or qb-core is started BEFORE ALD_Bridge.')
            print('^1[ALD_Bridge] Or set Config.Framework manually to "esx" or "qb" in config/config.lua.^7')
            return
        end
    else
        -- Invalid value in config
        ALD.Framework = nil
        print('^1[ALD_Bridge] ERROR: Invalid Config.Framework value "' .. tostring(Config.Framework) .. '".')
        print('^1[ALD_Bridge] Valid values are: "auto", "esx", "qb".^7')
        return
    end

    local label = ALD.Framework == 'esx' and 'ESX' or 'QBCore'
    print('^2[ALD_Bridge] Framework detected: ' .. label .. '^7')
end

DetectFramework()
