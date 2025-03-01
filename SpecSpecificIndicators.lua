-- Version 0.0.1 by Aathma @aathmawow

-- local I = Cell.iFuncs
local F = Cell.funcs
local debug = false

-- Table uses Class IDs as defined https://warcraft.wiki.gg/wiki/ClassId
-- and Specialization IDs as defined by https://warcraft.wiki.gg/wiki/SpecializationID
local classSpecIndicators = {
    [1] = {                                                    -- Warrior
        [71] = {},                                             -- Arms
        [72] = {},                                             -- Fury
        [73] = {},                                             -- Protection
    },
    [2] = {                                                    -- Paladin
        [65] = {"HPal", "Beacons", "Blessings", "Holy Bulwark", "Sacred Weapon"},                                             -- Holy
        [66] = {"Blessings", "Holy Bulwark", "Sacred Weapon"},                                             -- Protection
        [70] = {"Blessings"},                                             -- Retribution
    },
    [3] = {                                                    -- Hunter
        [253] = {},                                            -- Beast Mastery
        [254] = {},                                            -- Marksmanship
        [255] = {},                                            -- Survival
    },
    [4] = {                                                    -- Rogue
        [259] = {},                                            -- Assassination
        [260] = {},                                            -- Outlaw
        [261] = {},                                            -- Subtlety
    },
    [5] = {                                                    -- Priest
        [256] = { "Discipline" },                              -- Discipline
        [257] = { "HPriest" },                                 -- Holy
        [258] = {},                                            -- Shadow
    },
    [6] = {                                                    -- Death Knight
        [250] = {},                                            -- Blood
        [251] = {},                                            -- Frost
        [252] = {},                                            -- Unholy
    },
    [7] = {                                                    -- Shaman
        [262] = {},                                            -- Elemental
        [263] = {},                                            -- Enhancement
        [264] = { "RSham", "Earthliving", "Ancestral Vigor" }, -- Restoration
    },
    [8] = {                                                    -- Mage
        [62] = {},                                             -- Arcane
        [63] = {},                                             -- Fire
        [64] = {},                                             -- Frost
    },
    [9] = {                                                    -- Warlock
        [265] = {},                                            -- Affliction
        [266] = {},                                            -- Demonology
        [267] = {},                                            -- Destruction
    },
    [10] = {                                                   -- Monk
        [268] = {},                                            -- Brewmaster
        [269] = {},                                            -- Windwalker
        [270] = { "Mistweaver" },                              -- Mistweaver
    },
    [11] = {                                                   --Druid
        [102] = {},                                            -- Balance
        [103] = {},                                            -- Feral
        [104] = {},                                            -- Guardian
        [105] = { "RDruid" },                                  -- Restoration
    },
    [12] = {                                                   -- Demon Hunter
        [577] = {},                                            -- Havoc
        [581] = {},                                            -- Vengeance
    },
    [13] = {                                                   -- Evoker
        [1467] = {},                                           -- Devastation
        [1468] = { "Preservation", "Reversions" },             -- Preservation
        [1473] = { "Augmentation", "Blistering Scales" },      -- Augmentation
    },
}

local function setCustomIndicatorInLayout(t, indicatorName, state)
    for i = Cell.defaults.builtIns + 1, #t do
        if t[i]["indicatorName"] == indicatorName then
            t[i]["enabled"] = state
            F:ReloadIndicatorOptions(i) -- Resets the highlight status of enabled or disabled indicators
        end
    end
end

local function setIndicatorStatus(customIndicators, enable, disable)
    for indicatorName, indicatorTable in pairs(customIndicators) do
        -- Enable first, which allows for duplicate indicators shared between specs (e.g., Blessings for Paladins)
        if enable[indicatorTable["name"]] ~= nil then
            -- Enable the indicator and add it to the set of enabledIndicators
            Cell.Fire("UpdateIndicators", Cell.vars.currentLayout, indicatorName, "enabled", true)
            setCustomIndicatorInLayout(Cell.vars.currentLayoutTable.indicators, indicatorName, true)
        elseif disable[indicatorTable["name"]] ~= nil then
            -- Disable the indicator and remove it from the set of enabledIndicators
            Cell.Fire("UpdateIndicators", Cell.vars.currentLayout, indicatorName, "enabled", false)
            setCustomIndicatorInLayout(Cell.vars.currentLayoutTable.indicators, indicatorName, false)
        end
    end
end

-- Callback function to tie in with load, change spec, etc.
local function SetSpecSpecificIndicators()
    -- local playerClassId = UnitClassBase("player")
    local playerSpecIndex = GetSpecialization()
    local playerSpecId, playerSpecName = GetSpecializationInfo(playerSpecIndex)

    if debug then print(string.format("Cell - SpecSpecificIndicators: Loading indicators for %s (%s)\n", playerSpecName, playerSpecId)) end

    -- Fetch the list of spec indicators to enable or disable
    local disable = {}
    local enable = {}
    for _, specs in pairs(classSpecIndicators) do
        for s, indicators in pairs(specs) do
            -- Disable everything in specs that we are not currently playing
            if playerSpecId ~= s then
                for _, indicator in pairs(indicators) do
                    disable[indicator] = true
                end
            else -- Enable everything in the spec that we are
                for _, indicator in pairs(indicators) do
                    enable[indicator] = true
                end
            end
        end
    end

    setIndicatorStatus(Cell.snippetVars.customIndicators["buff"], enable, disable)
    setIndicatorStatus(Cell.snippetVars.customIndicators["debuff"], enable, disable)
end

local timer
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if timer then timer:Cancel() end
    timer = C_Timer.NewTimer(1, SetSpecSpecificIndicators)
end)