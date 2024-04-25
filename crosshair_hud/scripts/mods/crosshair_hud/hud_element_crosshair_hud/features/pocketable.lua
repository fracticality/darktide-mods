local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local pocketable_scale = mod:get("pocketable_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local pocketable_offset = {
  mod:get("pocketable_x_offset"),
  mod:get("pocketable_y_offset")
}

local feature_name = "pocketable_indicator"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  [feature_name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 20 * pocketable_scale, 20 * pocketable_scale },
    position = {
      global_offset[1] + pocketable_offset[1],
      global_offset[2] + pocketable_offset[2],
      55
    }
  },
}

function feature.create_widget_definitions()
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "texture",
        value_id = "pocketable_icon",
        style_id = "pocketable_icon",
        style = {
          size = { 20 * pocketable_scale, 20 * pocketable_scale },
          vertical_alignment = "center",
          horizontal_alignment = "center",
          color = UIHudSettings.color_tint_main_1,
          offset = { 0, 0, 1 },
        },
        visibility_function = function(content, style)
          return content.pocketable_icon
        end
      },
      {
        pass_type = "texture",
        value_id = "pocketable_icon",
        style_id = "pocketable_icon_shadow",
        style = {
          size = { 20 * pocketable_scale, 20 * pocketable_scale },
          vertical_alignment = "center",
          horizontal_alignment = "center",
          color = UIHudSettings.color_tint_0,
          offset = { 2 * pocketable_scale, 2 * pocketable_scale, 0 },
        },
        visibility_function = function(content, style)
          return content.pocketable_icon and _shadows_enabled("pocketable")
        end
      },
    }, feature_name)
  }
end

function feature.update(parent)
  local pocketable_widget = parent._widgets_by_name[feature_name]
  if not pocketable_widget then
    return
  end

  local display_pocketable_indicator = mod:get("display_pocketable_indicator")
  local content = pocketable_widget.content

  content.visible = display_pocketable_indicator

  if not display_pocketable_indicator then
    return
  end

  local player_extensions = parent._parent:player_extensions()
  local visual_loadout_extension = player_extensions.visual_loadout
  local weapon_template = visual_loadout_extension:weapon_template_from_slot("slot_pocketable")

  content.pocketable_icon = weapon_template and weapon_template.hud_icon_small
end

return feature
