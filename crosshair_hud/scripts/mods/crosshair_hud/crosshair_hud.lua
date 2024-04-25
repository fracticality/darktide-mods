local mod = get_mod("crosshair_hud")

mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/utils")

local Archetypes = require("scripts/settings/archetype/archetypes")

local _loaded_archetypes = {}
local _loading_archetypes = {}

local function _cb_load_icons_for_profile(archetype_name)
  _loaded_archetypes[archetype_name] = _loading_archetypes[archetype_name]
  _loading_archetypes[archetype_name] = nil
end

local function load_talent_icon_packages()
  _loaded_archetypes = _loaded_archetypes or {}
  _loading_archetypes = _loading_archetypes or {}

  local talents_service = Managers.data_service.talents

  for archetype_name, archetype_data in pairs(Archetypes) do
    local on_package_loaded = callback(_cb_load_icons_for_profile, archetype_name)
    local profile = { archetype = archetype_data }
    local load_id = talents_service:load_icons_for_profile(profile, "CrosshairHUD", on_package_loaded, true)
    _loading_archetypes[archetype_name] = load_id
  end
end

local _packages_loaded = false
function mod.on_game_state_changed(status, state)
  if state == "StateMainMenu" and status == "enter" then
    if not _packages_loaded then
      Managers.package:load("packages/ui/views/talent_builder_view/talent_builder_view", "CrosshairHUD")
      load_talent_icon_packages()
      _packages_loaded = true
    end
  end
end

function mod.archetype_is_loading(archetype_name)
  return not not _loading_archetypes[archetype_name]
end

function mod.archetype_is_loaded(archetype_name)
  return not not _loaded_archetypes[archetype_name]
end

function mod.archetype_load_id(archetype_name)
  return _loaded_archetypes[archetype_name] or _loading_archetypes[archetype_name]
end

local _setting_id_by_template_name = {
  coherency_toughness_regen = "hide_coherency_buff_bar",
  sprint_with_stamina_buff = "hide_sprint_buff",
  psyker_souls = "hide_warp_charges_buff",
  psyker_souls_increased_max_stacks = "hide_warp_charges_buff",
  psyker_smite_on_hit = "hide_kinetic_flayer_buff"
}

local function hide_icon_hook(templates)
  templates = templates.__data or templates
  for template_name, template in pairs(templates) do
    local setting_id = _setting_id_by_template_name[template_name]
    if setting_id then
      template.hide_icon_in_hud = mod:get(setting_id)
    end
  end
end

mod:hook_require("scripts/settings/buff/player_buff_templates", hide_icon_hook)
mod:hook_require("scripts/settings/buff/archetype_buff_templates/psyker_buff_templates", hide_icon_hook)

local class_name = "HudElementCrosshairHud"
local filename = "crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/hud_element_crosshair_hud"

mod:register_hud_element({
  class_name = class_name,
  filename = filename,
  use_hud_scale = true,
  visibility_groups = {
    "alive"
  }
})

function mod.on_setting_changed(setting_id)
  local ui_hud = Managers.ui:get_hud()
  local crosshair_hud_element = ui_hud and ui_hud:element(class_name)

  if crosshair_hud_element then
    crosshair_hud_element.needs_refresh = true
  end
end
