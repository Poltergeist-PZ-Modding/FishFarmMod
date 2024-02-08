local Patch = {}


Patch["ISMoveableSpriteProps.scrapObject"] = function()
    require "Moveables/ISMoveableSpriteProps"
    local original = ISMoveableSpriteProps.scrapObject
    function ISMoveableSpriteProps.scrapObject(self,_character)
        if self.sprite:getSpriteGrid() ~= nil and self.spriteName ~= nil and self.spriteName:find("^FishFarmMod_") ~= nil then
            local added = 0
            local scrapResult, chance, perkName = self:canScrapObject(_character)

            if scrapResult.canScrap then
                local scrapDef = ISMoveableDefinitions:getInstance().getScrapDefinition( self.material )
                --local scrapResult, chance, perkName = self:canScrapObject(_character)

                local gridObjects = ArrayList.new()
                self.object:getSpriteGridObjects(gridObjects)
                for i=0,gridObjects:size()-1 do
                    local object = gridObjects:get(i)
                    local square = object:getSquare()
                    if scrapDef and object and square then
                        added = added + self:scrapObjectInternal(_character, scrapDef, square, object, scrapResult, chance, perkName)
                    end
                end
            end
            self:scrapHaloNoteCheck(_character, added)
        else
            return original(self,_character)
        end
    end
end

require("FishFarmMod").ClientPatch = Patch
