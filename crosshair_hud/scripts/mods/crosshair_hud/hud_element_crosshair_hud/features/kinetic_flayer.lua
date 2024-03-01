local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local kinetic_flayer_scale = mod:get("kinetic_flayer_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local kinetic_flayer_offset = {
  mod:get("kinetic_flayer_x_offset"),
  mod:get("kinetic_flayer_y_offset")
}

local feature_name = "kinetic_flayer"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  [feature_name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = {
      40 * kinetic_flayer_scale,
      40 * kinetic_flayer_scale
    },
    position = {
      kinetic_flayer_offset[1] + global_offset[1],
      kinetic_flayer_offset[2] + global_offset[2],
      55
    }
  }
}

function feature.create_widget_definitions()
  local passes = {
    {
      pass_type = "text",
      value = "",
      value_id = "kinetic_flayer_cooldown",
      style_id = "kinetic_flayer_cooldown",
      style = {
        font_type = "machine_medium",
        font_size = 14 * kinetic_flayer_scale,
        text_vertical_alignment = "bottom",
        text_horizontal_alignment = "center",
        text_color = UIHudSettings.color_tint_main_1,
        offset = { -2 * kinetic_flayer_scale, 4, 5 }
      }
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/frames/talents/talent_icon_container",
      style_id = "kinetic_flayer_icon",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40 * kinetic_flayer_scale, 40 * kinetic_flayer_scale },
        color = { 255, 255, 255, 255 },
        offset = { 0, -8 * kinetic_flayer_scale, 3 },
        material_values = {
          icon = "content/ui/textures/icons/buffs/hud/psyker/psyker_2_tier_5_name_3",
          gradient_map = "content/ui/textures/color_ramps/talent_blitz",
          frame = "content/ui/textures/frames/talents/circular_frame",
          icon_mask = "content/ui/textures/frames/talents/circular_frame_mask"
        }
      },
    }
  }

  return {
    [feature_name] = UIWidget.create_definition(passes, feature_name),
  }
end

function feature.update(parent, dt, t)
  local widget = parent._widgets_by_name[feature_name]
  if not widget then
    return
  end

  local display_kinetic_flayer_indicator = mod:get("display_kinetic_flayer_indicator")
  local widget_content = widget.content

  widget_content.visible = display_kinetic_flayer_indicator
  if not display_kinetic_flayer_indicator then
    return
  end

  local widget_style = widget.style

  local ui_hud = parent._parent
  local player_extensions = ui_hud:player_extensions()
  local buff_extension = player_extensions.buff
  local buffs = buff_extension:buffs()
  local kinetic_flayer_is_on_cooldown = false
  local cooldown_remaining = 0
  local kinetic_flayer_cooldown = ""
  local has_kinetic_flayer = false

  for i = 1, #buffs do
    local buff = buffs[i]
    local buff_name = buff:template_name()
    if buff_name == "psyker_smite_on_hit" then
      local duration = 15
      local duration_progress = buff:duration_progress() or 0
      cooldown_remaining = duration - (duration * duration_progress)
      kinetic_flayer_cooldown = string.format(":%02d", cooldown_remaining)
      kinetic_flayer_is_on_cooldown = cooldown_remaining > 0
      has_kinetic_flayer = true

      break
    end
  end

  widget_content.kinetic_flayer_cooldown = kinetic_flayer_cooldown
  widget_style.kinetic_flayer_cooldown.visible = kinetic_flayer_is_on_cooldown
  widget_style.kinetic_flayer_icon.visible = has_kinetic_flayer

  local kinetic_flayer_icon_style = widget_style.kinetic_flayer_icon
  local material_values = kinetic_flayer_icon_style.material_values
  if material_values then
    material_values.saturation = not kinetic_flayer_is_on_cooldown and 1 or (1 - cooldown_remaining / 15)
  end
end

return feature
