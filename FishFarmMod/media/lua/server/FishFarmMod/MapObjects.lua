if isClient() then return end

local Util = require("FishFarmMod").Util

local function OnLoadWithSprite(isoObject)
    local data = isoObject:getModData()

    local compost = isoObject:getCompost()
    if compost > 0 then
        isoObject:setCompost(0)

        if not data.farmType then
            data.compost = (data.compost or 0) + compost
        else
            data.filled = data.filled + compost / data.fillSpeed
        end
    end

    if data.farmType == "moss" and data.filled > 9000 then
        Util.changeAttachedSprite(isoObject,"FishFarmMod_22")
    end
    if (data.compost or 0) > 200 or data.farmType ~= nil and data.farmType ~= "moss" and ZombRand(100-data.filled) == 0 then -- and data.filled > 8
        Util.changeAttachedSprite(isoObject,"FishFarmMod_21")
        data.farmType,data.fillSpeed,data.filled,data.compost = "moss", 0.025, 0, nil
    end
    --isoObject:transmitModData()
end

---Convert old overlays to attached sprites
---FIXME added in Feb '24
---@param object IsoObject
local function convertOverlays(object)
    local overlay = object:getOverlaySprite()
    if overlay ~= nil then
        object:setOverlaySprite(nil)
        Util.changeAttachedSprite(object, overlay:getName())
    end
end

MapObjects.OnLoadWithSprite("FishFarmMod_16", OnLoadWithSprite, 5)
MapObjects.OnLoadWithSprite("FishFarmMod_0", convertOverlays, 5)
MapObjects.OnLoadWithSprite("FishFarmMod_1", convertOverlays, 5)
MapObjects.OnLoadWithSprite("FishFarmMod_2", convertOverlays, 5)
MapObjects.OnLoadWithSprite("FishFarmMod_3", convertOverlays, 5)
MapObjects.OnLoadWithSprite("FishFarmMod_16", convertOverlays, 5)
