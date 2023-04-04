local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local WarpCharge = mod:original_require("scripts/utilities/warp_charge")
local ArchetypeWarpChargeTemplates = mod:original_require("scripts/settings/warp_charge/archetype_warp_charge_templates")

local global_scale = mod:get("global_scale")
local peril_scale = mod:get("peril_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local peril_offset = {
  mod:get("peril_x_offset"),
  mod:get("peril_y_offset")
}

local template = {
  name = "peril_indicator"
}

template.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  [template.name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48 * peril_scale, 20 * peril_scale },
    position = {
      global_offset[1] + peril_offset[1],
      peril_offset[2] + peril_offset[2],
      55
    }
  }
}

function template.create_widget_definitions()
  return {
    [template.name] = UIWidget.create_definition({
      {
        pass_type = "text",
        value = "",
        value_id = "symbol_text",
        style_id = "symbol_text",
        style = {
          font_size = 20 * peril_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_1,
          offset = { 0, 0, 1 }
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "symbol_text",
        style_id = "symbol_text_shadow",
        style = {
          font_size = 20 * peril_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "left",
          text_color = UIHudSettings.color_tint_0,
          offset = { 2 * peril_scale, 2 * peril_scale, 0 }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("peril")
        end
      },
      {
        pass_type = "text",
        value = "",
        value_id = "value_text",
        style_id = "value_text",
        style = {
          font_size = 20 * peril_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_1,
          offset = { 0, 0, 1 },
        }
      },
      {
        pass_type = "text",
        value = "",
        value_id = "value_text",
        style_id = "value_text_shadow",
        style = {
          font_size = 20 * peril_scale,
          font_type = "machine_medium",
          text_vertical_alignment = "center",
          text_horizontal_alignment = "right",
          text_color = UIHudSettings.color_tint_0,
          offset = { 2 * peril_scale, 2 * peril_scale, 0 }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("peril")
        end
      }
    }, template.name)
  }
end

function template.update(parent)
  local peril_widget = parent._widgets_by_name.peril_indicator
  if not peril_widget then
    return
  end

  local display_peril_indicator = mod:get("display_peril_indicator")
  local content = peril_widget.content
  local style = peril_widget.style

  content.visible = display_peril_indicator

  if not display_peril_indicator then
    return
  end

  content.visible = false

  local player_extensions = parent._parent:player_extensions()
  local unit_data_extension = player_extensions.unit_data
  local weapon_extension = player_extensions.weapon
  local weapon_template = weapon_extension and weapon_extension:weapon_template()
  if weapon_template and weapon_template.uses_overheat then
    local weapon_component = unit_data_extension:read_component("slot_secondary")
    local overheat_current_percentage = weapon_component and weapon_component.overheat_current_percentage or 0

    content.symbol_text = ""
    content.value_text = string.format("%.0f", overheat_current_percentage * 100)
    content.visible = true
    local text_color = mod_utils.get_text_color_for_percent_threshold((1 - overheat_current_percentage), "peril")
    style.value_text.text_color = text_color
    style.symbol_text.text_color = text_color

    return
  end

  local player = parent._parent:player()
  local specialization_warp_charge_template = WarpCharge.specialization_warp_charge_template(player)

  if specialization_warp_charge_template == ArchetypeWarpChargeTemplates.psyker then
    local warp_charge_component = unit_data_extension and unit_data_extension:read_component("warp_charge")
    local current_percentage = warp_charge_component and warp_charge_component.current_percentage or 0

    content.symbol_text = ""
    content.value_text = string.format("%.0f", current_percentage * 100)
    content.visible = true
    local text_color = mod_utils.get_text_color_for_percent_threshold((1 - current_percentage), "peril")
    style.value_text.text_color = text_color
    style.symbol_text.text_color = text_color

    return
  end
end

return template
