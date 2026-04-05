--[[---------------------------------------------------------
    ALD_Bridge — ESX Server-Side Adapter
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge

    Only runs if the detected framework is ESX.
    All functions return normalized structures — never raw ESX objects.
-----------------------------------------------------------]]

if ALD.Framework ~= 'esx' then return end

-- Lazy-loaded ESX object — fetched once on first call, cached thereafter
local ESX = nil
local function getESX()
    if ESX then return ESX end
    ESX = exports['es_extended']:getSharedObject()
    return ESX
end

-- Internal helper — fetches and nil-guards xPlayer with a named warning
local function fetchPlayer(source, callerName)
    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then
        print('^3[ALD_Bridge] WARN: ' .. callerName .. ' — no player found for source ' .. tostring(source) .. '^7')
        return nil
    end
    return xPlayer
end

-- ESX stores job.grade as a number in ESX Legacy, but as a table in older builds.
-- This normalizer handles both so ALD_Bridge works on any ESX version.
local function normalizeJob(job)
    local grade = type(job.grade) == 'table' and job.grade.level or job.grade
    local label = type(job.grade) == 'table' and job.grade.name  or job.grade_label
    return {
        name  = job.name,
        grade = grade,
        label = label or ''
    }
end

--[[---------------------------------------------------------
    GetPlayer(source)
    Returns a normalized player table or nil.
-----------------------------------------------------------]]
function GetPlayer(source)
    local xPlayer = fetchPlayer(source, 'GetPlayer')
    if not xPlayer then return nil end

    return {
        source     = source,
        identifier = xPlayer.identifier,
        name       = xPlayer.getName(),
        job        = normalizeJob(xPlayer.job)
    }
end

--[[---------------------------------------------------------
    GetIdentifier(source)
    Returns the player license identifier string or nil.
-----------------------------------------------------------]]
function GetIdentifier(source)
    local xPlayer = fetchPlayer(source, 'GetIdentifier')
    if not xPlayer then return nil end
    return xPlayer.identifier
end

--[[---------------------------------------------------------
    GetJob(source)
    Returns { name, grade, label } or nil.
-----------------------------------------------------------]]
function GetJob(source)
    local xPlayer = fetchPlayer(source, 'GetJob')
    if not xPlayer then return nil end
    return normalizeJob(xPlayer.job)
end

--[[---------------------------------------------------------
    AddItem(source, itemName, amount)
    Adds an item to the player's inventory.
    Returns true on success, false if player not found.
-----------------------------------------------------------]]
function AddItem(source, itemName, amount)
    local xPlayer = fetchPlayer(source, 'AddItem')
    if not xPlayer then return false end
    xPlayer.addInventoryItem(itemName, amount)
    return true
end

--[[---------------------------------------------------------
    RemoveItem(source, itemName, amount)
    Removes an item from the player's inventory.
    Returns true on success, false if player not found.
-----------------------------------------------------------]]
function RemoveItem(source, itemName, amount)
    local xPlayer = fetchPlayer(source, 'RemoveItem')
    if not xPlayer then return false end
    xPlayer.removeInventoryItem(itemName, amount)
    return true
end

--[[---------------------------------------------------------
    Notify(source, message, type)
    Sends a notification to a specific player.
    type: 'success' | 'error' | 'info' | 'warning'
-----------------------------------------------------------]]
function Notify(source, message)
    -- ESX showNotification does not support typed styles (success/error/etc.)
    TriggerClientEvent('esx:showNotification', source, message)
end

--[[---------------------------------------------------------
    NotifyAll(message, type)
    Sends a notification to every connected player.
-----------------------------------------------------------]]
function NotifyAll(message)
    -- TriggerClientEvent with -1 broadcasts to all players in FiveM
    TriggerClientEvent('esx:showNotification', -1, message)
end

print('^2[ALD_Bridge] Server adapter loaded: ESX^7')
