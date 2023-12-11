local mod = get_mod("custom_hud")

return {
    name = mod:localize("custom_hud"),
    description = mod:localize("custom_hud_description"),
    is_togglable = true,
    --allow_rehooking = true,
    options = {
        widgets = {
            {
                setting_id = "toggle_hud_customization_key",
                type = "keybind",
                default_value = { "f3" },
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "toggle_hud_customization"
            },
            {
                setting_id = "toggle_hud_hidden_key",
                type = "keybind",
                default_value = { "f2" },
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "toggle_hud_hidden"
            },
            {
                setting_id = "opacity",
                type = "numeric",
                range = { 0, 1 },
                default_value = 1,
                decimals_number = 2,
                step_size_value = 0.25,
                change = function(new_value)
                    mod:set("opacity", new_value)
                end,
                get = function()
                    return mod:get("opacity") or 1
                end
            },
            {
                setting_id = "display_grid",
                type = "checkbox",
                default_value = true,
                change = function(new_value)
                    mod:set("display_grid", new_value)
                end,
                get = function()
                    return mod:get("display_grid")
                end,
                sub_widgets = {
                    {
                        setting_id = "snap_to_grid",
                        type = "checkbox",
                        default_value = true,
                        change = function(new_value)
                            mod:set("snap_to_grid", new_value)
                        end,
                        get = function()
                            return mod:get("snap_to_grid")
                        end
                    },
                    {
                        setting_id = "grid_cols",
                        type = "numeric",
                        range = { 1, 54 },
                        default_value = 3,
                        decimals_number = 0,
                        step_size_value = 1,
                        change = function(new_value)
                            mod:set("grid_cols", new_value)
                        end,
                        get = function()
                            return mod:get("grid_cols") or 3
                        end
                    },
                    {
                        setting_id = "grid_rows",
                        type = "numeric",
                        range = { 1, 27 },
                        default_value = 3,
                        decimals_number = 0,
                        step_size_value = 1,
                        change = function(new_value)
                            mod:set("grid_rows", new_value)
                        end,
                        get = function()
                            return mod:get("grid_rows") or 3
                        end
                    }
                }
            },
            {
                setting_id = "reset_hud",
                type = "dropdown",
                default_value = 0,
                options = {
                    { text = "", value = 0 },
                    { text = "reset_hud", value = 1 }
                }
            }
        }
    }
}