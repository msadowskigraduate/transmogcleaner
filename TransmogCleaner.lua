-- SavedVariables
local defaultSettings = {
    minItemLevel = 0,
    maxItemLevel = 380,
    maxReqLevel = 79,
    quality = {
        [0] = false, -- Poor
        [1] = false, -- Common
        [2] = false, -- Uncommon
        [3] = true,  -- Rare (default)
        [4] = false, -- Epic
        [5] = false, -- Legendary
    },
    nameFilter = "",
    itemTypes = {
        Equip = true,
        Consumable = false,
        Container = false,
        Gem = false,
        Reagent = false,
        Projectile = false,
        TradeGoods = false,
        Generic = false,
        Recipe = false,
        Misc = false,
        Glyph = false,
        ItemEnhancement = false,
    },
    skipboes = true, -- Skip Bind on Equip items
    skipList = {},
    skipExpansions = {
        [254] = false, -- Classic
        [1] = false, -- The Burning Crusade
        [2] = true, -- Wrath of the Lich King
        [3] = true, -- Cataclysm
        [4] = true, -- Mists of Pandaria
        [5] = true, -- Warlords of Draenor
        [6] = true, -- Legion
        [7] = true, -- Battle for Azeroth
        [8] = true, -- Shadowlands
        [9] = true, -- Dragonflight
        [10] = true, -- New Expansion
    }
}

-- Merge default values into SavedVariables
local function MergeDefaults(tbl, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            tbl[k] = tbl[k] or {}
            MergeDefaults(tbl[k], v)
        else
            if tbl[k] == nil then
                tbl[k] = v
            end
        end
    end
end

TransmogCleanerSettings = TransmogCleanerSettings or {}
MergeDefaults(TransmogCleanerSettings, defaultSettings)
------------------------------------------------------------
-- Draggable Filter Frame with Filter Controls
------------------------------------------------------------
local filterFrame = CreateFrame("Frame", "SellFilterFrame", UIParent, "BasicFrameTemplateWithInset")
filterFrame:SetSize(640, 550)
filterFrame:SetPoint("CENTER")
filterFrame:SetMovable(true)
filterFrame:EnableMouse(true)
filterFrame:RegisterForDrag("LeftButton")
filterFrame:SetScript("OnDragStart", filterFrame.StartMoving)
filterFrame:SetScript("OnDragStop", filterFrame.StopMovingOrSizing)
filterFrame:Hide()

filterFrame.title = filterFrame:CreateFontString(nil, "OVERLAY")
filterFrame.title:SetFontObject("GameFontHighlight")
filterFrame.title:SetPoint("CENTER", filterFrame.TitleBg, "CENTER")
filterFrame.title:SetText("Nyly's Sell Low-Level Epics")

-- Min Item Level
local minLevelLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
minLevelLabel:SetPoint("TOPLEFT", 12, -40)
minLevelLabel:SetText("Min Item Level:")

local minLevelInput = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
minLevelInput:SetSize(40, 20)
minLevelInput:SetPoint("LEFT", minLevelLabel, "RIGHT", 8, 0)
minLevelInput:SetAutoFocus(false)
minLevelInput:SetNumeric(true)
minLevelInput:SetText(tostring(TransmogCleanerSettings.minItemLevel))

minLevelInput:SetScript("OnEnterPressed", function(self)
    TransmogCleanerSettings.minItemLevel = tonumber(self:GetText()) or 0
    self:ClearFocus()
end)

minLevelInput:SetScript("OnEditFocusLost", function(self)
    TransmogCleanerSettings.minItemLevel = tonumber(self:GetText()) or 0
end)

-- Max Item Level
local maxLevelLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
maxLevelLabel:SetPoint("TOPLEFT", minLevelLabel, 0, -20)
maxLevelLabel:SetText("Max Item Level:")
local maxLevelInput = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
maxLevelInput:SetSize(40, 20)
maxLevelInput:SetPoint("LEFT", maxLevelLabel, "RIGHT", 8, 0)
maxLevelInput:SetAutoFocus(false)
maxLevelInput:SetNumeric(true)
maxLevelInput:SetText(tostring(TransmogCleanerSettings.maxItemLevel))
maxLevelInput:SetScript("OnEnterPressed", function(self)
    TransmogCleanerSettings.maxItemLevel = tonumber(self:GetText()) or 380
    self:ClearFocus()
end)

maxLevelInput:SetScript("OnEditFocusLost", function(self)
    TransmogCleanerSettings.maxItemLevel = tonumber(self:GetText()) or 380
end)

-- Max Required Level
local maxReqLevelLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
maxReqLevelLabel:SetPoint("TOPLEFT", maxLevelLabel, 0, -20)
maxReqLevelLabel:SetText("Max Required Level:") -- Max Required Level
local maxReqLevelInput = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
maxReqLevelInput:SetSize(40, 20)

maxReqLevelInput:SetPoint("LEFT", maxReqLevelLabel, "RIGHT", 8, 0)
maxReqLevelInput:SetAutoFocus(false)
maxReqLevelInput:SetNumeric(true)
maxReqLevelInput:SetText(tostring(TransmogCleanerSettings.maxReqLevel))
maxReqLevelInput:SetScript("OnEnterPressed", function(self)
    TransmogCleanerSettings.maxReqLevel = tonumber(self:GetText()) or 79
    self:ClearFocus()
end)

maxReqLevelInput:SetScript("OnEditFocusLost", function(self)
    TransmogCleanerSettings.maxReqLevel = tonumber(self:GetText()) or 79
end)

-- Quality Dropdown
local qualityLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
qualityLabel:SetPoint("TOPLEFT", maxReqLevelLabel, "BOTTOMLEFT", 0, -20)
qualityLabel:SetText("Item Quality:")

local qualityOptions = {
    { value = 0, label = "Poor" },
    { value = 1, label = "Common" },
    { value = 2, label = "Uncommon" },
    { value = 3, label = "Rare" },
    { value = 4, label = "Epic" },
    { value = 5, label = "Legendary" },
}

local previousLabel
for i, qualityInfo in ipairs(qualityOptions) do
    local cb = CreateFrame("CheckButton", nil, filterFrame, "ChatConfigCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", i == 1 and qualityLabel or previousLabel, "BOTTOMLEFT", 0, -4)
    cb.Text:SetText(qualityInfo.label)

    cb:SetScript("OnClick", function(self)
        TransmogCleanerSettings.quality[qualityInfo.value] = self:GetChecked()
    end)

    cb:SetScript("OnShow", function(self)
        self:SetChecked(TransmogCleanerSettings.quality[qualityInfo.value])
    end)

    cb:Show()
    previousLabel = cb
end

-- Name Filter
local nameLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nameLabel:SetPoint("TOPLEFT", 220, -40)
nameLabel:SetText("Skip Name Contains:")

local nameInput = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
nameInput:SetSize(100, 20)
nameInput:SetPoint("LEFT", nameLabel, "RIGHT", 8, 0)
nameInput:SetAutoFocus(false)
nameInput:SetScript("OnEnterPressed", function(self)
    TransmogCleanerSettings.nameFilter = self:GetText()
    self:ClearFocus()
end)
nameInput:SetScript("OnEditFocusLost", function(self)
    TransmogCleanerSettings.nameFilter = self:GetText()
end)

-- Item Type Filters
local typeLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
typeLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -20)
typeLabel:SetText("Item Types:")

local itemTypes = {
    { key = "Consumable", label = "Consumables" },
    { key = "Container", label = "Containers" },
    { key = "Gem", label = "Gems" },
    { key = "Glyph", label = "Glyphs" },
    { key = "ItemEnhancement", label = "Item Enhancements" },
    { key = "Miscellaneous", label = "Miscellaneous" },
    { key = "Projectile", label = "Projectiles" },
    { key = "Quiver", label = "Quivers" },
    { key = "Reagent", label = "Reagents" },
    { key = "Recipe", label = "Recipes" },
    { key = "TradeGoods", label = "Trade Goods" },
    { key = "BattlePet", label = "Battle Pets" },
}


local previous
for i, typeInfo in ipairs(itemTypes) do
    local cb = CreateFrame("CheckButton", nil, filterFrame, "ChatConfigCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", i == 1 and typeLabel or previous, "BOTTOMLEFT", 0, -4)
    cb.Text:SetText(typeInfo.label)

    cb:SetScript("OnClick", function(self)
        TransmogCleanerSettings.itemTypes[typeInfo.key] = self:GetChecked()
    end)

    cb:SetScript("OnShow", function(self)
        self:SetChecked(TransmogCleanerSettings.itemTypes[typeInfo.key])
    end)

    cb:Show()
    previous = cb
end

-- Skip Expansions
local skipExpansionsLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
skipExpansionsLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 260, 0)
skipExpansionsLabel:SetText("Skip Expansions:")
local skipExpansions = {
    { id = 254, label = "Classic" },
    { id = 1, label = "The Burning Crusade" },
    { id = 2, label = "Wrath of the Lich King" },
    { id = 3, label = "Cataclysm" },
    { id = 4, label = "Mists of Pandaria" },
    { id = 5, label = "Warlords of Draenor" },
    { id = 6, label = "Legion" },
    { id = 7, label = "Battle for Azeroth" },
    { id = 8, label = "Shadowlands" },
    { id = 9, label = "Dragonflight" },
    { id = 10, label = "The War Within" }, 
}

local previousExpansion
for i, expansion in ipairs(skipExpansions) do
    local cb = CreateFrame("CheckButton", nil, filterFrame, "ChatConfigCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", i == 1 and skipExpansionsLabel or previousExpansion, "BOTTOMLEFT", 0, -4)
    cb.Text:SetText(expansion.label)

    cb:SetScript("OnClick", function(self)
        TransmogCleanerSettings.skipExpansions[expansion.id] = self:GetChecked()
    end)

    cb:SetScript("OnShow", function(self)
       self:SetChecked(TransmogCleanerSettings.skipExpansions[expansion.id])
    end)

    cb:Show()
    previousExpansion = cb
end

local function RenderSkipListIcons(parent)
    if parent.skipIcons then
        for _, icon in ipairs(parent.skipIcons) do
            icon:Hide()
        end
    else
        parent.skipIcons = {}
    end

    local padding, size = 6, 32
    local items = {}
    for itemID in pairs(TransmogCleanerSettings.skipList) do
        table.insert(items, itemID)
    end

    local cols = 6
    for i, itemID in ipairs(items) do
        local icon = parent.skipIcons[i]
        if not icon then
            icon = CreateFrame("Button", nil, parent)
            icon:SetSize(size, size)

            icon.icon = icon:CreateTexture(nil, "ARTWORK")
            icon.icon:SetAllPoints()

            parent.skipIcons[i] = icon
        end


        local row = math.floor((i - 1) / cols)
        local col = (i - 1) % cols
        icon:SetPoint("TOPLEFT", parent.skipGridHeader, "BOTTOMLEFT", col * (size + padding), -row * (size + padding))

        local id, type, subtype, loc, tex, clsid, sclsid = GetItemInfoInstant(itemID)
        --print(tex, itemID)
        icon.icon:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")

        icon:SetScript("OnEnter", function()
            GameTooltip:SetOwner(icon, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. itemID)
            GameTooltip:Show()
        end)
        icon:SetScript("OnLeave", function() GameTooltip:Hide() end)

        icon:SetScript("OnClick", function()
            TransmogCleanerSettings.skipList[itemID] = nil
            RenderSkipListIcons(parent)
        end)

        icon:Show()
    end
end


-- BOEs Skip Checkbox
local skipBOEsCheck = CreateFrame("CheckButton", nil, filterFrame, "ChatConfigCheckButtonTemplate")
skipBOEsCheck:SetPoint("TOPLEFT", previousLabel, "BOTTOMLEFT", 0, -20)
skipBOEsCheck.Text:SetText("Skip Bind on Equip Items")
skipBOEsCheck:SetScript("OnClick", function(self)
    print("Skip BOEs:", self:GetChecked())
    TransmogCleanerSettings.skipboes = self:GetChecked()
end)

-- Skip List Item Icon Grid
local skipGridHeader = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
skipGridHeader:SetPoint("TOPLEFT", skipBOEsCheck, "BOTTOMLEFT", 0, -20)
skipGridHeader:SetText("Skipped Items: ")
filterFrame.skipGridHeader = skipGridHeader

local tooltip = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tooltip:SetPoint("BOTTOMLEFT", filterFrame, "BOTTOMLEFT", 20, 80)
tooltip:SetText("Drag items here to skip them.")

-- Drag-and-drop to skip list
filterFrame:SetScript("OnReceiveDrag", function(self)
    local type, link = GetCursorInfo()
    if type == "item" and link then
        local id = select(1, GetItemInfoInstant(link))
        if id and not TransmogCleanerSettings.skipList[id] then
            TransmogCleanerSettings.skipList[id] = true
            RenderSkipListIcons(filterFrame)
        end
        ClearCursor()
    end
end)

filterFrame:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        local type, link = GetCursorInfo()
        if type == "item" and link then
            local id = select(1, GetItemInfoInstant(link))
            if id and not TransmogCleanerSettings.skipList[id] then
                TransmogCleanerSettings.skipList[id] = true
                RenderSkipListIcons(filterFrame)
            end
            ClearCursor()
        end
    end
end)

-- Handle item drops (drag-and-drop)
local function AddItemLinkToSkipList(itemLink)
    if not itemLink then return end
    local itemID = tonumber(itemLink:match("item:(%d+):"))
    if itemID and not TransmogCleanerSettings.skipList[itemID] then
        TransmogCleanerSettings.skipList[itemID] = true
        RenderSkipListIcons(filterFrame)
    end
end


-- Update inputs when frame shows
filterFrame:SetScript("OnShow", function()
    minLevelInput:SetText(TransmogCleanerSettings.minItemLevel)
    nameInput:SetText(TransmogCleanerSettings.nameFilter)
    maxLevelInput:SetText(TransmogCleanerSettings.maxItemLevel)
    maxReqLevelInput:SetText(TransmogCleanerSettings.maxReqLevel)
    for i, qualityInfo in ipairs(qualityOptions) do
        local cb = filterFrame["QualityCheckButton" .. i]
        if cb then
            cb:SetChecked(TransmogCleanerSettings.quality[qualityInfo.value])
        end
    end
    for _, typeInfo in ipairs(itemTypes) do
        local cb = filterFrame[typeInfo.key .. "CheckButton"]
        if cb then
            cb:SetChecked(TransmogCleanerSettings.itemTypes[typeInfo.key])
        end
    end
    RenderSkipListIcons(filterFrame)
    -- Clear any existing cursor item
    ClearCursor()   
end)
--
-- Set of valid equip locations
local validEquipLocs = {
    INVTYPE_HEAD = true,
    INVTYPE_NECK = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_BODY = true,
    INVTYPE_CHEST = true,
    INVTYPE_WAIST = true,
    INVTYPE_LEGS = true,
    INVTYPE_FEET = true,
    INVTYPE_WRIST = true,
    INVTYPE_HAND = true,
    INVTYPE_FINGER = true,
    INVTYPE_TRINKET = true,
    INVTYPE_CLOAK = true,
    INVTYPE_WEAPON = true,
    INVTYPE_SHIELD = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_HOLDABLE = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_THROWN = true,
    INVTYPE_RELIC = true,
    INVTYPE_TABARD = true,
    INVTYPE_ROBE = true
}

------------------------------------------------------------
-- Sell Logic
------------------------------------------------------------
local function IsItemSellable(itemLink)
    if not itemLink then return false end

    local itemName, link, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
        itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID,
        bindType, expansionID, setID, isCraftingReagent = GetItemInfo(itemLink)

    if not itemQuality or not itemLevel then
        -- Item not fully loaded
        return false
    end

    local itemID = select(1, GetItemInfoInstant(itemLink))
    if not itemID then return false end

    local qualityPass       = TransmogCleanerSettings.quality[itemQuality] == true
    local levelPass         = itemLevel >= TransmogCleanerSettings.minItemLevel and itemLevel <= TransmogCleanerSettings.maxItemLevel
    local requiredLevelPass = (not itemMinLevel or itemMinLevel <= TransmogCleanerSettings.maxReqLevel)
    local namePass          = true
    local skipListPass      = TransmogCleanerSettings.skipList[itemID] ~= true
    local expansionPass     = not TransmogCleanerSettings.skipExpansions[expansionID]
    
    -- Check if item is Bind on Equip
    local boePass = bindType ~= 2 or not TransmogCleanerSettings.skipboes

    -- Name filter (if defined)
    local nameFilter = TransmogCleanerSettings.nameFilter and TransmogCleanerSettings.nameFilter:lower()
    if nameFilter ~= "" and itemName then
        namePass = itemName:lower():find(nameFilter, 1, true) == nil
    end

    -- Item type filters
    local typePass = false
    if validEquipLocs[itemEquipLoc] and TransmogCleanerSettings.itemTypes.Equip then
        typePass = true
    else
    -- Table of itemType keys mapped to settings keys
    local itemTypeMap = {
        ["Consumable"]      = "Consumable",
        ["Container"]       = "Container",
        ["Weapon"]          = "Weapon",
        ["Gem"]             = "Gem",
        ["Armor"]           = "Armor",
        ["Reagent"]         = "Reagent",
        ["Projectile"]      = "Projectile",
        ["Trade Goods"]     = "TradeGoods",
        ["Generic"]         = "Generic",
        ["Recipe"]          = "Recipe",
        ["Quiver"]          = "Quiver",
        ["Quest"]           = "Quest",
        ["Key"]             = "Key",
        ["Permanent"]       = "Permanent",
        ["Miscellaneous"]   = "Misc",
        ["Glyph"]           = "Glyph",
        ["Battle Pet"]      = "BattlePet",
        ["WoW Token"]       = "WoWToken",
        ["Item Enhancement"] = "ItemEnhancement",
    }

    local settingsKey = itemTypeMap[itemType]
    if settingsKey and TransmogCleanerSettings.itemTypes[settingsKey] then
        typePass = true
    end
end
   -- if not qualityPass then print(itemLink, "Failed quality") end
   -- if not levelPass then print(itemLink, "Failed level") end
   -- if not requiredLevelPass then print(itemLink, "Failed required level") end
   -- if not namePass then print(itemLink, "Failed name filter") end
   -- if not skipListPass then print(itemLink, "In skip list") end
   -- if not expansionPass then print(itemLink, "Skipped due to expansion") end
   if not typePass then print(itemLink, "Failed type filter", itemEquipLoc) end
   -- if not boePass then print(itemLink, "Failed Bind on Equip filter") end

    -- Final AND evaluation
    return qualityPass
        and levelPass
        and requiredLevelPass
        and namePass
        and skipListPass
        and expansionPass
        and typePass
        and boePass
end


local selling = false
local BATCH_SIZE = 5
local DELAY = 0.2

local function SellBatch()
    local itemsToSell = {}

    -- Build item list once (prevents infinite loop)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink and IsItemSellable(itemLink) then
                table.insert(itemsToSell, {bag = bag, slot = slot, link = itemLink})
            end
        end
    end

    local index = 1
    local function SellNextBatch()
        local sold = 0
        while sold < BATCH_SIZE and index <= #itemsToSell do
            local entry = itemsToSell[index]
            if C_Container.GetContainerItemLink(entry.bag, entry.slot) == entry.link then
                C_Container.UseContainerItem(entry.bag, entry.slot)
                print("Sold: " .. entry.link)
                sold = sold + 1
            end
            index = index + 1
        end

        if index <= #itemsToSell then
            C_Timer.After(DELAY, SellNextBatch)
        else
            selling = false
            print("|cff00ff00[SellLowLevelEpics]|r Done selling.")
        end
    end

    if #itemsToSell > 0 then
        selling = true
        SellNextBatch()
    else
        print("|cff00ff00[SellLowLevelEpics]|r No matching items to sell.")
    end
end

function SellItems()
    if not selling then
        SellBatch()
    end
end

------------------------------------------------------------
-- Create a Button on the Merchant Frame
------------------------------------------------------------
local function CreateSellButton()
    if MerchantFrame.SellEpicsButton then return end

    local btn = CreateFrame("Button", "SellLowLevelEpicsButton", MerchantFrame, "UIPanelButtonTemplate")
    btn:SetSize(160, 24)
    btn:SetText("Sell Low-Level Epics")
    btn:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 1, 2)

    btn:SetScript("OnClick", function()
        SellItems()
    end)

    MerchantFrame.SellEpicsButton = btn
end

------------------------------------------------------------
-- Event Handler
------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("MERCHANT_CLOSED")

f:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        CreateSellButton()
        filterFrame:Show()
    elseif event == "MERCHANT_CLOSED" then
        filterFrame:Hide()
    end
end)

-- Parse Item Link
local function ParseItemLink(itemLink)
    if not itemLink then return end
    local itemID = select(2, GetItemInfo(itemLink))
    if not itemID then return end
    local itemName = GetItemInfo(itemID)
    if not itemName then return end
    return itemID, itemName
end
