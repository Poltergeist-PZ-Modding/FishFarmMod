local Mod = require "FishFarmMod"

require "TimedActions/ISBaseTimedAction"
local Action = ISBaseTimedAction:derive("FFMCollectFishAction")

function Action:new(character, farm)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.stopOnWalk = true
    o.stopOnRun = true
    o.farm = farm
    o.farmType = farm:getModData().farmType
    o.items = Mod.Types[o.farmType].items

    if character:isTimedActionInstant() then
        o.maxTime = 1
    else
        o.maxTime = 300
    end
    return o
end

function Action:isValid()
    return self.farm:getObjectIndex() ~= -1 and self.farmType == self.farm:getModData().farmType
end

function Action:update()
    self.character:faceThisObject(self.farm)
    self.character:setMetabolicTarget(Metabolics.MediumWork)
end

function Action:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    self.character:reportEvent("EventLootItem")
    self.character:getSquare():playSound("CheckFishingNet")
    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 20, 1)
end

function Action:stop()
    ISBaseTimedAction.stop(self)
end

function Action:perform()
    local data = self.farm:getModData()
    local skill = self.character:getPerkLevel(Perks.Fishing)
    local inventory = self.character:getInventory()
    local fishAvailable = data.filled
    local ctLen = #self.items
    local caught = 0
    for i = 1, fishAvailable do
        if ZombRand(10) < skill then
            caught = caught + 1
            inventory:AddItem(self.items[ZombRand(ctLen) + 1])
        end
    end
    if caught > 0 then
        self.character:getXp():AddXP(Perks.Fishing, 1 * caught)
    else
        self.character:setHaloNote(getText("IGUI_Moveable_Fail"), 255,255,255,300)
    end

    data.filled = data.filled - caught
    self.farm:transmitModData()

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

Mod.CollectAction = Action
