local mod = get_mod("crosshair_hud")

local ArchetypeTalents = mod:original_require("scripts/settings/ability/archetype_talents/archetype_talents")
local UIViewHandler = mod:original_require("scripts/managers/ui/ui_view_handler")
local ReloadStates = mod:original_require("scripts/extension_systems/weapon/utilities/reload_states")


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

local function _handle_state_transition(self, reload_template, inventory_slot_component, time_in_action, time_in_action)
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
