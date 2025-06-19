local mod = get_mod("psych_ward")
mod.context = mod:persistent_table("mod_context", {
  button_settings = {},
})

mod:io_dofile("psych_ward/scripts/mods/psych_ward/patches/title_view")

local ProfileUtils = require("scripts/utilities/profile_utils")
local Promise = require("scripts/foundation/utilities/promise")
local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local Missions = require("scripts/settings/mission/mission_templates")
local StepperPassTemplates = require("scripts/ui/pass_templates/stepper_pass_templates")
local MatchmakingConstants = require("scripts/settings/network/matchmaking_constants")
local SINGLEPLAY_TYPES = MatchmakingConstants.SINGLEPLAY_TYPES

local _is_matchmaking_from_main_menu = false
local _setup_complete = false
local _flag_for_return = false
local _is_transitioning = false
local _return_to_character_select = false
local _go_to_shooting_range = false
local _horde_button = "horde_button"
local _mission_button = "mission_button"
local _vendor_button = "vendor_button"
local _contracts_button = "contracts_button"
local _crafting_button = "crafting_button"
local _inventory_button = "inventory_button"
local _cosmetics_button = "cosmetics_button"
local _penance_button = "penance_button"
local _havoc_button = "havoc_button"
local _meatgrinder_button = "meatgrinder_button"
local _difficulty_stepper = "difficulty_stepper"
local _stepper_content

local _view_button_names = {
  _horde_button,
  _vendor_button,
  _contracts_button,
  _crafting_button,
  _inventory_button,
  _cosmetics_button,
  _mission_button,
  _penance_button,
  _meatgrinder_button,
  --_havoc_button,
}

local button_size = { 150, ButtonPassTemplates.terminal_button_small.size[2] -12 }
local button_offset = { 0, button_size[2] + 10, 0 }
local _button_settings = {
  [_horde_button] = {
    view_name = "training_grounds_view",
    scenegraph_definition = {
      parent = "character_info",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = { 240, 50 },
      position = { 0, -185, 0 }
    }
  },
  [_mission_button] = {
    view_name = "mission_board_view",
    scenegraph_definition = {
      parent = "play_button",
      vertical_alignment = "bottom",
      horizontal_alignment = "center",
      size = { 240, 50 },
      position = { 0, 45, 0 }
    }
  },
  [_vendor_button] = {
    view_name = "credits_vendor_background_view",
    scenegraph_definition = {
      parent = _inventory_button,
      vertical_alignment = "bottom",
      horizontal_alignment = "right",
      size = button_size,
      position = button_offset
    }
  },
  [_contracts_button] = {
    view_name = "contracts_background_view",
    scenegraph_definition = {
      parent = _vendor_button,
      vertical_alignment = "top",
      horizontal_alignment = "right",
      size = button_size,
      position = button_offset
    }
  },
  [_crafting_button] = {
    view_name = "crafting_view",
    scenegraph_definition = {
      parent = _contracts_button,
      vertical_alignment = "top",
      horizontal_alignment = "right",
      size = button_size,
      position = button_offset
    }
  },
  [_cosmetics_button] = {
    view_name = "cosmetics_vendor_background_view",
    scenegraph_definition = {
      parent = _crafting_button,
      vertical_alignment = "top",
      horizontal_alignment = "right",
      size = button_size,
      position = button_offset
    }
  },
  [_inventory_button] = {
    view_name = "inventory_background_view",
    scenegraph_definition = {
      parent = "wallet_element_background",
      vertical_alignment = "bottom",
      horizontal_alignment = "right",
      size = button_size,
      position = { -15, button_size[2] + 25, 0 }
    }
  },
  [_penance_button] = {
    view_name = "penance_overview_view",
    scenegraph_definition = {
      parent = _cosmetics_button,
      vertical_alignment = "top",
      horizontal_alignment = "right",
      size = button_size,
      position = button_offset
    }
  },
  --[_havoc_button] = {
  --  view_name = "havoc_background_view",
  --  scenegraph_definition = {
  --    parent = "play_button",
  --    vertical_alignment = "bottom",
  --    horizontal_alignment = "right",
  --    size = { 240, 50 },
  --    position = { 0, 45, 0 }
  --  }
  --},
  [_meatgrinder_button] = {
    scenegraph_definition = {
      parent = "character_info",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = { 240, 50 },
      position = { 0, -25, 0 }
    }
  },
}

--[[
  Character Select Psykhanium Button
]]--

local function _get_challenge_level()
  local PsykhaniumDefaultDifficulty = get_mod("PsykaniumDefaultDifficulty")
  local challenge_level = PsykhaniumDefaultDifficulty and PsykhaniumDefaultDifficulty:is_enabled() and PsykhaniumDefaultDifficulty:get("default_difficulty")

  if not challenge_level then
    challenge_level = mod:get("selected_difficulty")
  end

  if not challenge_level then
    local save_data = Managers.save:account_data()
    local mission_board_data = save_data and save_data.mission_board

    challenge_level = (mission_board_data and mission_board_data.quickplay_difficulty) or 3
  end

  return challenge_level
end

local MainMenuView = require("scripts/ui/views/main_menu_view/main_menu_view")
function MainMenuView:cb_on_toggle_view_buttons()
  local widgets_by_name = self._widgets_by_name
  for _, button_name in ipairs(_view_button_names) do
    local button_widget = widgets_by_name[button_name]
    if button_widget then
      if button_widget.content.visible == nil then
        button_widget.content.visible = true
      end

      button_widget.content.visible = not button_widget.content.visible
    end
  end

  local difficulty_stepper_widget = widgets_by_name[_difficulty_stepper]
  if difficulty_stepper_widget then
    local widget_content = difficulty_stepper_widget.content
    if widget_content.visible == nil then
      widget_content.visible = true
    end

    widget_content.visible = not widget_content.visible
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

local _is_view_loading
local function _open_view(view_name)
  local character_id = Managers.player:local_player(1):profile().character_id
  local narrative_promise = Managers.narrative:load_character_narrative(character_id)

  if not _is_view_loading then
    _is_view_loading = true

    Promise.all(narrative_promise):next(function (_)
      _is_view_loading = false

      Managers.ui:open_view(view_name, nil, nil, nil, nil, {
        hub_interaction = true,
      })
    end):catch(function ()
      _is_view_loading = false

      return
    end)
  end
end

mod:hook(CLASS.TrainingGroundsView, "on_enter", function(func, self)
  local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()

  self._base_definitions.starting_option_index = game_mode_name ~= "hub" and 1 or nil

  return func(self)
end)

mod:hook_safe(CLASS.StoryMissionLoreView, "on_enter", function(self)

  local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()

  if game_mode_name ~= "hub" then
    self._widgets_by_name.trailer_button.content.hotspot.disabled = true
    self._widgets_by_name.trailer_button.content.original_text = mod:localize("cutscenes_hub_only")
  end
end)

local _presence_hook_top_views = {
  mission_board_view = true,
  story_mission_play_view = true,
  horde_play_view = true,
}

local function presence_name_hook(func, self)
  local result = func(self)

  if _presence_hook_top_views[Managers.ui:active_top_view()] then
    if result == "training_grounds" or result == "main_menu" then
      return "hub"
    end
  end

  return result
end

mod:hook(CLASS.PartyImmateriumMemberMyself, "presence_name", presence_name_hook)
mod:hook(CLASS.PartyImmateriumMember, "presence_name", presence_name_hook)

-- This handles cases where the player times out in the post-mission screen
mod:hook(CLASS.MechanismHub, "wanted_transition", function(func, self)
  if _return_to_character_select then

    if not _is_transitioning then
      _is_transitioning = true

      return false, CLASS.StateLoading, {
        next_state = CLASS.StateExitToMainMenu,
        next_state_params = {}
      }
    end

    return false
  end

  return func(self)
end)

mod:hook_safe(CLASS.MechanismLeftSession, "init", function(self, ...)
  if _return_to_character_select then
    self._next_state = CLASS.StateExitToMainMenu
  end
end)

-- This handles cases where the player skipped post-mission timeout or left a mission
mod:hook(CLASS.MultiplayerSessionManager, "find_available_session", function(func, ...)

  if _return_to_character_select then
    return CLASS.StateExitToMainMenu, {}
  end

  if _flag_for_return then
    _return_to_character_select = true
    _flag_for_return = false
  end

  return func(...)
end)

local main_menu_definitions_file = "scripts/ui/views/main_menu_view/main_menu_view_definitions"
mod:hook_require(main_menu_definitions_file, function(definitions)

  local index = table.find_by_key(definitions.legend_inputs, "is_custom", true)
  if index then
    table.remove(definitions.legend_inputs, index)
  end

  table.insert(definitions.legend_inputs, legend_input)

  definitions.scenegraph_definition[_difficulty_stepper] = {
    parent = _meatgrinder_button,
    vertical_alignment = "bottom",
    horizontal_alignment = "center",
    size = { 300, 60 },
    position = { -25, -75, 10 }
  }

  for button_name, button_settings in pairs(_button_settings) do
    local button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, button_name, {
      text = mod:localize(button_name),
      view_name = button_settings.view_name
    })

    definitions.widget_definitions[button_name] = button
    definitions.scenegraph_definition[button_name] = button_settings.scenegraph_definition
  end

  local stepper_template = table.clone(StepperPassTemplates.difficulty_stepper)
  local definition = UIWidget.create_definition(stepper_template, _difficulty_stepper)
  index = table.find_by_key(definition.passes, "style_id", "danger")
  if index then
    table.remove(definition.passes, index)
  end

  index = table.find_by_key(definition.passes, "style_id", "stepper_left")
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

local function _open_voting_view(view_context)
  if not table.is_empty(Managers.ui:active_views()) then
    Managers.ui:close_all_views(false, {
      "main_menu_view",
      "main_menu_background_view"
    })
  end

  Managers.ui:open_view("mission_voting_view", nil, false, false, nil, view_context)
end

local mission_vote_matchmaking_immaterium = "scripts/settings/voting/voting_templates/mission_vote_matchmaking_immaterium"

mod:hook_require(mission_vote_matchmaking_immaterium, function(voting_template)
  voting_template.on_started = function(voting_id, template, params)
    if Managers.ui:view_active("system_view") then
      Managers.ui:close_view("system_view")
    end

    if GameParameters.debug_mission then
      Managers.voting:cast_vote(voting_id, "yes")
    elseif not Managers.voting:has_voted(voting_id, Managers.party_immaterium:get_myself():unique_id()) then
      if params.qp == "true" then
        local view_context = {
          qp = params.qp,
          voting_id = voting_id,
          backend_mission_id = params.backend_mission_id
        }

        _open_voting_view(view_context)
      else
        local view_context = {
          voting_id = voting_id,
          backend_mission_id = params.backend_mission_id,
          mission_data = cjson.decode(params.mission_data).mission
        }

        _open_voting_view(view_context)
      end
    end
  end
end)

mod:hook(CLASS.StateMainMenu, "_show_reconnect_popup", function(func, self)
  _flag_for_return = true

  if _is_matchmaking_from_main_menu then
    self._reconnect_popup_id = nil
    self._reconnect_pressed = true
    self:_rejoin_game()

    return
  end

  return func(self)
end)

mod:hook(CLASS.StateMainMenu, "update", function(func, self, main_dt, main_t)
  if self._continue and not self:_waiting_for_profile_synchronization() then

    --mod:hook_disable(CLASS.PartyImmateriumMemberMyself, "presence_name")
    --mod:hook_disable(CLASS.PartyImmateriumMember, "presence_name")

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
  elseif self._continue then
    self._continue = false
  end

  local next_state, next_state_params = func(self, main_dt, main_t)

  return next_state, next_state_params

end)

local _wallet_update_t = 5
mod:hook(CLASS.MainMenuView, "_handle_input", function(func, self, input_service, dt, t)

  local constant_elements = Managers.ui:ui_constant_elements()
  if mod:get("allow_chat_main_menu") then
    if input_service:get("confirm_pressed") then
      constant_elements._elements.ConstantElementChat:set_visible(true)
      return
    end
  elseif constant_elements._elements.ConstantElementChat then
    constant_elements._elements.ConstantElementChat:set_visible(false)
  end

  func(self, input_service, dt, t)

  local is_in_matchmaking = Managers.party_immaterium:is_in_matchmaking()
  local play_button_content = self._widgets_by_name.play_button.content
  local create_button_content = self._widgets_by_name.create_button.content
  local meatgrinder_button_content = self._widgets_by_name[_meatgrinder_button].content
  local mission_button_content = self._widgets_by_name[_mission_button].content
  local horde_button_content = self._widgets_by_name[_horde_button].content
  --local havoc_button_content = self._widgets_by_name[_havoc_button].content

  play_button_content.hotspot.disabled = is_in_matchmaking
  meatgrinder_button_content.hotspot.disabled = is_in_matchmaking or self._is_main_menu_open
  mission_button_content.hotspot.disabled = is_in_matchmaking
  create_button_content.hotspot.disabled = is_in_matchmaking
  horde_button_content.hotspot.disabled = is_in_matchmaking
  --havoc_button_content.hotspot.disabled = true

  for i, character_list_widget in ipairs(self._character_list_widgets) do
    character_list_widget.content.hotspot.disabled = is_in_matchmaking
  end

  if not _setup_complete then
    self:_setup_interactions()
  end

  local wallet_element = self._wallet_element
  if wallet_element then
    local wallet_update_t = (self._wallet_update_t or 0) + dt

    if wallet_update_t > _wallet_update_t then
      wallet_update_t = nil
      wallet_element:update_wallets()
    end

    self._wallet_update_t = wallet_update_t
  end

  --if is_in_matchmaking then
  --  mod:hook_disable(CLASS.PartyImmateriumMemberMyself, "presence_name")
  --  mod:hook_disable(CLASS.PartyImmateriumMember, "presence_name")
  --else
  --  mod:hook_enable(CLASS.PartyImmateriumMemberMyself, "presence_name")
  --  mod:hook_enable(CLASS.PartyImmateriumMember, "presence_name")
  --end

  _is_matchmaking_from_main_menu = is_in_matchmaking
end)

mod:hook_safe(CLASS.MainMenuView, "_setup_interactions", function(self)

  local widgets_by_name = self._widgets_by_name

  local challenge_level = _get_challenge_level()
  _stepper_content = widgets_by_name.difficulty_stepper.content
  _stepper_content.danger = challenge_level

  widgets_by_name[_meatgrinder_button].content.hotspot.pressed_callback = function()
    _go_to_shooting_range = true
    self:_on_play_pressed()
  end

  for _, button_name in ipairs(_view_button_names) do
    local content = widgets_by_name[button_name] and widgets_by_name[button_name].content
    if content.view_name then
      content.hotspot.pressed_callback = function()
        _open_view(content.view_name)
      end
    end
  end

  local play_button_content = widgets_by_name.play_button.content
  play_button_content.original_text = mod:localize("enter_hub")

  --mod:hook_enable(CLASS.PartyImmateriumMemberMyself, "presence_name")
  --mod:hook_enable(CLASS.PartyImmateriumMember, "presence_name")

  _return_to_character_select = false
  _is_transitioning = false
  _setup_complete = true

  Managers.data_service.store:reset()
end)

mod:hook_safe(CLASS.MissionBoardView, "on_enter", function(self)
  self._regions_latency = self._regions_latency or {}
end)

-- prevent issues with sacrifice menu
local sacrifice_package_id = nil

mod:hook(CLASS.CraftingMechanicusBarterItemsView, "_setup_background_world", function(func, self)
  local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
  if game_mode_name ~= "hub" then
    sacrifice_package_id = sacrifice_package_id or Managers.package:load("packages/ui/views/masteries_overview_view/masteries_overview_view", mod.name, nil, true)
    return -- running func causes a crash; there's presumably something else that isn't loaded, but this func is not needed
  end
  func(self)
end)

mod:hook_safe(CLASS.CraftingView, "on_exit", function(self)
  if sacrifice_package_id then
    Managers.package:release(sacrifice_package_id)
    sacrifice_package_id = nil
  end
end)

--local extra_package_id
--
--mod:hook(CLASS.TabbedMenuViewBase, "_setup_background_world", function(func, self)
--  local game_mode_name = Managers.state.game_mode_name and Managers.state.game_mode:game_mode_name()
--  if game_mode_name ~= "hub" then
--    extra_package_id = extra_package_id or Managers.package:load("packages/ui/views/credits_vendor_view/credits_vendor_view", mod.name, nil, true)
--  end
--end)
--
--mod:hook_safe(CLASS.CreditsVendorView, "on_exit", function(self)
--  if extra_package_id then
--    Managers.package:release(extra_package_id)
--    extra_package_id = nil
--  end
--end)
