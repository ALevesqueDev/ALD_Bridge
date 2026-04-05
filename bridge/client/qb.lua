--[[---------------------------------------------------------
    ALD_Bridge — QBCore / Qbox Client-Side Adapter
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge

    Only runs if the detected framework is QBCore or Qbox.
    Qbox (qbx_core) is preferred when available — falls back to qb-core.
    All functions return normalized structures — never raw framework objects.
-----------------------------------------------------------]]

if ALD.Framework ~= 'qb' then return end

-- ox_lib exposes `lib` as a global — unknown to the Lua LSP but valid at runtime.
---@diagnostic disable-next-line: undefined-global
local lib = lib

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

-- Active progress bar handle for cancellation
local activeProgressBar = nil

-- QBCore job normalizer — grade is stored as { level, name }
local function normalizeJob(job)
    return {
        name  = job.name,
        grade = job.grade.level,
        label = job.grade.name or ''
    }
end

--[[---------------------------------------------------------
    GetPlayerData()
    Returns a normalized local player data table.
-----------------------------------------------------------]]
function GetPlayerData()
    local pd = getCore().Functions.GetPlayerData()
    if not pd then return nil end

    return {
        identifier = pd.citizenid,
        name       = pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname,
        job        = normalizeJob(pd.job)
    }
end

--[[---------------------------------------------------------
    Notify(message, type, duration)
    Shows a typed notification to the local player.
    type: 'success' | 'error' | 'info' | 'warning'
-----------------------------------------------------------]]
function Notify(message, type, duration)
    getCore().Functions.Notify(message, type, duration or 5000)
end

--[[---------------------------------------------------------
    ProgressBar(label, duration, callback)
    Starts a progress bar. Fires callback(cancelled) when done.
    cancelled = false on completion, true if CancelProgressBar() was called.
-----------------------------------------------------------]]
function ProgressBar(label, duration, callback)
    -- Use ox_lib if available — cleaner API and widely used on QBCore/Qbox servers
    if GetResourceState('ox_lib') == 'started' then
        lib.progressBar({
            duration        = duration,
            label           = label,
            useWhileDead    = false,
            canCancel       = true,
            disable = { move = true, car = true, combat = true },
        }, function(cancelled)
            activeProgressBar = nil
            if callback then callback(cancelled) end
        end)
        activeProgressBar = true
        return
    end

    -- Fallback: progressbar resource (common on QBCore servers)
    if GetResourceState('progressbar') == 'started' then
        activeProgressBar = true
        exports['progressbar']:Progress({
            name         = 'ald_bridge_progress',
            duration     = duration,
            label        = label,
            useWhileDead = false,
            canCancel    = true,
            controlDisables = { disableMovement = true, disableCarMovement = true, disableCombat = true },
        }, function(cancelled)
            activeProgressBar = nil
            if callback then callback(cancelled) end
        end)
        return
    end

    -- Last resort: simple timer with no visual bar
    activeProgressBar = true
    SetTimeout(duration, function()
        if activeProgressBar then
            activeProgressBar = nil
            if callback then callback(false) end
        end
    end)
end

--[[---------------------------------------------------------
    CancelProgressBar()
    Cancels any active progress bar.
-----------------------------------------------------------]]
function CancelProgressBar()
    if not activeProgressBar then return end
    activeProgressBar = nil

    if GetResourceState('ox_lib') == 'started' then
        lib.cancelProgressBar()
        return
    end

    if GetResourceState('progressbar') == 'started' then
        exports['progressbar']:RemoveProgressBar()
    end
end

--[[---------------------------------------------------------
    HasItem(itemName)
    Returns true if the local player has at least 1 of the item.
-----------------------------------------------------------]]
function HasItem(itemName)
    return getCore().Functions.HasItem(itemName)
end

--[[---------------------------------------------------------
    GetInventory()
    Returns the full local player inventory table.
-----------------------------------------------------------]]
function GetInventory()
    local pd = getCore().Functions.GetPlayerData()
    if not pd then return {} end
    return pd.items or {}
end

print('^2[ALD_Bridge] Client adapter loaded: QBCore/Qbox^7')
