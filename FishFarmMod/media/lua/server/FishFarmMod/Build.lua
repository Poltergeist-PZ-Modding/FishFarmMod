local Mod = require "FishFarmMod"

require "BuildingObjects/ISBuildingObject"
local Build = ISBuildingObject:derive("FishFarmModBuild")

function Build:new(playerNum,buildInfo)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o.player = playerNum
    o.character = getSpecificPlayer(playerNum)
    o.buildInfo = buildInfo
    o.sprite = buildInfo.sprite
    o.spriteList = buildInfo.spriteList
    o.modData = {
        ["need:Base.Plank"] = tostring(buildInfo.Planks),
        ["need:Base.Nails"] = tostring(buildInfo.Nails),
        ["need:Base.FishingNet"] = tostring(buildInfo.FishingNets),
    }
    o:initialise()
    return o
end

function Build:initialise()
    self.colorMod = { r = 0, g = 1, b = 0 }
    self.colorModInvalid = { r = 1, g = 0, b = 0 }
    self.floorSprite = IsoSprite.new()
    self.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
    self.userName = isClient() and self.character:getUsername()

    if self.spriteList ~= nil then
        self.spriteGrid = {}
        for i,sprite in ipairs(self.spriteList) do
            local spriteObj = IsoSprite.new()
            spriteObj:LoadFramesNoDirPageSimple(sprite)
            self.spriteGrid[i-1] = spriteObj
        end
        self.xGridOff, self.yGridOff = 0, 0
    else
        self.renderSprite = IsoSprite.new()
        self.renderSprite:LoadFramesNoDirPageSimple(self.sprite)
    end
end

function Build:isValid(square,north)
    if self.prevSquare ~= square then
        self.prevSquare = square
        self.valid = false
        if not self:canBuildOnSquare(square) then return false end
        if not self:haveMaterial(square) then return false end
        if not self.canWalkTo(self.character,square) then return false end

        if self.spriteList ~= nil then
            self.valid = self:updateGridDir(square)
        else
            self.valid = true
        end
    end
    return self.valid
end

function Build:render(x, y, z, square)
    local col = self.valid and self.colorMod or self.colorModInvalid

    self.floorSprite:RenderGhostTileColor(x, y, z, col.r, col.g, col.b, 0.8)

    if self.spriteList ~= nil then
        x, y = x + self.xGridOff, y + self.yGridOff
        for xGrid = 0, 1 do
            for yGrid = 0, 1 do
                self.spriteGrid[xGrid+2*yGrid]:RenderGhostTileColor(x+xGrid, y+yGrid, z, 0, 0, col.r, col.g, col.b, 0.8)
            end
        end
    else
        self.renderSprite:RenderGhostTileColor(x, y, z, 0, 0, col.r, col.g, col.b, 0.8)
    end
end

function Build:tryBuild(x, y, z)
    self.prevSquare = nil
    if self:isValid(getSquare(x,y,z)) then
        ISBuildingObject.tryBuild(self, x, y, z)
    end
end

function Build:create(x, y, z, north, sprite)
    local Cell = getCell()

    if self.spriteList ~= nil then
        x, y = x + self.xGridOff, y + self.yGridOff
        for xGrid = 0, 1 do
            for yGrid = 0, 1 do
                local square = Cell:getGridSquare(x+xGrid,y+yGrid,z)
                local object = IsoCompost.new(Cell, square)
                object:setSprite(getSprite(self.spriteList[1+xGrid+2*yGrid]))
                square:transmitAddObjectToSquare(object, -1)
            end
        end
    else
        local square = Cell:getGridSquare(x,y,z)
        local object = IsoCompost.new(Cell, square)
        object:setSprite(getSprite(self.sprite))
        square:transmitAddObjectToSquare(object, -1)
    end

    buildUtil.consumeMaterial(self)
end

function Build.canWalkTo(character,square)
    square = luautils.getCorrectSquareForWall(character, square)
    local diffX = math.abs(square:getX() + 0.5 - character:getX())
    local diffY = math.abs(square:getY() + 0.5 - character:getY())
    if diffX <= 1.6 and diffY <= 1.6 then return true end
    local adjacent = AdjacentFreeTileFinder.Find(square, character)
    if adjacent ~= nil then return true else return  false end
end

function Build:canBuildOnSquare(square)
    if not square then return end
    if not square:Is(IsoFlagType.water) then return end
    if square:getObjects():size() > 1 then return end
    if square:getMovingObjects():size() > 0 then return end
    if square:isVehicleIntersecting() then return end
    if self.userName then
         if SafeHouse.isSafeHouse(square, self.userName, true) then return end
    end

    return true
end

function Build:updateGridDir(square)
    local IsoDirections = IsoDirections

    local validE = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.E))
    local validS = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.S))
    local validSE = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.SE))
    if validE and validS and validSE then
        self.xGridOff, self.yGridOff = 0, 0
        return true
    end
    local validW = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.W))
    local validSW = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.SW))
    if validS and validW and validSW then
        self.xGridOff, self.yGridOff = -1, 0
        return true
    end
    local validN = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.N))
    local validNW = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.NW))
    if validN and validW and validNW then
        self.xGridOff, self.yGridOff = -1, -1
        return true
    end
    local validNE = self:canBuildOnSquare(square:getAdjacentSquare(IsoDirections.NE))
    if validN and validE and validNE then
        self.xGridOff, self.yGridOff = 0, -1
        return true
    end
end

Mod.Build = Build