require "FishFarmMod/ClientPatches"
local Mod = require "FishFarmMod"

for k,v in pairs(Mod.ClientPatch) do
    v()
end
Mod.ClientPatch = nil