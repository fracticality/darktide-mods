local mod = get_mod("psych_ward")

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = mod:original_require("scripts/ui/pass_templates/button_pass_templates")
local Missions = mod:original_require("scripts/settings/mission/mission_templates")
local MatchmakingConstants = mod:original_require("scripts/settings/network/matchmaking_constants")
local SINGLEPLAY_TYPES = MatchmakingConstants.SINGLEPLAY_TYPES

local _go_to_shooting_range = false
local _psykhanium_button = "psykhanium_button"
local _exit_button = "exit_button"

--[[
  Character Select Psykhanium Button
]]--

mod:hook(StateMainMenu, "update", function(func, self, main_dt, main_t)

  local next_state, state_context = func(self, main_dt, main_t)


  local save_data = Managers.save:account_data()
  local challenge_level = save_data.mission_board.quickplay_difficulty or 1




  if self._continue and not self:_waiting_for_profile_synchronization() then
    if _go_to_shooting_range then
      _go_to_shooting_range = false

      local mechanism_context = {
        mission_name = "tg_shooting_range",
        singleplay_type = SINGLEPLAY_TYPES.training_grounds,
        challenge_level = challenge_level
      }

      local mechanism_manager = Managers.mechanism
      local mission_settings = Missions[mechanism_context.mission_name]
      local mechanism_name = mission_settings.mechanism_name

      Managers.multiplayer_session:boot_singleplayer_session()
      mechanism_manager:change_mechanism(mechanism_name, mechanism_context)
      next_state, state_context = mechanism_manager:wanted_transition()
      --next_state, state_context = Managers.multiplayer_session:start_singleplayer_session("tg_shooting_range", SINGLEPLAY_TYPES.training_grounds)
    end
  end

  return next_state, state_context

end)

local main_menu_definitions_file = "scripts/ui/views/main_menu_view/main_menu_view_definitions"
mod:hook_require(main_menu_definitions_file, function(definitions)

  definitions.scenegraph_definition[_psykhanium_button] = {
    parent = "character_info",
    vertical_alignment = "top",
    horizontal_alignment = "center",
    size = ButtonPassTemplates.ready_button.size,
    position = { 0, -ButtonPassTemplates.ready_button.size[2], 2 }
  }

  definitions.widget_definitions[_psykhanium_button] = UIWidget.create_definition(ButtonPassTemplates.ready_button, _psykhanium_button, {
    text = (mod:localize("enter_psykhanium"))
  })

end)

mod:hook_safe("MainMenuView", "_handle_input", function(self, input_service)
  local play_button = self._widgets_by_name.play_button.content

  local widget = self._widgets_by_name[_psykhanium_button].content
  widget.hotspot.disabled = self._is_main_menu_open
  widget.visible = play_button.visible
end)

mod:hook_safe("MainMenuView", "_setup_interactions", function(self)
  self._widgets_by_name[_psykhanium_button].content.hotspot.pressed_callback = function()
    _go_to_shooting_range = true
    self:_on_play_pressed()
  end
end)


--[[
  Title Screen Exit Button
]]--

local function _quit_callback()
  Application.quit()
end

local title_view_definitions_file = "scripts/ui/views/title_view/title_view_definitions"
mod:hook_require(title_view_definitions_file, function(definitions)
  definitions.scenegraph_definition[_exit_button] = {
    parent = "background_image",
    vertical_alignment = "top",
    horizontal_alignment = "right",
    size = { 50, 50 },
    position = { -55, 55, 4 }
  }

  definitions.widget_definitions[_exit_button] = UIWidget.create_definition({
    {
      pass_type = "hotspot",
      content_id = "hotspot",
      content = {
        pressed_callback = _quit_callback
      },
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/system/escape/quit",
    }
  }, "exit_button")

end)

mod:hook_safe(TitleView, "update", function(self, dt, t, input_service)
  if input_service:get("hotkey_system") then
    _quit_callback()
  end
end)

mod:hook_safe(TitleView, "on_enter", function(self)
  Managers.ui:load_view("system_view", "psych_ward")
end)
