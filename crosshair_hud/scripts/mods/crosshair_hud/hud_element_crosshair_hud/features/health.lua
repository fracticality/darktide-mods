local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local health_scale = mod:get("health_scale") * global_scale
local health_gauge_scale = mod:get("independent_health_gauge_scaling") and (mod:get("health_gauge_scale") * global_scale) or health_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local health_offset = {
  mod:get("health_x_offset"),
  mod:get("health_y_offset")
}
local health_gauge_offset = {
  mod:get("health_gauge_x_offset"),
  mod:get("health_gauge_y_offset")
}

local permanent_health_offsets = {
  top = { 0, -20 * health_scale, 2 },
  bottom = { 0, 24 * health_scale, 2 },
}

local permanent_health_position = mod:get("permanent_health_position")
local permanent_health_offset = permanent_health_offsets[permanent_health_position]

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
  },
  [feature_name .. "_gauge"] = mod:get("independent_health_gauge") and {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 24 * health_gauge_scale, 56 * health_gauge_scale },
    position = {
      global_offset[1],
      global_offset[2],
      55
    }
  } or nil
}

function feature.create_widget_definitions()
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "text",
        style_id = "wounds_count",
        value_id = "wounds_count",
        value = "",
        style = {
          font_size = 18 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_main_1,
          offset = {
            -35 * health_scale,
            5 * health_scale,
            2
          }
        },
        visibility_function = function(content, style)
          return mod:get("display_wounds_count") and not mod:get("display_health_gauge")
        end
      },
      {
        pass_type = "text",
        style_id = "permanent_text_1",
        value_id = "permanent_text_1",
        value = "0",
        style = {
          font_size = 20 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_8,
          offset = {
            -14 * health_scale + permanent_health_offset[1],
            permanent_health_offset[2],
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "permanent_text_1_shadow",
        value_id = "permanent_text_1",
        value = "0",
        style = {
          text_style_id = "permanent_text_1",
          font_size = 20 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            -12 * health_scale + permanent_health_offset[1],
            2 * health_scale + permanent_health_offset[2],
            1
          }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
        end
      },
      {
        pass_type = "text",
        style_id = "permanent_text_2",
        value_id = "permanent_text_2",
        value = "0",
        style = {
          font_size = 20 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_8,
          offset = {
            permanent_health_offset[1],
            permanent_health_offset[2],
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "permanent_text_2_shadow",
        value_id = "permanent_text_2",
        value = "0",
        style = {
          text_style_id = "permanent_text_2",
          font_size = 20 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            2 * health_scale + permanent_health_offset[1],
            2 * health_scale + permanent_health_offset[2],
            1
          }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
        end
      },
      {
        pass_type = "text",
        style_id = "permanent_text_3",
        value_id = "permanent_text_3",
        value = "0",
        style = {
          font_size = 20 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_8,
          offset = {
            14 * health_scale + permanent_health_offset[1],
            permanent_health_offset[2],
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "permanent_text_3_shadow",
        value_id = "permanent_text_3",
        value = "0",
        style = {
          text_style_id = "permanent_text_3",
          font_size = 20 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            16 * health_scale + permanent_health_offset[1],
            2 * health_scale + permanent_health_offset[2],
            1
          }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
        end
      },
      {
        pass_type = "text",
        style_id = "permanent_text_symbol",
        value_id = "permanent_text_symbol",
        value = "%",
        style = {
          font_size = 16 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_8,
          offset = {
            30 * health_scale + permanent_health_offset[1],
            permanent_health_offset[2],
            2
          }
        }
      },
      {
        pass_type = "text",
        style_id = "permanent_text_symbol_shadow",
        value_id = "permanent_text_symbol",
        value = "%",
        style = {
          font_size = 16 * health_scale,
          text_vertical_alignment = "top",
          text_horizontal_alignment = "center",
          text_style_id = "permanent_text_symbol",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = {
            32 * health_scale + permanent_health_offset[1],
            2 * health_scale + permanent_health_offset[2],
            1
          }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
        end
      },
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
        },
      },
      {
        pass_type = "text",
        style_id = "text_1_shadow",
        value_id = "text_1",
        value = "0",
        style = {
          text_style_id = "text_1",
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
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
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
          text_style_id = "text_2",
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
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
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
          text_style_id = "text_3",
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
          return style.parent[style.text_style_id].visible and _shadows_enabled("health")
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

feature.segment_definition = UIWidget.create_definition({
  {
    pass_type = "texture_uv",
    value = "content/ui/materials/hud/crosshairs/charge_up",
    style_id = "background",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      uvs = mod:get("mirror_health_gauge") and {
        { 0, 0 },
        { 1, 1 }
      } or {
        { 1, 0 },
        { 0, 1 }
      },
      color = UIHudSettings.color_tint_main_1,
      size = { 24 * health_gauge_scale, 56 * health_gauge_scale },
      offset = { health_gauge_offset[1], 0, 1 }
    },
    visibility_function = function(content, style)
      return mod:get("display_health_gauge") and _shadows_enabled("health")
    end
  },
  {
    pass_type = "texture_uv",
    value = "content/ui/materials/hud/crosshairs/charge_up_mask",
    style_id = "health",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      uvs = mod:get("mirror_health_gauge") and {
        { 0, 0 },
        { 1, 1 }
      } or {
        { 1, 0 },
        { 0, 1 }
      },
      color = UIHudSettings.color_tint_main_2,
      size = { 24 * health_gauge_scale, 56 * health_gauge_scale },
      offset = { health_gauge_offset[1], 0, 2 }
    },
    visibility_function = function(content, style)
      return mod:get("display_health_gauge")
    end
  },
  {
    pass_type = "texture_uv",
    value = "content/ui/materials/hud/crosshairs/charge_up_mask",
    style_id = "permanent_damage",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      uvs = mod:get("mirror_health_gauge") and {
        { 0, 0 },
        { 1, 1 }
      } or {
        { 1, 0 },
        { 0, 1 }
      },
      color = UIHudSettings.color_tint_8,
      size = { 24 * health_gauge_scale, 56 * health_gauge_scale },
      offset = { health_gauge_offset[1], 0, 2 }
    },
    visibility_function = function(content, style)
      return mod:get("display_health_gauge") and content.permanent_damage and content.permanent_damage > 0
    end
  }
}, mod:get("independent_health_gauge") and (feature_name .. "_gauge") or feature_name)

local function update_gauge(parent, dt, t)
  local visible = mod:get("display_health_gauge")
  for i, segment_widget in ipairs(feature._health_segment_widgets or {}) do
    segment_widget.content.visible = visible
  end

  if not visible then
    return
  end

  local player_extensions = parent._parent:player_extensions()
  local health_extension = player_extensions.health
  local health_percent = health_extension:current_health_percent()
  local permanent_damage_taken_percent = health_extension:permanent_damage_taken_percent()
  local max_wounds = health_extension:max_wounds()
  local threshold_color = mod_utils.get_text_color_for_percent_threshold(health_percent, "health") or UIHudSettings.color_tint_main_2
  local permanent_color = mod:get("customize_permanent_health_color") and Color[mod:get("permanent_health_color")](255, true) or UIHudSettings.color_tint_8

  local spacing = 1 * health_gauge_scale
  local bar_height = 56 * health_gauge_scale
  local segment_height = (bar_height - (max_wounds - 1) * spacing) / max_wounds
  local y_offset = health_gauge_offset[2] + (bar_height * 0.5) - segment_height / 2

  if not feature._health_segment_widgets then

    local health_segment_widgets = {}
    for i = max_wounds, 1, -1 do
      local widget_name = string.format("segment_%s", i)
      local widget = parent:_create_widget(widget_name, feature.segment_definition)
      table.insert(parent._widgets, widget)
      table.insert(health_segment_widgets, widget)
    end

    feature._health_segment_widgets = health_segment_widgets
  end

  local step_fraction = 1 / max_wounds
  for i = 1, max_wounds, 1 do
    local widget = feature._health_segment_widgets[i]
    if not widget then
      local widget_name = string.format("segment_%s", i)
      widget = parent:_create_widget(widget_name, feature.segment_definition)
      table.insert(parent._widgets, widget)
      feature._health_segment_widgets[i] = widget
    end

    local health_fraction
    if health_percent then
      local end_value = i * step_fraction
      local start_value = end_value - step_fraction
      health_fraction = math.clamp((health_percent - start_value) / step_fraction, 0, 1)
    end

    local corruption_fraction
    if permanent_damage_taken_percent then
      local end_value = (max_wounds + 1 - i) * step_fraction
      local start_value = end_value - step_fraction
      corruption_fraction = math.clamp((math.floor(permanent_damage_taken_percent * 100) / 100 - start_value) / step_fraction, 0, 1)
    end

    local widget_style = widget.style
    widget_style.health.color = threshold_color
    widget_style.health.size[2] = health_fraction * segment_height
    widget_style.health.uvs[1][2] = (step_fraction * i) - ((1 - health_fraction) / max_wounds)
    widget_style.health.uvs[2][2] = (i - 1) * step_fraction
    widget_style.health.offset[2] = segment_height * (1 - health_fraction) * 0.5

    widget.content.permanent_damage = permanent_damage_taken_percent
    widget_style.permanent_damage.color = permanent_color
    widget_style.permanent_damage.size[2] = corruption_fraction * segment_height
    widget_style.permanent_damage.uvs[1][2] = (step_fraction * i)
    widget_style.permanent_damage.uvs[2][2] = (step_fraction * i) - corruption_fraction / max_wounds
    widget_style.permanent_damage.offset[2] = -(segment_height * (1 - corruption_fraction) * 0.5)

    widget_style.background.size[2] = segment_height
    widget_style.background.uvs[1][2] = (step_fraction * i)
    widget_style.background.uvs[2][2] = (i - 1) * step_fraction

    widget.offset[2] = y_offset
    y_offset = y_offset - (segment_height + spacing)
  end
end

function feature.update(parent, dt, t)
  local player_extensions = parent._parent:player_extensions()
  local health_widget = parent._widgets_by_name.health_indicator
  local health_extension = player_extensions.health
  local current_health = health_extension:current_health()
  local health_percent = health_extension:current_health_percent()
  local max_health = health_extension:max_health()
  local permanent_damage_taken = health_extension:permanent_damage_taken()
  local permanent_damage_taken_percent = health_extension:permanent_damage_taken_percent()

  if health_percent == 1 and mod:get("health_hide_at_full") then
    health_widget.content.visible = false

    for i, segment_widget in ipairs(feature._health_segment_widgets or {}) do
      segment_widget.content.visible = false
    end

    return
  end

  local health_always_show = mod:get("health_always_show")
  if health_always_show or current_health ~= parent.current_health then
    parent.current_health = current_health
    parent.health_visible_timer = mod:get("health_stay_time") or 1.5

    health_widget.content.visible = true

    local show_permanent_text = mod:get("display_permanent_health_text")
    local health_display_type = mod:get("health_display_type")
    local show_text = health_display_type ~= mod.options_display_type.hide

    local number_to_display = (health_display_type == mod.options_display_type.percent and (health_percent * 100)) or current_health
    local text_color = mod_utils.get_text_color_for_percent_threshold(health_percent, "health") or UIHudSettings.color_tint_main_2
    local permanent_color = mod:get("customize_permanent_health_color") and Color[mod:get("permanent_health_color")](255, true) or UIHudSettings.color_tint_8

    local permanent_number_to_display = (health_display_type == mod.options_display_type.percent and ((1 - permanent_damage_taken_percent) * 100)) or (max_health - permanent_damage_taken)
    local permanent_texts = mod_utils.convert_number_to_display_texts(math.floor(permanent_number_to_display), 3, nil, false, true)
    local texts = mod_utils.convert_number_to_display_texts(math.ceil(number_to_display), 3, nil, false, true)
    for i = 1, 3 do
      local key = string.format("text_%s", i)
      local permanent_key = string.format("permanent_%s", key)
      health_widget.content[key] = texts[i] or ""
      health_widget.style[key].text_color = text_color
      health_widget.style[key].visible = show_text

      health_widget.content[permanent_key] = permanent_texts[i] or ""
      health_widget.style[permanent_key].text_color = permanent_color
      health_widget.style[permanent_key].visible = show_text and show_permanent_text and permanent_damage_taken > 0
    end

    health_widget.style.text_symbol.visible = health_display_type == mod.options_display_type.percent
    health_widget.style.text_symbol.text_color = text_color
    health_widget.style.permanent_text_symbol.visible = health_display_type == mod.options_display_type.percent and permanent_damage_taken > 0

    local num_wounds = health_extension:num_wounds()

    health_widget.content.wounds_count = num_wounds
    health_widget.style.wounds_count.text_color = (num_wounds == 1 and UIHudSettings.color_tint_alert_2) or UIHudSettings.color_tint_main_1

    update_gauge(parent, dt, t)
  end

  if not health_always_show and parent.health_visible_timer then
    parent.health_visible_timer = parent.health_visible_timer - dt
    if parent.health_visible_timer <= 0 then
      parent.health_visible_timer = nil
      health_widget.content.visible = false

      for i, segment_widget in ipairs(feature._health_segment_widgets or {}) do
        segment_widget.content.visible = false
      end
    end
  end
end

return feature
