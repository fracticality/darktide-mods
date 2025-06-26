local mod = get_mod("psych_ward")

local _exit_text = "exit_text"

local UIWidget = require("scripts/managers/ui/ui_widget")
local InputUtils = require("scripts/managers/input/input_utils")

local function _quit()
    Application.quit()
end

local title_view_definitions_file = "scripts/ui/views/title_view/title_view_definitions"
mod:hook_require(title_view_definitions_file, function(definitions)
    definitions.scenegraph_definition[_exit_text] = {
        parent = "background_image",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 450, 50 },
        position = { 0, -25, 4 }
    }

    definitions.widget_definitions[_exit_text] = UIWidget.create_definition({
        {
            pass_type = "hotspot",
            content_id = "hotspot",
            content = {
                pressed_callback = _quit
            },
        },
        {
            pass_type = "text",
            value = "",
            value_id = "text",
            style = {
                font_size = 24,
                font_type = "proxima_nova_bold",
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                text_color = Color.text_default(255, true),
                offset = { 0, 0, 2 }
            },
            change_function = function(content, style)
                local progress = 0.5 + math.sin(Application.time_since_launch() * 3) * 0.5
                local text_color = style.text_color
                local progress_color = 180 + 75 * progress
                text_color[2] = progress_color
                text_color[3] = progress_color
                text_color[4] = progress_color
            end
        }
    }, _exit_text)

end)

mod:hook_safe(CLASS.TitleView, "update", function(self, dt, t, input_service)
    if self._parent:is_loading() then
        mod:hook_disable(CLASS.TitleView, "update")

        local exit_widget = self._widgets_by_name[_exit_text]
        local widget_content = exit_widget and exit_widget.content
        if widget_content then
            widget_content.visible = false
        end

        return
    end

    if input_service:get("hotkey_system") then
        _quit()
    end
end)

mod:hook_safe(CLASS.TitleView, "_apply_title_text", function(self)
    local exit_text_widget = self._widgets_by_name[_exit_text]
    if exit_text_widget then
        local input = InputUtils.input_text_for_current_input_device("View", "close_view", true)
        local text = mod:localize("exit_text", input)
        exit_text_widget.content.text = text
    end
end)