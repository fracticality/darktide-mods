local mod = get_mod("crosshair_hud")

local global_x_offset = mod:get("global_x_offset")
local global_y_offset = mod:get("global_y_offset")
local coherency_x_offset = mod:get("coherency_x_offset")
local coherency_y_offset = mod:get("coherency_y_offset")
local toughness_x_offset = mod:get("toughness_x_offset")
local toughness_y_offset = mod:get("toughness_y_offset")
local health_x_offset = mod:get("health_x_offset")
local health_y_offset = mod:get("health_y_offset")
local ability_x_offset = mod:get("ability_x_offset")
local ability_y_offset = mod:get("ability_y_offset")
local reload_x_offset = mod:get("reload_x_offset")
local reload_y_offset = mod:get("reload_y_offset")
local ammo_x_offset = mod:get("ammo_x_offset")
local ammo_y_offset = mod:get("ammo_y_offset")
local grenade_x_offset = mod:get("grenade_x_offset")
local grenade_y_offset = mod:get("grenade_y_offset")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  toughness_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48, 24 },
    position = {
      global_x_offset + toughness_x_offset,
      global_y_offset + toughness_y_offset,
      55
    }
  },
  health_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 72, 24 },
    position = {
      global_x_offset + health_x_offset,
      global_y_offset + health_y_offset,
      55
    }
  },
  ability_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48, 28 },
    position = {
      global_x_offset + ability_x_offset,
      global_y_offset + ability_y_offset,
      55
    }
  },
  coherency_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48, 32 },
    position = {
      global_x_offset + coherency_x_offset,
      global_y_offset + coherency_y_offset,
      55
    }
  },
  ammo_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 52, 44 },
    position = {
      global_x_offset + ammo_x_offset,
      global_y_offset + ammo_y_offset,
      55
    }
  },
  grenade_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 60, 25 },
    position = {
      global_x_offset + grenade_x_offset,
      global_y_offset + grenade_y_offset,
      55
    }
  },
  reload_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 28, 20 },
    position = {
      global_x_offset + reload_x_offset,
      global_y_offset + reload_y_offset,
      55
    }
  },
}

local widget_definitions = {
  coherency_indicator_aura = UIWidget.create_definition({
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/buffs/hud/buff_frame",
      style_id = "frame_player_1",
      style = {
        buff_style_id = "player_1",
        horizontal_alignment = "left",
        vertical_alignment = "center",
        size = { 43, 43 },
        offset = { -30, -2, 3 },
        color = UIHudSettings.color_tint_alert_2,
      },
      visibility_function = function(content, style)
        local parent = style.parent
        local buff_style_id = style.buff_style_id
        local buff_style = parent and parent[buff_style_id]

        return buff_style and buff_style.visible
      end
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/buffs/hud/buff_frame",
      style_id = "frame_player_2",
      style = {
        buff_style_id = "player_2",
        horizontal_alignment = "center",
        vertical_alignment = "center",
        size = { 43, 43 },
        offset = { 0, -2, 3 },
        color = UIHudSettings.color_tint_alert_2,
      },
      visibility_function = function(content, style)
        local parent = style.parent
        local buff_style_id = style.buff_style_id
        local buff_style = parent and parent[buff_style_id]

        return buff_style and buff_style.visible
      end
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/buffs/hud/buff_frame",
      style_id = "frame_player_3",
      style = {
        buff_style_id = "player_3",
        horizontal_alignment = "right",
        vertical_alignment = "center",
        size = { 43, 43 },
        offset = { 30, -2, 3 },
        color = UIHudSettings.color_tint_alert_2,
      },
      visibility_function = function(content, style)
        local parent = style.parent
        local buff_style_id = style.buff_style_id
        local buff_style = parent and parent[buff_style_id]

        return buff_style and buff_style.visible
      end
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
      style_id = "player_1",
      style = {
        horizontal_alignment = "left",
        vertical_alignment = "center",
        size = { 28, 28 },
        offset = { -22, -2, 2 },
        color = { 255, 255, 255, 255 },
        material_values = {}
      },
      visibility_function = function(content, style)
        return style.material_values.talent_icon ~= nil
      end
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
      style_id = "player_2",
      style = {
        horizontal_alignment = "center",
        vertical_alignment = "center",
        size = { 28, 28 },
        offset = { 0, -2, 2 },
        color = { 255, 255, 255, 255 },
        material_values = {}
      },
      visibility_function = function(content, style)
        return style.material_values.talent_icon ~= nil
      end
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
      style_id = "player_3",
      style = {
        horizontal_alignment = "right",
        vertical_alignment = "center",
        size = { 28, 28 },
        offset = { 22, -2, 2 },
        color = { 255, 255, 255, 255 },
        material_values = {}
      },
      visibility_function = function(content, style)
        return style.material_values.talent_icon ~= nil
      end
    },
  }, "coherency_indicator"),
  coherency_indicator_simple = UIWidget.create_definition({
    {
      pass_type = "text",
      style_id = "player_1",
      value_id = "player_1",
      value = "+",
      style = {
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { -14, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_1_shadow",
      value_id = "player_1",
      value = "+",
      style = {
        text_style_id = "player_1",
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { -12, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "player_2",
      value_id = "player_2",
      value = "+",
      style = {
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 0, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_2_shadow",
      value_id = "player_2",
      value = "+",
      style = {
        text_style_id = "player_2",
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "player_3",
      value_id = "player_3",
      value = "+",
      style = {
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 14, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_3_shadow",
      value_id = "player_3",
      value = "+",
      style = {
        text_style_id = "player_3",
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 16, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
  }, "coherency_indicator"),
  coherency_indicator_archetype = UIWidget.create_definition({
    {
      pass_type = "text",
      style_id = "player_1",
      value_id = "player_1",
      value = "+",
      style = {
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { -26, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_1_shadow",
      value_id = "player_1",
      value = "+",
      style = {
        text_style_id = "player_1",
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { -24, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "player_2",
      value_id = "player_2",
      value = "+",
      style = {
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 0, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_2_shadow",
      value_id = "player_2",
      value = "+",
      style = {
        text_style_id = "player_2",
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "player_3",
      value_id = "player_3",
      value = "+",
      style = {
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 26, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_3_shadow",
      value_id = "player_3",
      value = "+",
      style = {
        text_style_id = "player_3",
        font_size = 24,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 28, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
  }, "coherency_indicator"),
  toughness_indicator = UIWidget.create_definition({
    {
      pass_type = "text",
      style_id = "text_1",
      value_id = "text_1",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          -14,
          2,
          2
        }
      }
    },
    {
      pass_type = "text",
      style_id = "text_1_shadow",
      value_id = "text_1",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          -12,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "text_2",
      value_id = "text_2",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          0,
          2,
          2
        }
      }
    },
    {
      pass_type = "text",
      style_id = "text_2_shadow",
      value_id = "text_2",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          2,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "text_3",
      value_id = "text_3",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          14,
          2,
          2
        }
      }
    },
    {
      pass_type = "text",
      style_id = "text_3_shadow",
      value_id = "text_3",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          16,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "text_symbol",
      value_id = "text_symbol",
      value = "%",
      style = {
        font_size = 16,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = { 30, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "text_symbol_shadow",
      value_id = "text_symbol",
      value = "%",
      style = {
        text_style_id = "text_symbol",
        font_size = 16,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 32, 4, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    }
  }, "toughness_indicator"),
  health_indicator = UIWidget.create_definition({
    {
      pass_type = "text",
      style_id = "text_1",
      value_id = "text_1",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          -14,
          2,
          2
        }
      }
    },
    {
      pass_type = "text",
      style_id = "text_1_shadow",
      value_id = "text_1",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          -12,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "text_2",
      value_id = "text_2",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          0,
          2,
          2
        }
      }
    },
    {
      pass_type = "text",
      style_id = "text_2_shadow",
      value_id = "text_2",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          2,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "text_3",
      value_id = "text_3",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          14,
          2,
          2
        }
      }
    },
    {
      pass_type = "text",
      style_id = "text_3_shadow",
      value_id = "text_3",
      value = "0",
      style = {
        font_size = 24,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          16,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      style_id = "text_symbol",
      value_id = "text_symbol",
      value = "%",
      style = {
        font_size = 16,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = { 30, 2, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "text_symbol_shadow",
      value_id = "text_symbol",
      value = "%",
      style = {
        text_style_id = "text_symbol",
        font_size = 16,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          32,
          4,
          1
        }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    },
  }, "health_indicator"),
  ability_indicator = UIWidget.create_definition({
    {
      pass_type = "rotated_texture",
      value_id = "symbol",
      value = "",
      style_id = "symbol",
      style = {
        pivot = { 10, 10 },
        angle = math.pi,
        horizontal_alignment = "center",
        vertical_alignment = "center",
        size = { 20, 20 },
        color = { 255, 255, 255, 255 },
        offset = { 0, 0, 2 }
      },
      visibility_function = function(content, style)
        return content.symbol ~= ""
      end
    },
    {
      pass_type = "rotated_rect",
      style_id = "rect",
      style = {
        horizontal_alignment = "center",
        vertical_alignment = "center",
        size = { 20, 20 },
        pivot = { 10, 10 },
        angle = math.pi / 4,
        color = UIHudSettings.color_tint_0,
        offset = { 0, 0, 1 }
      },
      --visibility_function = function(content, style)
      --  return mod:get("enable_shadows")
      --end
    },
    {
      pass_type = "text",
      value_id = "charge_count",
      value = "",
      style_id = "charge_count",
      style = {
        font_size = 14,
        font_type = "machine_medium",
        text_horizontal_alignment = "right",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_1,
        offset = { -5, 4, 2 }
      }
    },
    {
      pass_type = "text",
      value_id = "charge_count",
      value = "",
      style_id = "charge_count_shadow",
      style = {
        font_size = 14,
        font_type = "machine_medium",
        text_horizontal_alignment = "right",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_0,
        offset = { -3, 6, 1 }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      value_id = "cooldown_text",
      value = "",
      style_id = "cooldown_text",
      style = {
        font_size = 14,
        font_type = "machine_medium",
        text_horizontal_alignment = "left",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_1,
        offset = { -5, 4, 2 }
      },
      visibility_function = function(content, style)
        local ability_cooldown_threshold = mod:get("ability_cooldown_threshold")
        if not content.cooldown or not ability_cooldown_threshold then
          return
        end

        return content.cooldown > 0 and content.cooldown <= ability_cooldown_threshold + 1
      end
    },
    {
      pass_type = "text",
      value_id = "cooldown_text",
      value = "",
      style_id = "cooldown_enable_shadows",
      style = {
        text_style_id = "cooldown_text",
        font_size = 14,
        font_type = "machine_medium",
        text_horizontal_alignment = "left",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_0,
        offset = { -3, 6, 1 }
      },
      visibility_function = function(content, style)
        return style.parent[style.text_style_id].visible and mod:get("enable_shadows")
      end
    }
  }, "ability_indicator"),
  ammo_indicator = UIWidget.create_definition({
    {
      pass_type = "texture",
      value = "content/ui/materials/hud/icons/party_ammo",
      style_id = "ammo_icon",
      style = {
        size = { 20, 20 },
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_main_1,
        offset = { 0, 0, 1 }
      }
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/hud/icons/party_ammo",
      style_id = "ammo_icon_shadow",
      style = {
        size = { 20, 20 },
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_0,
        offset = { 2, 2, 0}
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      value = "000",
      value_id = "clip_ammo",
      style_id = "clip_ammo",
      style = {
        font_size = 30,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_1,
        offset = { 1, 0, 2 }
      }
    },
    {
      pass_type = "text",
      value = "000",
      value_id = "clip_ammo",
      style_id = "clip_ammo_shadow",
      style = {
        font_size = 30,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 3, 2, 1 }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      value = "0000",
      value_id = "reserve_ammo",
      style_id = "reserve_ammo",
      style = {
        font_size = 18,
        font_type = "machine_medium",
        text_vertical_alignment = "bottom",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_1,
        offset = { 0, 0, 2 }
      }
    },
    {
      pass_type = "text",
      value = "0000",
      value_id = "reserve_ammo",
      style_id = "reserve_ammo_shadow",
      style = {
        font_size = 18,
        font_type = "machine_medium",
        text_vertical_alignment = "bottom",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2, 2, 1 }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    }
  }, "ammo_indicator"),
  grenade_indicator = UIWidget.create_definition({
    {
      pass_type = "texture",
      value = "content/ui/materials/hud/icons/party_throwable",
      style_id = "grenade_icon",
      style = {
        size = { 20, 20 },
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = UIHudSettings.color_tint_main_1,
        offset = { 0, 0, 1 }
      }
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/hud/icons/party_throwable",
      style_id = "grenade_icon_shadow",
      style = {
        size = { 20, 20 },
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = UIHudSettings.color_tint_0,
        offset = { 2, 2, 0 }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      value = "0",
      value_id = "grenade_count",
      style_id = "grenade_count",
      style = {
        font_size = 20,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_1,
        offset = { 0, 0, 2 }
      }
    },
    {
      pass_type = "text",
      value = "0",
      value_id = "grenade_count",
      style_id = "grenade_count_shadow",
      style = {
        font_size = 20,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2, 2, 1 }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    },
  }, "grenade_indicator"),
  reload_indicator = UIWidget.create_definition({
    {
      pass_type = "rect",
      style_id = "reload_bar",
      style = {
        size = { 28, 4 },
        max_height = 28,
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        color = UIHudSettings.color_tint_1,
        offset = { 0, 0, 2 }
      },
      visibility_function = function(content, style)
        local only_during_reload = mod:get("only_during_reload")
        local has_reload_time = mod.reload_time and mod.reload_time > 0

        return (only_during_reload and has_reload_time) or not only_during_reload
      end
    },
    {
      pass_type = "rect",
      style_id = "reload_bar_bg",
      style = {
        rect_style_id = "reload_bar",
        size = { 30, 6 },
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_0,
        offset = { -1, 1, 1 }
      },
      visibility_function = function(content, style)
        local only_during_reload = mod:get("only_during_reload")
        local has_reload_time = mod.reload_time and mod.reload_time > 0

        return (only_during_reload and has_reload_time) or not only_during_reload
      end
    },
    {
      pass_type = "text",
      value = "0.00",
      value_id = "reload_time",
      style_id = "reload_time",
      style = {
        font_size = 14,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",
        text_color = UIHudSettings.color_tint_1,
        offset = { 0, 0, 2 }
      },
      visibility_function = function(content, style)
        local only_during_reload = mod:get("only_during_reload")
        local has_reload_time = mod.reload_time and mod.reload_time > 0

        return (only_during_reload and has_reload_time) or not only_during_reload
      end
    },
    {
      pass_type = "text",
      value = "0.00",
      value_id = "reload_time",
      style_id = "reload_time_shadow",
      style = {
        text_style_id = "reload_time",
        font_size = 14,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2, 2, 1 }
      },
      visibility_function = function(content, style)
        local enable_shadows = mod:get("enable_shadows")
        local only_during_reload = mod:get("only_during_reload")
        local has_reload_time = mod.reload_time and mod.reload_time > 0

        return enable_shadows and (only_during_reload and has_reload_time) or not only_during_reload
      end
    }
  }, "reload_indicator")
}

return {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions
}