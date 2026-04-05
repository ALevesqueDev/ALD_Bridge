--[[---------------------------------------------------------
    ALD_Bridge — ESX Client-Side Adapter
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

-- ox_lib exposes `lib` as a global — unknown to the Lua LSP but valid at runtime.
-- Will be nil if ox_lib is not running, which is guarded by GetResourceState() checks.
---@diagnostic disable-next-line: undefined-global
local lib = lib

-- Active progress bar handle for cancellation
local activeProgressBar = nil

-- ESX job normalizer — handles Legacy (grade as int) and older builds (grade as table)
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
    GetPlayerData()
    Returns a normalized local player data table.
-----------------------------------------------------------]]
function GetPlayerData()
    local pd = getESX().GetPlayerData()
    if not pd then return nil end

    return {
        identifier = pd.identifier,
        name       = (pd.firstName or '') .. ' ' .. (pd.lastName or ''),
        job        = normalizeJob(pd.job)
    }
end

--[[---------------------------------------------------------
    Notify(message, type, duration)
    Shows a notification to the local player.
    ESX showNotification does not support typed styles.
    duration is unused — ESX manages its own timing.
-----------------------------------------------------------]]
function Notify(message)
    getESX().ShowNotification(message)
end

--[[---------------------------------------------------------
    ProgressBar(label, duration, callback)
    Starts a progress bar. Fires callback(cancelled) when done.
    cancelled = false on completion, true if CancelProgressBar() was called.
-----------------------------------------------------------]]
function ProgressBar(label, duration, callback)
    -- Use ox_lib if available — cleaner API and widely used on ESX servers
    if GetResourceState('ox_lib') == 'started' then
        lib.progressBar({
            duration = duration,
            label    = label,
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

    -- Fallback: progressbar resource (common on ESX servers)
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
    ESX has no native HasItem — requires looping the inventory.
-----------------------------------------------------------]]
function HasItem(itemName)
    local pd = getESX().GetPlayerData()
    if not pd or not pd.inventory then return false end

    for _, item in pairs(pd.inventory) do
        if item.name == itemName and item.count > 0 then
            return true
        end
    end
    return false
end

--[[---------------------------------------------------------
    GetInventory()
    Returns the full local player inventory table.
-----------------------------------------------------------]]
function GetInventory()
    local pd = getESX().GetPlayerData()
    if not pd then return {} end
    return pd.inventory or {}
end

print('^2[ALD_Bridge] Client adapter loaded: ESX^7')
