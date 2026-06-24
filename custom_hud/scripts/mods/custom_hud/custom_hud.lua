local mod = get_mod("custom_hud")

-- Cached settings (refreshed on change)
local _cached_opacity = 1

local function _refresh_cached_settings()
    _cached_opacity = tonumber(mod:get("opacity")) or 1
end

local hud_element_customizer_path = "custom_hud/scripts/mods/custom_hud/hud_element_customizer"

local function _mod_enabled()
    return not mod.is_enabled or mod:is_enabled()
end

local function _remove_custom_hud_entries(elements, visibility_groups, remove_hide_hud)
    if not elements or not visibility_groups then
        return
    end

    local class_name = "HudElementCustomizer"
    local element_index = table.find_by_key(elements, "class_name", class_name)
    while element_index do
        table.remove(elements, element_index)
        element_index = table.find_by_key(elements, "class_name", class_name)
    end

    local visibility_group_index = table.find_by_key(visibility_groups, "name", "custom_hud")
    while visibility_group_index do
        table.remove(visibility_groups, visibility_group_index)
        visibility_group_index = table.find_by_key(visibility_groups, "name", "custom_hud")
    end

    if remove_hide_hud then
        visibility_group_index = table.find_by_key(visibility_groups, "name", "hide_hud")
        while visibility_group_index do
            table.remove(visibility_groups, visibility_group_index)
            visibility_group_index = table.find_by_key(visibility_groups, "name", "hide_hud")
        end
    end
end

local function _clear_runtime_overrides()
    local position_overrides = mod._position_overrides or {}
    for element in pairs(position_overrides) do
        if element then
            element._is_hidden = false
        end
    end

    mod._position_overrides = {}
end

local function ui_hud_init_hook(func, self, elements, visibility_groups, params)
    _remove_custom_hud_entries(elements, visibility_groups)

    if not _mod_enabled() then
        return func(self, elements, visibility_groups, params)
    end

    _remove_custom_hud_entries(elements, visibility_groups, true)

    local class_name = "HudElementCustomizer"
    table.insert(elements, {
        class_name = class_name,
        filename = hud_element_customizer_path,
        use_hud_scale = true,
        visibility_groups = {
            "custom_hud"
        }
    })

    local visibility_group_name = "custom_hud"
    table.insert(visibility_groups, 1, {
        name = visibility_group_name,
        validation_function = function(hud)
            return _mod_enabled() and mod.is_customizing
        end
    })

    visibility_group_name = "hide_hud"
    table.insert(visibility_groups, 2, {
        name = visibility_group_name,
        validation_function = function(hud)
            return _mod_enabled() and mod.is_hud_hidden
        end
    })

    return func(self, elements, visibility_groups, params)
end

mod:add_require_path(hud_element_customizer_path)
mod:hook("UIHud", "init", ui_hud_init_hook)

local function _is_missing_module_error(error_message, filename)
    if not error_message or not filename then
        return false
    end

    return string.find(error_message, "module '" .. filename .. "' not found", 1, true) ~= nil
        or string.find(error_message, "no lua resource '" .. filename, 1, true) ~= nil
end

local function _remove_unloadable_elements(elements)
    if not elements then
        return
    end

    for i = #elements, 1, -1 do
        local element = elements[i]
        local filename = element and element.filename

        if filename then
            local ok, error_message = pcall(require, filename)
            if not ok and _is_missing_module_error(error_message, filename) then
                table.remove(elements, i)
            end
        end
    end
end

local function recreate_hud()
    local managers = rawget(_G, "Managers")
    local ui_manager = managers and managers.ui
    if ui_manager then
        local hud = ui_manager._hud
        if hud then
            local player_manager = managers.player
            local player = player_manager and player_manager:local_player(1)
            if not player then
                return
            end

            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

            _remove_custom_hud_entries(elements, visibility_groups, _mod_enabled())
            _remove_unloadable_elements(elements)
            ui_manager:destroy_player_hud()
            ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
        end
    end
end

local function reset_hud()
    mod:set("saved_node_settings", {})
    recreate_hud()
end

function mod.on_setting_changed(setting_id)
    _refresh_cached_settings()

    if mod._refresh_panel_font then
        mod._refresh_panel_font()
    end

    if setting_id == "reset_hud" then
        if mod:get("reset_hud") == 1 then
            mod:notify("HUD Reset")
            mod:set("reset_hud", 0)
            reset_hud()
        end
    end
end

function mod.on_all_mods_loaded()
    _refresh_cached_settings()
    if _mod_enabled() then
        recreate_hud()
    end
end

function mod.on_enabled(initial_call)
    _refresh_cached_settings()
    recreate_hud()
end

function mod.on_disabled(initial_call)
    mod.is_customizing = false
    mod.is_hud_hidden = false
    _clear_runtime_overrides()
    recreate_hud()
end

function mod:toggle_hud_customization()
    if not _mod_enabled() then
        return
    end

    local ui_manager = Managers.ui
    local view_handler = ui_manager and ui_manager._view_handler
    local view_using_input = view_handler and view_handler:using_input()

    if view_using_input then
        return
    end

    mod.is_customizing = not mod.is_customizing
end

function mod:toggle_hud_hidden()
    if not _mod_enabled() then
        return
    end

    mod.is_hud_hidden = not mod.is_hud_hidden
end

mod:command("reset_hud", "Restores the default HUD.", function()
    reset_hud()
end)

local _ignored_elements = {
    HudElementCrosshair = true,
    HudElementCrosshairHud = true
}

local function draw_hook(func, self, dt, t, ui_renderer, render_settings, input_service)
    if not _mod_enabled() then
        return func(self, dt, t, ui_renderer, render_settings, input_service)
    end

    if self._is_hidden then
        return
    end

    local element_name = self.__class_name
    if not _ignored_elements[element_name] and not self._always_full_alpha then
        local opacity = _cached_opacity
        if opacity ~= 1 and render_settings then
            render_settings.alpha_multiplier = opacity
        end
    end

    return func(self, dt, t, ui_renderer, render_settings, input_service)
end

mod:hook(HudElementBase, "draw", draw_hook)
mod:hook(ConstantElementBase, "draw", draw_hook)

mod:hook_safe(UIViewHandler, "open_view", function(self, view_name)
    mod.is_customizing = false
end)

mod:hook_safe(UIViewHandler, "close_view", function(self, view_name, force_close)
    if view_name == "dmf_options_view" or view_name == "options_view" then
        _refresh_cached_settings()
        mod.is_customizing = false
    end
end)

mod._hooked_elements = {}
mod._hooked_element_classes = {}
mod._hooked_element_draw_widgets = {}
mod._position_overrides = {}
mod._cached_opacity = function() return _cached_opacity end
