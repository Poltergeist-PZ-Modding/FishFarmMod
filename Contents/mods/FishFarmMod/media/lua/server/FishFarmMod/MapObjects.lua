if isClient() then return end

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
        isoObject:setOverlaySprite("FishFarmMod_22")
    end
    if (data.compost or 0) > 200 or data.farmType ~= nil and data.farmType ~= "moss" and ZombRand(100-data.filled) == 0 then -- and data.filled > 8
        isoObject:setOverlaySprite("FishFarmMod_21")
        data.farmType,data.fillSpeed,data.filled,data.compost = "moss", 0.025, 0, nil
    end
    --isoObject:transmitModData()
end

MapObjects.OnLoadWithSprite("FishFarmMod_16", OnLoadWithSprite, 5)
