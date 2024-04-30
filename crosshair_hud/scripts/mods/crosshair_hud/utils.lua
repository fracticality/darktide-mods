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

mod.utils = {
    shadows_enabled = _shadows_enabled,
    convert_number_to_display_texts = _convert_number_to_display_texts,
    get_text_color_for_percent_threshold = _get_text_color_for_percent_threshold,
    get_feature_offset = get_feature_offset,
    get_feature_scale = get_feature_scale
}