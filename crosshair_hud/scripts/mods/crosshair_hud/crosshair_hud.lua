local mod = get_mod("crosshair_hud")

local ArchetypeTalents = mod:original_require("scripts/settings/ability/archetype_talents/archetype_talents")
local UIViewHandler = mod:original_require("scripts/managers/ui/ui_view_handler")
local TextUtilities = mod:original_require("scripts/utilities/ui/text")
local ReloadStates = mod:original_require("scripts/extension_systems/weapon/utilities/reload_states")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local class_name = "HudElementCrosshairHud"
local filename = "crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/hud_element_crosshair_hud"

local function ui_hud_init_hook(func, self, elements, visibility_groups, params)
  if not table.find_by_key(elements, "class_name", class_name) then
    table.insert(elements, {
      class_name = class_name,
      filename = filename,
      use_hud_scale = true,
      visibility_groups = {
        "alive"
      }
    })
  end

  return func(self, elements, visibility_groups, params)
end

mod:add_require_path(filename)
mod:hook("UIHud", "init", ui_hud_init_hook)

local function recreate_hud()
  local ui_manager = Managers.ui
  if ui_manager then
    local hud = ui_manager._hud
    if hud then
      local player = Managers.player:local_player(1)
      local peer_id = player:peer_id()
      local local_player_id = player:local_player_id()
      local elements = hud._element_definitions
      local visibility_groups = hud._visibility_groups

      hud:destroy()
      ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
    end
  end
end

local _loaded_specializations = {}
local _loading_specializations = {}
local function load_talent_icon_packages()
  _loaded_specializations = _loaded_specializations or {}
  _loading_specializations = _loading_specializations or {}

  local talents_service = Managers.data_service.talents

  for _, archetype_talents in pairs(ArchetypeTalents) do
    for specialization_name, _ in pairs(archetype_talents) do
      if specialization_name ~= "none" then
        local on_package_loaded = callback(mod, "_cb_load_icons_for_profile", mod, specialization_name)
        local load_id = talents_service:load_icons_for_profile({ specialization = specialization_name }, "CrosshairHUD", on_package_loaded, true)
        _loading_specializations[specialization_name] = load_id
      end
    end
  end
end

function mod.on_all_mods_loaded()
  recreate_hud()
end

local _packages_loaded = false
function mod.on_game_state_changed(status, state)
  if state == "StateMainMenu" and status == "enter" then
    if not _packages_loaded then
      load_talent_icon_packages()
      _packages_loaded = true
    end
  end
end

function mod.on_unload(exit_game)

end

function mod:_cb_load_icons_for_profile(specialization_name)
  _loaded_specializations[specialization_name] = _loading_specializations[specialization_name]
  _loading_specializations[specialization_name] = nil
end

function mod:specialization_is_loading(specialization_name)
  return _loading_specializations[specialization_name] ~= nil
end

function mod:specialization_is_loaded(specialization_name)
  return _loaded_specializations[specialization_name] ~= nil
end

function mod:specialization_load_id(specialization_name)
  return _loaded_specializations[specialization_name] or _loading_specializations[specialization_name]
end

mod:hook_safe(UIViewHandler, "close_view", function(self, view_name, force_close)
  if view_name == "dmf_options_view" then
    recreate_hud()
  end
end)

local function fixed_update(func, self, dt, t, time_in_action)
  mod.time_in_action = time_in_action or 0

  return func(self, dt, t, time_in_action)
end
mod:hook("ActionReloadState", "fixed_update", fixed_update)
mod:hook("ActionReloadShotgun", "fixed_update", fixed_update)

local function _handle_state_transition(self, reload_template, inventory_slot_component, time_in_action, time_scale)
  local total_time = ReloadStates.get_total_time(reload_template, inventory_slot_component)

  mod.time_in_action = total_time or 0
end
mod:hook_safe("ActionReloadState", "_handle_state_transition", _handle_state_transition)

local function start(func, ...)
  local result = func(...)

  mod.time_in_action = 0

  return result
end
mod:hook("ActionReloadState", "start", start)
mod:hook("ActionReloadShotgun", "start", start)

local _setting_id_by_template_name = {
  coherency_toughness_regen = "hide_coherency_buff_bar",
  sprint_with_stamina_buff = "hide_sprint_buff",
  psyker_biomancer_souls = "hide_warp_charges_buff",
  psyker_biomancer_souls_increased_max_stacks = "hide_warp_charges_buff"
}
mod:hook_require("scripts/settings/buff/player_buff_templates", function(templates)

  for template_name, template in pairs(templates) do
    local setting_id = _setting_id_by_template_name[template_name]
    if setting_id then
      template.hide_icon_in_hud = mod:get(setting_id)
    end
  end
end)

mod:hook_require("scripts/settings/buff/player_archetype_specialization/psyker_biomancer_buff_templates", function(templates)
  for template_name, template in pairs(templates) do
    local setting_id = _setting_id_by_template_name[template_name]
    if setting_id then
      template.hide_icon_in_hud = mod:get(setting_id)
    end
  end

  local kinetic_flayer_template = templates.psyker_biomancer_smite_on_hit
  if kinetic_flayer_template then
    mod:hook_safe(kinetic_flayer_template, "update_func", function(template_data, template_context, dt, t)
      template_data.t = t
    end)
  end
end)

local function _shadows_enabled(setting_id)
  local enable_shadows_id = string.format("enable_shadows_%s", setting_id)
  local enable_shadows_setting = mod:get(enable_shadows_id)

  if enable_shadows_setting == "global" then
    return mod:get("enable_shadows")
  end

  return enable_shadows_setting == "on"
end

local function _convert_number_to_display_texts(amount, max_character, zero_numeral_color, color_zero_values, ignore_coloring)
  local _temp_ammo_display_texts = {}

  max_character = math.min(max_character + 1, 3)
  local length = string.len(amount)
  local num_adds = max_character - length
  local zero_string = "0"
  local zero_string_colored = ignore_coloring and zero_string or TextUtilities.apply_color_to_text("0", zero_numeral_color)

  for i = 1, num_adds do
    _temp_ammo_display_texts[#_temp_ammo_display_texts + 1] = zero_string_colored
  end

  local num_amount_strings = string.format("%1d", amount)

  for i = 1, #num_amount_strings do
    local value = string.sub(num_amount_strings, i, i)

    if amount == 0 and color_zero_values then
      _temp_ammo_display_texts[#_temp_ammo_display_texts + 1] = zero_string_colored
    else
      _temp_ammo_display_texts[#_temp_ammo_display_texts + 1] = value
    end
  end

  return _temp_ammo_display_texts
end

local _threshold_settings = {
  {
    threshold = "critical",
    default_color = UIHudSettings.color_tint_alert_2,
    default_color_by_setting = {
      ammo = UIHudSettings.color_tint_ammo_high
    },
    validation_function = function(percent)
      return percent <= 0.15
    end
  },
  {
    threshold = "low",
    default_color = UIHudSettings.color_tint_ammo_medium,
    default_color_by_setting = {},
    validation_function = function(percent)
      return percent <= 0.5
    end
  },
  {
    threshold = "high",
    default_color = UIHudSettings.color_tint_ammo_low,
    default_color_by_setting = {},
    validation_function = function(percent)
      return percent < 1
    end
  },
  {
    threshold = "full",
    default_color = UIHudSettings.color_tint_main_1,
    default_color_by_setting = {
      health = UIHudSettings.color_tint_main_2,
      toughness = UIHudSettings.color_tint_6
    },
    validation_function = function(percent)
      return percent == 1
    end
  }
}
local function _get_text_color_for_percent_threshold(percent, setting)
  local base_setting_id = "custom_threshold_" .. setting
  local color = { 255, 255, 255, 255 }

  for i, settings in ipairs(_threshold_settings) do
    if settings.validation_function and settings.validation_function(percent) then
      local threshold = settings.threshold
      local threshold_setting_id = base_setting_id .. "_" .. threshold
      local default_color_by_setting = settings.default_color_by_setting
      local default_color = default_color_by_setting and default_color_by_setting[setting] or settings.default_color

      local is_threshold_customized = mod:get(threshold_setting_id)
      if is_threshold_customized then
        local color_id = string.format("%s_color", threshold_setting_id)
        color = Color[mod:get(color_id)](255, true)

        break
      end

      color = table.clone(default_color)
      break
    end
  end

  return color
end

mod.utils = {
  shadows_enabled = _shadows_enabled,
  convert_number_to_display_texts = _convert_number_to_display_texts,
  get_text_color_for_percent_threshold = _get_text_color_for_percent_threshold
}
