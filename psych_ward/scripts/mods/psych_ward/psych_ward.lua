local mod = get_mod("psych_ward")

local Promise = mod:original_require("scripts/foundation/utilities/promise")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")
local ButtonPassTemplates = mod:original_require("scripts/ui/pass_templates/button_pass_templates")
local Missions = mod:original_require("scripts/settings/mission/mission_templates")
local StepperPassTemplates = mod:original_require("scripts/ui/pass_templates/stepper_pass_templates")
local MatchmakingConstants = mod:original_require("scripts/settings/network/matchmaking_constants")
local SINGLEPLAY_TYPES = MatchmakingConstants.SINGLEPLAY_TYPES

local _setup_complete = false
local _go_to_shooting_range = false
local _psykhanium_button = "psykhanium_button"
local _exit_text = "exit_text"
local _vendor_button = "vendor_button"
local _contracts_button = "contracts_button"
local _crafting_button = "crafting_button"
local _inventory_button = "inventory_button"
local _difficulty_stepper = "difficulty_stepper"
local _stepper_content

local _view_button_names = {
  _vendor_button,
  _contracts_button,
  _crafting_button,
  _inventory_button,
  --_psykhanium_button
}

local _button_settings = {
  [_psykhanium_button] = {
    view_name = "training_grounds_view",
    scenegraph_definition = {
      parent = "character_info",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = ButtonPassTemplates.ready_button.size,
      position = { 0, -ButtonPassTemplates.ready_button.size[2], 0 }
    }
  },
  [_vendor_button] = {
    view_name = "credits_vendor_background_view",
    scenegraph_definition = {
      parent = "screen",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = ButtonPassTemplates.ready_button.size,
      position = { 0, 0, 0 }
    }
  },
  [_contracts_button] = {
    view_name = "contracts_background_view",
    scenegraph_definition = {
      parent = "screen",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = ButtonPassTemplates.ready_button.size,
      position = { ButtonPassTemplates.ready_button.size[1], 0, 0 }
    }
  },
  [_crafting_button] = {
    view_name = "crafting_view",
    scenegraph_definition = {
      parent = "screen",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = ButtonPassTemplates.ready_button.size,
      position = { -ButtonPassTemplates.ready_button.size[1], 0, 0 }
    }
  },
  [_inventory_button] = {
    view_name = "inventory_background_view",
    scenegraph_definition = {
      parent = "screen",
      vertical_alignment = "bottom",
      horizontal_alignment = "center",
      size = ButtonPassTemplates.ready_button.size,
      position = { 0, -ButtonPassTemplates.ready_button.size[2] / 2, 0 }
    }
  }
}

--[[
  Character Select Psykhanium Button
]]--

local function _get_challenge_level()
  local PsykhaniumDefaultDifficulty = get_mod("PsykaniumDefaultDifficulty")
  local challenge_level = PsykhaniumDefaultDifficulty and PsykhaniumDefaultDifficulty:get_internal_data("is_enabled") and PsykhaniumDefaultDifficulty:get("default_difficulty")

  if not challenge_level then
    challenge_level = mod:get("selected_difficulty")
  end

  if not challenge_level then
    local save_data = Managers.save:account_data()
    challenge_level = save_data.mission_board.quickplay_difficulty or 3
  end

  return challenge_level
end

local MainMenuView = mod:original_require("scripts/ui/views/main_menu_view/main_menu_view")
function MainMenuView:cb_on_toggle_view_buttons()
  local widgets_by_name = self._widgets_by_name
  for _, button_name in ipairs(_view_button_names) do
    local button_widget = widgets_by_name[button_name]
    if button_widget then
      button_widget.content.visible = not button_widget.content.visible
    end
  end
end

local legend_input = {
  is_custom = true,
  input_action = "hotkey_inventory",
  display_name = "loc_toggle_view_buttons",
  alignment = "center_alignment",
  on_pressed_callback = "cb_on_toggle_view_buttons",
  visibility_function = function(parent)
    return not parent._is_main_menu_open
  end
}

local function _open_view(view_name)
  local character_id = Managers.player:local_player(1):profile().character_id
  local promise = Managers.narrative:load_character_narrative(character_id)

  Promise.all(promise):next(function (_)
    Managers.ui:open_view(view_name, nil, nil, nil, nil, {
      hub_interaction = true,
    })
  end):catch(function ()
    return
  end)
end

local main_menu_definitions_file = "scripts/ui/views/main_menu_view/main_menu_view_definitions"
mod:hook_require(main_menu_definitions_file, function(definitions)

  local index = table.find_by_key(definitions.legend_inputs, "is_custom", true)
  if index then
    table.remove(definitions.legend_inputs, index)
  end

  table.insert(definitions.legend_inputs, legend_input)

  definitions.scenegraph_definition[_difficulty_stepper] = {
    parent = _psykhanium_button,
    vertical_alignment = "bottom",
    horizontal_alignment = "center",
    size = { 300, 60 },
    position = { -25, -200, 10 }
  }

  for button_name, button_settings in pairs(_button_settings) do
    local button = UIWidget.create_definition(ButtonPassTemplates.ready_button, button_name, {
      text = mod:localize(button_name),
      view_name = button_settings.view_name
    })
    button.content.visible = false
    definitions.widget_definitions[button_name] = button
    definitions.scenegraph_definition[button_name] = button_settings.scenegraph_definition
  end

  local definition = UIWidget.create_definition(table.clone(StepperPassTemplates.difficulty_stepper), _difficulty_stepper)
  index = table.find_by_key(definition.passes, "pass_type", "texture")
  if index then
    table.remove(definition.passes, index)
  end

  index = table.find_by_key(definition.passes, "value_id", "stepper_left")
  if index then
    local pass = definition.passes[index]
    local style = definition.style[pass.style_id]
    if style and style.offset then
      style.offset[1] = -75
    end
  end

  index = table.find_by_key(definition.passes, "content_id", "hotspot_left")
  if index then
    local pass = definition.passes[index]
    local style = definition.style[pass.style_id]
    if style and style.offset then
      style.offset[1] = -95
    end
  end

  index = table.find_by_key(definition.passes, "value_id", "difficulty_text")
  if index then
    local pass = definition.passes[index]
    local style = definition.style[pass.style_id]
    if style and style.offset then
      style.offset[1] = 25
    end
  end

  definitions.widget_definitions[_difficulty_stepper] = definition

end)

mod:hook("StateMainMenu", "update", function(func, self, main_dt, main_t)

  if self._continue and not self:_waiting_for_profile_synchronization() then
    if _go_to_shooting_range then
      _go_to_shooting_range = false

      local challenge_level = (_stepper_content and _stepper_content.danger) or _get_challenge_level()

      local mechanism_context = {
        mission_name = "tg_shooting_range",
        singleplay_type = SINGLEPLAY_TYPES.training_grounds,
        challenge_level = challenge_level
      }

      mod:debug("Going to shooting range with difficulty level [%s]", challenge_level)

      local mechanism_manager = Managers.mechanism
      local mission_settings = Missions[mechanism_context.mission_name]
      local mechanism_name = mission_settings.mechanism_name

      Managers.multiplayer_session:boot_singleplayer_session()
      mechanism_manager:change_mechanism(mechanism_name, mechanism_context)
      local next_state, state_context = mechanism_manager:wanted_transition()

      mod:set("selected_difficulty", challenge_level)

      return next_state, state_context
    end
  end

  return func(self, main_dt, main_t)

end)

mod:hook_safe("MainMenuView", "_handle_input", function(self, input_service)
  local play_button = self._widgets_by_name.play_button.content

  local widget = self._widgets_by_name[_psykhanium_button].content
  widget.hotspot.disabled = self._is_main_menu_open
  widget.visible = play_button.visible

  if not _setup_complete then
    self:_setup_interactions()
  end
end)

mod:hook_safe("MainMenuView", "_setup_interactions", function(self)

  _setup_complete = true
  local widgets_by_name = self._widgets_by_name

  local challenge_level = _get_challenge_level()
  _stepper_content = widgets_by_name.difficulty_stepper.content
  _stepper_content.danger = challenge_level

  widgets_by_name[_psykhanium_button].content.hotspot.pressed_callback = function()
    _go_to_shooting_range = true
    self:_on_play_pressed()
  end

  for _, button_name in ipairs(_view_button_names) do
    local content = widgets_by_name[button_name] and widgets_by_name[button_name].content
    content.hotspot.pressed_callback = function()
      _open_view(content.view_name)
    end
  end
end)

--[[
  Title Screen Exit Button
]]--

local function _quit()
  Application.quit()
end

local function _setup_title_button()
  local title_view_definitions_file = "scripts/ui/views/title_view/title_view_definitions"
  mod:hook_require(title_view_definitions_file, function(definitions)
    definitions.scenegraph_definition[_exit_text] = {
      parent = "background_image",
      vertical_alignment = "bottom",
      horizontal_alignment = "center",
      size = { 300, 50 },
      position = { 0, -25, 4 }
    }

    definitions.widget_definitions[_exit_text] = UIWidget.create_definition({
      {
        pass_type = "hotspot",
        content_id = "hotspot",
        content = {
          pressed_callback = _quit
        },
      },
      {
        pass_type = "text",
        value = "",
        value_id = "text",
        style = {
          font_size = 24,
          font_type = "proxima_nova_bold",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "center",
          text_color = Color.text_default(255, true),
          offset = { 0, 0, 2 }
        },
        change_function = function(content, style)
          local progress = 0.5 + math.sin(Application.time_since_launch() * 3) * 0.5
          local text_color = style.text_color
          local progress_color = 180 + 75 * progress
          text_color[2] = progress_color
          text_color[3] = progress_color
          text_color[4] = progress_color
        end
      }
    }, _exit_text)

  end)

  mod:hook_safe("TitleView", "update", function(self, dt, t, input_service)
    if self._parent:is_loading() then
      mod:hook_disable("TitleView", "update")

      local exit_widget = self._widgets_by_name[_exit_text]
      local widget_content = exit_widget and exit_widget.content
      if widget_content then
        widget_content.visible = false
      end

      return
    end

    if input_service:get("hotkey_system") then
      _quit()
    end
  end)

  mod:hook_safe("TitleView", "_apply_title_text", function(self)
    local input = InputUtils.input_text_for_current_input_device("View", "close_view", true)
    local text = mod:localize("exit_text", input)
    self._widgets_by_name[_exit_text].content.text = text
  end)
end

--[[
  Init
]]--

_setup_title_button()
