--made for v41, sandbox not always loaded on Distributions merge

local Magazine = {}

function Magazine.addDistributions()
    local dist = ProceduralDistributions.list
    local subDist = {
        BookstoreMisc = 0.2,
        CampingStoreBooks = 8,
        CrateMagazines = 0.2,
        LibraryBooks = 0.2,
        MagazineRackMixed = 1,
        SurvivalGear = 1,
    }
    local item = "FFM.FishFarmCraftMagazine"

    local insert = table.insert
    for sd,r in pairs(subDist) do
        local dI = dist[sd] and dist[sd].items
        if dI then
            insert(dI, item)
            insert(dI, r)
        end
    end

    ItemPickerJava.doParse = true
end

function Magazine.recipeNeedLearn()
    local manager = getScriptManager()

    local recipe = manager:getRecipe("FishFarmMod MakeFarmNet")
    if recipe then
        recipe:setNeedToBeLearn(true)
    end
end

function Magazine.OnLoadedMapZones()
    if ItemPickerJava.doParse then
        ItemPickerJava.doParse = nil
        ItemPickerJava.Parse()
    end
end

function Magazine.OnInitGlobalModData()
    if not SandboxVars.OrbitFishingMod.FarmCraftingMagazine then return end
    Magazine.recipeNeedLearn()
    Magazine.addDistributions()
    Events.OnLoadedMapZones.Add(Magazine.OnLoadedMapZones)
end

Events.OnInitGlobalModData.Add(Magazine.OnInitGlobalModData)

return Magazine