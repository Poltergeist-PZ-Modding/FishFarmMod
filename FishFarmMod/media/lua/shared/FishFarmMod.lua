local Mod = {
    BuildInfo = {
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
    },
    Types = {
        bait = {
            attachedOffset1 = 1,
            attachedOffset2 = 8,
            items = {
                "Base.BaitFish"
            },
        },
        crab = {
            attachedOffset1 = 2,
            attachedOffset2 = 4,
            items = {
                "FFM.Lobster",
                "FFM.BlueCrab",
                "FFM.PortunusCrab",
            },
        },
        shrimp = {
            attachedOffset1 = 3,
            attachedOffset2 = 12,
            items = {
                "FFM.Shrimp",
                "FFM.Shell",
            },
        },
        moss = {},
        clean = {},
    },
    Util = {},
}

---@param object IsoObject
---@param name? string
function Mod.Util.changeAttachedSprite(object,name)
    local attached = object:getAttachedAnimSprite()
    if not attached then
        attached = ArrayList.new(4)
        object:setAttachedAnimSprite(attached)
    end

    for i = attached:size() - 1, 0, -1 do
        local o = attached:get(i)
        if string.find(o:getName() or "","^FishFarmMod_") then
            attached:remove(o)
        end
    end

    if name ~= nil then
        attached:add(getSprite(name):newInstance())
    end

    object:transmitUpdatedSprite()
end

function Mod.Util.OnLoadedTileDefinitions(manager)
    local spriteList = Mod.BuildInfo.FishFarm.spriteList
    local grid = IsoSpriteGrid.new(2,2)
    for xGrid = 0, 1 do
        for yGrid = 0, 1 do
            local sprite = manager:getSprite(spriteList[1+xGrid+2*yGrid])
            grid:setSprite(xGrid,yGrid,sprite)
            sprite:setSpriteGrid(grid)
        end
    end
end

Events.OnLoadedTileDefinitions.Add(Mod.Util.OnLoadedTileDefinitions)

return Mod