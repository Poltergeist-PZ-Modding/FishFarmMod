local mod = FishFarmMod or {}

local Util = {}

mod.BuildInfo = {
    FishFarm = {
        sprite = "FishFarmMod_0",
        spriteList = {"FishFarmMod_2","FishFarmMod_3","FishFarmMod_0","FishFarmMod_1"},
        Carpentry = 4,
        Planks = 8,
        Nails = 12,
        FishingNets = 2,
    },
    FishFarmSingle = {
        sprite = "FishFarmMod_16",
        Carpentry = 3,
        Planks = 5,
        Nails = 4,
        FishingNets = 1,
    },
}

function Util.OnLoadedTileDefinitions(manager)
    local spriteList = mod.BuildInfo.FishFarm.spriteList
    local grid = IsoSpriteGrid.new(2,2)
    for xGrid = 0, 1 do
        for yGrid = 0, 1 do
            local sprite = manager:getSprite(spriteList[1+xGrid+2*yGrid])
            grid:setSprite(xGrid,yGrid,sprite)
            sprite:setSpriteGrid(grid)
        end
    end
end
Events.OnLoadedTileDefinitions.Add(Util.OnLoadedTileDefinitions)

mod.Util = Util
FishFarmMod = mod
