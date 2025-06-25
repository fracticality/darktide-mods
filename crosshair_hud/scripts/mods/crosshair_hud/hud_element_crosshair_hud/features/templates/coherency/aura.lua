local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local Archetypes = require("scripts/settings/archetype/archetypes")
local UISettings = require("scripts/settings/ui/ui_settings")
local player_slot_colors = UISettings.player_slot_colors

local global_scale = mod:get("global_scale")
local coherency_scale = mod:get("coherency_scale") * global_scale

local template_name = "aura"
local template = {
  name = template_name
}

--template.scenegraph_overrides = {
--  size = {
--    76 * coherency_scale,
--    24 * coherency_scale
--  }
--}

function template.create_widget_definitions(feature_name)
  template.feature_name = feature_name
  return {
    [feature_name] = UIWidget.create_definition({
      {
        pass_type = "texture",
        value = "content/ui/materials/icons/buffs/hud/buff_frame",
        style_id = "frame_player_1",
        style = {
          buff_style_id = "player_1",
          horizontal_alignment = "left",
          vertical_alignment = "center",
          size = { 43 * coherency_scale, 43 * coherency_scale },
          offset = { -30 * coherency_scale, -2 * coherency_scale, 3 },
          color = UIHudSettings.color_tint_alert_2,
        },
        visibility_function = function(content, style)
          local parent = style.parent
          local buff_style_id = style.buff_style_id
          local buff_style = parent and parent[buff_style_id]

          return buff_style and buff_style.visible
        end
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/icons/buffs/hud/buff_frame",
        style_id = "frame_player_2",
        style = {
          buff_style_id = "player_2",
          horizontal_alignment = "center",
          vertical_alignment = "center",
          size = { 43 * coherency_scale, 43 * coherency_scale },
          offset = { 0, -2 * coherency_scale, 3 },
          color = UIHudSettings.color_tint_alert_2,
        },
        visibility_function = function(content, style)
          local parent = style.parent
          local buff_style_id = style.buff_style_id
          local buff_style = parent and parent[buff_style_id]

          return buff_style and buff_style.visible
        end
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/icons/buffs/hud/buff_frame",
        style_id = "frame_player_3",
        style = {
          buff_style_id = "player_3",
          horizontal_alignment = "right",
          vertical_alignment = "center",
          size = { 43 * coherency_scale, 43 * coherency_scale },
          offset = { 30 * coherency_scale, -2 * coherency_scale, 3 },
          color = UIHudSettings.color_tint_alert_2,
        },
        visibility_function = function(content, style)
          local parent = style.parent
          local buff_style_id = style.buff_style_id
          local buff_style = parent and parent[buff_style_id]

          return buff_style and buff_style.visible
        end
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
        style_id = "player_1",
        style = {
          horizontal_alignment = "left",
          vertical_alignment = "center",
          size = { 28 * coherency_scale, 28 * coherency_scale },
          offset = { -22 * coherency_scale, -2 * coherency_scale, 2 },
          color = { 255, 255, 255, 255 },
          material_values = {
            gradient_map = "content/ui/textures/color_ramps/talent_aura",
          }
        },
        visibility_function = function(content, style)
          return style.material_values.talent_icon ~= nil
        end
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
        style_id = "player_2",
        style = {
          horizontal_alignment = "center",
          vertical_alignment = "center",
          size = { 28 * coherency_scale, 28 * coherency_scale },
          offset = { 0, -2 * coherency_scale, 2 },
          color = { 255, 255, 255, 255 },
          material_values = {
            gradient_map = "content/ui/textures/color_ramps/talent_aura",
          }
        },
        visibility_function = function(content, style)
          return style.material_values.talent_icon ~= nil
        end
      },
      {
        pass_type = "texture",
        value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
        style_id = "player_3",
        style = {
          horizontal_alignment = "right",
          vertical_alignment = "center",
          size = { 28 * coherency_scale, 28 * coherency_scale },
          offset = { 22 * coherency_scale, -2 * coherency_scale, 2 },
          color = { 255, 255, 255, 255 },
          material_values = {
            gradient_map = "content/ui/textures/color_ramps/talent_aura",
          }
        },
        visibility_function = function(content, style)
          return style.material_values.talent_icon ~= nil
        end
      },
    }, feature_name)
  }
end

local _coherency_talents = {}
local _aura_icon_by_talent_name = {}
local _talent_icons_by_player = {}

for archetype_name, archetype in pairs(Archetypes) do
  local talent_names = {}

  local talent_tree = require(archetype.talent_layout_file_path)

  for i, talent_node in ipairs(talent_tree.nodes) do
    local node_type = talent_node.type

    if node_type == "aura" then
      local talent_name = talent_node.talent
      local talent_icon = talent_node.icon

      _aura_icon_by_talent_name[talent_name] = talent_icon
      table.insert(talent_names, talent_name)
    end
  end

  for talent_name in pairs(archetype.base_talents) do
    if string.find(talent_name, "aura") or string.find(talent_name, "coherency") then
      table.insert(talent_names, talent_name)

      break
    end
  end

  _coherency_talents[archetype_name] = talent_names

end

local function _get_talent_icon(profile)
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_talents = archetype.talents
  local talents = profile.talents
  local aura_talent_names = _coherency_talents[archetype_name]

  if not aura_talent_names then
    return
  end

  for i, talent_name in ipairs(aura_talent_names) do
    if talents[talent_name] then

      local icon = _aura_icon_by_talent_name[talent_name]

      if not icon then
        local archetype_talent = archetype_talents[talent_name]

        icon = archetype_talent.medium_icon or archetype_talent.icon
        _aura_icon_by_talent_name[talent_name] = icon
      end

      return icon
    end
  end
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
      local material_values = style.material_values
      if material_values then
        local talent_icons_by_player = _talent_icons_by_player
        local talent_icon_by_player = talent_icons_by_player[player]
        if not talent_icon_by_player then
          talent_icon_by_player = _get_talent_icon(profile)
          talent_icons_by_player[player] = talent_icon_by_player
        end

        material_values.talent_icon = talent_icon_by_player
        style.visible = true
      end

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
