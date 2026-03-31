local mod = get_mod("custom_hud")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local ColorUtilities = mod:original_require("scripts/utilities/ui/colors")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

-- ============================================================================
-- Constants
-- ============================================================================

local PANEL_WIDTH = 340
local PANEL_MARGIN = 10
local PANEL_LINE_HEIGHT = 22
local PANEL_HEADER_HEIGHT = 32
local PANEL_DETAIL_HEIGHT = 310
local PANEL_MAX_VISIBLE_LINES = 30
local PANEL_BG_COLOR = { 200, 15, 15, 15 }
local PANEL_HEADER_COLOR = { 220, 25, 25, 30 }
local PANEL_LINE_COLOR = { 0, 0, 0, 0 }
local PANEL_LINE_HOVER_COLOR = { 100, 60, 60, 80 }
local PANEL_LINE_SELECTED_COLOR = { 150, 80, 120, 80 }
local PANEL_DETAIL_BG_COLOR = { 200, 20, 20, 25 }
local PANEL_TEXT_COLOR = { 255, 200, 200, 200 }
local PANEL_TEXT_HIDDEN_COLOR = { 180, 120, 60, 60 }
local PANEL_DETAIL_LABEL_COLOR = { 200, 140, 140, 140 }
local PANEL_DETAIL_VALUE_COLOR = { 255, 220, 220, 220 }
local PANEL_SCROLL_SPEED = 3


local PANEL_FONT_TYPE = "proxima_nova_bold"
local PANEL_FONT_SIZE = 18
local PANEL_FONT_SIZE_SMALL = 15

local function _safe_draw_text(ui_renderer, text, font_type, font_size, position, size, color, horizontal_alignment, vertical_alignment)
    if text == nil then
        return false
    end
    text = tostring(text)
    if text == "" then
        return false
    end

    local options = {
        horizontal_alignment = horizontal_alignment or "left",
        vertical_alignment = vertical_alignment or "center",
        drop_shadow = true,
        word_wrap = false,
    }

    local tries = {
        function() return UIRenderer.draw_text(ui_renderer, text, font_type, font_size, position, size, color, options) end,
        function() return UIRenderer.draw_text(ui_renderer, text, font_type, font_size, position, size, color) end,
        function() return UIRenderer.draw_text(ui_renderer, text, font_size, font_type, position, size, color, options) end,
        function() return UIRenderer.draw_text(ui_renderer, text, font_size, font_type, position, size, color) end,
        function() return UIRenderer.draw_text(ui_renderer, text, nil, font_size, font_type, position, size, color, options) end,
        function() return UIRenderer.draw_text(ui_renderer, text, nil, font_size, font_type, position, size, color) end,
    }

    for i = 1, #tries do
        local ok = pcall(tries[i])
        if ok then
            return true
        end
    end

    return false
end

local RESIZE_HANDLE_SIZE = 12
local RESIZE_HANDLE_COLOR = { 220, 255, 200, 50 }
local RESIZE_HANDLE_HOVER_COLOR = { 255, 255, 255, 100 }
local RESIZE_EDGE_THRESHOLD = 10

local _excluded_element_names = {
    HudElementCustomizer = true,
    HudElementPrologueTutorialSequenceTransitionEnd = true,
    HudElementPrologueTutorialInfoBox = true,
    HudElementCrosshair = true,
    HudElementInteraction = true,
    HudElementWorldMarkers = true,
    HudElementTacticalOverlay = true,
    HudElementEmoteWheel = true,
    HudElementSmartTagging = true,
    HudElementDamageIndicator = true,
    ConstantElementWatermark = true,
    ConstantElementPopupHandler = true,
    ConstantElementSoftwareCursor = true,
    ConstantElementExpeditionContinue = true,
}

local _excluded_scenegraphs_by_element = {
    HudElementPlayerWeaponHandler = {
        weapon_slot_1 = true,
        weapon_slot_2 = true,
        weapon_slot_3 = true,
        weapon_slot_4 = true
    }
}

-- ============================================================================
-- Keyboard helpers
-- ============================================================================

local Keyboard = Keyboard

local function _get_keyboard()
    if not Keyboard then
        Keyboard = rawget(_G, "Keyboard")
    end
    return Keyboard
end

local function is_shift_held()
    local kb = _get_keyboard()
    return kb and kb.button(kb.button_index("left shift")) > 0.5
end

local function is_alt_held()
    local kb = _get_keyboard()
    return kb and kb.button(kb.button_index("left alt")) > 0.5
end

local function is_ctrl_held()
    local kb = _get_keyboard()
    return kb and kb.button(kb.button_index("left ctrl")) > 0.5
end

-- ============================================================================
-- Utilities
-- ============================================================================



local function _point_in_rect(x, y, rx, ry, rw, rh)
    return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

local function _format_field_value(v)
    if v == nil then
        return ""
    end
    if math.type and math.type(v) == "integer" then
        return tostring(v)
    end
    local n = tonumber(v) or 0
    if math.abs(n - math.floor(n)) < 0.001 then
        return tostring(math.floor(n))
    end
    return string.format("%.2f", n)
end

local function _copy_table(t)
    return t and table.clone(t) or nil
end

local function split_node_name(node_name)
    local splits = string.split(node_name, "|")
    return splits[1], splits[2]
end

local function short_element_name(node_name)
    local element_name, scenegraph_id = split_node_name(node_name)
    -- Strip "HudElement" or "ConstantElement" prefix for display
    local short = element_name:gsub("^HudElement", ""):gsub("^ConstantElement", "C:")
    if scenegraph_id and scenegraph_id ~= "" then
        return short .. "|" .. scenegraph_id
    end
    return short
end

-- ============================================================================
-- Definitions
-- ============================================================================

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

-- ============================================================================
-- Class
-- ============================================================================

local HudElementCustomizer = class("HudElementCustomizer", "HudElementBase")

function HudElementCustomizer:init(parent, draw_layer, start_scale)
    self._selected_node_list = {}
    self._widget_press_stack = {}
    self._grid_line_positions = { {}, {} }
    self._always_full_alpha = true
    self._start_scale = start_scale

    -- Cached settings
    self._num_rows = mod:get("grid_rows") or 3
    self._num_cols = mod:get("grid_cols") or 3
    self._display_grid = mod:get("display_grid")
    if self._display_grid == nil then self._display_grid = true end
    self._snap_to_grid = mod:get("snap_to_grid")
    if self._snap_to_grid == nil then self._snap_to_grid = true end
    self._show_info_panel = mod:get("show_info_panel")
    if self._show_info_panel == nil then self._show_info_panel = true end

    self._saved_node_settings = mod:get("saved_node_settings") or {}
    self._default_node_settings = {}

    -- Cursor tracking - FIX: track our own push state, not input_manager state
    self._cursor_pushed = false
    self._using_cursor = false

    -- Info panel state
    self._panel_scroll_offset = 0
    self._panel_all_node_names = {}  -- ordered list of all node names
    self._panel_hovered_index = nil
    self._panel_dragging = false
    self._panel_drag_offset = nil
    self._panel_position = mod:get("panel_position")
    self._panel_active_field = nil
    self._panel_field_targets = {}
    self._panel_key_repeat = {}

    -- Resize state
    self._resize_mode = false
    self._resize_edge = nil  -- "tl", "tr", "bl", "br", "t", "b", "l", "r"
    self._resize_start_cursor = nil
    self._resize_start_size = nil
    self._resize_start_pos = nil
    self._resize_node_name = nil

    -- Build visibility group data
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
        for element_name in pairs(elements) do
            scenegraphs[group_name][element_name] = {}
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

    -- Commands
    mod:command("grid", "", function(num_cols, num_rows)
        local is_displayed = self._display_grid
        if (not num_cols and not num_rows) or (self._num_cols == num_cols and self._num_rows == num_rows) then
            is_displayed = not is_displayed
        else
            is_displayed = true
        end

        self._grid_line_positions = { {}, {} }
        self._num_cols = num_cols or self._num_cols
        self._num_rows = num_rows or self._num_rows
        self._display_grid = is_displayed

        mod:set("grid_rows", self._num_rows)
        mod:set("grid_cols", self._num_cols)
        mod:set("display_grid", self._display_grid)

        mod:notify("Grid (%sx%s): [%s]", self._num_cols, self._num_rows, is_displayed and "on" or "off")
    end)

    mod:command("snap_to_grid", "", function(active)
        if active == nil then
            active = not self._snap_to_grid
        end
        self._snap_to_grid = active
        mod:set("snap_to_grid", active)
        mod:notify("Snap to grid: [%s]", active and "on" or "off")
    end)

    mod:command("panel", "", function()
        self._show_info_panel = not self._show_info_panel
        mod:set("show_info_panel", self._show_info_panel)
        mod:notify("Info panel: [%s]", self._show_info_panel and "on" or "off")
    end)

    HudElementCustomizer.super.init(self, parent, draw_layer, start_scale, _definitions)
end

-- ============================================================================
-- Element lookup
-- ============================================================================

function HudElementCustomizer:_get_element(element_name)
    local element = self._parent:element(element_name)
    if not element then
        local ui_constant_elements = Managers.ui:ui_constant_elements()
        element = ui_constant_elements:element(element_name)
    end
    return element
end

-- ============================================================================
-- Setup
-- ============================================================================

function HudElementCustomizer:_setup_elements(render_settings)
    local saved_node_settings = self._saved_node_settings
    local default_node_settings = self._default_node_settings
    local inverse_scale = render_settings.inverse_scale
    local font_type = "proxima_nova_bold"
    local font_size = 16
    local all_node_names = {}
    local seen_panel_nodes = {}

    for i, group_data in ipairs(self._elements_by_group) do
        local group_name = group_data.name
        local elements = group_data.elements
        local element_scenegraphs = self._scenegraphs[group_name]

        for element_name in pairs(elements) do
            repeat
                local element = self:_get_element(element_name)
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

                            local node_name = string.format("%s|%s", element_name, child_name)
                            local node_settings = saved_node_settings[node_name]

                            local vertical_alignment = (node_settings and node_settings.vertical_alignment) or "top"
                            local horizontal_alignment = (node_settings and node_settings.horizontal_alignment) or "left"
                            local position = (node_settings and node_settings.position) or child.world_position
                            local size = (node_settings and node_settings.size) or child.size
                            local scenegraph_id = child_name

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

                            local is_constant_element = string.starts_with(element_name, "ConstantElement")
                            if is_constant_element then
                                local inverse_hud_scale = self:_get_inverse_hud_scale()
                                size[1] = default_settings.size[1] * inverse_hud_scale
                                size[2] = default_settings.size[2] * inverse_hud_scale
                                position[1] = position[1] * inverse_hud_scale
                                position[2] = position[2] * inverse_hud_scale
                            end

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
                                scale = (node_settings and node_settings.scale) or 1
                            }

                            -- Pre-compute inner size to avoid per-frame allocation
                            local inner_w = size[1] - 4
                            local inner_h = size[2] - 4

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
                                        size = { inner_w, inner_h },
                                        offset = { 2, 2, 2 }
                                    },
                                    change_function = function(content, style)
                                        local color = style.color
                                        local hotspot = content.hotspot
                                        local anim_hover_progress = hotspot.anim_hover_progress
                                        local is_hidden = content.is_hidden
                                        local color_from = is_hidden and style.color_hidden or style.color_default
                                        local color_to = is_hidden and style.color_hidden_hovered or style.color_hovered
                                        local content_size = content.size

                                        if content_size then
                                            style.size[1] = content_size[1] - 4
                                            style.size[2] = content_size[2] - 4
                                        end

                                        ColorUtilities.color_lerp(color_from, color_to, anim_hover_progress, color, false)
                                    end
                                },
                                -- Element name tooltip on hover
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
                                -- Scale label
                                {
                                    pass_type = "text",
                                    value_id = "scale_text",
                                    value = "x1.00",
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
                                        content.scale_text = string.format("x%.02f", content.scale or 1)
                                    end
                                },
                                -- Position info when selected
                                {
                                    pass_type = "text",
                                    value_id = "pos_text",
                                    value = "",
                                    style_id = "pos_text",
                                    style = {
                                        size = { 300, 20 },
                                        font_size = (font_size - 2) * inverse_scale,
                                        font_type = font_type,
                                        text_horizontal_alignment = "left",
                                        text_vertical_alignment = "top",
                                        text_color = { 220, 180, 255, 180 },
                                        drop_shadow = true,
                                        offset = { 0, -28 * inverse_scale, 4 }
                                    },
                                    visibility_function = function(content, style)
                                        return content.hotspot.is_selected
                                    end,
                                    change_function = function(content, style)
                                        local sz = content.size
                                        local sc = content.scale or 1
                                        content.pos_text = string.format("%.0f,%.0f  z:%.0f  %dx%d",
                                            content.node_x or 0, content.node_y or 0, content.node_z or 0,
                                            sz and sz[1] or 0, sz and sz[2] or 0)
                                    end
                                }
                            }, node_name, content_overrides)

                            _definitions.widget_definitions[node_name] = definition
                            if not seen_panel_nodes[node_name] then
                                seen_panel_nodes[node_name] = true
                                table.insert(all_node_names, node_name)
                            end

                        until true
                    end
                end
            until true
        end
    end

    -- Sort node names alphabetically for panel display
    table.sort(all_node_names)
    self._panel_all_node_names = all_node_names

    local scale = (self._inverse_scale and 1 / self._inverse_scale) or self._start_scale
    self._ui_scenegraph = self:_create_scenegraph(_definitions, scale)
    self:_create_widgets(_definitions, self._widgets, self._widgets_by_name)
    self:_apply_saved_node_settings()
    self._setup_complete = true
end

-- ============================================================================
-- Node management
-- ============================================================================

function HudElementCustomizer:reset_node(node_name)
    local node_settings = self._saved_node_settings[node_name]
    if not node_settings then
        return
    end

    local default_node_settings = node_settings.default_settings
    if not default_node_settings then
        mod:warning("No default settings for node [%s]!", node_name)
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

    self._saved_node_settings[node_name] = nil
    self._default_node_settings[node_name] = nil
    self._setup_complete = nil
    self:_persist_saved_settings()
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
    self:_persist_saved_settings()
    return node_settings
end


function HudElementCustomizer:_persist_saved_settings()
    mod:set("saved_node_settings", self._saved_node_settings or {})
end

function HudElementCustomizer:_get_selected_node_settings(node_name)
    local settings = self._saved_node_settings[node_name]
    if not settings then
        settings = self:_init_node_settings(node_name)
    end
    return settings
end

function HudElementCustomizer:_apply_node_settings_live(node_name, node_settings)
    local widget = self._widgets_by_name[node_name]
    if widget then
        widget.content.size = node_settings.size
        widget.content.scale = node_settings.scale or 1
        widget.content.node_x = node_settings.x
        widget.content.node_y = node_settings.y
        widget.content.node_z = node_settings.z or 0
    end

    if node_settings.size then
        self:_set_scenegraph_size(node_name, node_settings.size[1], node_settings.size[2])
    end
    self:set_scenegraph_position(node_name, node_settings.x or 0, node_settings.y or 0, node_settings.z or 0)
    self:_persist_saved_settings()
end

function HudElementCustomizer:_get_field_numeric_value(node_name, group_name, field_key)
    local node_settings = self:_get_selected_node_settings(node_name)
    local defaults = node_settings.default_settings or self._default_node_settings[node_name] or {}
    local default_pos = defaults.position or {0,0,0}
    local default_size = defaults.size or {0,0}

    if group_name == "current" then
        if field_key == "x" then return node_settings.x or 0 end
        if field_key == "y" then return node_settings.y or 0 end
        if field_key == "z" then return node_settings.z or 0 end
        if field_key == "w" then return (node_settings.size and node_settings.size[1]) or 0 end
        if field_key == "h" then return (node_settings.size and node_settings.size[2]) or 0 end
    else
        if field_key == "x" then return default_pos[1] or 0 end
        if field_key == "y" then return default_pos[2] or 0 end
        if field_key == "z" then return default_pos[3] or 0 end
        if field_key == "w" then return default_size[1] or 0 end
        if field_key == "h" then return default_size[2] or 0 end
    end

    return 0
end

function HudElementCustomizer:_set_field_numeric_value(node_name, group_name, field_key, value)
    local node_settings = self:_get_selected_node_settings(node_name)
    node_settings.default_settings = node_settings.default_settings or _copy_table(self._default_node_settings[node_name]) or {}
    local defaults = node_settings.default_settings
    defaults.position = defaults.position or {0,0,0}
    defaults.size = defaults.size or {0,0}

    if group_name == "current" then
        if field_key == "x" then node_settings.x = value end
        if field_key == "y" then node_settings.y = value end
        if field_key == "z" then node_settings.z = value end
        if field_key == "w" then
            node_settings.size = node_settings.size or {0,0}
            node_settings.size[1] = math.max(1, math.floor(value + 0.5))
        end
        if field_key == "h" then
            node_settings.size = node_settings.size or {0,0}
            node_settings.size[2] = math.max(1, math.floor(value + 0.5))
        end
        self:_apply_node_settings_live(node_name, node_settings)
    else
        if field_key == "x" then defaults.position[1] = value end
        if field_key == "y" then defaults.position[2] = value end
        if field_key == "z" then defaults.position[3] = value end
        if field_key == "w" then defaults.size[1] = math.max(1, math.floor(value + 0.5)) end
        if field_key == "h" then defaults.size[2] = math.max(1, math.floor(value + 0.5)) end
        self._default_node_settings[node_name] = defaults
        self:_persist_saved_settings()
    end
end

function HudElementCustomizer:_activate_panel_field(node_name, group_name, field_key)
    self._panel_active_field = {
        node_name = node_name,
        group = group_name,
        key = field_key,
        buffer = _format_field_value(self:_get_field_numeric_value(node_name, group_name, field_key)),
        replace_on_first_input = true
    }
    self._panel_key_repeat = {}
end

function HudElementCustomizer:_commit_panel_field()
    local active = self._panel_active_field
    if not active then
        return
    end

    local value = tonumber(active.buffer)
    if value ~= nil then
        self:_set_field_numeric_value(active.node_name, active.group, active.key, value)
    end

    self._panel_active_field = nil
    self._panel_key_repeat = {}
end

function HudElementCustomizer:_apply_panel_active_buffer()
    local active = self._panel_active_field
    if not active then
        return false
    end

    local value = tonumber(active.buffer)
    if value == nil then
        return false
    end

    self:_set_field_numeric_value(active.node_name, active.group, active.key, value)
    return true
end

function HudElementCustomizer:_cancel_panel_field()
    self._panel_active_field = nil
    self._panel_key_repeat = {}
end

function HudElementCustomizer:_panel_take_key(key_name)
    local kb = _get_keyboard()
    if not kb then
        return false
    end
    local ok, idx = pcall(kb.button_index, key_name)
    if not ok or not idx then
        return false
    end
    local down = kb.button(idx) > 0.5
    local was_down = self._panel_key_repeat[key_name]
    self._panel_key_repeat[key_name] = down
    return down and not was_down
end

function HudElementCustomizer:_handle_panel_text_input()
    local active = self._panel_active_field
    if not active then
        return false
    end

    local changed = false

    local function prepare_buffer_for_char(char)
        local buffer = active.buffer or ""
        if active.replace_on_first_input then
            if char == "-" then
                buffer = "-"
            elseif char == "." then
                buffer = "0."
            else
                buffer = ""
            end
            active.replace_on_first_input = false
        end
        return buffer
    end

    local function append_char(char)
        local buffer = prepare_buffer_for_char(char)
        if char == "." then
            if not string.find(buffer, ".", 1, true) then
                active.buffer = (buffer == "" or buffer == "-") and (buffer .. "0.") or (buffer .. ".")
                changed = true
            end
            return
        end
        if char == "-" then
            if buffer == "" then
                active.buffer = "-"
                changed = true
            end
            return
        end
        active.buffer = buffer .. char
        changed = true
    end

    local digit_keys = {
        {"0", "0"}, {"1", "1"}, {"2", "2"}, {"3", "3"}, {"4", "4"},
        {"5", "5"}, {"6", "6"}, {"7", "7"}, {"8", "8"}, {"9", "9"},
        {"numpad 0", "0"}, {"numpad 1", "1"}, {"numpad 2", "2"}, {"numpad 3", "3"}, {"numpad 4", "4"},
        {"numpad 5", "5"}, {"numpad 6", "6"}, {"numpad 7", "7"}, {"numpad 8", "8"}, {"numpad 9", "9"}
    }

    for _, entry in ipairs(digit_keys) do
        if self:_panel_take_key(entry[1]) then
            append_char(entry[2])
        end
    end

    if self:_panel_take_key("backspace") then
        local buffer = active.buffer or ""
        if active.replace_on_first_input then
            active.buffer = ""
            active.replace_on_first_input = false
        else
            active.buffer = buffer:sub(1, math.max(0, #buffer - 1))
        end
        changed = true
    end

    if self:_panel_take_key("delete") then
        active.buffer = ""
        active.replace_on_first_input = false
        changed = true
    end

    if self:_panel_take_key("minus") or self:_panel_take_key("numpad -") then
        append_char("-")
    end

    if self:_panel_take_key("period") or self:_panel_take_key("decimal") or self:_panel_take_key("numpad .") then
        append_char(".")
    end

    if self:_panel_take_key("escape") then
        self:_cancel_panel_field()
        return true
    end

    if changed then
        self:_apply_panel_active_buffer()
    end

    return true
end

-- ============================================================================
-- Widget press handling
-- ============================================================================

function HudElementCustomizer:_on_widget_pressed(node_name)
    table.insert(self._widget_press_stack, { node_name = node_name, press_type = "left" })
end

function HudElementCustomizer:_on_widget_right_pressed(node_name)
    table.insert(self._widget_press_stack, { node_name = node_name, press_type = "right" })
end

function HudElementCustomizer:_on_widget_double_clicked(node_name)
    self:reset_node(node_name)
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
    local alt_held = is_alt_held()

    if node_name_index > 0 then
        if shift_held then
            self._start_dragging = true
            self._cursor_start_position = nil
            self._cursor_end_position = nil
            return
        elseif alt_held and num_selected_nodes == 1 then
            -- Preserve the current single selection so Alt+hold can start resize mode.
            return
        elseif ctrl_held or num_selected_nodes == 1 then
            table.remove(selected_node_list, node_name_index)
            widgets_by_name[node_name].content.hotspot.is_selected = false
            self:_persist_saved_settings()
            return
        end
    end

    if shift_held then
        return
    end

    if not ctrl_held then
        for _, selected_node_name in ipairs(selected_node_list) do
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
    end
    node_settings.is_hidden = should_hide
    self:_persist_saved_settings()
end

function HudElementCustomizer:_handle_widget_presses()
    local widget_press_stack = self._widget_press_stack
    local stack_size = #widget_press_stack
    if stack_size == 0 then
        return
    end

    local press_data
    if stack_size == 1 then
        press_data = widget_press_stack[1]
    else
        -- Multiple overlapping widgets pressed: pick highest z
        local highest_z = -math.huge
        local best_index
        for i, pd in ipairs(widget_press_stack) do
            local pos = self:scenegraph_position(pd.node_name)
            if pos and pos[3] > highest_z then
                highest_z = pos[3]
                best_index = i
            end
        end
        press_data = best_index and widget_press_stack[best_index]
    end

    if press_data then
        local func_name = press_data.press_type == "left" and "_process_widget_press_left" or "_process_widget_press_right"
        self[func_name](self, press_data.node_name)
    end

    table.clear(self._widget_press_stack)
end

-- ============================================================================
-- Cursor management - FIXED: tracks own push state to prevent imbalanced pop
-- ============================================================================

function HudElementCustomizer:using_input()
    return self._using_cursor
end

function HudElementCustomizer:_activate_mouse_cursor()
    if not self._cursor_pushed then
        local input_manager = Managers.input
        input_manager:push_cursor(self.__class_name)
        self._cursor_pushed = true
    end
    self._using_cursor = true
end

function HudElementCustomizer:_deactivate_mouse_cursor()
    if self._cursor_pushed then
        local input_manager = Managers.input
        input_manager:pop_cursor(self.__class_name)
        self._cursor_pushed = false
    end
    self._using_cursor = false
end

function HudElementCustomizer:_get_inverse_hud_scale()
    local default_value = 100
    local save_data = Managers.save:account_data()
    local interface_settings = save_data.interface_settings
    local hud_scale = (interface_settings.hud_scale or default_value) / 100
    return 1 / hud_scale
end

-- ============================================================================
-- Visibility
-- ============================================================================

function HudElementCustomizer:set_visible(status)
    if status == false then
        if self._using_cursor then
            self:_deactivate_mouse_cursor()
        end

        self:_apply_saved_node_settings()
    end
end

function HudElementCustomizer:destroy()
    if self._using_cursor then
        self:_deactivate_mouse_cursor()
    end
end

function HudElementCustomizer:_update_group_visibility()
    if not self._group_changed then
        return
    end
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

-- ============================================================================
-- Resize detection
-- ============================================================================

function HudElementCustomizer:_detect_resize_edge(node_name, cursor_pos)
    local sg_pos = self:scenegraph_world_position(node_name)
    local sg_size = self:scenegraph_size(node_name)
    if not sg_pos or not sg_size then
        return nil
    end

    local scale = 1 / (self._inverse_scale or RESOLUTION_LOOKUP.inverse_scale)
    local x = sg_pos[1] * scale
    local y = sg_pos[2] * scale
    local w = sg_size[1] * scale
    local h = sg_size[2] * scale
    local cx, cy = cursor_pos[1], cursor_pos[2]
    local t = RESIZE_EDGE_THRESHOLD

    local near_left = cx >= x and cx <= x + t
    local near_right = cx >= x + w - t and cx <= x + w
    local near_top = cy >= y and cy <= y + t
    local near_bottom = cy >= y + h - t and cy <= y + h
    local in_x = cx >= x and cx <= x + w
    local in_y = cy >= y and cy <= y + h

    if near_top and near_left then return "tl"
    elseif near_top and near_right then return "tr"
    elseif near_bottom and near_left then return "bl"
    elseif near_bottom and near_right then return "br"
    elseif near_top and in_x then return "t"
    elseif near_bottom and in_x then return "b"
    elseif near_left and in_y then return "l"
    elseif near_right and in_y then return "r"
    end

    return nil
end

-- ============================================================================
-- Input handling
-- ============================================================================

function HudElementCustomizer:_handle_input(input_service)
    local saved_node_settings = self._saved_node_settings
    local selected_node_list = self._selected_node_list
    local num_selected_nodes = #selected_node_list

    if num_selected_nodes == 0 then
        self._resize_mode = false
        return
    end

    local inverse_scale = self._inverse_scale or RESOLUTION_LOOKUP.inverse_scale

    -- Handle resize mode
    if self._resize_mode then
        self:_handle_resize_input(input_service, inverse_scale)
        return
    end

    -- Check for resize initiation on single selected node
    if num_selected_nodes == 1 and input_service:get("left_hold") and is_alt_held() then
        local node_name = selected_node_list[1]
        local cursor = input_service:get("cursor")
        if cursor then
            local cursor_arr = Vector3.to_array(cursor)
            local edge = self:_detect_resize_edge(node_name, cursor_arr)
            if edge then
                local node_settings = saved_node_settings[node_name] or self:_init_node_settings(node_name)
                self._resize_mode = true
                self._resize_edge = edge
                self._resize_node_name = node_name
                self._resize_start_cursor = cursor_arr
                self._resize_start_size = { node_settings.size[1], node_settings.size[2] }
                self._resize_start_pos = { node_settings.x, node_settings.y }
                return
            end
        end
    end

    -- Normal drag with shift+hold
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

        -- Scroll wheel: scale
        local scroll_axis = input_service:get("scroll_axis")
        if scroll_axis and scroll_axis[2] ~= 0 then
            local original_size = { size[1] / scale, size[2] / scale }
            local scroll_diff = (scroll_axis[2] > 0 and 0.05) or (scroll_axis[2] < 0 and -0.05) or 0

            scale = math.max(scale + scroll_diff, 0.05)
            node_settings.scale = scale

            local new_size = { original_size[1] * scale, original_size[2] * scale }
            node_settings.size = new_size

            local widget = self._widgets_by_name[node_name]
            if widget then
                widget.content.size = new_size
                widget.content.scale = scale
            end
            self:_set_scenegraph_size(node_name, new_size[1], new_size[2])
        end

        -- Update widget content for position display
        local widget = self._widgets_by_name[node_name]
        if widget then
            widget.content.node_x = node_settings.x
            widget.content.node_y = node_settings.y
            widget.content.node_z = node_settings.z or 0
        end

        -- Cursor-based dragging
        local cursor_end_position = self._cursor_end_position
        if cursor_end_position then
            local cursor_start_position = self._cursor_start_position
            local cursor_diff_x = (cursor_end_position[1] - cursor_start_position[1]) * inverse_scale
            local cursor_diff_y = (cursor_end_position[2] - cursor_start_position[2]) * inverse_scale
            local dest_x = cursor_diff_x + node_settings.x
            local dest_y = cursor_diff_y + node_settings.y

            -- Grid snapping
            local ctrl_held = is_ctrl_held()
            local should_snap = (num_selected_nodes == 1) and self._display_grid
                and ((ctrl_held and not self._snap_to_grid) or (not ctrl_held and self._snap_to_grid))

            if should_snap and self._grid_line_positions then
                local alt_held = is_alt_held()
                local grid_y = self._grid_line_positions[1]
                local grid_x = self._grid_line_positions[2]

                if grid_y then
                    for _, line_y in ipairs(grid_y) do
                        local diff_y = cursor_end_position[2] - line_y
                        if alt_held then
                            if math.abs(diff_y) < 5 then
                                dest_y = (line_y * inverse_scale) - (size[2] / 2)
                            end
                        elseif diff_y < -3 and diff_y > -10 then
                            dest_y = (line_y * inverse_scale) - size[2]
                        elseif diff_y > 3 and diff_y < 10 then
                            dest_y = line_y * inverse_scale
                        end
                    end
                end

                if grid_x then
                    for _, line_x in ipairs(grid_x) do
                        local diff_x = (cursor_end_position[1] - line_x) * inverse_scale
                        if alt_held then
                            if math.abs(diff_x) < 5 then
                                dest_x = (line_x * inverse_scale) - (size[1] / 2)
                            end
                        elseif diff_x < -3 and diff_x > -10 then
                            dest_x = (line_x * inverse_scale) - size[1]
                        elseif diff_x > 3 and diff_x < 10 then
                            dest_x = line_x * inverse_scale
                        end
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
            -- Tab = reset node
            if input_service:get("cycle_chat_channel") then
                self:reset_node(node_name)
            end

            local input = input_service:get("navigation_keys_virtual_axis")
            if input then
                local alt_held = is_alt_held()

                if alt_held then
                    -- Alt + Arrow keys = resize
                    local dw = input[1]
                    local dh = -input[2]
                    if dw ~= 0 or dh ~= 0 then
                        local current_size = node_settings.size or { size[1], size[2] }
                        local new_w = math.max(current_size[1] + dw, 5)
                        local new_h = math.max(current_size[2] + dh, 5)
                        node_settings.size = { new_w, new_h }

                        local base_scale = node_settings.scale or 1
                        local widget_ref = self._widgets_by_name[node_name]
                        if widget_ref then
                            widget_ref.content.size = { new_w, new_h }
                        end
                        self:_set_scenegraph_size(node_name, new_w, new_h)
                    end
                elseif is_shift_held() then
                    -- Shift + Up/Down = z-order
                    node_settings.z = (node_settings.z or self:scenegraph_position(node_name)[3]) + input[2]
                else
                    -- Arrow keys = move
                    node_settings.x = node_settings.x + input[1]
                    node_settings.y = node_settings.y - input[2]
                end

                self:set_scenegraph_position(node_name, node_settings.x, node_settings.y, node_settings.z)
            end
        end
    end

    if should_clear_cursor_positions then
        self._cursor_start_position = nil
        self._cursor_end_position = nil
    end

    self:_persist_saved_settings()
end

function HudElementCustomizer:_handle_resize_input(input_service, inverse_scale)
    if not input_service:get("left_hold") then
        -- Released - commit resize
        self._resize_mode = false
        return
    end

    local cursor = input_service:get("cursor")
    if not cursor then
        return
    end

    local cursor_arr = Vector3.to_array(cursor)
    local dx = (cursor_arr[1] - self._resize_start_cursor[1]) * inverse_scale
    local dy = (cursor_arr[2] - self._resize_start_cursor[2]) * inverse_scale
    local edge = self._resize_edge
    local node_name = self._resize_node_name
    local start_w = self._resize_start_size[1]
    local start_h = self._resize_start_size[2]
    local start_x = self._resize_start_pos[1]
    local start_y = self._resize_start_pos[2]

    local new_w, new_h = start_w, start_h
    local new_x, new_y = start_x, start_y

    -- Apply resize based on which edge/corner is being dragged
    if edge == "r" or edge == "tr" or edge == "br" then
        new_w = math.max(start_w + dx, 10)
    end
    if edge == "l" or edge == "tl" or edge == "bl" then
        new_w = math.max(start_w - dx, 10)
        new_x = start_x + (start_w - new_w)
    end
    if edge == "b" or edge == "bl" or edge == "br" then
        new_h = math.max(start_h + dy, 10)
    end
    if edge == "t" or edge == "tl" or edge == "tr" then
        new_h = math.max(start_h - dy, 10)
        new_y = start_y + (start_h - new_h)
    end

    local node_settings = self._saved_node_settings[node_name]
    if node_settings then
        node_settings.size = { new_w, new_h }
        node_settings.x = new_x
        node_settings.y = new_y

        local widget = self._widgets_by_name[node_name]
        if widget then
            widget.content.size = { new_w, new_h }
        end
        self:_set_scenegraph_size(node_name, new_w, new_h)
        self:set_scenegraph_position(node_name, new_x, new_y, node_settings.z)
        self:_persist_saved_settings()
    end
end

-- ============================================================================
-- Update / Draw
-- ============================================================================

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

    -- Handle panel input before element input (panel consumes scroll when hovered)
    local panel_consumed = self:_handle_panel_input(input_service)

    if not panel_consumed then
        self:_handle_input(input_service)
    end

    HudElementCustomizer.super.update(self, dt, t, ui_renderer, render_settings, input_service)
end

function HudElementCustomizer:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
    HudElementCustomizer.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

    self:_draw_grid(ui_renderer)
    self:_draw_resize_handles(ui_renderer)
    self:_draw_info_panel(ui_renderer, input_service)
end

-- ============================================================================
-- Grid drawing
-- ============================================================================

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

    local grid_line_positions = self._grid_line_positions
    if not grid_line_positions then
        grid_line_positions = { {}, {} }
        self._grid_line_positions = grid_line_positions
    end

    local center_row = num_rows / 2 + 1
    for i = 1, num_rows + 1 do
        local x = 1
        local y = (i - 1) * cell_height - 1
        local is_center = (i == center_row or math.ceil(center_row) == i or math.floor(center_row) == i)
        local color = is_center and { 255, 255, 0, 0 } or { 170, 255, 255, 255 }
        local position = Vector3(x * inverse_scale, y * inverse_scale, draw_layer)
        local size = Vector2(width * inverse_scale, 1)

        grid_line_positions[1][i] = position[2] / inverse_scale
        UIRenderer.draw_rect(ui_renderer, position, size, color)
    end

    local center_col = num_cols / 2 + 1
    for i = 1, num_cols + 1 do
        local x = (i - 1) * cell_width - 1
        local is_center = (i == center_col or math.ceil(center_col) == i or math.floor(center_col) == i)
        local color = is_center and { 255, 255, 0, 0 } or { 170, 255, 255, 255 }
        local position = Vector3(x * inverse_scale, 0, draw_layer)
        local size = Vector2(1, height * inverse_scale)

        grid_line_positions[2][i] = position[1] / inverse_scale
        UIRenderer.draw_rect(ui_renderer, position, size, color)
    end
end

-- ============================================================================
-- Resize handles drawing
-- ============================================================================

function HudElementCustomizer:_draw_resize_handles(ui_renderer)
    local selected_node_list = self._selected_node_list
    if #selected_node_list ~= 1 then
        return
    end

    local node_name = selected_node_list[1]
    local sg_pos = self:scenegraph_world_position(node_name)
    local sg_size = self:scenegraph_size(node_name)
    if not sg_pos or not sg_size then
        return
    end

    local draw_layer = 1000
    local hs = RESIZE_HANDLE_SIZE * (self._inverse_scale or 1)
    local x = sg_pos[1]
    local y = sg_pos[2]
    local w = sg_size[1]
    local h = sg_size[2]
    local color = RESIZE_HANDLE_COLOR

    -- Four corners
    local corners = {
        { x, y },                     -- top-left
        { x + w - hs, y },            -- top-right
        { x, y + h - hs },            -- bottom-left
        { x + w - hs, y + h - hs }    -- bottom-right
    }

    local handle_size = Vector2(hs, hs)
    for _, corner in ipairs(corners) do
        UIRenderer.draw_rect(ui_renderer, Vector3(corner[1], corner[2], draw_layer), handle_size, color)
    end
end

-- ============================================================================
-- Info panel
-- ============================================================================

function HudElementCustomizer:_get_panel_position(inverse_scale)
    local width = RESOLUTION_LOOKUP.width
    local default_x = (width - PANEL_WIDTH - PANEL_MARGIN) * inverse_scale
    local default_y = PANEL_MARGIN * inverse_scale

    if not self._panel_position then
        self._panel_position = { default_x, default_y }
    end

    return self._panel_position[1] or default_x, self._panel_position[2] or default_y
end

function HudElementCustomizer:_save_panel_position()
    if self._panel_position then
        mod:set("panel_position", { self._panel_position[1], self._panel_position[2] })
    end
end

function HudElementCustomizer:_handle_panel_input(input_service)
    if not self._show_info_panel then
        return false
    end

    local panel_text_consumed = false
    if self._panel_active_field then
        panel_text_consumed = self:_handle_panel_text_input() or false
    end

    local cursor = input_service:get("cursor")
    if not cursor then
        return panel_text_consumed
    end

    local cursor_arr = Vector3.to_array(cursor)
    local inverse_scale = self._inverse_scale or RESOLUTION_LOOKUP.inverse_scale
    local px, py = self:_get_panel_position(inverse_scale)
    local panel_w = PANEL_WIDTH * inverse_scale
    local total_nodes = #self._panel_all_node_names
    local visible_count = math.min(total_nodes, PANEL_MAX_VISIBLE_LINES)
    local list_height = visible_count * PANEL_LINE_HEIGHT * inverse_scale
    local panel_h = (PANEL_HEADER_HEIGHT + visible_count * PANEL_LINE_HEIGHT + PANEL_DETAIL_HEIGHT) * inverse_scale
    local hh = PANEL_HEADER_HEIGHT * inverse_scale

    local cx = cursor_arr[1] * inverse_scale
    local cy = cursor_arr[2] * inverse_scale

    local in_panel = cx >= px and cx <= px + panel_w and cy >= py and cy <= py + panel_h
    local in_header = cx >= px and cx <= px + panel_w and cy >= py and cy <= py + hh

    if self._panel_dragging then
        if input_service:get("left_hold") then
            local ox = self._panel_drag_offset and self._panel_drag_offset[1] or 0
            local oy = self._panel_drag_offset and self._panel_drag_offset[2] or 0
            local width_scaled = RESOLUTION_LOOKUP.width * inverse_scale
            local height_scaled = RESOLUTION_LOOKUP.height * inverse_scale
            local new_x = math.clamp(cx - ox, 0, math.max(0, width_scaled - panel_w))
            local new_y = math.clamp(cy - oy, 0, math.max(0, height_scaled - panel_h))
            self._panel_position = { new_x, new_y }
            return true
        else
            self._panel_dragging = false
            self._panel_drag_offset = nil
            self:_save_panel_position()
        end
    end

    if input_service:get("left_pressed") and self._panel_active_field then
        local clicked_field = false
        for _, box in ipairs(self._panel_field_targets or {}) do
            if _point_in_rect(cx, cy, box.x, box.y, box.w, box.h) then
                clicked_field = true
                break
            end
        end
        if not clicked_field then
            self:_commit_panel_field()
        end
    end

    if in_header and input_service:get("left_pressed") then
        self._panel_dragging = true
        self._panel_drag_offset = { cx - px, cy - py }
        self._panel_hovered_index = nil
        return true
    end

    if not in_panel then
        self._panel_hovered_index = nil
        return panel_text_consumed
    end

    local list_start_y = py + hh
    local line_h = PANEL_LINE_HEIGHT * inverse_scale
    if cy >= list_start_y and cy < list_start_y + list_height then
        local rel_y = cy - list_start_y
        local line_index = math.floor(rel_y / line_h) + 1 + self._panel_scroll_offset
        if line_index >= 1 and line_index <= total_nodes then
            self._panel_hovered_index = line_index
        else
            self._panel_hovered_index = nil
        end
    else
        self._panel_hovered_index = nil
    end

    if input_service:get("left_pressed") then
        for _, box in ipairs(self._panel_field_targets or {}) do
            if _point_in_rect(cx, cy, box.x, box.y, box.w, box.h) then
                self:_activate_panel_field(box.node_name, box.group, box.key)
                return true
            end
        end

        if self._panel_hovered_index then
            local node_name = self._panel_all_node_names[self._panel_hovered_index]
            if node_name and self._widgets_by_name[node_name] then
                self:_cancel_panel_field()
                self:_process_widget_press_left(node_name)
                return true
            end
        else
            self:_cancel_panel_field()
        end
    end

    local scroll_axis = input_service:get("scroll_axis")
    if scroll_axis and scroll_axis[2] ~= 0 then
        local max_scroll = math.max(0, total_nodes - PANEL_MAX_VISIBLE_LINES)
        local dir = scroll_axis[2] > 0 and -PANEL_SCROLL_SPEED or PANEL_SCROLL_SPEED
        self._panel_scroll_offset = math.clamp(self._panel_scroll_offset + dir, 0, max_scroll)
        return true
    end

    return in_panel or panel_text_consumed
end

function HudElementCustomizer:_draw_info_panel(ui_renderer, input_service)
    if not self._show_info_panel then
        return
    end

    local inverse_scale = self._inverse_scale or RESOLUTION_LOOKUP.inverse_scale
    local all_node_names = self._panel_all_node_names
    local total_nodes = #all_node_names
    local saved_settings = self._saved_node_settings
    local selected_list = self._selected_node_list
    local draw_layer = 998

    local selected_lookup = {}
    for _, name in ipairs(selected_list) do
        selected_lookup[name] = true
    end

    local visible_count = math.min(total_nodes, PANEL_MAX_VISIBLE_LINES)
    local panel_content_h = PANEL_HEADER_HEIGHT + visible_count * PANEL_LINE_HEIGHT + PANEL_DETAIL_HEIGHT
    local px, py = self:_get_panel_position(inverse_scale)
    local pw = PANEL_WIDTH * inverse_scale
    local ph = panel_content_h * inverse_scale
    local lh = PANEL_LINE_HEIGHT * inverse_scale
    local hh = PANEL_HEADER_HEIGHT * inverse_scale

    UIRenderer.draw_rect(ui_renderer, Vector3(px, py, draw_layer), Vector2(pw, ph), PANEL_BG_COLOR)
    UIRenderer.draw_rect(ui_renderer, Vector3(px, py, draw_layer + 1), Vector2(pw, hh), PANEL_HEADER_COLOR)

    _safe_draw_text(
        ui_renderer,
        string.format("Custom HUD Panel (%d)  [drag header]", total_nodes),
        PANEL_FONT_TYPE,
        math.floor(PANEL_FONT_SIZE * inverse_scale),
        Vector3(px + 10 * inverse_scale, py + 3 * inverse_scale, draw_layer + 2),
        Vector2(pw - 20 * inverse_scale, hh - 6 * inverse_scale),
        PANEL_TEXT_COLOR,
        "left",
        "center"
    )

    local scroll = self._panel_scroll_offset
    for i = 1, visible_count do
        local data_index = i + scroll
        if data_index > total_nodes then
            break
        end

        local node_name = all_node_names[data_index]
        local short_name = short_element_name(node_name)
        local line_y = py + hh + (i - 1) * lh
        local is_selected = selected_lookup[node_name]
        local is_hovered = (self._panel_hovered_index == data_index)
        local node_settings = saved_settings[node_name]
        local is_hidden = node_settings and node_settings.is_hidden

        local line_color = PANEL_LINE_COLOR
        if is_selected then
            line_color = PANEL_LINE_SELECTED_COLOR
        elseif is_hovered then
            line_color = PANEL_LINE_HOVER_COLOR
        end

        if line_color[1] > 0 then
            UIRenderer.draw_rect(ui_renderer, Vector3(px + 2 * inverse_scale, line_y, draw_layer + 1),
                Vector2(pw - 4 * inverse_scale, lh - 1 * inverse_scale), line_color)
        end

        local text_color = is_hidden and PANEL_TEXT_HIDDEN_COLOR or PANEL_TEXT_COLOR
        local suffix = is_hidden and " [hidden]" or ""
        _safe_draw_text(
            ui_renderer,
            short_name .. suffix,
            PANEL_FONT_TYPE,
            math.floor(PANEL_FONT_SIZE_SMALL * inverse_scale),
            Vector3(px + 10 * inverse_scale, line_y, draw_layer + 2),
            Vector2(pw - 20 * inverse_scale, lh),
            text_color,
            "left",
            "center"
        )
    end

    self._panel_field_targets = {}

    if #selected_list > 0 then
        local selected_name = selected_list[1]
        local node_settings = self:_get_selected_node_settings(selected_name)
        local detail_y = py + hh + visible_count * lh
        local detail_h = PANEL_DETAIL_HEIGHT * inverse_scale
        UIRenderer.draw_rect(ui_renderer, Vector3(px, detail_y, draw_layer + 1),
            Vector2(pw, detail_h), PANEL_DETAIL_BG_COLOR)

        local title_h = 22 * inverse_scale
        _safe_draw_text(
            ui_renderer,
            "Selected: " .. short_element_name(selected_name),
            PANEL_FONT_TYPE,
            math.floor(PANEL_FONT_SIZE_SMALL * inverse_scale),
            Vector3(px + 10 * inverse_scale, detail_y + 6 * inverse_scale, draw_layer + 2),
            Vector2(pw - 20 * inverse_scale, title_h),
            PANEL_DETAIL_VALUE_COLOR,
            "left",
            "center"
        )

        _safe_draw_text(
            ui_renderer,
            "Click a value label and type to replace it live.",
            PANEL_FONT_TYPE,
            math.floor((PANEL_FONT_SIZE_SMALL - 1) * inverse_scale),
            Vector3(px + 10 * inverse_scale, detail_y + 30 * inverse_scale, draw_layer + 2),
            Vector2(pw - 20 * inverse_scale, title_h),
            PANEL_DETAIL_LABEL_COLOR,
            "left",
            "center"
        )

        _safe_draw_text(
            ui_renderer,
            "Click elsewhere to keep it. Esc cancels the active edit.",
            PANEL_FONT_TYPE,
            math.floor((PANEL_FONT_SIZE_SMALL - 1) * inverse_scale),
            Vector3(px + 10 * inverse_scale, detail_y + 50 * inverse_scale, draw_layer + 2),
            Vector2(pw - 20 * inverse_scale, title_h),
            PANEL_DETAIL_LABEL_COLOR,
            "left",
            "center"
        )

        local active = self._panel_active_field
        if active and active.node_name == selected_name then
            _safe_draw_text(
                ui_renderer,
                string.format("Editing %s %s = %s", active.group, string.upper(active.key), tostring(active.buffer or "")),
                PANEL_FONT_TYPE,
                math.floor((PANEL_FONT_SIZE_SMALL - 1) * inverse_scale),
                Vector3(px + 10 * inverse_scale, detail_y + 74 * inverse_scale, draw_layer + 2),
                Vector2(pw - 20 * inverse_scale, title_h),
                PANEL_DETAIL_VALUE_COLOR,
                "left",
                "center"
            )
        end

        local defaults = node_settings.default_settings or self._default_node_settings[selected_name] or {}
        defaults.position = defaults.position or {0,0,0}
        defaults.size = defaults.size or {0,0}

        local col_gap = 10 * inverse_scale
        local box_gap = 6 * inverse_scale
        local label_w = 18 * inverse_scale
        local col_w = (pw - 24 * inverse_scale - col_gap) / 2
        local box_w = (col_w - label_w - box_gap)
        local row_h = 24 * inverse_scale
        local row_gap = 6 * inverse_scale
        local fields_top = detail_y + 102 * inverse_scale
        local left_x = px + 8 * inverse_scale
        local right_x = left_x + col_w + col_gap
        local current_map = {x = node_settings.x or 0, y = node_settings.y or 0, z = node_settings.z or 0, w = (node_settings.size and node_settings.size[1]) or 0, h = (node_settings.size and node_settings.size[2]) or 0}
        local default_map = {x = defaults.position[1] or 0, y = defaults.position[2] or 0, z = defaults.position[3] or 0, w = defaults.size[1] or 0, h = defaults.size[2] or 0}
        local rows = {
            { key = "x", label = "X" },
            { key = "y", label = "Y" },
            { key = "z", label = "Z" },
            { key = "w", label = "W" },
            { key = "h", label = "H" },
        }

        local function draw_field_column(group_name, base_x, values, title)
            _safe_draw_text(
                ui_renderer,
                title,
                PANEL_FONT_TYPE,
                math.floor(PANEL_FONT_SIZE_SMALL * inverse_scale),
                Vector3(base_x, fields_top - 22 * inverse_scale, draw_layer + 2),
                Vector2(col_w, 18 * inverse_scale),
                PANEL_DETAIL_VALUE_COLOR,
                "left",
                "center"
            )

            for row_index, row in ipairs(rows) do
                local y = fields_top + (row_index - 1) * (row_h + row_gap)
                local active = self._panel_active_field
                local is_active = active and active.node_name == selected_name and active.group == group_name and active.key == row.key
                local display_value = is_active and ((active.buffer ~= "" and active.buffer) or "") or _format_field_value(values[row.key])
                local display_text = tostring(display_value or "")
                local row_x = base_x
                local row_w = col_w

                if is_active then
                    UIRenderer.draw_rect(ui_renderer, Vector3(row_x, y, draw_layer + 1), Vector2(row_w, row_h), {120, 85, 110, 140})
                end

                _safe_draw_text(
                    ui_renderer,
                    string.format("%s: %s", row.label, display_text ~= "" and display_text or "-"),
                    PANEL_FONT_TYPE,
                    math.floor(PANEL_FONT_SIZE_SMALL * inverse_scale),
                    Vector3(base_x, y, draw_layer + 2),
                    Vector2(col_w, row_h),
                    is_active and PANEL_DETAIL_VALUE_COLOR or PANEL_DETAIL_LABEL_COLOR,
                    "left",
                    "center"
                )

                table.insert(self._panel_field_targets, {
                    x = row_x, y = y, w = row_w, h = row_h,
                    node_name = selected_name, group = group_name, key = row.key
                })
            end
        end

        draw_field_column("current", left_x, current_map, "Current")
        draw_field_column("default", right_x, default_map, "Default / Reset")

        local status_y = fields_top + #rows * (row_h + row_gap) + 12 * inverse_scale
        _safe_draw_text(
            ui_renderer,
            string.format("Scale: %.2f   Hidden: %s", node_settings.scale or 1, node_settings.is_hidden and "yes" or "no"),
            PANEL_FONT_TYPE,
            math.floor((PANEL_FONT_SIZE_SMALL - 1) * inverse_scale),
            Vector3(px + 8 * inverse_scale, status_y, draw_layer + 2),
            Vector2(pw - 16 * inverse_scale, 18 * inverse_scale),
            PANEL_DETAIL_LABEL_COLOR,
            "left",
            "center"
        )
    end
end

-- ============================================================================
-- Apply saved settings
-- ============================================================================

function HudElementCustomizer:_apply_saved_node_settings()
    local saved_node_settings = self._saved_node_settings
    if not saved_node_settings then
        return
    end

    local inverse_hud_scale = self:_get_inverse_hud_scale()
    for node_name, node_settings in pairs(saved_node_settings) do
        local element_name, scenegraph_id = split_node_name(node_name)
        local element = self:_get_element(element_name)
        if element and type(element._ui_scenegraph) == "table" then
            local has_scenegraph_id = rawget(element._ui_scenegraph, scenegraph_id) ~= nil

            if has_scenegraph_id then
                local is_constant_element = string.starts_with(element_name, "ConstantElement")
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

                local ok = pcall(element.set_scenegraph_position, element, scenegraph_id, x, y, z, "left", "top")
                if ok then
                    element._is_hidden = node_settings.is_hidden

                    local hooked_elements = mod._hooked_elements
                    if not hooked_elements[element] then
                        mod:hook(element, "draw", function(func, self, ...)
                            if self._is_hidden then
                                return
                            end

                            local element_render_settings = select(4, ...)
                            local opacity = mod._cached_opacity()
                            if opacity ~= 1 then
                                if type(element_render_settings) == "table" then
                                    element_render_settings.alpha_multiplier = opacity
                                end
                            end

                            return func(self, ...)
                        end)
                        hooked_elements[element] = true
                    end
                end
            else
                saved_node_settings[node_name] = nil
            end
        end
    end

    mod:set("saved_node_settings", saved_node_settings)
end

return HudElementCustomizer
