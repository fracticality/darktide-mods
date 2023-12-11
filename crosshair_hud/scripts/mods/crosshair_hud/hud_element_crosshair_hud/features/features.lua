local mod = get_mod("crosshair_hud")

local _base_path = "crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/features/%s"

local _features = {}

local function _create_feature_entry(filename)
  local file_path = string.format(_base_path, filename)
  local feature = mod:io_dofile(file_path)
  if not feature then
    return
  end

  local feature_name = feature.name

  if not feature_name then
    local message = "Feature definition in file [\"%s\"] missing `name` property!"
    mod:error(message, file_path)
    mod:notify(message, file_path)

    return
  end

  if _features[feature_name] then
    local message = "Feature with name [%s] has already been defined."
    mod:error(message, feature_name)
    mod:notify(message, feature_name)

    return
  end

  _features[feature_name] = feature
end

_create_feature_entry("pocketable")
_create_feature_entry("ability")
_create_feature_entry("peril")
_create_feature_entry("reload")
_create_feature_entry("grenade")
_create_feature_entry("ammo")
_create_feature_entry("health")
_create_feature_entry("toughness")
_create_feature_entry("coherency")
_create_feature_entry("ally")
_create_feature_entry("warp_charge")
_create_feature_entry("kinetic_flayer")
_create_feature_entry("stimm")

return _features