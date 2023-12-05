local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")
local UISettings = require("scripts/settings/ui/ui_settings")
local player_slot_colors = UISettings.player_slot_colors

local PlayerCompositions = require("scripts/utilities/players/player_compositions")
local WarpCharge = require("scripts/utilities/warp_charge")
local ArchetypeWarpChargeTemplates = require("scripts/settings/warp_charge/archetype_warp_charge_templates")

local global_scale = mod:get("global_scale")
local ally_scale = mod:get("ally_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local ally_offset = {
  {
    mod:get("ally_1_x_offset"),
    mod:get("ally_1_y_offset")
  },
  {
    mod:get("ally_2_x_offset"),
    mod:get("ally_2_y_offset")
  },
  {
    mod:get("ally_3_x_offset"),
    mod:get("ally_3_y_offset")
  }
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
  local scenegraph_offset = ally_offset[i]
  feature.scenegraph_definition[scenegraph_id] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 72 * ally_scale, 72 * ally_scale },
    position = {
      global_offset[1] + scenegraph_offset[1],
      global_offset[2] + scenegraph_offset[2],
      55
    }
  }
end

function feature.create_widget_definitions()
  local game_mode_manager = Managers.state.game_mode
  local hud_settings = game_mode_manager:hud_settings()
  feature._player_composition_name = hud_settings.player_composition
  feature._players = {}
  feature._wounds_widgets_by_player = {}

  local widget_definitions = {}
  for i = 1, 3 do
    local widget_id = string.format("%s_%s", feature_name, i)
    widget_definitions[widget_id] = UIWidget.create_definition({
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
          offset = { -64 * ally_scale, 0, 3 }
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
          offset = { 64 * ally_scale, 0, 3 }
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
          offset = { -20 * ally_scale, -5 * ally_scale, 1 }
        }
      },
      {
        pass_type = "text",
        value = "0",
        value_id = "grenade_count",
        style_id = "grenade_count",
        style = {
          font_size = 18 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "bottom",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { -94 * ally_scale, -2 * ally_scale, 3 }
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
          font_size = 20 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { 78 * ally_scale, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "max_ammo",
        style_id = "max_ammo",
        style = {
          font_size = 18 * ally_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "bottom",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_main_1,
          offset = { 98 * ally_scale, 0, 2 }
        }
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

local function create_segment_definition(widget_id)
  return UIWidget.create_definition({
    {
      pass_type = "texture_uv",
      value = "content/ui/materials/hud/crosshairs/charge_up",
      style_id = "background",
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
      style_id = "health",
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
      style_id = "permanent_damage",
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
      },
      visibility_function = function(content, style)
        return content.permanent_damage and content.permanent_damage > 0
      end
    }
  }, widget_id)
end

local function update_health(parent, dt, t, widget, player)
  local health_extension = ScriptUnit.has_extension(player.player_unit, "health_system")

  local health_percent = health_extension and health_extension:current_health_percent() or 0
  local permanent_damage_percent = health_extension and health_extension:permanent_damage_taken_percent() or 0
  local max_wounds = health_extension and health_extension:max_wounds() or 1

  local content = widget.content
  content.health_text = math.ceil(health_percent * 100)

  if not feature._wounds_widgets_by_player[player] then
    local wounds_widgets = {}
    for i = max_wounds, 1, -1 do
      local widget_name = string.format("%s_segment_%s", widget.name, i)
      local wounds_widget = parent:_create_widget(widget_name, create_segment_definition(widget.name))
      table.insert(parent._widgets, wounds_widget)
      table.insert(wounds_widgets, wounds_widget)
    end

    feature._wounds_widgets_by_player[player] = wounds_widgets
  end

  local step_fraction = 1 / max_wounds
  local spacing = 1 * ally_scale
  local bar_height = 56 * ally_scale
  local segment_height = (bar_height - (max_wounds - 1) * spacing) / max_wounds
  local y_offset = -(segment_height + spacing) / 2

  local wounds_widgets = feature._wounds_widgets_by_player[player]
  for i = 1, max_wounds do
    local wounds_widget = wounds_widgets[i]
    if not wounds_widget then
      return
    end

    local health_fraction
    if health_percent then
      local end_value = i * step_fraction
      local start_value = end_value - step_fraction
      health_fraction = math.clamp01((health_percent - start_value) / step_fraction)
    end

    local permanent_fraction = 0
    if permanent_damage_percent then
      local end_value = (max_wounds + 1 - i) * step_fraction
      local start_value = end_value - step_fraction
      permanent_fraction = math.clamp01((math.floor(permanent_damage_percent * 100) / 100 - start_value) / step_fraction)
    end

    local widget_style = wounds_widget.style
    widget_style.health.size[2] = health_fraction * segment_height
    widget_style.health.uvs[1][2] = (step_fraction * i) - ((1 - health_fraction) / max_wounds)
    widget_style.health.uvs[2][2] = (i - 1) * step_fraction
    widget_style.health.offset[2] = segment_height * (1 - health_fraction) * 0.5

    wounds_widget.content.permanent_damage = permanent_damage_percent
    widget_style.permanent_damage.size[2] = permanent_fraction * segment_height
    widget_style.permanent_damage.uvs[1][2] = (step_fraction * i)
    widget_style.permanent_damage.uvs[2][2] = (step_fraction * i) - permanent_fraction / max_wounds
    widget_style.permanent_damage.offset[2] = -(segment_height * (1 - permanent_fraction) * 0.5)

    widget_style.background.size[2] = segment_height
    widget_style.background.uvs[1][2] = (step_fraction * i)
    widget_style.background.uvs[2][2] = (i - 1) * step_fraction

    wounds_widget.offset[2] = y_offset + bar_height / 2
    y_offset = y_offset - (segment_height + spacing)
  end
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
  local content = widget.content
  local style = widget.style

  content.visible = false

  local unit_data_extension = ScriptUnit.has_extension(player.player_unit, "unit_data_system")
  local weapon_extension = ScriptUnit.has_extension(player.player_unit, "weapon_system")

  if not (unit_data_extension or weapon_extension) then
    return
  end

  local archetype_warp_charge_template = WarpCharge.archetype_warp_charge_template(player)

  if archetype_warp_charge_template == ArchetypeWarpChargeTemplates.psyker then
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

  local weapon_template = weapon_extension and weapon_extension:weapon_template()
  if (weapon_template and weapon_template.uses_overheat) then
    feature._weapon_template = weapon_template
    local weapon_component = unit_data_extension and unit_data_extension:read_component("slot_secondary")
    local overheat_current_percentage = weapon_component and weapon_component.overheat_current_percentage or 0

    content.symbol_text = ""
    content.peril_text = math.ceil(overheat_current_percentage * 100)
    content.visible = true
    local text_color = mod_utils.get_text_color_for_percent_threshold((1 - overheat_current_percentage), "peril")
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

  local profile = player:profile()
  local talents = profile.talents
  local ogryn_frag_grenade = talents.ogryn_grenade_frag
  if (max_ability_charges == 1 and not ogryn_frag_grenade) or max_ability_charges == 0 then
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
  local current_ammo_percent = current_ammo / max_ammo
  local current_clip_percent = clip_ammo / clip_max

  current_ammo_percent = current_ammo / max_ammo

  local content = widget.content
  content.max_ammo = reserve_ammo
  content.current_ammo = clip_ammo

  local style = widget.style
  local icon_style = style.ammo_icon
  local clip_color = mod_utils.get_text_color_for_percent_threshold(current_clip_percent, "ammo")
  local reserve_color = mod_utils.get_text_color_for_percent_threshold(current_ammo_percent, "ammo")

  style.current_ammo.text_color = clip_color
  style.max_ammo.text_color = reserve_color
  icon_style.color = reserve_color
end

local unit_alive = Unit.alive
local function update_status(parent, dt, t, widget, player)
  local profile = player:profile()
  if not profile then
    return
  end

  local string_symbol = profile.archetype.string_symbol
  local player_name = player:name()
  local is_alive = unit_alive(player.player_unit)

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
  widget.style.status_icon.color = (not is_alive and UIHudSettings.player_status_colors.dead) or (is_disabled and UIHudSettings.player_status_colors[character_state_name])
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
  local hud_player = parent._parent:player()

  local i = 1
  for unique_id, player in pairs(players) do
    if i > 3 then
      break
    end

    repeat
      if hud_player == player or player.__deleted then
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

    repeat
      if not mod:get("display_ally_indicator") then
        ally_content.visible = false
        break
      end

      local player = feature._players[i]
      if not player or player.__deleted then
        ally_content.visible = false
        break
      end

      ally_content.visible = true

      update_status(parent, dt, t, ally_widget, player)
      update_health(parent, dt, t, ally_widget, player)
      update_toughness(parent, dt, t, ally_widget, player)
      update_grenade(parent, dt, t, ally_widget, player)
      update_peril(parent, dt, t, ally_widget, player)
      update_ammo(parent, dt, t, ally_widget, player)
      update_pocketable(parent, dt, t, ally_widget, player)
    until true

  end

end

return feature
