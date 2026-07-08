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
                        setting_id = "panel_font",
                        type = "dropdown",
                        default_value = 1,
                        options = {
                            { text = "font_proxima_nova_bold", value = 1 },
                            { text = "font_proxima_nova_light", value = 2 },
                            { text = "font_proxima_nova_medium", value = 3 },
                            { text = "font_machine_medium", value = 4 },
                            { text = "font_itc_novarese", value = 5 },
                            { text = "font_friz_quadrata", value = 6 },
                            { text = "font_rexlia", value = 7 },
                        }
                    },
                    {
                        setting_id = "panel_font_size",
                        type = "numeric",
                        range = { 10, 28 },
                        default_value = 18,
                        decimals_number = 0,
                        step_size_value = 1
                    },
                    {
                        setting_id = "panel_scale",
                        type = "numeric",
                        range = { 0.75, 2.0 },
                        default_value = 1,
                        decimals_number = 2,
                        step_size_value = 0.05
                    },
                    {
                        setting_id = "panel_list_rows",
                        type = "numeric",
                        range = { 8, 30 },
                        default_value = 18,
                        decimals_number = 0,
                        step_size_value = 1
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
                                setting_id = "snap_to_elements",
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
