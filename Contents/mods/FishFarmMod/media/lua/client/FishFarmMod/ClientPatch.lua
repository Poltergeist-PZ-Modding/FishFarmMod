local Patch = {}

Patch["ISMoveableSpriteProps.scrapObject"] = function(scrapObject)
    return function(self,_character)
        if self.sprite:getSpriteGrid() ~= nil and self.spriteName ~= nil and self.spriteName:find("^FishFarmMod_") then
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
            return scrapObject(self,_character)
        end
    end
end

FishFarmMod.ClientPatch = Patch
