local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local Ammo = require("scripts/utilities/ammo")

local global_scale = mod:get("global_scale")
local ammo_scale = mod:get("ammo_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local ammo_offset = {
  mod:get("ammo_x_offset"),
  mod:get("ammo_y_offset")
}

local feature_name = "ammo_indicator"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  [feature_name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 120 * ammo_scale, 30 * ammo_scale },
    position = {
      global_offset[1] + ammo_offset[1],
      global_offset[2] + ammo_offset[2],
      55
    }
  }
}

function feature.create_widget_definitions()
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "texture",
        value = "content/ui/materials/hud/icons/party_ammo",
        style_id = "ammo_icon",
        style = {
          size = { 20 * ammo_scale, 20 * ammo_scale },
          vertical_alignment = "center",
          horizontal_alignment = "right",
          color = UIHudSettings.color_tint_main_1,
          offset = { 0, 0, 1 }
        }
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/hud/icons/party_ammo",
        style_id = "ammo_icon_shadow",
        style = {
          text_style_id = "ammo_icon",
          size = { 20 * ammo_scale, 20 * ammo_scale },
          vertical_alignment = "center",
          horizontal_alignment = "right",
          color = UIHudSettings.color_tint_0,
          offset = { 2 * ammo_scale, 2 * ammo_scale, 0}
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("ammo")
        end
      },
      {
        pass_type = "text",
        value_id = "reserve_ammo",
        style_id = "reserve_ammo",
        style = {
          font_size = 18 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_1,
          offset = { -25 * ammo_scale, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value_id = "reserve_ammo",
        style_id = "reserve_ammo_shadow",
        style = {
          text_style_id = "reserve_ammo",
          font_size = 18 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_0,
          offset = { -23 * ammo_scale, 2 * ammo_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("ammo")
        end
      },
      {
        pass_type = "text",
        value_id = "clip_ammo",
        style_id = "clip_ammo",
        style = {
          font_size = 20 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_1,
          offset = { -55 * ammo_scale, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value_id = "clip_ammo",
        style_id = "clip_ammo_shadow",
        style = {
          text_style_id = "clip_ammo",
          font_size = 20 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_0,
          offset = { -53 * ammo_scale, 2 * ammo_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("ammo")
        end
      }
    }, feature_name)
  }
end

function feature.update(parent)
  local ammo_widget = parent._widgets_by_name[feature_name]
  if not ammo_widget then
    return
  end

  local content = ammo_widget.content
  local display_ammo_indicator = mod:get("display_ammo_indicator")
  content.visible = display_ammo_indicator

  if not display_ammo_indicator then
    return
  end

  local player_extensions = parent._parent:player_extensions()
  local unit_data_extension = player_extensions.unit_data
  local inventory_component = unit_data_extension:read_component("slot_secondary")

  if not inventory_component then
    content.visible = false
    return
  end

  -- Use Ammo utility functions
  local max_reserve = Ammo.max_ammo_in_reserve(inventory_component) or 0
  local current_reserve = Ammo.current_ammo_in_reserve(inventory_component) or 0
  local max_clip = Ammo.max_ammo_in_clips(inventory_component) or 0
  local current_clip = Ammo.current_ammo_in_clips(inventory_component) or 0

  local max_ammo = max_clip + max_reserve
  if max_ammo == 0 then
    content.visible = false
    return
  end

  local current_ammo = current_clip + current_reserve
  local current_ammo_percent = current_ammo / max_ammo
  local reserve_ammo_percent = max_reserve > 0 and (current_reserve / max_reserve) or 0
  local clip_ammo_percent = max_clip > 0 and (current_clip / max_clip) or 0

  content.clip_ammo = tostring(current_clip)
  content.reserve_ammo = string.format("%03d", current_reserve)

  local style = ammo_widget.style
  local icon_style = style.ammo_icon
  icon_style.color = mod_utils.get_text_color_for_percent_threshold(current_ammo_percent, "ammo")

  local clip_style = style.clip_ammo
  clip_style.text_color = mod_utils.get_text_color_for_percent_threshold(clip_ammo_percent, "ammo")

  local reserve_style = style.reserve_ammo
  reserve_style.text_color = mod_utils.get_text_color_for_percent_threshold(reserve_ammo_percent, "ammo")

  local show_ammo_icon = mod:get("show_ammo_icon")
  icon_style.visible = show_ammo_icon
end

return feature
