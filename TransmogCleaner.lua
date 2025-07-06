local f = CreateFrame("Frame")
local playerLevel = UnitLevel("player")

local function IsItemSellable(itemLink)
    if not itemLink then return false end
    local _, _, quality, _, reqLevel, _, _, _, equipSlot, _, vendorPrice = GetItemInfo(itemLink)

    -- List of valid equipment slots (all INVTYPE_* values that correspond to wearable gear)
    local validEquipSlots = {
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
        INVTYPE_TABARD = true
    }

    local isEquipable = equipSlot and validEquipSlots[equipSlot]

    return (quality == 4 or quality == 3) and reqLevel and reqLevel < (playerLevel - 9) and vendorPrice and vendorPrice > 0 and isEquipable
end

local function SellItems()
    local soldAny = false
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink and IsItemSellable(itemLink) then
                C_Container.UseContainerItem(bag, slot)
                print("Sold: " .. itemLink)
                soldAny = true
            end
        end
    end
    if not soldAny then
        print("|cff00ff00[SellLowLevelEpics]|r No qualifying epic or rare items to sell.")
    end
end

local function CreateSellButton()
    if MerchantFrame.SellEpicsButton then return end

    local btn = CreateFrame("Button", "SellLowLevelEpicsButton", MerchantFrame, "UIPanelButtonTemplate")
    btn:SetSize(160, 24)
    btn:SetText("Sell Low-Level Epics")
    btn:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 0, 0)

    btn:SetScript("OnClick", function()
        SellItems()
    end)

    MerchantFrame.SellEpicsButton = btn
end

f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", function()
    CreateSellButton()
end)
