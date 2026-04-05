--[[---------------------------------------------------------
    ALD_Bridge — Client Bootstrap & Framework Detection
    Author: ALevesqueDev
    https://github.com/ALevesqueDev/ALD_Bridge

    Mirrors the server detection on the client side.
    Sets ALD.Framework so bridge adapter files know which one to load.
-----------------------------------------------------------]]

ALD = ALD or {}

-- Client-side detection uses the same GetResourceState() approach.
-- Framework objects are fetched lazily inside each adapter, not here.
if GetResourceState('es_extended') == 'started' then
    ALD.Framework = 'esx'
elseif GetResourceState('qb-core') == 'started' then
    ALD.Framework = 'qb'
elseif GetResourceState('qbx_core') == 'started' then
    ALD.Framework = 'qb'
else
    ALD.Framework = nil
    -- Server already printed the error — no need to duplicate it on the client
end
