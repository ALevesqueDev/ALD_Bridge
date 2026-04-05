--[[---------------------------------------------------------
    ALD_Bridge — QBCore / Qbox Server-Side Adapter
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge

    Only runs if the detected framework is QBCore or Qbox.
    Qbox (qbx_core) is preferred when available — falls back to qb-core.
    All functions return normalized structures — never raw framework objects.
-----------------------------------------------------------]]

if ALD.Framework ~= 'qb' then return end

-- Lazy-loaded core object — fetched once on first call, cached thereafter
local Core = nil
local function getCore()
    if Core then return Core end
    if GetResourceState('qbx_core') == 'started' then
        Core = exports.qbx_core:GetCoreObject()
    else
        Core = exports['qb-core']:GetCoreObject()
    end
    return Core
end

-- Internal helper — fetches and nil-guards Player with a named warning
local function fetchPlayer(source, callerName)
    local player = getCore().Functions.GetPlayer(source)
    if not player then
        print('^3[ALD_Bridge] WARN: ' .. callerName .. ' — no player found for source ' .. tostring(source) .. '^7')
        return nil
    end
    return player
end

-- QBCore stores job grade as: PlayerData.job.grade.level (int) and .grade.name (string)
local function normalizeJob(job)
    return {
        name  = job.name,
        grade = job.grade.level,
        label = job.grade.name or ''
    }
end

--[[---------------------------------------------------------
    GetPlayer(source)
    Returns a normalized player table or nil.
-----------------------------------------------------------]]
function GetPlayer(source)
    local player = fetchPlayer(source, 'GetPlayer')
    if not player then return nil end

    local pd = player.PlayerData
    return {
        source     = source,
        identifier = pd.citizenid,
        name       = pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname,
        job        = normalizeJob(pd.job)
    }
end

--[[---------------------------------------------------------
    GetIdentifier(source)
    Returns the player citizenid string or nil.
-----------------------------------------------------------]]
function GetIdentifier(source)
    local player = fetchPlayer(source, 'GetIdentifier')
    if not player then return nil end
    return player.PlayerData.citizenid
end

--[[---------------------------------------------------------
    GetJob(source)
    Returns { name, grade, label } or nil.
-----------------------------------------------------------]]
function GetJob(source)
    local player = fetchPlayer(source, 'GetJob')
    if not player then return nil end
    return normalizeJob(player.PlayerData.job)
end

--[[---------------------------------------------------------
    AddItem(source, itemName, amount)
    Adds an item to the player's inventory.
    Returns true on success, false if player not found.
-----------------------------------------------------------]]
function AddItem(source, itemName, amount)
    local player = fetchPlayer(source, 'AddItem')
    if not player then return false end
    return player.Functions.AddItem(itemName, amount)
end

--[[---------------------------------------------------------
    RemoveItem(source, itemName, amount)
    Removes an item from the player's inventory.
    Returns true on success, false if player not found.
-----------------------------------------------------------]]
function RemoveItem(source, itemName, amount)
    local player = fetchPlayer(source, 'RemoveItem')
    if not player then return false end
    return player.Functions.RemoveItem(itemName, amount)
end

--[[---------------------------------------------------------
    Notify(source, message, type)
    Sends a typed notification to a specific player.
    type: 'success' | 'error' | 'info' | 'warning'
-----------------------------------------------------------]]
function Notify(source, message, type)
    TriggerClientEvent('QBCore:Notify', source, message, type)
end

--[[---------------------------------------------------------
    NotifyAll(message, type)
    Sends a typed notification to every connected player.
    Passing -1 as source broadcasts to all players in FiveM.
-----------------------------------------------------------]]
function NotifyAll(message, type)
    TriggerClientEvent('QBCore:Notify', -1, message, type)
end

print('^2[ALD_Bridge] Server adapter loaded: QBCore/Qbox^7')
