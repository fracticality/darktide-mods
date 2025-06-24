local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UISettings = require("scripts/settings/ui/ui_settings")
local player_slot_colors = UISettings.player_slot_colors

local global_scale = mod:get("global_scale")
local coherency_scale = mod:get("coherency_scale") * global_scale

local template_name = "archetype"
local template = {
  name = template_name
}

template.scenegraph_overrides = {
  size = {
    76 * coherency_scale,
    24 * coherency_scale
  }
}

function template.create_widget_definitions(feature_name)
  template.feature_name = feature_name
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "text",
        style_id = "player_1",
        value_id = "player_1",
        value = "+",
        style = {
          font_size = 24 * coherency_scale,
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_6,
          offset = { -26 * coherency_scale, 2 * coherency_scale, 2 }
        }
      },
      {
        pass_type = "text",
        style_id = "player_1_shadow",
        value_id = "player_1",
        value = "+",
        style = {
          text_style_id = "player_1",
          font_size = 24 * coherency_scale,
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = { -24 * coherency_scale, 4 * coherency_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("coherency")
        end
      },
      {
        pass_type = "text",
        style_id = "player_2",
        value_id = "player_2",
        value = "+",
        style = {
          font_size = 24 * coherency_scale,
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_6,
          offset = { 0, 2, 2 }
        }
      },
      {
        pass_type = "text",
        style_id = "player_2_shadow",
        value_id = "player_2",
        value = "+",
        style = {
          text_style_id = "player_2",
          font_size = 24 * coherency_scale,
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = { 2 * coherency_scale, 4 * coherency_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("coherency")
        end
      },
      {
        pass_type = "text",
        style_id = "player_3",
        value_id = "player_3",
        value = "+",
        style = {
          font_size = 24 * coherency_scale,
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",
          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_6,
          offset = { 26 * coherency_scale, 2 * coherency_scale, 2 }
        }
      },
      {
        pass_type = "text",
        style_id = "player_3_shadow",
        value_id = "player_3",
        value = "+",
        style = {
          text_style_id = "player_3",
          font_size = 24 * coherency_scale,
          text_horizontal_alignment = "center",
          text_vertical_alignment = "center",

          font_type = "machine_medium",
          text_color = UIHudSettings.color_tint_0,
          offset = { 28 * coherency_scale, 4 * coherency_scale, 1 }
        },
        visibility_function = function(content, style)
          return style.parent[style.text_style_id].visible and _shadows_enabled("coherency")
        end
      },
    }, feature_name)
  }
end

function template.update(parent, dt, t)
  local feature_name = template.feature_name
  local widget = parent._widgets_by_name[feature_name]
  local widget_content = widget.content
  local widget_style = widget.style

  local ui_hud = parent._parent
  local hud_player = ui_hud:player()
  local player_extensions = ui_hud:player_extensions()
  local coherency_extension = player_extensions.coherency
  local units_in_coherency = coherency_extension:in_coherence_units()

  widget_content.visible = true

  local coherency_color_type = mod:get("coherency_colors")
  local color_by_teammate = coherency_color_type == "player_color"
  local color_by_health = coherency_color_type == "player_health"
  local color_by_toughness = coherency_color_type == "player_toughness"
  local color_static = coherency_color_type == "static_color"

  local i = 1
  for unit in pairs(units_in_coherency) do
    if i > 3 then -- Extra bot bug (or bot spawns in Psykhanium)
      break
    end
    local player = Managers.player:player_by_unit(unit)

    repeat
      if player == hud_player or not player then
        break
      end

      local id = string.format("player_%s", i)
      local profile = player:profile()
      local color = UIHudSettings.color_tint_1

      if color_by_teammate then
        local player_slot = player.slot and player:slot()
        color = player_slot_colors[player_slot] or color

      elseif color_by_health then
        local health_extension = ScriptUnit.has_extension(unit, "health_system")
        if health_extension then
          local health_percent = health_extension:current_health_percent()
          color = mod_utils.get_text_color_for_percent_threshold(health_percent, "health")
        end

      elseif color_by_toughness then
        local toughness_extension = ScriptUnit.has_extension(unit, "toughness_system")
        if toughness_extension then
          local toughness_percent = toughness_extension:current_toughness_percent()
          color = mod_utils.get_text_color_for_percent_threshold(toughness_percent, "toughness")
        end

      elseif color_static then
        color = Color[mod:get("coherency_color_static_color")](255, true)
      end

      local frame_id = string.format("frame_%s", id)
      local frame_style = widget_style[frame_id]
      if frame_style then
        frame_style.color = color
      end

      local style = widget_style[id]
      local archetype_name = profile.archetype and profile.archetype.name
      local text = archetype_name and UISettings.archetype_font_icon_simple[archetype_name] or "•"
      widget_content[id] = text

      style.text_color = color
      style.visible = true

      i = i + 1
    until true
  end

  for j = i, 3 do
    local style_id = string.format("player_%s", j)
    local style = widget_style[style_id]
    style.visible = false
  end
end

return template
