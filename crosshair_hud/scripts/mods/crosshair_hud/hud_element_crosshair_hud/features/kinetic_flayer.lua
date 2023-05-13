local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local kinetic_flayer_scale = mod:get("kinetic_flayer_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local kinetic_flayer_offset = {
  mod:get("kinetic_flayer_x_offset") + global_offset[1],
  mod:get("kinetic_flayer_y_offset") + global_offset[2]
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
      kinetic_flayer_offset[1],
      kinetic_flayer_offset[2],
      55
    }
  }
}

function feature.create_widget_definitions(parent)
  local ui_hud = parent._parent
  local hud_player = ui_hud and ui_hud:player()
  local profile = hud_player and hud_player:profile()
  local archetype = profile and profile.archetype
  local archetype_name = archetype and archetype.name

  local widgets_by_name = parent._widgets_by_name
  local widget = widgets_by_name and widgets_by_name[feature_name]
  if widget then
    UIWidget.destroy(ui_hud:ui_renderer(), widget)
  end

  if not (archetype_name and archetype_name == "psyker") or not profile.talents.psyker_2_tier_5_name_3 then
    return
  end

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
        offset = { -2 * kinetic_flayer_scale, 0, 5 }
      }
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/talents/talent_icon_container",
      style_id = "kinetic_flayer_icon",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40 * kinetic_flayer_scale, 40 * kinetic_flayer_scale },
        color = { 255, 255, 255, 255 },
        offset = { 0, -8 * kinetic_flayer_scale, 3 },
        material_values = {
          icon_texture = "content/ui/textures/icons/talents/psyker_2/psyker_2_tier_2_1",
        }
      },
    },
    {
      value = "content/ui/vector_textures/hud/circle_full",
      pass_type = "slug_icon",
      style_id = "kinetic_flayer_icon_frame",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 28 * kinetic_flayer_scale, 28 * kinetic_flayer_scale },
        color = Color.steel_blue(255, true),
        offset = { 0, -8 * kinetic_flayer_scale, 4 },
      }
    }
  }

  return {
    [feature_name] = UIWidget.create_definition(passes, feature_name),
  }
end

function feature.update(parent, dt, t)
  local widget = parent._widgets_by_name[feature_name]
  local widget_content = widget.content
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
    if buff_name == "psyker_biomancer_smite_on_hit" then
      local template_data = buff._template_data
      if template_data then
        local next_allowed_t = template_data.next_allowed_t or 0
        local template_data_t = template_data.t or 0
        cooldown_remaining = math.max(next_allowed_t - template_data_t, 0)
        kinetic_flayer_cooldown = string.format(":%02d", cooldown_remaining)
        kinetic_flayer_is_on_cooldown = cooldown_remaining > 0
        has_kinetic_flayer = true

        break
      end
    end
  end

  widget_content.kinetic_flayer_cooldown = kinetic_flayer_cooldown
  widget_style.kinetic_flayer_cooldown.visible = kinetic_flayer_is_on_cooldown
  widget_style.kinetic_flayer_icon.visible = has_kinetic_flayer
  widget_style.kinetic_flayer_icon_frame.visible = has_kinetic_flayer


  local kinetic_flayer_icon_style = widget_style.kinetic_flayer_icon
  local material_values = kinetic_flayer_icon_style.material_values
  if material_values then
    material_values.saturation = not kinetic_flayer_is_on_cooldown and 1 or (1 - cooldown_remaining / 15)
  end
end

return feature
