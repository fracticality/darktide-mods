local mod = get_mod("psych_ward")
local mod_context = mod.context

local UIWidget = require("scripts/managers/ui/ui_widget")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local StepperPassTemplates = require("scripts/ui/pass_templates/stepper_pass_templates")

local _meatgrinder_button = "meatgrinder_button"
local _difficulty_stepper = "difficulty_stepper"

local legend_input = {
    is_custom = true,
    input_action = "hotkey_inventory",
    display_name = "loc_toggle_view_buttons",
    alignment = "center_alignment",
    on_pressed_callback = "cb_on_toggle_view_buttons",
    visibility_function = function(parent)
        return not parent._is_main_menu_open
    end
}

local main_menu_definitions_file = "scripts/ui/views/main_menu_view/main_menu_view_definitions"
mod:hook_require(main_menu_definitions_file, function(definitions)

    local index = table.find_by_key(definitions.legend_inputs, "is_custom", true)
    if index then
        table.remove(definitions.legend_inputs, index)
    end

    table.insert(definitions.legend_inputs, legend_input)

    definitions.scenegraph_definition[_difficulty_stepper] = {
        parent = _meatgrinder_button,
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 300, 60 },
        position = { -25, -75, 10 }
    }

    for button_name, button_settings in pairs(mod_context.button_settings) do
        local button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, button_name, {
            text = mod:localize(button_name),
            view_name = button_settings.view_name
        })

        definitions.widget_definitions[button_name] = button
        definitions.scenegraph_definition[button_name] = button_settings.scenegraph_definition
    end

    local stepper_template = table.clone(StepperPassTemplates.difficulty_stepper)
    local definition = UIWidget.create_definition(stepper_template, _difficulty_stepper)
    index = table.find_by_key(definition.passes, "style_id", "danger")
    if index then
        table.remove(definition.passes, index)
    end

    index = table.find_by_key(definition.passes, "style_id", "stepper_left")
    if index then
        local pass = definition.passes[index]
        local style = definition.style[pass.style_id]
        if style and style.offset then
            style.offset[1] = -75
        end
    end

    index = table.find_by_key(definition.passes, "content_id", "hotspot_left")
    if index then
        local pass = definition.passes[index]
        local style = definition.style[pass.style_id]
        if style and style.offset then
            style.offset[1] = -95
        end
    end

    index = table.find_by_key(definition.passes, "value_id", "difficulty_text")
    if index then
        local pass = definition.passes[index]
        local style = definition.style[pass.style_id]
        if style and style.offset then
            style.offset[1] = 25
        end
    end

    definitions.widget_definitions[_difficulty_stepper] = definition

end)