local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local grenade_scale = mod:get("grenade_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local grenade_offset = {
  mod:get("grenade_x_offset"),
  mod:get("grenade_y_offset")
}

local feature_name = "grenade_indicator"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  [feature_name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 40 * grenade_scale, 20 * grenade_scale },
    position = {
      global_offset[1] + grenade_offset[1],
      global_offset[1] + grenade_offset[2],
      55
    }
  }
}

function feature.create_widget_definitions()
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "texture",
        value_id = "grenade_icon",
        value = "content/ui/materials/hud/icons/party_throwable",
        style_id = "grenade_icon",
        style = {
          size = { 20 * grenade_scale, 20 * grenade_scale },
          vertical_alignment = "center",
          horizontal_alignment = "left",
          color = UIHudSettings.color_tint_main_1,
          offset = { 0, 0, 1 }
        },
        visibility_function = function(content, style)
          return mod:get("display_grenade_icon")
        end
      },
      {
        pass_type = "texture",
        value_id = "grenade_icon",
        value = "content/ui/materials/hud/icons/party_throwable",
        style_id = "grenade_icon_shadow",
        style = {
          size = { 20 * grenade_scale, 20 * grenade_scale },
          vertical_alignment = "center",
          horizontal_alignment = "left",
          color = UIHudSettings.color_tint_0,
          offset = { 2 * grenade_scale, 2 * grenade_scale, 0 }
        },
        visibility_function = function(content, style)
          return mod:get("display_grenade_icon") and _shadows_enabled("grenade")
        end
      },
      {
        pass_type = "text",
        value = "0",
        value_id = "grenade_count",
        style_id = "grenade_count",
        style = {
          font_size = 20 * grenade_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_1,
          offset = { 0, 0, 2 }
        }
      },
      {
        pass_type = "text",
        value = "0",
        value_id = "grenade_count",
        style_id = "grenade_count_shadow",
        style = {
          text_style_id = "grenade_count",
          font_size = 20 * grenade_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_0,
          offset = { 2 * grenade_scale, 2 * grenade_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("grenade")
        end
      },
    }, feature_name)
  }
end

function feature.update(parent)
  local grenade_widget = parent._widgets_by_name.grenade_indicator
  if not grenade_widget then
    return
  end

  local content = grenade_widget.content
  local display_grenade_indicator = mod:get("display_grenade_indicator")

  content.visible = display_grenade_indicator

  if not display_grenade_indicator then
    return
  end

  local player_extensions = parent._parent:player_extensions()
  local ability_extension = player_extensions.ability

  if not (ability_extension and ability_extension:ability_is_equipped("grenade_ability")) then
    return
  end

  local ui_hud = parent._parent
  local hud_player = ui_hud:player()
  local profile = hud_player:profile()
  local talents = profile.talents
  local ogryn_frag_grenade = talents.ogryn_grenade_frag

  local remaining_ability_charges = ability_extension:remaining_ability_charges("grenade_ability")
  local max_ability_charges = ability_extension:max_ability_charges("grenade_ability")
  local ability_charges_percent = remaining_ability_charges / max_ability_charges
  local style = grenade_widget.style
  
  if (max_ability_charges == 1 and not ogryn_frag_grenade) or max_ability_charges == 0 then
    content.visible = false
    return
  end

  content.grenade_count = remaining_ability_charges

  local color = mod_utils.get_text_color_for_percent_threshold(ability_charges_percent, "grenade")
  style.grenade_icon.visible = true
  style.grenade_icon.color = color
  style.grenade_count.text_color = color
end

return feature
