local mod = get_mod("crosshair_hud")
local mod_utils = mod.utils
local _shadows_enabled = mod_utils.shadows_enabled

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")

local global_scale = mod:get("global_scale")
local stimm_scale = mod:get("stimm_scale") * global_scale

local global_offset = {
    mod:get("global_x_offset"),
    mod:get("global_y_offset")
}
local stimm_offset = {
    mod:get("stimm_x_offset"),
    mod:get("stimm_y_offset")
}

local feature_name = "stimm_indicator"
local feature = {
    name = feature_name
}

feature.scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    [feature_name] = {
        parent = "screen",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40 * stimm_scale, 20 * stimm_scale },
        position = {
            global_offset[1] + stimm_offset[1],
            global_offset[2] + stimm_offset[2],
            55
        }
    },
}

local _stimm_colors = {
    syringe_corruption_pocketable = { 255, 38, 205, 26 },
    syringe_ability_boost_pocketable = { 255, 230, 192, 13 },
    syringe_power_boost_pocketable = { 255, 205, 51, 26 },
    syringe_speed_boost_pocketable = { 255, 0, 127, 218 },
    syringe_broker_pocketable = { 255, 178, 102, 255 },
}

local _stimm_icons = {
    syringe_corruption_pocketable = "content/ui/materials/icons/pocketables/hud/small/party_syringe_corruption",
    syringe_ability_boost_pocketable = "content/ui/materials/icons/pocketables/hud/small/party_syringe_ability",
    syringe_power_boost_pocketable = "content/ui/materials/icons/pocketables/hud/small/party_syringe_power",
    syringe_speed_boost_pocketable = "content/ui/materials/icons/pocketables/hud/small/party_syringe_speed",
    syringe_broker_pocketable = "content/ui/materials/icons/pocketables/hud/small/party_syringe_broker",
}

function feature.create_widget_definitions()
    return {
        [feature_name] = UIWidget.create_definition({
            {
                pass_type = "texture",
                value_id = "stimm_icon",
                style_id = "stimm_icon",
                style = {
                    size = { 20 * stimm_scale, 20 * stimm_scale },
                    vertical_alignment = "center",
                    horizontal_alignment = "left",
                    color = UIHudSettings.color_tint_main_1,
                    offset = { 0, 0, 1 },
                },
                visibility_function = function(content, style)
                    return content.stimm_icon
                end
            },
            {
                pass_type = "texture",
                value_id = "stimm_icon",
                style_id = "stimm_icon_shadow",
                style = {
                    size = { 20 * stimm_scale, 20 * stimm_scale },
                    vertical_alignment = "center",
                    horizontal_alignment = "left",
                    color = UIHudSettings.color_tint_0,
                    offset = { 2 * stimm_scale, 2 * stimm_scale, 0 },
                },
                visibility_function = function(content, style)
                    return content.stimm_icon and _shadows_enabled("stimm")
                end
            },
            {
                pass_type = "text",
                value_id = "stimm_countdown",
                style_id = "stimm_countdown",
                style = {
                    font_size = 20 * stimm_scale,
                    font_type = "machine_medium",
                    text_vertical_alignment = "center",
                    text_horizontal_alignment = "right",
                    text_color = UIHudSettings.color_tint_1,
                    offset = { 0, 0, 2 }
                },
                visibility_function = function(content, style)
                    return content.stimm_countdown and content.stimm_countdown ~= ""
                end
            },
            {
                pass_type = "text",
                value_id = "stimm_countdown",
                style_id = "stimm_countdown_shadow",
                style = {
                    font_size = 20 * stimm_scale,
                    font_type = "machine_medium",
                    text_vertical_alignment = "center",
                    text_horizontal_alignment = "right",
                    text_color = UIHudSettings.color_tint_0,
                    offset = { 2 * stimm_scale, 2 * stimm_scale, 1 }
                },
                visibility_function = function(content, style)
                    return content.stimm_countdown and content.stimm_countdown ~= "" and _shadows_enabled("stimm")
                end
            },
        }, feature_name)
    }
end

local RecolorStimms = get_mod("RecolorStimms")
function feature.update(parent)
    local stimm_widget = parent._widgets_by_name[feature_name]
    if not stimm_widget then
        return
    end

    local display_stimm_indicator = mod:get("display_stimm_indicator")
    local content = stimm_widget.content
    local style = stimm_widget.style

    content.visible = display_stimm_indicator

    if not display_stimm_indicator then
        return
    end

    local player_extensions = parent._parent:player_extensions()
    local buff_ext = player_extensions.buff
    local ability_ext = player_extensions.ability
    local visual_loadout_extension = player_extensions.visual_loadout
    
    local stimm_countdown = ""
    local countdown_color = UIHudSettings.color_tint_1
    local active_stimm_name = nil
    local has_active_buff = false

    if buff_ext and ability_ext then
        local buffs_by_index = buff_ext._buffs_by_index
        if buffs_by_index then
            local max_buff_time = 0
            for _, buff in pairs(buffs_by_index) do
                local template = buff:template()
                if template and template.name and string.find(template.name, "^syringe") then
                    local remaining = buff:duration_progress() or 1
                    local duration = buff:duration() or 15
                    local buff_time = duration * remaining
                    if buff_time > max_buff_time then
                        max_buff_time = buff_time
                        active_stimm_name = string.gsub(template.name, "_buff$", "_pocketable")
                    end
                end
            end

            if max_buff_time >= 0.05 then
                stimm_countdown = string.format("%.0f", math.ceil(max_buff_time))
                countdown_color = { 255, 0, 255, 0 }
                has_active_buff = true
            end
        end

        if stimm_countdown == "" then
            local cooldown = ability_ext:remaining_ability_cooldown("pocketable_ability") or 0
            if cooldown >= 0.05 then
                stimm_countdown = string.format("%.0f", math.ceil(cooldown))
                countdown_color = { 255, 255, 0, 0 }
            end
        end
    end

    local weapon_template = visual_loadout_extension:weapon_template_from_slot("slot_pocketable_small")
    local stimm_name = nil
    
    if weapon_template then
        stimm_name = weapon_template.name
    elseif has_active_buff and active_stimm_name then
        stimm_name = active_stimm_name
    end

    if not stimm_name then
        content.visible = false
        return
    end

    local color = _stimm_colors[stimm_name]

    if RecolorStimms and RecolorStimms.get_stimm_argb_255 and RecolorStimms:is_enabled() then
        color = RecolorStimms.get_stimm_argb_255(stimm_name)
    end

    if weapon_template then
        content.stimm_icon = weapon_template.hud_icon_small
    else
        content.stimm_icon = _stimm_icons[stimm_name]
    end
    
    style.stimm_icon.color = color or { 255, 255, 255, 255 }

    content.stimm_countdown = stimm_countdown
    style.stimm_countdown.text_color = countdown_color
end

return feature
