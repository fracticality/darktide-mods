local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils

local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local ArchetypeTalents = mod:original_require("scripts/settings/ability/archetype_talents/archetype_talents")
local UISettings = mod:original_require("scripts/settings/ui/ui_settings")
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
          material_values = {}
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
          material_values = {}
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
          material_values = {}
        },
        visibility_function = function(content, style)
          return style.material_values.talent_icon ~= nil
        end
      },
    }, feature_name)
  }
end

local _coherency_talents = {
  psyker_2 = {
    base = "psyker_2_base_3",
    improved = "psyker_2_tier_3_name_2"
  },
  ogryn_2 = {
    base = "ogryn_2_base_4",
    improved = "ogryn_2_tier_3_name_2"
  },
  veteran_2 = {
    base = "veteran_2_base_3",
    improved = "veteran_2_tier_3_name_2"
  },
  zealot_2 = {
    base = "zealot_2_base_3",
    improved = "zealot_2_tier_3_name_2"
  }
}

local _psyker_talents = ArchetypeTalents.psyker
local _ogryn_talents = ArchetypeTalents.ogryn
local _veteran_talents = ArchetypeTalents.veteran
local _zealot_talents = ArchetypeTalents.zealot

local _talent_by_name = {
  psyker_2_tier_3_name_2 = _psyker_talents.psyker_2.psyker_2_tier_3_name_2,
  psyker_2_base_3 = _psyker_talents.psyker_2.psyker_2_base_3,

  veteran_2_tier_3_name_2 = _veteran_talents.veteran_2.veteran_2_tier_3_name_2,
  veteran_2_base_3 = _veteran_talents.veteran_2.veteran_2_base_3,

  ogryn_2_base_4 = _ogryn_talents.ogryn_2.ogryn_2_base_4,
  ogryn_2_tier_3_name_2 = _ogryn_talents.ogryn_2.ogryn_2_tier_3_name_2,

  zealot_2_base_3 = _zealot_talents.zealot_2.zealot_2_base_3,
  zealot_2_tier_3_name_2 = _zealot_talents.zealot_2.zealot_2_tier_3_name_2
}
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
      if player == hud_player then
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
        color = {
          255,
          mod:get("coherency_color_static_red") or 255,
          mod:get("coherency_color_static_green") or 255,
          mod:get("coherency_color_static_blue") or 255
        }
      end

      local frame_id = string.format("frame_%s", id)
      local frame_style = widget_style[frame_id]
      if frame_style then
        frame_style.color = color
      end

      local style = widget_style[id]
      local material_values = style.material_values
      if material_values then
        local talents_by_unit = parent._talents_by_unit
        local talent_by_unit = talents_by_unit[unit]
        if not talent_by_unit then
          local talents = profile.talents
          for _, coherency_talents in pairs(_coherency_talents) do
            local improved_talent_name = coherency_talents.improved
            local base_talent_name = coherency_talents.base
            local talent_name = (talents[improved_talent_name] and improved_talent_name)
                or (talents[base_talent_name] and base_talent_name)

            if talent_name then
              talents_by_unit[unit] = _talent_by_name[talent_name]
              break
            end
          end

          talent_by_unit = talents_by_unit[unit]
        end

        parent._talents_by_unit[unit] = talent_by_unit

        local talent_icon = talent_by_unit and talent_by_unit.icon
        material_values.talent_icon = talent_icon
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
