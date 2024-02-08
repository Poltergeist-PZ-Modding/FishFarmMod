local Mod = require("FishFarmMod")

require "TimedActions/ISBaseTimedAction"
local Action = ISBaseTimedAction:derive("FFMCollectFishAction")

function Action:new(character,info,option)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.stopOnWalk = true
    o.stopOnRun = true
    o.farm = info.obj
    o.info = info
    o.option = option
    o.startType = info.farmData.farmType

    if character:isTimedActionInstant() then
        o.maxTime = 1
    else
        o.maxTime = 300
    end

    return o
end

function Action:isValid()
    return self.farm:getObjectIndex() ~= -1 and self.startType == self.info.farmData.farmType
end

function Action:update()
    self.character:faceThisObject(self.farm)
    self.character:setMetabolicTarget(Metabolics.MediumWork)
end

function Action:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    self.character:reportEvent("EventLootItem")
    self.sound = self.character:playSound("CheckFishingNet")
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 20, 1)
end

function Action:stop()
    self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self)
end

function Action:perform()
    self.character:stopOrTriggerSound(self.sound)

    local data = self.info.farmData
    local dataObj
    local offset
    if self.info.singleTile then
        dataObj = self.farm
        offset = Mod.Types[self.option].attachedOffset1
        if offset ~= nil then
            Mod.Util.changeAttachedSprite(self.farm, string.format("FishFarmMod_%d", 16 + offset))
        else
            Mod.Util.changeAttachedSprite(self.farm, nil)
        end
    else
        local gridObjects = ArrayList.new()
        self.farm:getSpriteGridObjects(gridObjects)
        dataObj = gridObjects:get(0)
        offset = Mod.Types[self.option].attachedOffset2
        local fn = function(s) return s + offset end
        for i = 0, gridObjects:size() - 1 do
            local object = gridObjects:get(i)
            if offset ~= nil then
                Mod.Util.changeAttachedSprite(object, object:getTextureName():gsub("%d+$",fn))
            else
                Mod.Util.changeAttachedSprite(object, nil)
            end
        end
    end

    if self.option == "clean" then
        local bleach = self.character:getInventory():getFirstTypeEvalRecurse("Base.Bleach",function(item) return item:getThirstChange() < self.info.bleachDelta end)
        if bleach ~= nil then
            bleach:setThirstChange(bleach:getThirstChange() + self.info.bleachDelta)
            if bleach:getThirstChange() >= 0 then bleach:Use() end
            data.farmType,data.fillSpeed,data.filled = nil, nil, nil
        end
    else
        data.farmType = self.option
        data.fillSpeed = self.option == "bait" and 30 or self.option == "crab" and 20 or 10
        data.filled = 0
        data.compost = nil
    end
    dataObj:transmitModData()

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

Mod.FishFarmAction = Action
