local Mod = require "FishFarmMod"

local Context = {
    farmObjects = ArrayList.new(),
}

function Context.onFarmAction(character, info, action)
    if luautils.walkAdj(character,info.obj:getSquare(), false) then
        ISTimedActionQueue.add(Mod.FishFarmAction:new(character,info,action))
    end
end

---@param character IsoGameCharacter
---@param info table
function Context.onCollectAction(character, info)
    if luautils.walkAdj(character, info.obj:getSquare(), false) then
        local ft = info.obj:getModData().farmType
        if ft ~= nil and ft ~= "moss" then
            ISTimedActionQueue.add(Mod.CollectAction:new(character, info.obj))
        end
    else
        character:setHaloNote(getText("ContextMenu_FishFarmMod_NoAccessNW"),255,255,255,150)
    end
end

function Context.onBuildFarm(playerNum,info)
    getCell():setDrag(Mod.Build:new(playerNum,info), playerNum)
end

function Context.addBuildContextOptions(playerNum,context)
    local ISBuildMenu = ISBuildMenu
    local character = getSpecificPlayer(playerNum)

    local invalid
    if SandboxVars.OrbitFishingMod.FarmCraftingMagazine and not character:getKnownRecipes():contains("FishFarmMod MakeFarmNet") then
        invalid = getText("IGUI_FishFarmMod_RequiresMagazine")
    elseif not character:getInventory():containsTagEvalRecurse("Hammer", function(item) return not item:isBroken() end) then
        invalid = getText("IGUI_FishFarmMod_RequiresHammer")
    end

    if invalid ~= nil and not ISBuildMenu.cheat then
        local option = context:addOption(getText("IGUI_FishFarmMod_FishFarm"))
        option.notAvailable = true
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip.description = (ISBuildMenu.bhs or "") .. invalid
    else
        local subMenu = context:getNew(context)
        context:addSubMenu(context:addOption(getText("IGUI_FishFarmMod_FishFarm")), subMenu)
        for _,option in ipairs({"FishFarm","FishFarmSingle"}) do
            local buildReq = Mod.BuildInfo[option]
            local option = subMenu:addOption(getText("IGUI_FishFarmMod_Build"..option), playerNum, Context.onBuildFarm, buildReq)
            local toolTip = ISBuildMenu.canBuild(buildReq.Planks,buildReq.Nails,0,0,0,buildReq.Carpentry,option,playerNum)
            toolTip:setName(getText("IGUI_FishFarmMod_FishFarm"))
            local rgb
            local netCount = ISBuildMenu.countMaterial(playerNum,"Base.FishingNet")
            if netCount < buildReq.FishingNets and not ISBuildMenu.cheat then
                rgb = ISBuildMenu.bhs
                option.notAvailable = true
            else
                rgb = ISBuildMenu.ghs
            end
            toolTip.description = getText("IGUI_FishFarmMod_BuildFishDescription")..string.format("%s%s%s %d/%d <LINE> ",toolTip.description,
                    rgb or "",getItemNameFromFullType("Base.FishingNet"),netCount, buildReq.FishingNets)
            ISBuildMenu.requireHammer(option)
        end
    end
end

function Context.addFarmContextOptions(playerNum,context)
    local character = getSpecificPlayer(playerNum)
    local info = {}

    local spriteGrid = Context.farmObject:getSprite():getSpriteGrid()
    local dc = 0
    if not spriteGrid then
        info.singleTile = true
        info.obj = Context.farmObject
        info.farmData = Context.farmObject:getModData()
        dc = Context.farmObject:getCompost()
        if dc > 0 then
            Context.farmObject:setCompost(0)
        end
    else
        Context.farmObject:getSpriteGridObjects(Context.farmObjects)
        local objSize = Context.farmObjects:size()
        if spriteGrid:getSpriteCount() == objSize then
            info.obj = Context.farmObjects:get(0)
            info.farmData = info.obj:getModData()
            for i = 0, objSize - 1 do
                local object = Context.farmObjects:get(i)
                local objectCompost = object ~= nil and object:getCompost() or 0
                if objectCompost > 0 then
                    dc = dc + objectCompost
                    object:setCompost(0)
                end
            end
        end
    end

    if dc > 0 and info.farmData ~= nil then
        if not info.farmData.farmType then
            info.farmData.compost = (info.farmData.compost or 0) + dc
        else
            info.farmData.filled = info.farmData.filled + dc / info.farmData.fillSpeed
        end

        if info.singleTile then
            Context.farmObject:transmitModData()
        else
            Context.farmObjects:get(0):transmitModData()
        end
    end

    if not info.farmData then
        local option = context:addOption(getText("IGUI_FishFarmMod_FishFarm"))
        option.notAvailable = true
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip.description = (ISBuildMenu.bhs or "") .. getText("IGUI_FishFarmMod_FarmBroken")
    elseif not info.farmData.farmType then
        info.farmData.compost = info.farmData.compost or 0
        local subMenu = context:getNew(context)
        local subMenuOption = context:addOption(getText("IGUI_FishFarmMod_FishFarm"))
        context:addSubMenu(subMenuOption, subMenu)

        local option = subMenu:addOption(getText("IGUI_FishFarmMod_FishFarmOption"),character, Context.onFarmAction, info, "bait")
        if info.singleTile then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = (ISBuildMenu.bhs or "") .. getText("IGUI_FishFarmMod_SmallFarm")
        elseif info.farmData.compost < 30 then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = (ISBuildMenu.bhs or "") .. getText("IGUI_FishFarmMod_LowCompost",info.farmData.compost,30)
        end

        option = subMenu:addOption(getText("IGUI_FishFarmMod_CrabFarmOption"),character, Context.onFarmAction, info, "crab")
        if info.farmData.compost < 20 then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = (ISBuildMenu.bhs or "") .. getText("IGUI_FishFarmMod_LowCompost",info.farmData.compost,20)
        end

        option = subMenu:addOption(getText("IGUI_FishFarmMod_ShrimpFarmOption"),character, Context.onFarmAction, info, "shrimp")
        if info.farmData.compost < 10 then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = (ISBuildMenu.bhs or "") .. getText("IGUI_FishFarmMod_LowCompost",info.farmData.compost,10)
        end
    else
        local subMenu = context:getNew(context)
        local subMenuOption = context:addOption(getText("IGUI_FishFarmMod_FishFarm"))
        context:addSubMenu(subMenuOption, subMenu)

        local collectNum = math.floor(info.farmData.filled)
        local collectOption = subMenu:addOption(getText("IGUI_FishFarmMod_CollectFarmOption",collectNum),character, Context.onCollectAction, info)
        if collectNum < 1 or info.farmData.farmType == "moss" then collectOption.notAvailable = true end

        local cleanOption = subMenu:addOption(getText("IGUI_FishFarmMod_CleanFarmOption"),character, Context.onFarmAction, info, "clean")
        info.bleachDelta = info.singleTile and - 0.05 or  - 0.2
        if not character:getInventory():containsTypeEvalRecurse("Base.Bleach",function(item) return item:getThirstChange() < info.bleachDelta end) then
            cleanOption.notAvailable = true
        end
    end
end

function Context.OnPreFillWorldObjectContextMenu(player, context, worldobjects, test)
    Context.farmObject = nil
    local _compost = compost
    if _compost ~= nil then
        local name = _compost:getTextureName()
        if name ~= nil and name:find("^FishFarmMod_") ~= nil then
            Context.farmObject = _compost
            compost = nil
        end
    end
end

function Context.OnFillWorldObjectContextMenu(playerNum, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end

    if Context.farmObject == nil then
        local hasWater = canTrapFish or canFish
        if not hasWater then
            local waterFlag = IsoFlagType.water
            for i,v in ipairs(worldobjects) do
                local sq = v:getSquare()
                if sq ~= nil and sq:Is(waterFlag) then
                    hasWater = true
                    break
                end
            end
        end
        if hasWater then
            Context.addBuildContextOptions(playerNum,context)
        end
    else
        Context.addFarmContextOptions(playerNum,context)
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(Context.OnPreFillWorldObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(Context.OnFillWorldObjectContextMenu)

Mod.UI = Context