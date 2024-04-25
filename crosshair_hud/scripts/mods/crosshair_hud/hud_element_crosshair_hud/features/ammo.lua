local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

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
    size = { 52 * ammo_scale, 44 * ammo_scale },
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
          vertical_alignment = "bottom",
          horizontal_alignment = "left",
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
          vertical_alignment = "bottom",
          horizontal_alignment = "left",
          color = UIHudSettings.color_tint_0,
          offset = { 2 * ammo_scale, 2 * ammo_scale, 0}
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("ammo")
        end
      },
      {
        pass_type = "text",
        value = "000",
        value_id = "clip_ammo",
        style_id = "clip_ammo",
        style = {
          font_size = 30 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          text_color = UIHudSettings.color_tint_1,
          offset = { 10 * ammo_scale, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value = "000",
        value_id = "clip_ammo",
        style_id = "clip_ammo_shadow",
        style = {
          text_style_id = "clip_ammo",
          font_size = 30 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          text_color = UIHudSettings.color_tint_0,
          offset = { 12 * ammo_scale, 2 * ammo_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("ammo")
        end
      },
      {
        pass_type = "text",
        value = "0000",
        value_id = "reserve_ammo",
        style_id = "reserve_ammo",
        style = {
          font_size = 18 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "bottom",
          text_horizontal_alignment = "center",
          text_color = UIHudSettings.color_tint_1,
          offset = { 10 * ammo_scale, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value = "0000",
        value_id = "reserve_ammo",
        style_id = "reserve_ammo_shadow",
        style = {
          text_style_id = "reserve_ammo",
          font_size = 18 * ammo_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "bottom",
          text_horizontal_alignment = "center",
          text_color = UIHudSettings.color_tint_0,
          offset = { 12 * ammo_scale, 2 * ammo_scale, 1 }
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
    return
  end

  local clip_max = inventory_component.max_ammunition_clip or 0
  local reserve_max = inventory_component.max_ammunition_reserve or 0
  local max_ammo = clip_max + reserve_max

  if max_ammo == 0 then
    content.visible = false
    return
  end

  local clip_ammo = inventory_component.current_ammunition_clip or 0
  local reserve_ammo = inventory_component.current_ammunition_reserve or 0
  local current_ammo = clip_ammo + reserve_ammo
  local current_ammo_percent = 0
  local reserve_ammo_percent = 0
  local clip_ammo_percent = 0

  current_ammo_percent = current_ammo / max_ammo
  reserve_ammo_percent = reserve_ammo / reserve_max
  clip_ammo_percent = clip_ammo / clip_max

  content.max_ammo = max_ammo or 0
  content.current_ammo = current_ammo or 0
  content.reserve_ammo = reserve_ammo or 0
  content.clip_ammo = clip_ammo or 0

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
