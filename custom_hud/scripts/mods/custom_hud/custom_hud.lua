local mod = get_mod("custom_hud")

local hud_element_customizer_path = "custom_hud/scripts/mods/custom_hud/hud_element_customizer"
local function ui_hud_init_hook(func, self, elements, visibility_groups, params)
    local class_name = "HudElementCustomizer"
    local element_index = table.find_by_key(elements, "class_name", class_name)
    if element_index then
        table.remove(elements, element_index)
    end

    table.insert(elements, {
        class_name = class_name,
        filename = hud_element_customizer_path,
        use_hud_scale = true,
        visibility_groups = {
            "custom_hud"
        }
    })

    local visibility_group_name = "custom_hud"
    local visibility_group_index = table.find_by_key(visibility_groups, "name", visibility_group_name)
    if visibility_group_index then
        table.remove(visibility_groups, visibility_group_index)
    end
    table.insert(visibility_groups, 1, {
        name = visibility_group_name,
        validation_function = function(hud)
            return mod.is_customizing
        end
    })

    visibility_group_name = "hide_hud"
    visibility_group_index = table.find_by_key(visibility_groups, "name", visibility_group_name)
    if visibility_group_index then
        table.remove(visibility_groups, visibility_group_index)
    end
    table.insert(visibility_groups, 2, {
        name = visibility_group_name,
        validation_function = function(hud)
            return mod.is_hud_hidden
        end
    })

    return func(self, elements, visibility_groups, params)
end

mod:add_require_path(hud_element_customizer_path)
mod:hook("UIHud", "init", ui_hud_init_hook)

local function recreate_hud()
    local ui_manager = Managers.ui
    if ui_manager then
        local hud = ui_manager._hud
        if hud then
            local player_manager = Managers.player
            local player = player_manager:local_player(1)
            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

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
    if setting_id == "reset_hud" then
        if mod:get("reset_hud") == 1 then
            mod:notify("HUD Reset")
            mod:set("reset_hud", 0)
            reset_hud()
        end
    end
end

function mod.on_all_mods_loaded()
    recreate_hud()
end

function mod:toggle_hud_customization()
    local ui_manager = Managers.ui
    local view_handler = ui_manager and ui_manager._view_handler
    local view_using_input = view_handler and view_handler:using_input()

    if view_using_input then
        return
    end

    mod.is_customizing = not mod.is_customizing
end

function mod:toggle_hud_hidden()
    mod.is_hud_hidden = not mod.is_hud_hidden
end

mod:command("reset_hud", "Restores the default HUD.", function()
    reset_hud()
end)

local _ignored_elements = {
    HudElementCrosshair = true
}

local function draw_hook(func, self, ...)
    if self._is_hidden then
        return
    end

    local element_name = self.__class_name
    if not _ignored_elements[element_name] then

        local opacity = tonumber(mod:get("opacity"))
        if opacity ~= nil and not self._always_full_alpha then

            local element_render_settings = select(4, ...)
            if type(element_render_settings) == "table" then
                element_render_settings.alpha_multiplier = opacity
            end

        end

    end

    return func(self, ...)
end

mod:hook(HudElementBase, "draw", draw_hook)
mod:hook(ConstantElementBase, "draw", draw_hook)

mod:hook_safe(UIViewHandler, "open_view", function(self, view_name)
    mod.is_customizing = false
end)

mod:hook_safe(UIViewHandler, "close_view", function(self, view_name, force_close)
    if view_name == "dmf_options_view" or view_name == "options_view" then
        recreate_hud()
    end
end)

mod._hooked_elements = {}