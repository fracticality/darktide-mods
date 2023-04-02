-- TODO: Customizable thresholds and colors

local mod = get_mod("crosshair_hud")

local UISettings = mod:original_require("scripts/settings/ui/ui_settings")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local TextUtilities = mod:original_require("scripts/utilities/ui/text")
local ColorUtilities = mod:original_require("scripts/utilities/ui/colors")
local ArchetypeTalents = mod:original_require("scripts/settings/ability/archetype_talents/archetype_talents")
local PlayerSpecialization = mod:original_require("scripts/utilities/player_specialization/player_specialization")
local PlayerCharacterConstants = mod:original_require("scripts/settings/player_character/player_character_constants")
local WeaponTemplate = mod:original_require("scripts/utilities/weapon/weapon_template")
local WarpCharge = mod:original_require("scripts/utilities/warp_charge")
local ArchetypeWarpChargeTemplates = mod:original_require("scripts/settings/warp_charge/archetype_warp_charge_templates")

local player_slot_colors = UISettings.player_slot_colors

local _definitions = mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/hud_element_crosshair_hud_definitions")

local _psyker_talents = ArchetypeTalents.psyker
local _ogryn_talents = ArchetypeTalents.ogryn
local _veteran_talents = ArchetypeTalents.veteran
local _zealot_talents = ArchetypeTalents.zealot

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

local _talent_by_icon = {}
for _, v in pairs(_talent_by_name) do
  _talent_by_icon[v.icon] = v
end

local _apply_color_to_text = TextUtilities.apply_color_to_text
local _temp_ammo_display_texts = {}
local function _convert_number_to_display_texts(amount, max_character, zero_numeral_color, color_zero_values, ignore_coloring)
  table.clear(_temp_ammo_display_texts)

  max_character = math.min(max_character + 1, 3)
  local length = string.len(amount)
  local num_adds = max_character - length
  local zero_string = "0"
  local zero_string_colored = ignore_coloring and zero_string or _apply_color_to_text("0", zero_numeral_color)

  for i = 1, num_adds do
    _temp_ammo_display_texts[#_temp_ammo_display_texts + 1] = zero_string_colored
  end

  local num_amount_strings = string.format("%1d", amount)

  for i = 1, #num_amount_strings do
    local value = string.sub(num_amount_strings, i, i)

    if amount == 0 and color_zero_values then
      _temp_ammo_display_texts[#_temp_ammo_display_texts + 1] = zero_string_colored
    else
      _temp_ammo_display_texts[#_temp_ammo_display_texts + 1] = value
    end
  end

  return _temp_ammo_display_texts
end

local HudElementCrosshairHud = class("HudElementCrosshairHud", "HudElementBase")

function HudElementCrosshairHud:init(parent, draw_layer, start_scale)
  self._talents_by_unit = {}

  HudElementCrosshairHud.super.init(self, parent, draw_layer, start_scale, _definitions)
end

function HudElementCrosshairHud:_update_coherency(dt, t)

  local simple_widget = self._widgets_by_name.coherency_indicator_simple
  local simple_content = simple_widget.content
  local archetype_widget = self._widgets_by_name.coherency_indicator_archetype
  local archetype_content = archetype_widget.content
  local aura_widget = self._widgets_by_name.coherency_indicator_aura
  local aura_content = aura_widget.content

  simple_content.visible = false
  archetype_content.visible = false
  aura_content.visible = false

  local coherency_type = mod:get("coherency_type")
  if coherency_type == mod.options_coherency_type.off then
    return
  end

  local coherency_color_type = mod:get("coherency_colors")
  local color_by_teammate = coherency_color_type == "player_color"
  local color_by_health = coherency_color_type == "player_health"
  local color_by_toughness = coherency_color_type == "player_toughness"
  local color_static = coherency_color_type == "static_color"

  local widget_name = string.format("coherency_indicator_%s", coherency_type)
  local coherency_widget = self._widgets_by_name[widget_name]

  if not coherency_widget then
    if not mod.coherency_widget_alerted then
      local message = string.format("Coherency Type [%s] no longer exists. Please select a new one in the options menu.", coherency_type)
      mod:error(message)
      mod:notify(message)
      mod.coherency_widget_alerted = true
    end

    return
  end

  local coherency_style = coherency_widget.style
  local coherency_content = coherency_widget.content

  local ui_hud = self._parent
  local hud_player = ui_hud:player()
  local player_extensions = ui_hud:player_extensions()
  local coherency_extension = player_extensions.coherency
  local units_in_coherency = coherency_extension:in_coherence_units()

  coherency_content.visible = true

  local i = 1
  for unit in pairs(units_in_coherency) do
    if i > 3 then
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
          color = self:_get_text_color_for_percent_threshold(health_percent, "health")
        end
      elseif color_by_toughness then
        local toughness_extension = ScriptUnit.has_extension(unit, "toughness_system")
        if toughness_extension then
          local toughness_percent = toughness_extension:current_toughness_percent()
          color = self:_get_text_color_for_percent_threshold(toughness_percent, "toughness")
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
      local frame_style = coherency_style[frame_id]
      if frame_style then
        frame_style.color = color
      end

      local style = coherency_style[id]
      local material_values = style.material_values
      if material_values then
        local talents_by_unit = self._talents_by_unit
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

        self._talents_by_unit[unit] = talent_by_unit

        local talent_icon = talent_by_unit and talent_by_unit.icon
        material_values.talent_icon = talent_icon
        style.visible = true
      else
        local is_archetype_style = coherency_type == mod.options_coherency_type.archetype
        local text = (is_archetype_style and profile.archetype.string_symbol) or "+"
        coherency_content[id] = text

        style.text_color = color
        style.visible = true
      end

      i = i + 1
    until true
  end

  for j = i, 3 do
    local style_id = string.format("player_%s", j)
    local style = coherency_style[style_id]
    style.visible = false
  end
end

function HudElementCrosshairHud:_update_toughness(dt, t)
  local player_extensions = self._parent:player_extensions()
  local toughness_extension = player_extensions.toughness
  local toughness_percent = toughness_extension:current_toughness_percent()
  local current_toughness = toughness_extension:remaining_toughness()
  local toughness_widget = self._widgets_by_name.toughness_indicator

  if toughness_percent == 1 and mod:get("toughness_hide_at_full") then
    toughness_widget.content.visible = false
    return
  end

  local toughness_always_show = mod:get("toughness_always_show")
  if toughness_always_show or current_toughness ~= self.current_toughness then
    self.current_toughness = current_toughness
    self.toughness_visible_timer = mod:get("health_stay_time") or 1.5

    toughness_widget.content.visible = true

    local toughness_display_type = mod:get("toughness_display_type")
    local number_to_display = (toughness_display_type == mod.options_display_type.percent and (toughness_percent * 100)) or current_toughness
    local text_color = self:_get_text_color_for_percent_threshold(toughness_percent, "toughness") or UIHudSettings.color_tint_6

    local amount = math.ceil(number_to_display)
    local texts = _convert_number_to_display_texts(amount, 3, nil, false, true)
    for i = 1, 3 do
      local key = string.format("text_%s", i)
      toughness_widget.content[key] = texts[i] or ""
      toughness_widget.style[key].text_color = text_color
    end
    toughness_widget.style.text_symbol.visible = toughness_display_type == mod.options_display_type.percent
    toughness_widget.style.text_symbol.text_color = text_color
    toughness_widget.dirty = true
  end

  if not toughness_always_show and self.toughness_visible_timer then
    self.toughness_visible_timer = self.toughness_visible_timer - dt
    if self.toughness_visible_timer <= 0 then
      self.toughness_visible_timer = nil
      toughness_widget.content.visible = false
    end
  end
end

function HudElementCrosshairHud:_update_health(dt, t)
  local player_extensions = self._parent:player_extensions()
  local health_widget = self._widgets_by_name.health_indicator
  local health_extension = player_extensions.health
  local current_health = health_extension:current_health()
  local health_percent = health_extension:current_health_percent()

  if health_percent == 1 and mod:get("health_hide_at_full") then
    health_widget.content.visible = false
    return
  end

  local health_always_show = mod:get("health_always_show")
  if health_always_show or current_health ~= self.current_health then
    self.current_health = current_health
    self.health_visible_timer = mod:get("health_stay_time") or 1.5

    health_widget.content.visible = true

    local health_display_type = mod:get("health_display_type")
    local number_to_display = (health_display_type == mod.options_display_type.percent and (health_percent * 100)) or current_health
    local text_color = self:_get_text_color_for_percent_threshold(health_percent, "health") or UIHudSettings.color_tint_main_2

    local texts = _convert_number_to_display_texts(math.ceil(number_to_display), 3, nil, false, true)
    for i = 1, 3 do
      local key = string.format("text_%s", i)
      health_widget.content[key] = texts[i] or ""
      health_widget.style[key].text_color = text_color
    end
    health_widget.style.text_symbol.visible = health_display_type == mod.options_display_type.percent
    health_widget.style.text_symbol.text_color = text_color
    health_widget.dirty = true
  end

  if not health_always_show and self.health_visible_timer then
    self.health_visible_timer = self.health_visible_timer - dt
    if self.health_visible_timer <= 0 then
      self.health_visible_timer = nil
      health_widget.content.visible = false
    end
  end
end

function HudElementCrosshairHud:_update_ability(dt, t)
  local ability_widget = self._widgets_by_name.ability_indicator

  if not mod:get("display_ability_cooldown") then
    ability_widget.content.visible = false
    return
  end

  local player_extensions = self._parent:player_extensions()
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
  local symbol = self:_get_cooldown_symbol_for_percent_threshold(cooldown_percent, remaining_ability_charges)
  local content = ability_widget.content
  local style = ability_widget.style
  --local color = (missing_ability_charges == 0 and { 255, 255, 150, 0 }) or (remaining_ability_charges == 0 and UIHudSettings.color_tint_alert_2) or UIHudSettings.color_tint_1
  local color = self:_get_text_color_for_percent_threshold(cooldown_percent, "ability")

  --- Full: { 255, 255, 150, 0 }

  content.symbol = symbol
  content.charge_count = (max_ability_charges > 1 and remaining_ability_charges) or ""
  content.cooldown = remaining_ability_cooldown

  local cooldown_display_texts = _convert_number_to_display_texts(math.floor(remaining_ability_cooldown), 1, nil, false, true)
  local cooldown_text = table.concat(cooldown_display_texts)
  content.cooldown_text = string.format(":%s", cooldown_text)

  style.symbol.color = color
  style.charge_count.text_color = color
end

local _reload_actions = {
  reload_state = true,
  reload_shotgun = true
}
function HudElementCrosshairHud:_update_reload(dt, t)
  local reload_widget = self._widgets_by_name.reload_indicator
  if not reload_widget then
    return
  end

  local display_reload_indicator = mod:get("display_reload_indicator")
  reload_widget.content.visible = display_reload_indicator

  if not display_reload_indicator then
    return
  end

  local player_extensions = self._parent:player_extensions()
  local unit_data_extension = player_extensions and player_extensions.unit_data
  local weapon_action_component = unit_data_extension and unit_data_extension:read_component("weapon_action")
  local weapon_template = weapon_action_component and WeaponTemplate.weapon_template(weapon_action_component.template_name)
  local reload_template = weapon_template and weapon_template.reload_template
  local current_action_name = weapon_action_component and weapon_action_component.current_action_name
  local current_action_settings = weapon_template and weapon_template.actions[current_action_name]
  local is_reload_action = current_action_settings and _reload_actions[current_action_settings.kind]

  if reload_template then
    local time_scale = weapon_action_component.time_scale
    local total_time = is_reload_action and current_action_settings.total_time or 0
    local scaled_time = total_time / time_scale
    local time_in_action = mod.time_in_action or scaled_time

    mod.reload_percent = math.min(1, time_in_action / scaled_time)
    mod.reload_time = math.max(0, scaled_time - time_in_action)

  elseif mod:get("only_during_reload") then
    reload_widget.content.visible = false
    return
  end

  local reload_style = reload_widget.style
  local reload_bar = reload_style.reload_bar
  reload_widget.content.reload_time = mod.reload_time and string.format("%.2f", mod.reload_time) or ""
  reload_bar.size[1] = reload_bar.max_height * (mod.reload_percent or 0)
end

function HudElementCrosshairHud:_update_pocketable(dt, t)

  local pocketable_widget = self._widgets_by_name.pocketable_indicator
  if not pocketable_widget then
    return
  end

  local content = pocketable_widget.content
  local display_pocketable_indicator = mod:get("display_pocketable_indicator")

  content.visible = display_pocketable_indicator

  if not display_pocketable_indicator then
    return
  end

  local player_extensions = self._parent:player_extensions()
  local unit_data_extension = player_extensions.unit_data
  local visual_loadout_extension = player_extensions.visual_loadout
  local inventory_component = unit_data_extension:read_component("inventory")
  local pocketable_name = inventory_component.slot_pocketable
  local weapon_template = pocketable_name and visual_loadout_extension:weapon_template_from_slot("slot_pocketable")
  content.pocketable_icon = weapon_template and weapon_template.hud_icon_small
end

function HudElementCrosshairHud:_update_peril(dt, t)
  local peril_widget = self._widgets_by_name.peril_indicator
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

  local player_extensions = self._parent:player_extensions()
  local unit_data_extension = player_extensions.unit_data
  local weapon_extension = player_extensions.weapon
  local weapon_template = weapon_extension and weapon_extension:weapon_template()
  if weapon_template and weapon_template.uses_overheat then
    local weapon_component = unit_data_extension:read_component("slot_secondary")
    local overheat_current_percentage = weapon_component and weapon_component.overheat_current_percentage or 0

    content.symbol_text = ""
    content.value_text = string.format("%.0f", overheat_current_percentage * 100)
    content.visible = true
    local text_color = self:_get_text_color_for_percent_threshold((1 - overheat_current_percentage), "peril")
    style.value_text.text_color = text_color
    style.symbol_text.text_color = text_color

    return
  end

  local player = self._parent:player()
  local specialization_warp_charge_template = WarpCharge.specialization_warp_charge_template(player)

  if specialization_warp_charge_template == ArchetypeWarpChargeTemplates.psyker then
    local warp_charge_component = unit_data_extension and unit_data_extension:read_component("warp_charge")
    local current_percentage = warp_charge_component and warp_charge_component.current_percentage or 0

    content.symbol_text = ""
    content.value_text = string.format("%.0f", current_percentage * 100)
    content.visible = true
    local text_color = self:_get_text_color_for_percent_threshold((1 - current_percentage), "peril")
    style.value_text.text_color = text_color
    style.symbol_text.text_color = text_color

    return
  end
end

function HudElementCrosshairHud:_update_grenade_ability(dt, t)
  local grenade_widget = self._widgets_by_name.grenade_indicator
  if not grenade_widget then
    return
  end

  local content = grenade_widget.content
  local display_grenade_indicator = mod:get("display_grenade_indicator")

  content.visible = display_grenade_indicator

  if not display_grenade_indicator then
    return
  end

  local player_extensions = self._parent:player_extensions()
  local ability_extension = player_extensions.ability

  if not (ability_extension and ability_extension:ability_is_equipped("grenade_ability")) then
    return
  end

  local remaining_ability_charges = ability_extension:remaining_ability_charges("grenade_ability")
  local max_ability_charges = ability_extension:max_ability_charges("grenade_ability")
  local ability_charges_percent = remaining_ability_charges / max_ability_charges
  local style = grenade_widget.style

  local unit_data_extension = player_extensions.unit_data
  local warp_charge_component = unit_data_extension and unit_data_extension:read_component("warp_charge")
  if warp_charge_component and max_ability_charges == 1 then
    content.visible = false
    return
  end

  content.grenade_count = remaining_ability_charges

  style.grenade_icon.visible = true
  style.grenade_icon.color = self:_get_text_color_for_percent_threshold(ability_charges_percent, "grenade")
  style.grenade_count.text_color = self:_get_text_color_for_percent_threshold(ability_charges_percent, "grenade")
end

function HudElementCrosshairHud:_update_ammo(dt, t)
  local ammo_widget = self._widgets_by_name.ammo_indicator
  if not ammo_widget then
    return
  end

  local display_ammo_indicator = mod:get("display_ammo_indicator")
  ammo_widget.content.visible = display_ammo_indicator

  if not display_ammo_indicator then
    return
  end

  local player_extensions = self._parent:player_extensions()
  local unit_data_extension = player_extensions.unit_data
  local inventory_component = unit_data_extension:read_component("slot_secondary")

  if not inventory_component then
    return
  end

  local clip_max = inventory_component.max_ammunition_clip or 0
  local reserve_max = inventory_component.max_ammunition_reserve or 0
  local max_ammo = clip_max + reserve_max

  if max_ammo == 0 then
    ammo_widget.content.visible = false
    return
  end

  local clip_ammo = inventory_component.current_ammunition_clip or 0
  local reserve_ammo = inventory_component.current_ammunition_reserve or 0
  local current_ammo = clip_ammo + reserve_ammo
  local current_ammo_percent = 0
  local reserve_ammo_percent = 0
  local clip_ammo_percent = 0

  current_ammo_percent = current_ammo / max_ammo
  reserve_ammo_percent = reserve_ammo / reserve_max
  clip_ammo_percent = clip_ammo / clip_max

  local content = ammo_widget.content
  content.max_ammo = max_ammo or 0
  content.current_ammo = current_ammo or 0
  content.reserve_ammo = reserve_ammo or 0
  content.clip_ammo = clip_ammo or 0

  local style = ammo_widget.style
  local icon_style = style.ammo_icon
  icon_style.color = self:_get_text_color_for_percent_threshold(current_ammo_percent, "ammo")

  local clip_style = style.clip_ammo
  clip_style.text_color = self:_get_text_color_for_percent_threshold(clip_ammo_percent, "ammo")

  local reserve_style = style.reserve_ammo
  reserve_style.text_color = self:_get_text_color_for_percent_threshold(reserve_ammo_percent, "ammo")

  local show_ammo_icon = mod:get("show_ammo_icon")
  icon_style.visible = show_ammo_icon
  style.ammo_icon_shadow.visible = show_ammo_icon
end

function HudElementCrosshairHud:update(dt, t, ui_renderer, render_settings, input_service)
  HudElementCrosshairHud.super.update(self, dt, t, ui_renderer, render_settings, input_service)

  self:_update_coherency(dt, t)
  self:_update_toughness(dt, t)
  self:_update_health(dt, t)
  self:_update_ability(dt, t)
  self:_update_ammo(dt, t)
  self:_update_grenade_ability(dt, t)
  self:_update_pocketable(dt, t)
  self:_update_peril(dt, t)
  self:_update_reload(dt, t)
end

function HudElementCrosshairHud:_get_cooldown_symbol_for_percent_threshold(percent, remaining_ability_charges)
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

--TODO: Move to _data.lua file and attach to mod object (for custom thresholds)
local _threshold_settings = {
  {
    threshold = "critical",
    default_color = UIHudSettings.color_tint_alert_2,
    default_color_by_setting = {
      ammo = UIHudSettings.color_tint_ammo_high
    },
    validation_function = function(percent)
      return percent <= 0.15
    end
  },
  {
    threshold = "low",
    default_color = UIHudSettings.color_tint_ammo_medium,
    default_color_by_setting = {},
    validation_function = function(percent)
      return percent <= 0.5
    end
  },
  {
    threshold = "high",
    default_color = { 255, 255, 255, 50 },
    default_color_by_setting = {
      ammo = UIHudSettings.color_tint_ammo_low
    },
    validation_function = function(percent)
      return percent < 1
    end
  },
  {
    threshold = "full",
    default_color = UIHudSettings.color_tint_1,
    default_color_by_setting = {
      health = UIHudSettings.color_tint_main_2,
      toughness = UIHudSettings.color_tint_6
    },
    validation_function = function(percent)
      return percent == 1
    end
  }
}
function HudElementCrosshairHud:_get_text_color_for_percent_threshold(percent, setting)
  local base_setting_id = "custom_threshold_" .. setting
  local color = { 255, 255, 255, 255 }

  for i, settings in ipairs(_threshold_settings) do
    if settings.validation_function and settings.validation_function(percent) then
      local threshold = settings.threshold
      local threshold_setting_id = base_setting_id .. "_" .. threshold
      local default_color_by_setting = settings.default_color_by_setting
      local default_color = default_color_by_setting and default_color_by_setting[setting] or settings.default_color

      local is_threshold_customized = mod:get(threshold_setting_id)
      if is_threshold_customized then
        color = {
          color[1],
          mod:get(threshold_setting_id .. "_red") or default_color[2],
          mod:get(threshold_setting_id .. "_green") or default_color[3],
          mod:get(threshold_setting_id .. "_blue") or default_color[4]
        }

        break
      end

      color = table.clone(default_color)
      break
    end
  end

  return color
end

local function _is_in_hub()
  local game_mode_name = Managers.state.game_mode:game_mode_name()
  return (game_mode_name == "hub" or game_mode_name == "prologue_hub")
end

function HudElementCrosshairHud:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
  if _is_in_hub() then
    return
  end

  HudElementCrosshairHud.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

return HudElementCrosshairHud
