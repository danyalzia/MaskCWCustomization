local nativeSettings = nil

local configFileName = "config.json"
local settings = {
  cwCooldown = 25,
  cwPlusCooldown = 15,
  cwPlusPlusCooldown = 5,
  deactivatePreventionUptoFiveStars = false,
  allowInCombat = false,
}

function LoadSettings()
  local file = io.open(configFileName, "r")
  if file ~= nil then
    local configStr = file:read("*a")
    settings = json.decode(configStr)
    file:close()
  end
end

function SaveSettings()
  local file = io.open(configFileName, "w")
  if file ~= nil then
    local jconfig = json.encode(settings)
    file:write(jconfig)
    file:close()
  end
end

---@param recordNameArray any
---@param pos? integer
function ArrayRemove(recordNameArray, pos)
  local newArray = TweakDB:GetFlat(recordNameArray)
  table.remove(newArray, pos)
  TweakDB:SetFlat(recordNameArray, newArray)
end

---@param recordNameArray any
---@param element any
---@param pos? integer
function ArrayInsert(recordNameArray, element, pos)
  local newArray = TweakDB:GetFlat(recordNameArray)
  table.insert(newArray, pos, element)
  TweakDB:SetFlat(recordNameArray, newArray)
end

function CreateGameplayLogicPackageUIData(recordName, floatValues, iconPath, intValues, localizedDescription,
                                          localizedName, nameValues, stats)
  if TweakDB:GetRecord(recordName) == nil then
    TweakDB:CreateRecord(recordName, "gamedataGameplayLogicPackageUIData_Record")
    TweakDB:SetFlatNoUpdate(recordName .. ".floatValues", floatValues)
    TweakDB:SetFlatNoUpdate(recordName .. ".iconPath", iconPath)
    TweakDB:SetFlatNoUpdate(recordName .. ".intValues", intValues)
    TweakDB:SetFlatNoUpdate(recordName .. ".localizedDescription", localizedDescription)
    TweakDB:SetFlatNoUpdate(recordName .. ".localizedName", localizedName)
    TweakDB:SetFlatNoUpdate(recordName .. ".nameValues", nameValues)
    TweakDB:SetFlatNoUpdate(recordName .. ".stats", stats)
    TweakDB:Update(recordName)
    return true
  else
    TweakDB:SetFlat(recordName .. ".floatValues", floatValues)
    return false
  end
end

function CreateConstantStatModifier(recordName, modifierType, statType, value)
  if TweakDB:GetRecord(recordName) == nil then
    TweakDB:CreateRecord(recordName, "gamedataConstantStatModifier_Record")
    TweakDB:SetFlatNoUpdate(recordName .. ".modifierType", modifierType)
    TweakDB:SetFlatNoUpdate(recordName .. ".statType", statType)
    TweakDB:SetFlatNoUpdate(recordName .. ".value", value)
    TweakDB:Update(recordName)
    return true
  else
    TweakDB:SetFlat(recordName .. ".value", value)
    return false
  end
end

function CreateMaskCWGameplayLogicPackage(recordName, UIData)
  if TweakDB:GetRecord(recordName) == nil then
    TweakDB:CreateRecord(recordName, "gamedataGameplayLogicPackage_Record")
    TweakDB:SetFlatNoUpdate(recordName .. ".UIData", UIData)
    TweakDB:SetFlatNoUpdate(recordName .. ".animationWrapperOverrides", {})
    TweakDB:SetFlatNoUpdate(recordName .. ".effectors", {})
    TweakDB:SetFlatNoUpdate(recordName .. ".items", {})
    TweakDB:SetFlatNoUpdate(recordName .. ".prereq", nil)
    TweakDB:SetFlatNoUpdate(recordName .. ".stackable", false)
    TweakDB:SetFlatNoUpdate(recordName .. ".statPools", {})
    TweakDB:SetFlatNoUpdate(recordName .. ".stats", {})
    TweakDB:Update(recordName)
  else
    TweakDB:SetFlat(recordName .. ".UIData", UIData)
    TweakDB:SetFlat(recordName .. ".animationWrapperOverrides", {})
    TweakDB:SetFlat(recordName .. ".effectors", {})
    TweakDB:SetFlat(recordName .. ".items", {})
    TweakDB:SetFlat(recordName .. ".prereq", nil)
    TweakDB:SetFlat(recordName .. ".stackable", false)
    TweakDB:SetFlat(recordName .. ".statPools", {})
    TweakDB:SetFlat(recordName .. ".stats", {})
  end
end

function CreateCWMaskIPrereq(recordName)
  if TweakDB:GetRecord(recordName) == nil then
    TweakDB:CreateRecord(recordName, "gamedataIPrereq_Record")
    TweakDB:SetFlatNoUpdate(recordName .. ".stateName", "InCombat")
    TweakDB:SetFlatNoUpdate(recordName .. ".isInState", false)
    TweakDB:SetFlatNoUpdate(recordName .. ".prereqClassName", "CombatPSMPrereq")
    TweakDB:Update(recordName)
  else
    TweakDB:SetFlat(recordName .. ".stateName", "InCombat")
    TweakDB:SetFlat(recordName .. ".isInState", false)
    TweakDB:SetFlat(recordName .. ".prereqClassName", "CombatPSMPrereq")
  end
end

function SetTweak()
  -- base\gameplay\static_data\database\characters\player\player_base_stats.tweak
  -- {
  --   statType = "BaseStats.CWMaskRechargeDuration";
  --   modifierType = "Additive";
  --   value = 1500;
  -- } : ConstantStatModifier

  if CreateGameplayLogicPackageUIData("Items.MaskCWGameplayLogicPackageUIData", { settings.cwCooldown }, "cw_facemask", {}, "LocKey#93182", "", {}, {}) then
    CreateMaskCWGameplayLogicPackage("Items.MaskCWGameplayLogicPackage", "Items.MaskCWGameplayLogicPackageUIData")
    ArrayRemove("Items.MaskCW.OnEquip")
    ArrayInsert("Items.MaskCW.OnEquip", "Items.MaskCWGameplayLogicPackage")
  end

  if CreateGameplayLogicPackageUIData("Items.MaskCWPlusGameplayLogicPackageUIData", { settings.cwPlusCooldown }, "cw_facemask", {}, "LocKey#93182", "", {}, {}) then
    CreateMaskCWGameplayLogicPackage("Items.MaskCWPlusGameplayLogicPackage", "Items.MaskCWPlusGameplayLogicPackageUIData")
    ArrayRemove("Items.MaskCWPlus.OnEquip")
    ArrayInsert("Items.MaskCWPlus.OnEquip", "Items.MaskCWPlusGameplayLogicPackage")
  end

  if CreateGameplayLogicPackageUIData("Items.MaskCWPlusPlusGameplayLogicPackageUIData", { settings.cwPlusPlusCooldown }, "cw_facemask", {}, "LocKey#93182", "", {}, {}) then
    CreateMaskCWGameplayLogicPackage("Items.MaskCWPlusPlusGameplayLogicPackage",
      "Items.MaskCWPlusPlusGameplayLogicPackageUIData")
    ArrayRemove("Items.MaskCWPlusPlus.OnEquip")
    ArrayInsert("Items.MaskCWPlusPlus.OnEquip", "Items.MaskCWPlusPlusGameplayLogicPackage")
  end

  if CreateConstantStatModifier("Items.MaskCWCooldownConstantStatModifier", "Additive", "BaseStats.CWMaskRechargeDuration", -1500.000000 + settings.cwCooldown) then
    ArrayRemove("Items.MaskCW.statModifiers")
    ArrayInsert("Items.MaskCW.statModifiers", "Items.MaskCWCooldownConstantStatModifier")
  end

  if CreateConstantStatModifier("Items.MaskCWPlusCooldownConstantStatModifier", "Additive", "BaseStats.CWMaskRechargeDuration", -1500.000000 + settings.cwPlusCooldown) then
    ArrayRemove("Items.MaskCWPlus.statModifiers")
    ArrayInsert("Items.MaskCWPlus.statModifiers", "Items.MaskCWPlusCooldownConstantStatModifier")
  end

  if CreateConstantStatModifier("Items.MaskCWPlusPlusCooldownConstantStatModifier", "Additive", "BaseStats.CWMaskRechargeDuration", -1500.000000 + settings.cwPlusPlusCooldown) then
    ArrayRemove("Items.MaskCWPlusPlus.statModifiers")
    ArrayInsert("Items.MaskCWPlusPlus.statModifiers", "Items.MaskCWPlusPlusCooldownConstantStatModifier")
  end

  local instigatorPrereqs = TweakDB:GetFlat('CyberwareAction.UseCWMask.instigatorPrereqs')

  if settings.allowInCombat then
    if #instigatorPrereqs == 2 then
      ArrayRemove("CyberwareAction.UseCWMask.instigatorPrereqs", 1)
    end
  else
    if #instigatorPrereqs < 2 then
      CreateCWMaskIPrereq("CyberwareAction.UseCWMaskIPrereq")
      ArrayInsert("CyberwareAction.UseCWMask.instigatorPrereqs", "CyberwareAction.UseCWMaskIPrereq", 1)
    end
  end
end

function InitializeUI()
  nativeSettings = GetMod("nativeSettings")

  if nativeSettings == nil then return end

  if not nativeSettings.pathExists("/MaskCWCustomization") then
    nativeSettings.addTab(
      "/MaskCWCustomization",
      "Mask CW"
    )
  end

  -- This text is taken from Seijax's Weapon Handling Control
  -- https://www.nexusmods.com/cyberpunk2077/mods/11474
  nativeSettings.addSubcategory("/MaskCWCustomization/Disclaimer",
    "After changing the settings, you must reload the last save or checkpoint for the settings to be applied", 0)

  nativeSettings.addSubcategory("/MaskCWCustomization/Controls", "Behavioral Imprint-synced Faceplate Cyberware", 1)
  nativeSettings.addSubcategory("/MaskCWCustomization/Miscellaneous", "Miscellaneous", 2)

  -- Cooldown customization
  nativeSettings.addRangeInt(
    "/MaskCWCustomization/Controls",
    "Tier 5 Cooldown",
    "Changes the Cooldown of Tier 5 Cyberware",
    0,
    1500,
    1,
    settings.cwCooldown,
    25,
    function(value)
      settings.cwCooldown = value
      SetTweak()
      SaveSettings()
    end)

  nativeSettings.addRangeInt(
    "/MaskCWCustomization/Controls",
    "Tier 5+ Cooldown",
    "Changes the Cooldown of Tier 5+ Cyberware",
    0,
    600,
    1,
    settings.cwPlusCooldown,
    15,
    function(value)
      settings.cwPlusCooldown = value
      SetTweak()
      SaveSettings()
    end)

  nativeSettings.addRangeInt(
    "/MaskCWCustomization/Controls",
    "Tier 5++ Cooldown",
    "Changes the Cooldown of Tier 5++ Cyberware",
    0,
    300,
    1,
    settings.cwPlusPlusCooldown,
    5,
    function(value)
      settings.cwPlusPlusCooldown = value
      SetTweak()
      SaveSettings()
    end)

  -- Miscellaneous customization
  nativeSettings.addSwitch("/MaskCWCustomization/Miscellaneous", "Deactivate Prevention Up To Five Stars",
    "Disable the police even when there are five stars", settings.allowInCombat, false, function(state)
      settings.deactivatePreventionUptoFiveStars = state
      SetTweak()
      SaveSettings()
    end)

  nativeSettings.addSwitch("/MaskCWCustomization/Miscellaneous", "Allow In Combat",
    "Allow the use of Cyberware during the combat", settings.allowInCombat, false, function(state)
      settings.allowInCombat = state
      SetTweak()
      SaveSettings()
    end)
end

registerForEvent("onInit", function()
  LoadSettings()
  InitializeUI()

  Override('MaskCWCustomization.MaskCWCustomization', 'DeactivatePreventionUptoFiveStars;', function()
    return settings.deactivatePreventionUptoFiveStars
  end)

  Override('MaskCWCustomization.MaskCWCustomization', 'AllowInCombat;', function()
    return settings.allowInCombat
  end)

  SetTweak()
end)
