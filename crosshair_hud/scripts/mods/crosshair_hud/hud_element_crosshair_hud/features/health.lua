local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local health_scale = mod:get("health_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local health_offset = {
  mod:get("health_x_offset"),
  mod:get("health_y_offset")
}

local feature_name = "health_indicator"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  [feature_name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48 * health_scale, 24 * health_scale },
    position = {
      global_offset[1] + health_offset[1],
      global_offset[2] + health_offset[2],
      55
    }
  }
}

function feature.create_widget_definitions()
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "text",
        style_id = "text_1",
        value_id = "text_1",
        value = "0",
        style = {
          font_size = 24 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_main_2,
          offset = {
            -14 * health_scale,
            2 * health_scale,
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "text_1_shadow",
        value_id = "text_1",
        value = "0",
        style = {
          font_size = 24 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            -12 * health_scale,
            4 * health_scale,
            1
          }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("health")
        end
      },
      {
        pass_type = "text",
        style_id = "text_2",
        value_id = "text_2",
        value = "0",
        style = {
          font_size = 24 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_main_2,
          offset = {
            0,
            2 * health_scale,
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "text_2_shadow",
        value_id = "text_2",
        value = "0",
        style = {
          font_size = 24 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            2 * health_scale,
            4 * health_scale,
            1
          }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("health")
        end
      },
      {
        pass_type = "text",
        style_id = "text_3",
        value_id = "text_3",
        value = "0",
        style = {
          font_size = 24 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_main_2,
          offset = {
            14 * health_scale,
            2 * health_scale,
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "text_3_shadow",
        value_id = "text_3",
        value = "0",
        style = {
          font_size = 24 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            16 * health_scale,
            4 * health_scale,
            1
          }
        },
        visibility_function = function(content, style)
          return _shadows_enabled("health")
        end
      },
      {
        pass_type = "text",
        style_id = "text_symbol",
        value_id = "text_symbol",
        value = "%",
        style = {
          font_size = 16 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_main_2,
          offset = { 30 * health_scale, 2 * health_scale, 2 }
        }
      },
      {
        pass_type = "text",
        style_id = "text_symbol_shadow",
        value_id = "text_symbol",
        value = "%",
        style = {
          text_style_id = "text_symbol",
          font_size = 16 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            32 * health_scale,
            4 * health_scale,
            1
          }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
        end
      },
    }, feature_name)
  }
end

function feature.update(parent, dt, t)
  local player_extensions = parent._parent:player_extensions()
  local health_widget = parent._widgets_by_name.health_indicator
  local health_extension = player_extensions.health
  local current_health = health_extension:current_health()
  local health_percent = health_extension:current_health_percent()

  if health_percent == 1 and mod:get("health_hide_at_full") then
    health_widget.content.visible = false
    return
  end

  local health_always_show = mod:get("health_always_show")
  if health_always_show or current_health ~= parent.current_health then
    parent.current_health = current_health
    parent.health_visible_timer = mod:get("health_stay_time") or 1.5

    health_widget.content.visible = true

    local health_display_type = mod:get("health_display_type")
    local number_to_display = (health_display_type == mod.options_display_type.percent and (health_percent * 100)) or current_health
    local text_color = mod_utils.get_text_color_for_percent_threshold(health_percent, "health") or UIHudSettings.color_tint_main_2

    local texts = mod_utils.convert_number_to_display_texts(math.ceil(number_to_display), 3, nil, false, true)
    for i = 1, 3 do
      local key = string.format("text_%s", i)
      health_widget.content[key] = texts[i] or ""
      health_widget.style[key].text_color = text_color
    end
    health_widget.style.text_symbol.visible = health_display_type == mod.options_display_type.percent
    health_widget.style.text_symbol.text_color = text_color
    health_widget.dirty = true
  end

  if not health_always_show and parent.health_visible_timer then
    parent.health_visible_timer = parent.health_visible_timer - dt
    if parent.health_visible_timer <= 0 then
      parent.health_visible_timer = nil
      health_widget.content.visible = false
    end
  end
end

return feature
