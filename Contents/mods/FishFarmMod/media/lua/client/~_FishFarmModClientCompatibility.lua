require "FishFarmMod/ClientPatches"

require "Moveables/ISMoveableSpriteProps"
ISMoveableSpriteProps.scrapObject = FishFarmMod.ClientPatch["ISMoveableSpriteProps.scrapObject"](ISMoveableSpriteProps.scrapObject)
