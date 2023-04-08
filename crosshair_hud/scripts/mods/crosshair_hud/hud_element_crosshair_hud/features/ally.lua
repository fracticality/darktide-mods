local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local PlayerUnitStatus = mod:original_require("scripts/utilities/attack/player_unit_status")
local UISettings = mod:original_require("scripts/settings/ui/ui_settings")
local player_slot_colors = UISettings.player_slot_colors

local PlayerCompositions = mod:original_require("scripts/utilities/players/player_compositions")
local WarpCharge = mod:original_require("scripts/utilities/warp_charge")
local ArchetypeWarpChargeTemplates = mod:original_require("scripts/settings/warp_charge/archetype_warp_charge_templates")

local global_scale = mod:get("global_scale")
local ally_scale = mod:get("ally_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local ally_offset = {
  mod:get("ally_x_offset"),
  mod:get("ally_y_offset")
}

local feature_name = "ally_indicator"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen
}

for i = 1, 3 do
  local scenegraph_id = string.format("%s_%s", feature_name, i)
  feature.scenegraph_definition[scenegraph_id] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 72 * ally_scale, 70 * ally_scale },
    position = {
      global_offset[1] + ally_offset[1] + ((i - 1) * 72),
      global_offset[2] + ally_offset[2],
      55
    }
  }
end

function feature.create_widget_definitions()
  local game_mode_manager = Managers.state.game_mode
  local hud_settings = game_mode_manager:hud_settings()
  feature._player_composition_name = hud_settings.player_composition
  feature._players = {}

  local widget_definitions = {}
  for i = 1, 3 do
    local widget_id = string.format("%s_%s", feature_name, i)
    widget_definitions[widget_id] = UIWidget.create_definition({
      {
        pass_type = "texture_uv",
        value = "content/ui/materials/hud/crosshairs/charge_up",
        style_id = "health_gauge",
        style = {
          vertical_alignment = "center",
          horizontal_alignment = "left",
          uvs = {
            { 1, 0 },
            { 0, 1 }
          },
          color = UIHudSettings.color_tint_main_1,
          size = { 24 * ally_scale, 56 * ally_scale },
          offset = { 0, 0, 1 }
        }
      },
      {
        pass_type = "texture_uv",
        value = "content/ui/materials/hud/crosshairs/charge_up_mask",
        style_id = "health_gauge_mask",
        style = {
          vertical_alignment = "center",
          horizontal_alignment = "left",
          uvs = {
            { 1, 0 },
            { 0, 1 }
          },
          color = UIHudSettings.color_tint_main_2,
          size = { 24 * ally_scale, 56 * ally_scale },
          offset = { 0, 0, 2 }
        }
      },
      {
        pass_type = "texture_uv",
        value = "content/ui/materials/hud/crosshairs/charge_up_mask",
        style_id = "permanent_gauge_mask",
        style = {
          vertical_alignment = "center",
          horizontal_alignment = "left",
          uvs = {
            { 1, 0 },
            { 0, 1 }
          },
          color = UIHudSettings.color_tint_8,
          size = { 24 * ally_scale, 56 * ally_scale },
          offset = { 0, 0, 2 }
        }
      },
      --{
      --  pass_type = "texture_uv",
      --  value = "content/ui/materials/hud/crosshairs/charge_up_mask",
      --  style_id = "corruption_gauge_mask",
      --  style = {
      --    vertical_alignment = "center",
      --    horizontal_alignment = "left",
      --    uvs = {
      --      { 1, 0 },
      --      { 0, 1 }
      --    },
      --    color = UIHudSettings.color_tint_9,
      --    size = { 24 * ally_scale, 56 * ally_scale },
      --    offset = { 0, 0, 3 }
      --  }
      --},
      {
        pass_type = "text",
        value = "",
        value_id = "health_text",
        style_id = "health_text",
        style = {
          font_size = 16 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "top",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_main_2,
          offset = { -66 * ally_scale, 0, 3 }
        }
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/hud/crosshairs/charge_up",
        style_id = "toughness_gauge",
        style = {
          vertical_alignment = "center",
          horizontal_alignment = "right",
          color = UIHudSettings.color_tint_main_1,
          size = { 24 * ally_scale, 56 * ally_scale },
          offset = { 0, 0, 1 }
        }
      },
      {
        pass_type = "texture_uv",
        value = "content/ui/materials/hud/crosshairs/charge_up_mask",
        style_id = "toughness_gauge_mask",
        style = {
          vertical_alignment = "center",
          horizontal_alignment = "right",
          uvs = {
            { 0, 1 },
            { 1, 0 }
          },
          color = UIHudSettings.color_tint_6,
          size = { 24 * ally_scale, 56 * ally_scale },
          offset = { 0, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "toughness_text",
        style_id = "toughness_text",
        style = {
          font_size = 16 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "top",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_6,
          offset = { 66 * ally_scale, 0, 3 }
        }
      },
      {
        pass_type = "texture",
        value_id = "grenade_icon",
        value = "content/ui/materials/hud/icons/party_throwable",
        style_id = "grenade_icon",
        style = {
          size = { 20 * ally_scale, 20 * ally_scale },
          vertical_alignment = "bottom",
          horizontal_alignment = "left",
          color = UIHudSettings.color_tint_main_1,
          offset = { -25 * ally_scale, -5 * ally_scale, 1 }
        }
      },
      {
        pass_type = "text",
        value = "0",
        value_id = "grenade_count",
        style_id = "grenade_count",
        style = {
          font_size = 20 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "bottom",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { -100 * ally_scale, -1 * ally_scale, 3 }
        },
        visibility_function = function(content, style)
          return style.parent.grenade_icon.visible
        end
      },
      {
        pass_type = "text",
        value = "",
        value_id = "symbol_text",
        style_id = "symbol_text",
        style = {
          font_size = 20 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { -78 * ally_scale, -5 * ally_scale, 3 }
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "peril_text",
        style_id = "peril_text",
        style = {
          font_size = 18 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { -98 * ally_scale, -3 * ally_scale, 3 }
        }
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/hud/icons/party_ammo",
        style_id = "ammo_icon",
        style = {
          size = { 20 * ally_scale, 20 * ally_scale },
          vertical_alignment = "bottom",
          horizontal_alignment = "right",
          color = UIHudSettings.color_tint_main_1,
          offset = { 25 * ally_scale, -5 * ally_scale, 1 }
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "current_ammo",
        style_id = "current_ammo",
        style = {
          font_size = 18 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { 78 * ally_scale, 0, 2 }
        },
        visibility_function = function(content, style)
          return style.parent.ammo_icon.visible
        end
      },
      {
        pass_type = "text",
        value = "",
        value_id = "max_ammo",
        style_id = "max_ammo",
        style = {
          font_size = 20 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "bottom",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { 98 * ally_scale, 0, 2 }
        },
        visibility_function = function(content, style)
          return style.parent.ammo_icon.visible
        end
      },
      {
        pass_type = "text",
        value = "",
        value_id = "archetype_symbol",
        style_id = "archetype_symbol",
        style = {
          font_size = 24,
          font_type = "machine_medium",
          vertical_alignment = "center",
          horizontal_alignment = "center",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "center",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { 0, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "ally_name",
        style_id = "ally_name",
        style = {
          font_size = 18,
          font_type = "machine_medium",
          vertical_alignment = "bottom",
          horizontal_alignment = "center",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "center",
          size = { 120 * ally_scale, 56 * ally_scale },
          text_color = UIHudSettings.color_tint_main_1,
          offset = { 0, 35 * ally_scale, 3 }
        }
      },
      {
        pass_type = "texture",
        value_id = "pocketable_icon",
        style_id = "pocketable_icon",
        style = {
          size = { 20 * ally_scale, 20 * ally_scale },
          vertical_alignment = "center",
          horizontal_alignment = "center",
          color = UIHudSettings.color_tint_main_1,
          offset = { 0, -30 * ally_scale, 1 },
        },
        visibility_function = function(content, style)
          return content.pocketable_icon
        end
      },
      {
        pass_type = "texture",
        value_id = "status_icon",
        style_id = "status_icon",
        style = {
          size = { 40 * ally_scale, 40 * ally_scale },
          vertical_alignment = "center",
          horizontal_alignment = "center",
          color = UIHudSettings.color_tint_main_1,
          offset = { 0, 64 * ally_scale, 1 }
        },
        visibility_function = function(content, style)
          return content.status_icon
        end
      }
    }, widget_id)
  end

  return widget_definitions
end

local function update_health(parent, dt, t, widget, player)
  local health_extension = ScriptUnit.has_extension(player.player_unit, "health_system")
  if not health_extension then
    return
  end

  local health_percent = health_extension:current_health_percent()
  local permanent_damage_percent = health_extension:permanent_damage_taken_percent()

  local mask_height_max = 56
  local health_mask_height = mask_height_max * health_percent
  local health_mask_height_offset = mask_height_max * (1 - health_percent) * 0.5

  local content = widget.content
  content.health_text = string.format("%.0f", health_percent * 100)

  local health_gauge_style = widget.style.health_gauge_mask
  health_gauge_style.uvs[1][2] = 1 - health_percent
  health_gauge_style.size[2] = health_mask_height
  health_gauge_style.offset[2] = health_mask_height_offset

  local permanent_mask_height = mask_height_max * permanent_damage_percent
  local permanent_mask_height_offset = mask_height_max * (1 - permanent_damage_percent) * 0.5

  local permanent_gauge_style = widget.style.permanent_gauge_mask
  permanent_gauge_style.uvs[2][2] = permanent_damage_percent
  permanent_gauge_style.size[2] = permanent_mask_height
  permanent_gauge_style.offset[2] = -permanent_mask_height_offset
end

local function update_toughness(parent, dt, t, widget, player)
  local toughness_extension = ScriptUnit.has_extension(player.player_unit, "toughness_system")
  if not toughness_extension then
    return
  end
  local toughness_percent = toughness_extension:current_toughness_percent()

  local mask_height_max = 56
  local mask_height = mask_height_max * toughness_percent
  local mask_height_offset = mask_height_max * (1 - toughness_percent) * 0.5

  local content = widget.content
  content.toughness_text = math.ceil(toughness_percent * 100)

  local style = widget.style.toughness_gauge_mask
  style.uvs[1][2] = toughness_percent
  style.size[2] = mask_height
  style.offset[2] = mask_height_offset
end

local function update_peril(parent, dt, t, widget, player)
  local display_peril_indicator = mod:get("display_peril_indicator")
  local content = widget.content
  local style = widget.style

  content.visible = false

  if not display_peril_indicator then
    return
  end

  local unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
  local weapon_extension = ScriptUnit.has_extension(player.player_unit, "weapon_system")

  if not (unit_data_extension and weapon_extension) then
    return
  end

  local weapon_template = weapon_extension:weapon_template()
  if feature._weapon_template or (weapon_template and weapon_template.uses_overheat) then
    feature._weapon_template = weapon_template
    local weapon_component = unit_data_extension:read_component("slot_secondary")
    local overheat_current_percentage = weapon_component and weapon_component.overheat_current_percentage or 0

    content.symbol_text = ""
    content.peril_text = string.format("%.0f", overheat_current_percentage * 100)
    content.visible = true
    local text_color = mod_utils.get_text_color_for_percent_threshold((1 - overheat_current_percentage), "peril")
    style.peril_text.text_color = text_color
    style.symbol_text.text_color = text_color

    return
  end

  local specialization_warp_charge_template = WarpCharge.specialization_warp_charge_template(player)

  if specialization_warp_charge_template == ArchetypeWarpChargeTemplates.psyker then
    local warp_charge_component = unit_data_extension and unit_data_extension:read_component("warp_charge")
    local current_percentage = warp_charge_component and warp_charge_component.current_percentage or 0

    content.symbol_text = ""
    content.peril_text = string.format("%.0f", current_percentage * 100)
    content.visible = true
    local text_color = mod_utils.get_text_color_for_percent_threshold((1 - current_percentage), "peril")
    style.peril_text.text_color = text_color
    style.symbol_text.text_color = text_color

    return
  end
end

local function update_grenade(parent, dt, t, widget, player)
  local ability_extension = ScriptUnit.has_extension(player.player_unit, "ability_system")

  if not (ability_extension and ability_extension:ability_is_equipped("grenade_ability")) then
    return
  end

  local remaining_ability_charges = ability_extension:remaining_ability_charges("grenade_ability")
  local max_ability_charges = ability_extension:max_ability_charges("grenade_ability")
  local ability_charges_percent = remaining_ability_charges / max_ability_charges
  local content = widget.content
  local style = widget.style

  local unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
  local warp_charge_component = unit_data_extension and unit_data_extension:read_component("warp_charge")
  if warp_charge_component and max_ability_charges == 1 then
    style.grenade_icon.visible = false
    return
  end

  content.grenade_count = remaining_ability_charges

  local color = mod_utils.get_text_color_for_percent_threshold(ability_charges_percent, "grenade")
  style.grenade_icon.visible = true
  style.grenade_icon.color = color
  style.grenade_count.text_color = color
end

local function update_ammo(parent, dt, t, widget, player)
  local display_ammo_indicator = mod:get("display_ammo_indicator")
  widget.style.ammo_icon.visible = display_ammo_indicator

  if not display_ammo_indicator then
    return
  end

  local unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
  local inventory_component = unit_data_extension and unit_data_extension:read_component("slot_secondary")

  if not inventory_component then
    return
  end

  local clip_max = inventory_component.max_ammunition_clip or 0
  local reserve_max = inventory_component.max_ammunition_reserve or 0
  local max_ammo = clip_max + reserve_max

  if max_ammo == 0 then
    widget.style.ammo_icon.visible = false
    return
  end

  local clip_ammo = inventory_component.current_ammunition_clip or 0
  local reserve_ammo = inventory_component.current_ammunition_reserve or 0
  local current_ammo = clip_ammo + reserve_ammo
  local current_ammo_percent = 0

  current_ammo_percent = current_ammo / max_ammo

  local content = widget.content
  content.max_ammo = max_ammo or 0
  content.current_ammo = current_ammo or 0

  local style = widget.style
  local icon_style = style.ammo_icon
  local color = mod_utils.get_text_color_for_percent_threshold(current_ammo_percent, "ammo")

  icon_style.color = color
  style.current_ammo.color = color


  local show_ammo_icon = mod:get("show_ammo_icon")
  icon_style.visible = show_ammo_icon
end

local function update_status(parent, dt, t, widget, player)
  local profile = player:profile()
  local string_symbol = profile.archetype.string_symbol
  local player_name = player:name()
  local is_alive = Unit.alive(player.player_unit)

  widget.content.archetype_symbol = string_symbol
  widget.content.ally_name = player_name

  local player_slot = player.slot and player:slot()
  local player_slot_color = player_slot_colors[player_slot] or UIHudSettings.color_tint_main_1

  local unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
  local character_state_component = unit_data_extension and unit_data_extension:read_component("character_state")
  local character_state_name = character_state_component and character_state_component.state_name
  local is_disabled = character_state_name and PlayerUnitStatus.is_disabled(character_state_component)


  widget.style.ally_name.text_color = (is_disabled and UIHudSettings.player_status_colors[character_state_name]) or (not is_alive and UIHudSettings.player_status_colors.dead) or UIHudSettings.color_tint_main_1
  widget.style.archetype_symbol.text_color = (is_disabled and UIHudSettings.player_status_colors[character_state_name]) or (not is_alive and UIHudSettings.player_status_colors.dead) or player_slot_color

  widget.content.status_icon = (not is_alive and UIHudSettings.player_status_icons.dead) or (is_disabled and UIHudSettings.player_status_icons[character_state_name])
  widget.style.status_icon.color = (is_disabled and UIHudSettings.player_status_colors[character_state_name]) or (not is_alive and UIHudSettings.player_status_colors.dead)

end

local function update_pocketable(parent, dt, t, widget, player)
  local display_pocketable_indicator = mod:get("display_pocketable_indicator")
  local content = widget.content

  content.visible = display_pocketable_indicator

  if not display_pocketable_indicator then
    return
  end

  local unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
  local visual_loadout_extension = ScriptUnit.has_extension(player.player_unit, "visual_loadout_system")
  local inventory_component = unit_data_extension and unit_data_extension:read_component("inventory")
  local pocketable_name = inventory_component and inventory_component.slot_pocketable
  local weapon_template = pocketable_name and visual_loadout_extension and visual_loadout_extension:weapon_template_from_slot("slot_pocketable")
  content.pocketable_icon = weapon_template and weapon_template.hud_icon_small
end

local temp_team_players = {}
local function update_players(parent, dt, t)
  local players = PlayerCompositions.players(feature._player_composition_name, temp_team_players)

  local i = 1
  for unique_id, player in pairs(players) do
    if i > 3 then
      break
    end

    repeat
      local hud_player = parent._parent:player()
      if hud_player == player then
        break
      end

      feature._players[i] = player

      i = i + 1
    until true

  end
end

function feature.update(parent, dt, t)
  update_players(parent, dt, t)

  for i = 1, 3 do
    local widget_id = string.format("%s_%s", feature_name, i)
    local ally_widget = parent._widgets_by_name[widget_id]
    local ally_content = ally_widget.content
    local ally_style = ally_widget.style

    repeat
      if not mod:get("display_ally_indicator") then
        ally_content.visible = false
        break
      end

      local player = feature._players[i]
      if player and not player.__deleted then
        ally_content.visible = true

        update_status(parent, dt, t, ally_widget, player)
        update_health(parent, dt, t, ally_widget, player)
        update_toughness(parent, dt, t, ally_widget, player)
        update_grenade(parent, dt, t, ally_widget, player)
        update_peril(parent, dt, t, ally_widget, player)
        update_ammo(parent, dt, t, ally_widget, player)
        update_pocketable(parent, dt, t, ally_widget, player)
      else
        feature._players[i] = nil

        ally_content.visible = false
      end
    until true

  end

end

return feature
