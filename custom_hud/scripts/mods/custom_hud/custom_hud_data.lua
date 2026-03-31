local mod = get_mod("custom_hud")

return {
    name = mod:localize("custom_hud"),
    description = mod:localize("custom_hud_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "settings_header",
                type = "group",
                sub_widgets = {
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
                        step_size_value = 0.25
                    },
                    {
                        setting_id = "show_info_panel",
                        type = "checkbox",
                        default_value = true
                    },
                    {
                        setting_id = "display_grid",
                        type = "checkbox",
                        default_value = true,
                        sub_widgets = {
                            {
                                setting_id = "snap_to_grid",
                                type = "checkbox",
                                default_value = true
                            },
                            {
                                setting_id = "grid_cols",
                                type = "numeric",
                                range = { 1, 54 },
                                default_value = 3,
                                decimals_number = 0,
                                step_size_value = 1
                            },
                            {
                                setting_id = "grid_rows",
                                type = "numeric",
                                range = { 1, 27 },
                                default_value = 3,
                                decimals_number = 0,
                                step_size_value = 1
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
    }
}
