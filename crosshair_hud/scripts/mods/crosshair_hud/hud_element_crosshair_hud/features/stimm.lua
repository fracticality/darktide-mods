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
        size = { 20 * stimm_scale, 20 * stimm_scale },
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
                    horizontal_alignment = "center",
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
                    horizontal_alignment = "center",
                    color = UIHudSettings.color_tint_0,
                    offset = { 2 * stimm_scale, 2 * stimm_scale, 0 },
                },
                visibility_function = function(content, style)
                    return content.stimm_icon and _shadows_enabled("stimm")
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
    local visual_loadout_extension = player_extensions.visual_loadout
    local weapon_template = visual_loadout_extension:weapon_template_from_slot("slot_pocketable_small")

    if not weapon_template then
        content.visible = false

        return
    end

    local stimm_name = weapon_template.name
    local color = _stimm_colors[stimm_name]

    if RecolorStimms and RecolorStimms.get_stimm_argb_255 and RecolorStimms:is_enabled() then
        color = RecolorStimms.get_stimm_argb_255(stimm_name)
    end

    content.stimm_icon = weapon_template and weapon_template.hud_icon_small
    style.stimm_icon.color = color or { 255, 255, 255, 255 }
end

return feature
