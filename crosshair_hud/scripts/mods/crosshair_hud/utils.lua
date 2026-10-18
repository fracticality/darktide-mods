local mod = get_mod("crosshair_hud")

local TextUtilities = require("scripts/utilities/ui/text")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local function _shadows_enabled(setting_id)
    local enable_shadows_id = string.format("enable_shadows_%s", setting_id)
    local enable_shadows_setting = mod:get(enable_shadows_id)

    if enable_shadows_setting == "global" then
        return mod:get("enable_shadows")
    end

    return enable_shadows_setting == "on"
end

local function _convert_number_to_display_texts(amount, max_character, zero_numeral_color, color_zero_values, ignore_coloring)
    local _temp_ammo_display_texts = {}

    max_character = math.min(max_character + 1, 3)
    local length = string.len(amount)
    local num_adds = max_character - length
    local zero_string = "0"
    local zero_string_colored = ignore_coloring and zero_string or TextUtilities.apply_color_to_text("0", zero_numeral_color)

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
        default_color = UIHudSettings.color_tint_ammo_low,
        default_color_by_setting = {},
        validation_function = function(percent)
            return percent < 1
        end
    },
    {
        threshold = "full",
        default_color = UIHudSettings.color_tint_main_1,
        default_color_by_setting = {
            health = UIHudSettings.color_tint_main_2,
            toughness = UIHudSettings.color_tint_6
        },
        validation_function = function(percent)
            return percent == 1
        end
    },
    {
        threshold = "bonus",
        default_color = UIHudSettings.color_tint_10,
        validation_function = function(percent)
            return percent > 1
        end
    }
}
local function _get_text_color_for_percent_threshold(percent, setting)
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
                local color_id = string.format("%s_color", threshold_setting_id)
                color = Color[mod:get(color_id)](255, true)

                break
            end

            color = table.clone(default_color)
            break
        end
    end

    return color
end

local function get_feature_offset(feature_name)
    return {
        mod:get("global_x_offset") + mod:get(feature_name .. "_x_offset"),
        mod:get("global_y_offset") + mod:get(feature_name .. "_y_offset")
    }
end

local function get_feature_scale(feature_name)
    return mod:get("global_scale") * mod:get(feature_name .. "_scale")
end

-- Game patch 1.13 turned ability cooldowns into a regenerating resource and removed
-- PlayerUnitAbilityExtension:remaining_ability_cooldown / :max_ability_cooldown.
-- These helpers reconstruct the real seconds-to-next-charge from the resource model,
-- mirroring the game's own regen math (player_unit_ability_extension.lua update loop):
--   net_regen_per_second = (base + flat_buff) * modifier_buff - cost_per_second
--   seconds = missing_resource / net_regen_per_second
-- so the timers match for both charge-based and resource-based abilities.
local function _ability_resource_regen_per_second(ability_extension, ability_type, ability)
    local buff_extension = ability_extension._buff_extension
    local stat_buffs = buff_extension and buff_extension:stat_buffs() or {}
    local max_resource = ability_extension:max_ability_resource(ability_type)
    local base = (ability.resource_regen_per_second or 0)
        + max_resource * (ability.resource_regen_percent_per_second or 0)
    local flat = stat_buffs[ability_type .. "_resource_flat_regen"] or 0
    local modifier = stat_buffs[ability_type .. "_resource_regen_modifier"] or 1
    local cost_per_second = ability_extension:get_ability_resource_cost_per_second(ability_type) or 0
    return (base + flat) * modifier - cost_per_second
end

-- Returns (seconds_until_next_charge, fill_progress_0_to_1).
-- seconds is nil when there is nothing to count down (ready, paused, no timed regen).
local function _ability_cooldown(ability_extension, ability_type)
    local abilities = ability_extension._equipped_abilities
    local ability = abilities and abilities[ability_type]
    if not ability or not ability_extension.missing_ability_resource_until_next_charge then
        return nil, 1
    end
    if ability_extension:is_ability_resource_regen_paused(ability_type) then
        return nil, 0
    end
    local progress = ability_extension:get_ability_resource_regen_progress(ability_type) or 1
    if progress ~= progress then
        progress = 1
    end
    local missing, missing_percent = ability_extension:missing_ability_resource_until_next_charge(ability_type)
    if not missing or missing <= 0 then
        return 0, progress
    end
    if ability.only_uses_charges then
        return nil, progress
    end
    -- Husk extensions (e.g. the spectated teammate while you are dead) have no buff
    -- extension and error() on get_ability_resource_cost_per_second, so fall back to
    -- the synced per-charge regen time there.
    if not ability_extension._buff_extension then
        local max_regen_time = ability_extension:max_regen_time_for_ability_charge(ability_type) or 0
        local seconds = (missing_percent or 0) * max_regen_time
        if seconds <= 0 then
            return nil, progress
        end
        return seconds, progress
    end
    local rate = _ability_resource_regen_per_second(ability_extension, ability_type, ability)
    if rate <= 0 then
        return nil, progress
    end
    return missing / rate, progress
end

local function _remaining_ability_cooldown(ability_extension, ability_type)
    return (_ability_cooldown(ability_extension, ability_type)) or 0
end

mod.utils = {
    shadows_enabled = _shadows_enabled,
    convert_number_to_display_texts = _convert_number_to_display_texts,
    get_text_color_for_percent_threshold = _get_text_color_for_percent_threshold,
    get_feature_offset = get_feature_offset,
    get_feature_scale = get_feature_scale,
    ability_cooldown = _ability_cooldown,
    remaining_ability_cooldown = _remaining_ability_cooldown
}