local mod = get_mod("custom_hud")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local ColorUtilities = mod:original_require("scripts/utilities/ui/colors")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local _excluded_element_names = {
    HudElementCustomizer = true,
    HudElementPrologueTutorialSequenceTransitionEnd = true,
    HudElementPrologueTutorialInfoBox = true,
    HudElementCrosshair = true,
    HudElementInteraction = true,
    HudElementWorldMarkers = true,
    HudElementTacticalOverlay = true,
    --HudElementOnboardingPopup = true,
    HudElementEmoteWheel = true,
    HudElementSmartTagging = true,
    HudElementDamageIndicator = true,

    ConstantElementWatermark = true,
    ConstantElementPopupHandler = true,
    ConstantElementSoftwareCursor = true
}

local _excluded_scenegraphs_by_element = {
    HudElementPlayerWeaponHandler = {
        weapon_slot_1 = true,
        weapon_slot_2 = true,
        weapon_slot_3 = true,
        weapon_slot_4 = true
    }
}

local Keyboard = Keyboard
local function is_shift_held()
    if not Keyboard then
        Keyboard = rawget(_G, "Keyboard")

        if not Keyboard then
            return
        end
    end

    return Keyboard.button(Keyboard.button_index("left shift")) > 0.5
end

local function is_alt_held()
    if not Keyboard then
        Keyboard = rawget(_G, "Keyboard")

        if not Keyboard then
            return
        end
    end

    return Keyboard.button(Keyboard.button_index("left alt")) > 0.5
end

local function is_ctrl_held()
    if not Keyboard then
        Keyboard = rawget(_G, "Keyboard")

        if not Keyboard then
            return
        end
    end

    return Keyboard.button(Keyboard.button_index("left ctrl")) > 0.5
end

local function split_node_name(node_name)
    local splits = string.split(node_name, "|")
    local element_name = splits[1]
    local scenegraph_id = splits[2]

    return element_name, scenegraph_id
end

local _definitions = {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        background = {
            parent = "screen",
            scale = "scale",
            size = { 1920, 1080 },
            position = { 0, 0, 50 }
        }
    },
    widget_definitions = {}
}

local HudElementCustomizer = class("HudElementCustomizer", "HudElementBase")

function HudElementCustomizer:init(parent, draw_layer, start_scale)

    self._selected_node_list = {}
    self._widget_press_stack = {}
    self._grid_line_positions = { {}, {} }
    self._always_full_alpha = true
    self._start_scale = start_scale
    self._num_rows = mod:get("grid_rows") or 3
    self._num_cols = mod:get("grid_cols") or 3
    self._saved_node_settings = mod:get("saved_node_settings") or {}
    self._default_node_settings = {}

    local visibility_groups = parent._visibility_groups
    local num_visibility_groups = #visibility_groups
    local elements_by_group = {}
    local scenegraphs = {}
    for i = 2, num_visibility_groups do
        local visibility_group = visibility_groups[i]
        local group_name = visibility_group.name
        local elements = visibility_group.visible_elements or {}
        table.insert(elements_by_group, {
            name = group_name,
            elements = elements
        })

        scenegraphs[group_name] = {}
        local element_scenegraphs = scenegraphs[group_name]
        for element_name in pairs(elements) do
            element_scenegraphs[element_name] = {}
        end
    end

    local selected_group_index = table.find_by_key(elements_by_group, "name", "alive") or 1
    local selected_group = elements_by_group[selected_group_index]
    local selected_group_elements = selected_group.elements

    local constant_elements = Managers.ui:ui_constant_elements()
    local constant_visibility_groups = constant_elements._visibility_groups
    local _, default_visibility_group = table.find_by_key(constant_visibility_groups, "name", "default")
    local visible_elements = (default_visibility_group and default_visibility_group.visible_elements) or {}

    table.merge(selected_group_elements, visible_elements)

    for element_name in pairs(visible_elements) do
        scenegraphs.alive[element_name] = {}
    end

    self._elements_by_group = elements_by_group
    self._selected_group_index = selected_group_index
    self._scenegraphs = scenegraphs

    -- TODO: Implement buttons for changing visibility groups?
    --mod:command("next", "", function()
    --    if self._selected_group_index == #elements_by_group then
    --        self._selected_group_index = 1
    --    else
    --        self._selected_group_index = self._selected_group_index + 1
    --    end
    --
    --    mod:echo("Group: [%s]: %s", self._selected_group_index, self._elements_by_group[self._selected_group_index].name)
    --    self._group_changed = true
    --end)
    --
    --mod:command("prev", "", function()
    --    if self._selected_group_index == 1 then
    --        self._selected_group_index = #elements_by_group
    --    else
    --        self._selected_group_index = self._selected_group_index - 1
    --    end
    --
    --    mod:echo("Group: [%s]: %s", self._selected_group_index, self._elements_by_group[self._selected_group_index].name)
    --    self._group_changed = true
    --end)

    local display_grid = mod:get("display_grid")
    self._display_grid = (display_grid == nil and true) or display_grid

    mod:command("grid", "", function(num_cols, num_rows)
        local is_displayed = self._display_grid
        if (not num_cols and not num_rows) or (self._num_cols == num_cols and self._num_rows == num_rows) then
            is_displayed = not is_displayed
        else
            is_displayed = true
        end

        self._grid_line_positions = nil
        self._num_cols = num_cols or self._num_cols
        self._num_rows = num_rows or self._num_rows
        self._display_grid = is_displayed

        mod:set("grid_rows", self._num_rows)
        mod:set("grid_cols", self._num_cols)

        mod:notify("Grid (%sx%s): [%s]", self._num_cols, self._num_rows, is_displayed and "on" or "off")
    end)

    local snap_to_grid = mod:get("snap_to_grid")
    self._snap_to_grid = (snap_to_grid == nil and true) or snap_to_grid

    mod:command("snap_to_grid", "", function(active)
        if active == nil then
            active = not self._snap_to_grid
        end

        mod:notify("Snap to grid: [%s]", active and "on" or "off")
        self._snap_to_grid = active
    end)

    HudElementCustomizer.super.init(self, parent, draw_layer, start_scale, _definitions)
end

function HudElementCustomizer:_get_element(element_name)
    local element = self._parent:element(element_name)
    if not element then
        local ui_constant_elements = Managers.ui:ui_constant_elements()
        element = ui_constant_elements:element(element_name)
    end

    return element
end

function HudElementCustomizer:_setup_elements(render_settings)
    local saved_node_settings = self._saved_node_settings
    local default_node_settings = self._default_node_settings
    local inverse_scale = render_settings.inverse_scale
    local font_type = "proxima_nova_bold"
    local font_size = 16

    -- Populate element scenegraph data once all elements are created
    for i, group_data in ipairs(self._elements_by_group) do
        local group_name = group_data.name
        local elements = group_data.elements
        local element_scenegraphs = self._scenegraphs[group_name]

        for element_name in pairs(elements) do
            repeat

                local element, scenegraph_id = self:_get_element(element_name)
                if _excluded_element_names[element_name] or not element then
                    break
                end

                local excluded_scenegraphs = _excluded_scenegraphs_by_element[element_name] or {}
                local ui_scenegraph = element._ui_scenegraph
                local element_definitions = element._definitions
                local scenegraph_definition = element_definitions and element_definitions.scenegraph_definition
                local children_scenegraphs = element_scenegraphs[element_name]
                local hierarchical_scenegraph = (ui_scenegraph and ui_scenegraph.hierarchical_scenegraph) or {}

                if not children_scenegraphs then
                    element_scenegraphs[element_name] = {}
                    children_scenegraphs = element_scenegraphs[element_name]
                end

                for j, scenegraph in ipairs(hierarchical_scenegraph) do
                    local children = scenegraph.children or {}
                    for _, child in ipairs(children) do
                        repeat

                            local child_name = child.name
                            if excluded_scenegraphs[child_name] then
                                break
                            end

                            child = table.clone(child)

                            -- TODO: Convert from "world space" and top-left alignment to local space and variable alignment

                            local node_name = string.format("%s|%s", element_name, child_name)
                            local node_settings = saved_node_settings[node_name]

                            local vertical_alignment = (node_settings and node_settings.vertical_alignment) or "top"
                            local horizontal_alignment = (node_settings and node_settings.horizontal_alignment) or "left"
                            local position = (node_settings and node_settings.position) or child.world_position
                            local size = (node_settings and node_settings.size) or child.size
                            --local scale = (node_settings and node_settings.scale) or 1

                            local scenegraph_node = scenegraph_definition and scenegraph_definition[scenegraph_id]
                            local default_settings = (node_settings and node_settings.default_settings) or {
                                size = (scenegraph_node and table.clone(scenegraph_node.size)) or table.clone(child.size),
                                position = (scenegraph_node and table.clone(scenegraph_node.position)) or table.clone(child.position),
                                vertical_alignment = (scenegraph_node and scenegraph_node.vertical_alignment) or child.vertical_alignment,
                                horizontal_alignment = (scenegraph_node and scenegraph_node.horizontal_alignment) or child.horizontal_alignment
                            }

                            default_node_settings[node_name] = default_settings

                            size[1] = ((size[1] ~= 0 and size[1]) or 25)
                            size[2] = ((size[2] ~= 0 and size[2]) or 25)

                            -- constant elements are unaffected by hud scale, so undo it for the anchors
                            local is_constant_element = string.starts_with(element_name, "ConstantElement")
                            if is_constant_element then
                                local inverse_hud_scale = self:_get_inverse_hud_scale()

                                size[1] = default_settings.size[1] * inverse_hud_scale
                                size[2] = default_settings.size[2] * inverse_hud_scale

                                position[1] = position[1] * inverse_hud_scale
                                position[2] = position[2] * inverse_hud_scale
                            end

                            --position[1] = position[1] * scale
                            --position[2] = position[2] * scale
                            --size = { size[1] * scale, size[2] * scale }

                            table.insert(children_scenegraphs, {
                                name = node_name,
                                size = size,
                                position = position,
                                vertical_alignment = vertical_alignment,
                                horizontal_alignment = horizontal_alignment,
                            })

                            _definitions.scenegraph_definition[node_name] = {
                                parent = "screen",
                                size = size,
                                position = position,
                                vertical_alignment = vertical_alignment,
                                horizontal_alignment = horizontal_alignment
                            }

                            local content_overrides = {
                                is_hidden = node_settings and node_settings.is_hidden,
                                size = size,
                                scale = 1
                            }
                            local definition = UIWidget.create_definition({
                                {
                                    pass_type = "hotspot",
                                    content_id = "hotspot",
                                    content = {
                                        pressed_callback = callback(self, "_on_widget_pressed", node_name),
                                        right_pressed_callback = callback(self, "_on_widget_right_pressed", node_name),
                                        double_click_callback = callback(self, "_on_widget_double_clicked", node_name)
                                    }
                                },
                                {
                                    pass_type = "rect",
                                    style_id = "border_rect",
                                    style = {
                                        color = { 255, 0, 0, 0 },
                                        offset = { 0, 0, 1 }
                                    },
                                    change_function = function(content, style)
                                        style.color = content.hotspot.is_selected and { 255, 255, 255, 0 } or { 255, 0, 0, 0 }
                                    end
                                },
                                {
                                    pass_type = "rect",
                                    style_id = "rect",
                                    style = {
                                        color = { 255, 255, 255, 255 },
                                        color_hidden = { 168, 30, 30, 30 },
                                        color_hidden_hovered = { 255, 60, 60, 60 },
                                        color_hovered = { 255, 168, 168, 168 },
                                        color_default = { 168, 168, 168, 168 },
                                        anim_hover_speed = 1,
                                        size = { size[1] - 4, size[2] - 4 },
                                        offset = { 2, 2, 2 }
                                    },
                                    change_function = function(content, style)
                                        local color = style.color
                                        local ignore_alpha = false
                                        local hotspot = content.hotspot
                                        local anim_hover_progress = hotspot.anim_hover_progress
                                        local is_hidden = content.is_hidden
                                        local color_from = is_hidden and style.color_hidden or style.color_default
                                        local color_to = is_hidden and style.color_hidden_hovered or style.color_hovered
                                        local content_size = content.size

                                        if content_size then
                                            style.size = { content_size[1] - 4, content_size[2] - 4 }
                                        end

                                        ColorUtilities.color_lerp(color_from, color_to, anim_hover_progress, color, ignore_alpha)
                                    end
                                },
                                {
                                    pass_type = "text",
                                    value_id = "text",
                                    value = node_name,
                                    style_id = "text",
                                    style = {
                                        size = { 1920, 1080 },
                                        font_size = font_size * inverse_scale,
                                        font_type = font_type,
                                        text_horizontal_alignment = "left",
                                        text_vertical_alignment = "top",
                                        text_color = Color.terminal_text_body(255, true),
                                        drop_shadow = true,
                                        offset = { 0, -14 * inverse_scale, 4 }
                                    },
                                    visibility_function = function(content, style)
                                        return content.hotspot.is_hover
                                    end
                                },
                                {
                                    pass_type = "text",
                                    value_id = "scale_text",
                                    value = 1,
                                    style = {
                                        font_size = font_size * inverse_scale,
                                        font_type = font_type,
                                        text_horizontal_alignment = "center",
                                        text_vertical_alignment = "center",
                                        text_color = Color.terminal_text_body(255, true),
                                        drop_shadow = true,
                                        offset = { 0, 0, 4 }
                                    },
                                    visibility_function = function(content, style)
                                        return content.hotspot.is_hover or content.hotspot.is_selected
                                    end,
                                    change_function = function(content, style)
                                        content.scale_text = string.format("x%.02f", content.scale)
                                    end
                                }
                            }, node_name, content_overrides)
                            _definitions.widget_definitions[node_name] = definition

                        until true
                    end
                end

            until true
        end
    end

    local scale = (self._inverse_scale and 1 / self._inverse_scale) or self._start_scale
    self._ui_scenegraph = self:_create_scenegraph(_definitions, scale)
    self:_create_widgets(_definitions, self._widgets, self._widgets_by_name)

    self:_apply_saved_node_settings()

    self._setup_complete = true
end

function HudElementCustomizer:reset_node(node_name)
    local node_settings = self._saved_node_settings[node_name]

    if not node_settings then
        return
    end

    local default_node_settings = node_settings.default_settings
    if not default_node_settings then
        mod:warning("No default settings for node [%s]! Ask author to investigate.", node_name)
        return
    end

    local element_name, scenegraph_id = split_node_name(node_name)
    local element = self:_get_element(element_name)

    if not element then
        return
    end

    local position = default_node_settings.position
    local vertical_alignment = default_node_settings.vertical_alignment
    local horizontal_alignment = default_node_settings.horizontal_alignment
    element:set_scenegraph_position(scenegraph_id, position[1], position[2], position[3], horizontal_alignment, vertical_alignment)
    --element._render_scale = 1

    self._saved_node_settings[node_name] = nil
    self._default_node_settings[node_name] = nil
    self._setup_complete = nil
end

function HudElementCustomizer:_process_widget_press_left(node_name)
    self._cursor_start_position = nil
    self._cursor_end_position = nil

    local widgets_by_name = self._widgets_by_name
    local selected_node_list = self._selected_node_list
    local num_selected_nodes = #selected_node_list
    local node_name_index = table.index_of(selected_node_list, node_name)
    local ctrl_held = is_ctrl_held()
    local shift_held = is_shift_held()

    if node_name_index > 0 then
        if shift_held then
            self._start_dragging = true
            self._cursor_start_position = nil
            self._cursor_end_position = nil
        elseif ctrl_held or num_selected_nodes == 1 then
            table.remove(selected_node_list, node_name_index)
            widgets_by_name[node_name].content.hotspot.is_selected = false

            return
        end
    end

    if shift_held then
        return
    end

    if not ctrl_held then
        for i, selected_node_name in ipairs(selected_node_list) do
            widgets_by_name[selected_node_name].content.hotspot.is_selected = false
        end

        table.clear(selected_node_list)
    end

    table.insert(selected_node_list, node_name)
    widgets_by_name[node_name].content.hotspot.is_selected = true
end

function HudElementCustomizer:_process_widget_press_right(node_name)
    local element_name, scenegraph_id = split_node_name(node_name)
    local element = self:_get_element(element_name)
    if not element then
        return
    end

    local node_widget = self._widgets_by_name[node_name]
    if not node_widget then
        return
    end

    local should_hide = not node_widget.content.is_hidden
    node_widget.content.is_hidden = should_hide

    if element.set_visible then
        element:set_visible(not should_hide)
    end

    element._is_hidden = should_hide

    local saved_node_settings = self._saved_node_settings
    local node_settings = saved_node_settings[node_name]
    if not node_settings then
        node_settings = self:_init_node_settings(node_name)
        saved_node_settings[node_name] = node_settings
    end

    node_settings.is_hidden = should_hide
end

function HudElementCustomizer:_on_widget_pressed(node_name)
    table.insert(self._widget_press_stack, {
        node_name = node_name,
        press_type = "left"
    })
end

function HudElementCustomizer:_on_widget_double_clicked(node_name)
    self:reset_node(node_name)
end

function HudElementCustomizer:_init_node_settings(node_name)
    local scenegraph_position = self:scenegraph_position(node_name)
    local scenegraph_size = self:scenegraph_size(node_name)
    local node_settings = {
        x = scenegraph_position[1],
        y = scenegraph_position[2],
        z = scenegraph_position[3],
        size = { scenegraph_size[1], scenegraph_size[2] },
        default_settings = self._default_node_settings[node_name]
    }
    self._saved_node_settings[node_name] = node_settings

    return node_settings
end

function HudElementCustomizer:_on_widget_right_pressed(node_name)
    table.insert(self._widget_press_stack, {
        node_name = node_name,
        press_type = "right"
    })
end

function HudElementCustomizer:using_input()
    return self._using_cursor
end

function HudElementCustomizer:_activate_mouse_cursor()
    local input_manager = Managers.input
    local name = self.__class_name

    if not input_manager:cursor_active() then
        input_manager:push_cursor(name)
    end

    self._using_cursor = true
end

function HudElementCustomizer:_deactivate_mouse_cursor()
    local input_manager = Managers.input
    local name = self.__class_name

    if input_manager:cursor_active() then
        input_manager:pop_cursor(name)
    end

    self._using_cursor = false
end

function HudElementCustomizer:_get_inverse_hud_scale()
    local default_value = 100
    local save_data = Managers.save:account_data()
    local interface_settings = save_data.interface_settings
    local hud_scale = (interface_settings.hud_scale or default_value) / 100
    local inverse_hud_scale = 1 / hud_scale

    return inverse_hud_scale
end

function HudElementCustomizer:_handle_widget_presses()
    local widget_press_stack = self._widget_press_stack
    local stack_size = #widget_press_stack
    if stack_size > 0 then
        if stack_size == 1 then
            local press_data = widget_press_stack[1]
            local node_name = press_data.node_name
            local press_type = press_data.press_type
            local press_func_name = string.format("_process_widget_press_%s", press_type)
            local press_func = self[press_func_name]

            if press_func then
                press_func(self, node_name)
            end
        elseif stack_size > 1 then
            local highest_z = -math.huge
            local index
            for i, press_data in ipairs(widget_press_stack) do
                local node_name = press_data.node_name
                local scenegraph_position = self:scenegraph_position(node_name)
                local z = scenegraph_position[3]

                if z > highest_z then
                    highest_z = z
                    index = i
                end
            end

            if index then
                local press_data = widget_press_stack[index]
                local node_name = press_data.node_name
                local press_type = press_data.press_type
                local press_func_name = string.format("_process_widget_press_%s", press_type)
                local press_func = self[press_func_name]

                if press_func then
                    press_func(self, node_name)
                end
            end
        end

        table.clear(self._widget_press_stack)
    end
end

function HudElementCustomizer:update(dt, t, ui_renderer, render_settings, input_service)

    if not self._setup_complete then
        self:_setup_elements(render_settings)
        return
    end

    self._inverse_scale = render_settings.inverse_scale

    local using_cursor = self._using_cursor
    if not using_cursor and mod.is_customizing then
        self:_activate_mouse_cursor()
    elseif using_cursor and not mod.is_customizing then
        self:_deactivate_mouse_cursor()
        return
    end

    self:_update_group_visibility()

    self:_handle_widget_presses()

    self:_handle_input(input_service)

    HudElementCustomizer.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

function HudElementCustomizer:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
    HudElementCustomizer.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

    self:_draw_grid(ui_renderer)
end

function HudElementCustomizer:_draw_grid(ui_renderer)

    if not self._display_grid then
        return
    end

    local width = RESOLUTION_LOOKUP.width
    local height = RESOLUTION_LOOKUP.height
    local inverse_scale = self._inverse_scale or RESOLUTION_LOOKUP.inverse_scale
    local draw_layer = 999

    local num_rows = self._num_rows
    local num_cols = self._num_cols
    local cell_width = width / num_cols
    local cell_height = height / num_rows

    local grid_line_positions = self._grid_line_positions or {
        {},
        {}
    }

    local center_row = (num_rows) / 2 + 1
    for i = 1, num_rows + 1 do
        local x = 1
        local y = (i - 1) * cell_height - 1
        local color = ((i == center_row or math.ceil(center_row) == i or math.floor(center_row) == i) and { 255, 255, 0, 0 }) or { 170, 255, 255, 255 }
        local position = Vector3(x * inverse_scale, y * inverse_scale, draw_layer)
        local size = Vector2(width * inverse_scale, 1)

        grid_line_positions[1][i] = position[2] / inverse_scale

        UIRenderer.draw_rect(ui_renderer, position, size, color)
    end

    local center_col = num_cols / 2 + 1
    for i = 1, num_cols + 1 do
        local x = (i - 1) * cell_width - 1
        local y = 0
        local color = ((i == center_col or math.ceil(center_col) == i or math.floor(center_col) == i) and { 255, 255, 0, 0 }) or { 170, 255, 255, 255 }
        local position = Vector3(x * inverse_scale, y * inverse_scale, draw_layer)
        local size = Vector2(1, height * inverse_scale)

        grid_line_positions[2][i] = position[1] / inverse_scale

        UIRenderer.draw_rect(ui_renderer, position, size, color)
    end

    self._grid_line_positions = grid_line_positions

end

function HudElementCustomizer:_handle_input(input_service)
    local saved_node_settings = self._saved_node_settings
    local selected_node_list = self._selected_node_list
    local num_selected_nodes = #selected_node_list

    if num_selected_nodes == 0 then
        return
    end

    if input_service:get("left_hold") and is_shift_held() then
        if not self._cursor_start_position then
            self._cursor_start_position = Vector3.to_array(input_service:get("cursor"))
        end

        self._cursor_end_position = Vector3.to_array(input_service:get("cursor"))
    else
        self._start_dragging = false
    end

    local should_clear_cursor_positions = false

    for i, node_name in ipairs(selected_node_list) do
        local node_settings = saved_node_settings[node_name]
        if not node_settings then
            node_settings = self:_init_node_settings(node_name)
        end

        local size = self:scenegraph_size(node_name)
        local scale = node_settings.scale or 1
        local inverse_scale = self._inverse_scale or RESOLUTION_LOOKUP.inverse_scale

        local scroll_axis = input_service:get("scroll_axis")
        if scroll_axis and scroll_axis[2] ~= 0 then
            local original_size = { size[1] / scale, size[2] / scale }
            local scroll_diff = (scroll_axis[2] > 0 and 0.05) or (scroll_axis[2] < 0 and -0.05) or 0

            scale = math.max(scale + scroll_diff, 0.05)
            node_settings.scale = scale

            local new_size = { original_size[1] * scale, original_size[2] * scale }
            node_settings.size = new_size

            local widget = self._widgets_by_name[node_name]

            widget.content.size = new_size
            widget.content.scale = scale

            self:_set_scenegraph_size(node_name, original_size[1] * scale, original_size[2] * scale)
        end

        local cursor_end_position = self._cursor_end_position
        if cursor_end_position then
            local cursor_start_position = self._cursor_start_position
            local cursor_diff_x = (cursor_end_position[1] - cursor_start_position[1]) * inverse_scale
            local cursor_diff_y = (cursor_end_position[2] - cursor_start_position[2]) * inverse_scale
            local dest_x = cursor_diff_x + node_settings.x
            local dest_y = cursor_diff_y + node_settings.y

            local ctrl_held = is_ctrl_held()
            self._display_grid = mod:get("display_grid")
            self._snap_to_grid = mod:get("snap_to_grid")

            if (num_selected_nodes == 1) and self._display_grid and (ctrl_held and not self._snap_to_grid) or (not ctrl_held and self._snap_to_grid) then

                local alt_held = is_alt_held()

                for _, line_y in ipairs(self._grid_line_positions[1]) do
                    local diff_y = (cursor_end_position[2] - line_y)

                    if alt_held then
                        local distance = math.abs(diff_y)
                        if distance >= 0 and distance < 5 then
                            dest_y = (line_y * inverse_scale) - (size[2] / 2)
                        end
                    elseif diff_y < -3 and diff_y > -10 then
                        dest_y = (line_y * inverse_scale) - size[2]
                    elseif diff_y > 3 and diff_y < 10 then
                        dest_y = line_y * inverse_scale
                    end
                end

                for _, line_x in ipairs(self._grid_line_positions[2]) do
                    local diff_x = (cursor_end_position[1] - line_x) * inverse_scale

                    if alt_held then
                        local distance = math.abs(diff_x)
                        if distance >= 0 and distance < 5 then
                            dest_x = (line_x * inverse_scale) - (size[1] / 2)
                        end
                    elseif diff_x < -3 and diff_x > -10 then
                        dest_x = (line_x * inverse_scale) - size[1]
                    elseif diff_x > 3 and diff_x < 10 then
                        dest_x = line_x * inverse_scale
                    end
                end
            end

            if self._start_dragging then
                self:set_scenegraph_position(node_name, dest_x, dest_y)
            else
                node_settings.x = dest_x
                node_settings.y = dest_y
                self:set_scenegraph_position(node_name, dest_x, dest_y)
                should_clear_cursor_positions = true
            end
        else
            if input_service:get("cycle_chat_channel") then
                self:reset_node(node_name)
            end

            local input = input_service:get("navigation_keys_virtual_axis")

            if is_shift_held() then
                node_settings.z = (node_settings.z or self:scenegraph_position(node_name)[3]) + input[2]
            else
                node_settings.x = node_settings.x + input[1]
                node_settings.y = node_settings.y - input[2]
            end

            self:set_scenegraph_position(node_name, node_settings.x, node_settings.y, node_settings.z)
        end
    end

    if should_clear_cursor_positions then
        self._cursor_start_position = nil
        self._cursor_end_position = nil
    end
end

function HudElementCustomizer:_update_group_visibility()
    if self._group_changed then
        self._group_changed = nil

        local current_group = self._elements_by_group[self._selected_group_index]
        if not current_group then
            return
        end

        local current_group_name = current_group.name
        for group_name, element_scenegraphs in pairs(self._scenegraphs) do
            for element_name, children in pairs(element_scenegraphs) do
                local visible = (current_group_name == group_name) or current_group.elements[element_name] or false
                for _, child in ipairs(children) do
                    self:set_scenegraph_widgets_visible(child.name, visible)
                end
            end
        end
    end
end

function HudElementCustomizer:set_visible(status)
    if status == false then
        if self._using_cursor then
            self:_deactivate_mouse_cursor()
        end

        self:_apply_saved_node_settings()

        --local widgets_by_name = self._widgets_by_name
        --local selected_node_list = self._selected_node_list
        --for i, node_name in ipairs(selected_node_list) do
        --    widgets_by_name[node_name].content.hotspot.is_selected = false
        --end
        --
        --table.clear(selected_node_list)
    end
end

function HudElementCustomizer:destroy()
    if self._using_cursor then
        self:_deactivate_mouse_cursor()
    end
end

function HudElementCustomizer:_apply_saved_node_settings()
    local saved_node_settings = self._saved_node_settings

    if not saved_node_settings then
        return
    end

    local inverse_hud_scale = self:_get_inverse_hud_scale()
    for node_name, node_settings in pairs(saved_node_settings) do
        local element_name, scenegraph_id = split_node_name(node_name)
        local element = self:_get_element(element_name)
        if element then

            local has_scenegraph_id = rawget(element._ui_scenegraph, scenegraph_id) ~= nil

            if has_scenegraph_id then
                local is_constant_element = string.starts_with(element_name, "ConstantElement")
                --local scale = node_settings.scale or 1
                local x = node_settings.x
                local y = node_settings.y
                local z = node_settings.z
                if is_constant_element then
                    x = x / inverse_hud_scale
                    y = y / inverse_hud_scale
                end

                if not element._hidden_scenegraphs then
                    element._hidden_scenegraphs = {}
                end

                --element._render_scale = scale
                element:set_scenegraph_position(scenegraph_id, x, y, z, "left", "top")
                element._is_hidden = node_settings.is_hidden

                local hooked_elements = mod._hooked_elements
                if not hooked_elements[element] then
                    mod:hook(element, "draw", function(func, self, ...)
                        -- TODO: Find a good way to hide individual scenegraph_ids instead of all
                        if self._is_hidden then
                            return
                        end

                        local element_render_settings = select(4, ...)

                        --element_render_settings.scale = self._render_scale or 1
                        local opacity = tonumber(mod:get("opacity"))
                        if opacity ~= nil then
                            if type(element_render_settings) == "table" then
                                element_render_settings.alpha_multiplier = opacity
                            end
                        end

                        return func(self, ...)
                    end)

                    hooked_elements[element] = true
                end
            else
                saved_node_settings[node_name] = nil
            end
        end
    end

    mod:set("saved_node_settings", saved_node_settings)
end

return HudElementCustomizer
