# ALD_Bridge

**Universal ESX / QBCore / Qbox framework bridge for FiveM**
Free, open-source dependency for all ALD_ scripts by [ALevesqueDev](https://github.com/ALevesqueDev).

---

## What is ALD_Bridge?

ALD_Bridge is a lightweight Lua resource that sits between your framework (ESX, QBCore, or Qbox) and any ALD_ script. Instead of writing framework-specific code inside every script, all ALD_ resources call the bridge — which handles the difference invisibly.

**One config line. Works on any server.**

```lua
Config.Framework = 'auto' -- detects ESX, QBCore, or Qbox automatically
```

---

## Features

- Auto-detects **ESX**, **QBCore**, and **Qbox** (`qbx_core`) at boot
- Manual framework override for edge cases
- Unified **server-side exports** — player data, jobs, inventory, notifications
- Unified **client-side exports** — player data, notifications, progress bars, inventory checks
- Clear console output on startup — know instantly if something is wrong
- Zero dependencies — ALD_Bridge itself requires nothing beyond your framework
- Free and open source forever

---

## Requirements

| Requirement | Version |
|---|---|
| FiveM Server | Latest recommended |
| Framework | ESX (`es_extended`) **or** QBCore (`qb-core`) **or** Qbox (`qbx_core`) |
| Lua | 5.4 (set automatically via manifest) |

---

## Installation

**1. Download and add to your server**

Place the `ALD_Bridge` folder inside your server's `resources/` directory.

**2. Add to server.cfg — after your framework**

```cfg
ensure qbx_core   # or es_extended / qb-core
ensure ALD_Bridge  # must come AFTER your framework
```

> **Important:** ALD_Bridge must start after your framework resource or detection will fail.

**3. Configure (optional)**

Open `config/config.lua`. The default `'auto'` setting works for most servers.

```lua
Config.Framework = 'auto'  -- 'auto' | 'esx' | 'qb'
```

Only change this if auto-detection fails on your server.

**4. Verify**

Start your server and look for this line in the console:

```
[ALD_Bridge] Framework detected: QBCore
```

That's it — no database setup, no additional config.

---

## Server-Side Exports

Call from any server-side script:

```lua
exports['ALD_Bridge']:FunctionName(...)
```

| Export | Parameters | Returns | Description |
|---|---|---|---|
| `GetPlayer` | `source` | `table` or `nil` | Full normalized player object |
| `GetIdentifier` | `source` | `string` or `nil` | Player license identifier |
| `GetJob` | `source` | `table` or `nil` | `{ name, grade, label }` |
| `AddItem` | `source, itemName, amount` | `bool` | Add item to player inventory |
| `RemoveItem` | `source, itemName, amount` | `bool` | Remove item from player inventory |
| `Notify` | `source, message, type` | `void` | Notify a specific player |
| `NotifyAll` | `message, type` | `void` | Notify all connected players |

**Notification types:** `'success'` `'error'` `'info'` `'warning'`

### Examples

```lua
-- Get a player's job
local job = exports['ALD_Bridge']:GetJob(source)
if job then
    print(job.name)   -- "police"
    print(job.grade)  -- 2
    print(job.label)  -- "Officer"
end

-- Add an item to a player
local ok = exports['ALD_Bridge']:AddItem(source, 'shell_casing', 1)

-- Notify a specific player
exports['ALD_Bridge']:Notify(source, 'Evidence collected.', 'success')

-- Notify everyone
exports['ALD_Bridge']:NotifyAll('Server restarting in 5 minutes.', 'warning')
```

---

## Client-Side Exports

Call from any client-side script:

```lua
exports['ALD_Bridge']:FunctionName(...)
```

| Export | Parameters | Returns | Description |
|---|---|---|---|
| `GetPlayerData` | — | `table` | Local player data (name, identifier, job) |
| `Notify` | `message, type, duration` | `void` | Show notification to local player |
| `ProgressBar` | `label, duration, callback` | `void` | Start a progress bar |
| `CancelProgressBar` | — | `void` | Cancel active progress bar |
| `HasItem` | `itemName` | `bool` | Check if local player has an item |
| `GetInventory` | — | `table` | Full local player inventory |

### Examples

```lua
-- Get local player data
local data = exports['ALD_Bridge']:GetPlayerData()
print(data.name)      -- "John Doe"
print(data.job.name)  -- "police"

-- Show a notification
exports['ALD_Bridge']:Notify('Evidence collected.', 'success', 3000)

-- Progress bar with callback
exports['ALD_Bridge']:ProgressBar('Collecting evidence...', 5000, function()
    TriggerServerEvent('ALD_ForensIQ:collectEvidence', evidenceId)
end)
```

---

## Normalized Player Object

Both ESX and QBCore return this identical structure:

```lua
{
    source     = 1,
    identifier = "license:abc123",
    name       = "John Doe",
    job        = {
        name  = "police",
        grade = 2,
        label = "Officer"
    }
}
```

---

## For Script Developers

Using ALD_Bridge in your own resource:

**1. Declare the dependency in your `fxmanifest.lua`:**
```lua
dependency 'ALD_Bridge'
```

**2. Call exports instead of framework functions:**
```lua
-- Instead of this (framework-specific):
local xPlayer = ESX.GetPlayerFromId(source)
local job = xPlayer.job.name

-- Do this (works everywhere):
local job = exports['ALD_Bridge']:GetJob(source)
```

**3. Your script now works on ESX, QBCore, and Qbox with zero changes.**

---

## Troubleshooting

**`ERROR: No supported framework detected`**
→ ALD_Bridge is starting before your framework. Move `ensure ALD_Bridge` to after your framework in `server.cfg`.

**`ERROR: Invalid Config.Framework value`**
→ Check `config/config.lua`. Valid values are `'auto'`, `'esx'`, `'qb'`.

**Export returns nil unexpectedly**
→ Check the server console for a `[ALD_Bridge] WARN` line — it will tell you which player lookup failed.

---

## ALD_ Script Collection

ALD_Bridge is the foundation for all scripts by ALevesqueDev:

| Script | Description | Price |
|---|---|---|
| **ALD_Bridge** | Framework bridge | Free |
| **ALD_ForensIQ** | Forensic evidence & investigation system | Coming soon |

---

## License

ALD_Bridge is released under the [MIT License](LICENSE). Free to use, modify, and distribute.

---

<div align="center">
  Made with care by <a href="https://github.com/ALevesqueDev">ALevesqueDev</a>
</div>
