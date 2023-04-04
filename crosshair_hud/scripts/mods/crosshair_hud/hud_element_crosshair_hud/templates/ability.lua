local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local ability_scale = mod:get("ability_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local ability_offset = {
  mod:get("ability_x_offset"),
  mod:get("ability_y_offset")
}

local template = {
  name = "ability_indicator"
}

template.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  [template.name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = {
      48 * ability_scale,
      28 * ability_scale
    },
    position = {
      global_offset[1] + ability_offset[1],
      global_offset[2] + ability_offset[2],
      55
    }
  }
}

function template.create_widget_definitions()
  return {
    [template.name] = UIWidget.create_definition({
      {
        pass_type = "rotated_texture",
        value_id = "symbol",
        value = "",
        style_id = "symbol",
        style = {
          pivot = { 10 * ability_scale, 10 * ability_scale },
          angle = math.pi,
          horizontal_alignment = "center",
          vertical_alignment = "center",
          size = { 20 * ability_scale, 20 * ability_scale },
          color = { 255, 255, 255, 255 },
          offset = { 0, 0, 2 }
        },
        visibility_function = function(content, style)
          return content.symbol ~= ""
        end
      },
      {
        pass_type = "rotated_rect",
        style_id = "rect",
        style = {
          horizontal_alignment = "center",
          vertical_alignment = "center",
          size = { 20 * ability_scale, 20 * ability_scale },
          pivot = { 10 * ability_scale, 10 * ability_scale },
          angle = math.pi / 4,
          color = UIHudSettings.color_tint_0,
          offset = { 0, 0, 1 }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("ability")
        end
      },
      {
        pass_type = "text",
        value_id = "charge_count",
        value = "",
        style_id = "charge_count",
        style = {
          font_size = 14 * ability_scale,
          font_type = "machine_medium",
          text_horizontal_alignment = "right",
          text_vertical_alignment = "bottom",
          text_color = UIHudSettings.color_tint_1,
          offset = { -5 * ability_scale, 4 * ability_scale, 2 }
        }
      },
      {
        pass_type = "text",
        value_id = "charge_count",
        value = "",
        style_id = "charge_count_shadow",
        style = {
          font_size = 14 * ability_scale,
          font_type = "machine_medium",
          text_horizontal_alignment = "right",
          text_vertical_alignment = "bottom",
          text_color = UIHudSettings.color_tint_0,
          offset = { -3 * ability_scale, 6 * ability_scale, 1 }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("ability")
        end
      },
      {
        pass_type = "text",
        value_id = "cooldown_text",
        value = "",
        style_id = "cooldown_text",
        style = {
          font_size = 14 * ability_scale,
          font_type = "machine_medium",
          text_horizontal_alignment = "left",
          text_vertical_alignment = "bottom",
          text_color = UIHudSettings.color_tint_1,
          offset = { -5 * ability_scale, 4 * ability_scale, 2 }
        },
        visibility_function = function(content, style)
          local ability_cooldown_threshold = mod:get("ability_cooldown_threshold")
          if not content.cooldown or not ability_cooldown_threshold then
            return
          end

          return content.cooldown > 0 and content.cooldown <= ability_cooldown_threshold + 1
        end
      },
      {
        pass_type = "text",
        value_id = "cooldown_text",
        value = "",
        style_id = "cooldown_enable_shadows",
        style = {
          text_style_id = "cooldown_text",
          font_size = 14 * ability_scale,
          font_type = "machine_medium",
          text_horizontal_alignment = "left",
          text_vertical_alignment = "bottom",
          text_color = UIHudSettings.color_tint_0,
          offset = { -3 * ability_scale, 6 * ability_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("ability")
        end
      }
    }, template.name)
  }
end

local function _get_cooldown_symbol_for_percent_threshold(percent, remaining_ability_charges)
  if percent == 1 then
    return "content/ui/materials/icons/perks/perk_level_05"
  elseif percent >= 0.80 then
    return "content/ui/materials/icons/perks/perk_level_04"
  elseif percent >= 0.60 then
    return "content/ui/materials/icons/perks/perk_level_03"
  elseif percent >= 0.40 then
    return "content/ui/materials/icons/perks/perk_level_02"
  elseif percent >= 0.20 then
    return "content/ui/materials/icons/perks/perk_level_01"
  end

  if remaining_ability_charges > 0 then
    return "content/ui/materials/icons/perks/perk_level_05"
  end

  return "content/ui/materials/icons/perks/perk_level_01"
end

function template.update(parent)
  local ability_widget = parent._widgets_by_name.ability_indicator

  if not mod:get("display_ability_cooldown") then
    ability_widget.content.visible = false
    return
  end

  local player_extensions = parent._parent:player_extensions()
  local ability_extension = player_extensions.ability

  if not (ability_extension and ability_extension:ability_is_equipped("combat_ability")) then
    return
  end

  local max_ability_cooldown = ability_extension:max_ability_cooldown("combat_ability")
  local max_ability_charges = ability_extension:max_ability_charges("combat_ability")
  local remaining_ability_charges = ability_extension:remaining_ability_charges("combat_ability")
  local missing_ability_charges = ability_extension:missing_ability_charges("combat_ability")
  local remaining_ability_cooldown = ability_extension:remaining_ability_cooldown("combat_ability")
  local cooldown_percent = 1 - (remaining_ability_cooldown / max_ability_cooldown)
  local symbol = _get_cooldown_symbol_for_percent_threshold(cooldown_percent, remaining_ability_charges)
  local content = ability_widget.content
  local style = ability_widget.style
  --local color = (missing_ability_charges == 0 and { 255, 255, 150, 0 }) or (remaining_ability_charges == 0 and UIHudSettings.color_tint_alert_2) or UIHudSettings.color_tint_1
  local color = mod_utils.get_text_color_for_percent_threshold(cooldown_percent, "ability")

  --- Full: { 255, 255, 150, 0 }

  content.symbol = symbol
  content.charge_count = (max_ability_charges > 1 and remaining_ability_charges) or ""
  content.cooldown = remaining_ability_cooldown

  local cooldown_display_texts = mod_utils.convert_number_to_display_texts(math.floor(remaining_ability_cooldown), 1, nil, false, true)
  local cooldown_text = table.concat(cooldown_display_texts)
  content.cooldown_text = string.format(":%s", cooldown_text)

  style.symbol.color = color
  style.charge_count.text_color = color
end

return template