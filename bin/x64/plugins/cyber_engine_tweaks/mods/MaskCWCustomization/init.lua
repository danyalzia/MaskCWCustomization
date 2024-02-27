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

function SetFlatAndUpdate(name, value)
  TweakDB:SetFlat(name, value)
  TweakDB:Update(name)
end

function SetTweak()
  if TweakDB:GetRecord("Items.MaskCW_inline00") == nil then
    TweakDB:CloneRecord("Items.MaskCW_inline00", "Items.MaskCWPlus_inline0")
    local cwStatModifiers = TweakDB:GetFlat('Items.MaskCW.statModifiers')
    table.insert(cwStatModifiers, "Items.MaskCW_inline00")
    SetFlatAndUpdate('Items.MaskCW.statModifiers', cwStatModifiers)
  end

  -- base\gameplay\static_data\database\characters\player\player_base_stats.tweak
  -- {
  --   statType = "BaseStats.CWMaskRechargeDuration";
  --   modifierType = "Additive";
  --   value = 1500;
  -- } : ConstantStatModifier

  SetFlatAndUpdate("Items.MaskCW_inline1.floatValues", { settings.cwCooldown })
  SetFlatAndUpdate("Items.MaskCWPlus_inline2.floatValues", { settings.cwPlusCooldown })
  SetFlatAndUpdate("Items.MaskCWPlusPlus_inline2.floatValues", { settings.cwPlusPlusCooldown })

  SetFlatAndUpdate("Items.MaskCW_inline00.value", -1500.000000 + settings.cwCooldown)
  SetFlatAndUpdate("Items.MaskCWPlus_inline0.value", -1500.000000 + settings.cwPlusCooldown)
  SetFlatAndUpdate("Items.MaskCWPlusPlus_inline0.value", -1500.000000 + settings.cwPlusPlusCooldown)

  local instigatorPrereqs = TweakDB:GetFlat('CyberwareAction.UseCWMask.instigatorPrereqs')

  if settings.allowInCombat then
    -- Remove CombatPSMPrereq
    table.remove(instigatorPrereqs)
    table.remove(instigatorPrereqs)
    table.insert(instigatorPrereqs, "CyberwareAction.UseCWMask_inline1")
    SetFlatAndUpdate('CyberwareAction.UseCWMask.instigatorPrereqs', instigatorPrereqs)
  else
    table.remove(instigatorPrereqs)
    table.remove(instigatorPrereqs)
    table.insert(instigatorPrereqs, "CyberwareAction.UseCWMask_inline0")
    table.insert(instigatorPrereqs, "CyberwareAction.UseCWMask_inline1")
    SetFlatAndUpdate('CyberwareAction.UseCWMask.instigatorPrereqs', instigatorPrereqs)
  end
end

function InitializeUI()
  nativeSettings = GetMod("nativeSettings")

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
