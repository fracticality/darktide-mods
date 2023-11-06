local mod = get_mod("loadout_config")

local loadout_config_view_path = "loadout_config/scripts/mods/loadout_config/views/loadout_config_view/loadout_config_view"

mod:add_require_path(loadout_config_view_path)

mod:register_view({
  view_name = "loadout_config",
  view_settings = {
    init_view_function = function(ingame_ui_context)
      return true
    end,
    state_bound = true,
    display_name = "loc_eye_color_sienna_desc",
    path = loadout_config_view_path,
    package = "packages/ui/views/credits_goods_vendor_view/credits_goods_vendor_view",
    class = "LoadoutConfigView",
    load_always = true,
    load_in_hub = true,
    game_world_blur = 0,
    enter_sound_events = {
      "wwise/events/ui/play_ui_enter_short"
    },
    exit_sound_events = {
      "wwise/events/ui/play_ui_back_short"
    },
    wwise_states = {}
  },
  view_transitions = {},
  view_options = {
    close_all = false,
    close_previous = false,
    close_transition_time = nil,
    transition_time = nil
  }
})

function mod.open_view()
  if not Managers.ui:has_active_view()
      and not Managers.ui:chat_using_input()
      and not Managers.ui:view_instance("loadout_config")
  then
    if not Managers.profile_synchronization:synchronizer_host() then
      mod:notify("Loadout Config can only be opened in the Psykhanium or during a SoloPlay-enabled game.")

      return
    end

    Managers.ui:open_view("loadout_config")
  elseif Managers.ui:view_instance("loadout_config") then
    Managers.ui:close_view("loadout_config")
  end
end

mod:command("loadout_config", "", mod.open_view)

mod:command("lc", mod:localize("mod_name"), mod.open_view)

local PackageSynchronizerHost = require("scripts/loading/package_synchronizer_host")
mod:hook(PackageSynchronizerHost, "_item_instance_altered", function(func, ...)
  return true
end)