local mod = get_mod("crosshair_hud")

local global_scale = mod:get("global_scale")
local global_x_offset = mod:get("global_x_offset")
local global_y_offset = mod:get("global_y_offset")
local coherency_scale = mod:get("coherency_scale") * global_scale
local coherency_x_offset = mod:get("coherency_x_offset")
local coherency_y_offset = mod:get("coherency_y_offset")
local toughness_scale = mod:get("toughness_scale") * global_scale
local toughness_x_offset = mod:get("toughness_x_offset")
local toughness_y_offset = mod:get("toughness_y_offset")
local health_scale = mod:get("health_scale") * global_scale
local health_x_offset = mod:get("health_x_offset")
local health_y_offset = mod:get("health_y_offset")
local ability_scale = mod:get("ability_scale") * global_scale
local ability_x_offset = mod:get("ability_x_offset")
local ability_y_offset = mod:get("ability_y_offset")
local reload_scale = mod:get("reload_scale") * global_scale
local reload_x_offset = mod:get("reload_x_offset")
local reload_y_offset = mod:get("reload_y_offset")
local ammo_scale = mod:get("ammo_scale") * global_scale
local ammo_x_offset = mod:get("ammo_x_offset")
local ammo_y_offset = mod:get("ammo_y_offset")
local grenade_scale = mod:get("grenade_scale") * global_scale
local grenade_x_offset = mod:get("grenade_x_offset")
local grenade_y_offset = mod:get("grenade_y_offset")
local pocketable_scale = mod:get("pocketable_scale") * global_scale
local pocketable_x_offset = mod:get("pocketable_x_offset")
local pocketable_y_offset = mod:get("pocketable_y_offset")
local peril_scale = mod:get("peril_scale") * global_scale
local peril_x_offset = mod:get("peril_x_offset")
local peril_y_offset = mod:get("peril_y_offset")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  toughness_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48 * toughness_scale, 24 * toughness_scale },
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
    size = { 48 * health_scale, 24 * health_scale },
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
    size = { 48 * ability_scale, 28 * ability_scale },
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
    size = { 48 * coherency_scale, 32 * coherency_scale },
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
    size = { 52 * ammo_scale, 44 * ammo_scale },
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
    size = { 40 * grenade_scale, 20 * grenade_scale },
    position = {
      global_x_offset + grenade_x_offset,
      global_y_offset + grenade_y_offset,
      55
    }
  },
  pocketable_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 20 * pocketable_scale, 20 * pocketable_scale },
    position = {
      global_x_offset + pocketable_x_offset,
      global_y_offset + pocketable_y_offset,
      55
    }
  },
  peril_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 40 * peril_scale, 20 * peril_scale },
    position = {
      global_x_offset + peril_x_offset,
      global_y_offset + peril_y_offset,
      55
    }
  },
  reload_indicator = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 28 * reload_scale, 20 * reload_scale },
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
        size = { 43 * coherency_scale, 43 * coherency_scale },
        offset = { -30 * coherency_scale, -2 * coherency_scale, 3 },
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
        size = { 43 * coherency_scale, 43 * coherency_scale },
        offset = { 0, -2 * coherency_scale, 3 },
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
        size = { 43 * coherency_scale, 43 * coherency_scale },
        offset = { 30 * coherency_scale, -2 * coherency_scale, 3 },
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
        size = { 28 * coherency_scale, 28 * coherency_scale },
        offset = { -22 * coherency_scale, -2 * coherency_scale, 2 },
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
        size = { 28 * coherency_scale, 28 * coherency_scale },
        offset = { 0, -2 * coherency_scale, 2 },
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
        size = { 28 * coherency_scale, 28 * coherency_scale },
        offset = { 22 * coherency_scale, -2 * coherency_scale, 2 },
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
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { -14 * coherency_scale, 2 * coherency_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_1_shadow",
      value_id = "player_1",
      value = "+",
      style = {
        text_style_id = "player_1",
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { -12 * coherency_scale, 4 * coherency_scale, 1 }
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
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 0, 2 * coherency_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_2_shadow",
      value_id = "player_2",
      value = "+",
      style = {
        text_style_id = "player_2",
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * coherency_scale, 4 * coherency_scale, 1 }
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
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 14 * coherency_scale, 2 * coherency_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_3_shadow",
      value_id = "player_3",
      value = "+",
      style = {
        text_style_id = "player_3",
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 16 * coherency_scale, 4 * coherency_scale, 1 }
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
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { -26 * coherency_scale, 2 * coherency_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_1_shadow",
      value_id = "player_1",
      value = "+",
      style = {
        text_style_id = "player_1",
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { -24 * coherency_scale, 4 * coherency_scale, 1 }
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
        font_size = 24 * coherency_scale,
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
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * coherency_scale, 4 * coherency_scale, 1 }
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
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_6,
        offset = { 26 * coherency_scale, 2 * coherency_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "player_3_shadow",
      value_id = "player_3",
      value = "+",
      style = {
        text_style_id = "player_3",
        font_size = 24 * coherency_scale,
        text_horizontal_alignment = "center",
        text_vertical_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 28 * coherency_scale, 4 * coherency_scale, 1 }
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
        font_size = 24 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          -14 * toughness_scale,
          2 * toughness_scale,
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
        font_size = 24 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",
        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          -12 * toughness_scale,
          4 * toughness_scale,
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
        font_size = 24 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          0,
          2 * toughness_scale,
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
        font_size = 24 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          2 * toughness_scale,
          4 * toughness_scale,
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
        font_size = 24 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          14 * toughness_scale,
          2 * toughness_scale,
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
        font_size = 24 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          16 * toughness_scale,
          4 * toughness_scale,
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
        font_size = 16 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = { 30 * toughness_scale, 2 * toughness_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "text_symbol_shadow",
      value_id = "text_symbol",
      value = "%",
      style = {
        text_style_id = "text_symbol",
        font_size = 16 * toughness_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = { 32 * toughness_scale, 4 * toughness_scale, 1 }
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
        font_size = 24 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          -14 * health_scale,
          2 * health_scale,
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
        font_size = 24 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          -12 * health_scale,
          4 * health_scale,
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
        font_size = 24 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          0,
          2 * health_scale,
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
        font_size = 24 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          2 * health_scale,
          4 * health_scale,
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
        font_size = 24 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = {
          14 * health_scale,
          2 * health_scale,
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
        font_size = 24 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          16 * health_scale,
          4 * health_scale,
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
        font_size = 16 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_main_2,
        offset = { 30 * health_scale, 2 * health_scale, 2 }
      }
    },
    {
      pass_type = "text",
      style_id = "text_symbol_shadow",
      value_id = "text_symbol",
      value = "%",
      style = {
        text_style_id = "text_symbol",
        font_size = 16 * health_scale,
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",

        font_type = "machine_medium",
        text_color = UIHudSettings.color_tint_0,
        offset = {
          32 * health_scale,
          4 * health_scale,
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
        pivot = { 10 * ability_scale, 10 * ability_scale },
        angle = math.pi,
        horizontal_alignment = "center",
        vertical_alignment = "center",
        size = { 20 * ability_scale, 20 * ability_scale },
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
        size = { 20 * ability_scale, 20 * ability_scale },
        pivot = { 10 * ability_scale, 10 * ability_scale },
        angle = math.pi / 4,
        color = UIHudSettings.color_tint_0,
        offset = { 0, 0, 1 }
      },
    },
    {
      pass_type = "text",
      value_id = "charge_count",
      value = "",
      style_id = "charge_count",
      style = {
        font_size = 14 * ability_scale,
        font_type = "machine_medium",
        text_horizontal_alignment = "right",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_1,
        offset = { -5 * ability_scale, 4 * ability_scale, 2 }
      }
    },
    {
      pass_type = "text",
      value_id = "charge_count",
      value = "",
      style_id = "charge_count_shadow",
      style = {
        font_size = 14 * ability_scale,
        font_type = "machine_medium",
        text_horizontal_alignment = "right",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_0,
        offset = { -3 * ability_scale, 6 * ability_scale, 1 }
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
        font_size = 14 * ability_scale,
        font_type = "machine_medium",
        text_horizontal_alignment = "left",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_1,
        offset = { -5 * ability_scale, 4 * ability_scale, 2 }
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
        font_size = 14 * ability_scale,
        font_type = "machine_medium",
        text_horizontal_alignment = "left",
        text_vertical_alignment = "bottom",
        text_color = UIHudSettings.color_tint_0,
        offset = { -3 * ability_scale, 6 * ability_scale, 1 }
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
        size = { 20 * ammo_scale, 20 * ammo_scale },
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
        size = { 20 * ammo_scale, 20 * ammo_scale },
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_0,
        offset = { 2 * ammo_scale, 2 * ammo_scale, 0}
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
        font_size = 30 * ammo_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_1,
        offset = { 1 * ammo_scale, 0, 2 }
      }
    },
    {
      pass_type = "text",
      value = "000",
      value_id = "clip_ammo",
      style_id = "clip_ammo_shadow",
      style = {
        font_size = 30 * ammo_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 3 * ammo_scale, 2 * ammo_scale, 1 }
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
        font_size = 18 * ammo_scale,
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
        font_size = 18 * ammo_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "bottom",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * ammo_scale, 2 * ammo_scale, 1 }
      },
      visibility_function = function(content, style)
        return mod:get("enable_shadows")
      end
    }
  }, "ammo_indicator"),
  pocketable_indicator = UIWidget.create_definition({
    {
      pass_type = "texture",
      value_id = "pocketable_icon",
      style_id = "pocketable_icon",
      style = {
        size = { 20 * pocketable_scale, 20 * pocketable_scale },
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = UIHudSettings.color_tint_main_1,
        offset = { 0, 0, 1 },
      },
      visibility_function = function(content, style)
        return content.pocketable_icon
      end
    },
    {
      pass_type = "texture",
      value_id = "pocketable_icon",
      style_id = "pocketable_icon_shadow",
      style = {
        size = { 20 * pocketable_scale, 20 * pocketable_scale },
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = UIHudSettings.color_tint_0,
        offset = { 2 * pocketable_scale, 2 * pocketable_scale, 0 },
      },
      visibility_function = function(content, style)
        return content.pocketable_icon and mod:get("enable_shadows")
      end
    },
  }, "pocketable_indicator"),
  peril_indicator = UIWidget.create_definition({
    {
      pass_type = "text",
      value = "",
      value_id = "symbol_text",
      style_id = "symbol_text",
      style = {
        font_size = 20 * peril_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "left",
        text_color = UIHudSettings.color_tint_1,
        offset = { 0, 0, 1 }
      }
    },
    {
      pass_type = "text",
      value = "",
      value_id = "symbol_text",
      style_id = "symbol_text_shadow",
      style = {
        font_size = 20 * peril_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "left",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * peril_scale, 2 * peril_scale, 0 }
      }
    },
    {
      pass_type = "text",
      value = "",
      value_id = "value_text",
      style_id = "value_text",
      style = {
        font_size = 20 * peril_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_1,
        offset = { 0, 0, 1 }
      }
    },
    {
      pass_type = "text",
      value = "",
      value_id = "value_text",
      style_id = "value_text_shadow",
      style = {
        font_size = 20 * peril_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * peril_scale, 2 * peril_scale, 0 }
      }
    }
  }, "peril_indicator"),
  grenade_indicator = UIWidget.create_definition({
    {
      pass_type = "texture",
      value_id = "grenade_icon",
      value = "content/ui/materials/hud/icons/party_throwable",
      style_id = "grenade_icon",
      style = {
        size = { 20 * grenade_scale, 20 * grenade_scale },
        vertical_alignment = "center",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_main_1,
        offset = { 0, 0, 1 }
      }
    },
    {
      pass_type = "texture",
      value_id = "grenade_icon",
      value = "content/ui/materials/hud/icons/party_throwable",
      style_id = "grenade_icon_shadow",
      style = {
        size = { 20 * grenade_scale, 20 * grenade_scale },
        vertical_alignment = "center",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_0,
        offset = { 2 * grenade_scale, 2 * grenade_scale, 0 }
      },
      visibility_function = function(content, style)
        return style.visible and mod:get("enable_shadows")
      end
    },
    {
      pass_type = "text",
      value = "0",
      value_id = "grenade_count",
      style_id = "grenade_count",
      style = {
        font_size = 20 * grenade_scale,
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
        font_size = 20 * grenade_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "right",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * grenade_scale, 2 * grenade_scale, 1 }
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
        size = { 28 * reload_scale, 4 * reload_scale },
        max_height = 28 * reload_scale,
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
        size = { 30 * reload_scale, 6 * reload_scale },
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        color = UIHudSettings.color_tint_0,
        offset = { -1 * reload_scale, 1 * reload_scale, 1 }
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
        font_size = 14 * reload_scale,
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
        font_size = 14 * reload_scale,
        font_type = "machine_medium",
        text_vertical_alignment = "top",
        text_horizontal_alignment = "center",
        text_color = UIHudSettings.color_tint_0,
        offset = { 2 * reload_scale, 2 * reload_scale, 1 }
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