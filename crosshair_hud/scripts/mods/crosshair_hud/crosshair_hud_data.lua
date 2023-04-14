local mod = get_mod("crosshair_hud")
local validations = mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/settings/validations")

local options_display_type = table.enum("percent", "value")
mod.options_display_type = options_display_type

local options_coherency_type = {
  simple = "simple",
  archetype = "archetype",
  aura = "aura",
  off = "off"
}
mod.options_coherency_type = options_coherency_type

validations.run()

--TODO: Test converting multiple widgets to one widget that updates dynamic value
--TODO: Recreate these local funcs to reproduce:
--[[
    [Color Settings] (Dropdown) --> Full, High, Low, Empty  ; "health_full", "toughness_high", etc.
      [Red]          (Numeric)  --> (0, 255)                ; "health_full_red", etc.
      [Green]        (Numeric)  --> (0, 255)                ; etc. etc.
      [Blue]         (Numeric)  --> (0, 255)
]]--

--TODO: Create mod.OPTIONS table that stores setting keys for use as constants in the hud element
---     Maybe loop through .data files for each feature?
--mod.OPTIONS = {}
--mod:io_dofile(. . .)

local width = (RESOLUTION_LOOKUP.width and RESOLUTION_LOOKUP.width > 0 and RESOLUTION_LOOKUP.width) or 1920
local height = (RESOLUTION_LOOKUP.height and RESOLUTION_LOOKUP.height > 0 and RESOLUTION_LOOKUP.height) or 1080
local range_x = width / 2
local range_y = height / 2
local _coordinates_settings = {
  x = {
    range = { -range_x, range_x },
  },
  y = {
    range = { -range_y, range_y }
  }
}
local function create_coordinate_setting(setting_id, coordinate, default_value)
  local coordinate_setting_id = string.format("%s_%s_offset", setting_id, coordinate)
  local coordinate_settings = _coordinates_settings[coordinate]

  return {
    setting_id = coordinate_setting_id,
    title = string.format("%s_offset", coordinate),
    type = "numeric",
    range = table.clone(coordinate_settings.range),
    default_value = default_value or 0,
    decimals_number = 0,
    step_size_value = 1
  }
end

local function create_color_setting(setting_id, color_name)
  local color_setting_id = setting_id .. "_" .. color_name
  local default_value = 255

  return {
    setting_id = color_setting_id,
    title = color_name,
    type = "numeric",
    range = { 0, 255 },
    default_value = default_value,
    decimals_number = 0,
    step_size_value = 1,
    --change = function(new_value)
    --    --mod:set(setting_id, new_value)
    --end,
    --value_get_function = function()
    --    local id = mod:get("selected_color_id") or "health_high"
    --    local dynamic_id = id .. "_" .. color_name
    --
    --    return mod:get(dynamic_id) or 0
    --    --local value = mod:get("custom_threshold_health")
    --    --return mod:get(setting_id) or default_value
    --end
  }
end

local _thresholds = { "full", "high", "low", "critical" }
local function create_threshold_settings(setting_id)
  local custom_setting_id = "custom_threshold_" .. setting_id

  local settings = {}
  for _, threshold in ipairs(_thresholds) do
    local threshold_id = custom_setting_id .. "_" .. threshold
    local setting = {
      setting_id = threshold_id,
      title = "custom_threshold_" .. threshold,
      type = "checkbox",
      default_value = false,
      sub_widgets = {
        create_color_setting(threshold_id, "red"),
        create_color_setting(threshold_id, "green"),
        create_color_setting(threshold_id, "blue")
        --{
        --    setting_id = threshold_id,
        --    type = "group",
        --    sub_widgets = {
        --    }
        --}
      }
    }

    table.insert(settings, setting)
  end

  return settings
end

local function create_scale_setting(setting_id)
  local scale_id = string.format("%s_scale", setting_id)

  return {
    setting_id = scale_id,
    title = "scale",
    type = "numeric",
    range = { 1, 3 },
    default_value = 1,
    decimals_number = 1,
    step_size_value = 0.25
  }
end

local function create_shadow_setting(setting_id)
  local shadow_id = string.format("enable_shadows_%s", setting_id)

  return {
    setting_id = shadow_id,
    title = "enable_shadows",
    type = "dropdown",
    default_value = "global",
    options = {
      { text = "on", value = "on" },
      { text = "off", value = "off" },
      { text = "global", value = "global" }
    }
  }
end

return {
  name = mod:localize("crosshair_hud"),
  description = mod:localize("crosshair_hud_description"),
  options = {
    widgets = {

      --- Global ---
      {
        setting_id = "options_global",
        type = "group",
        sub_widgets = {
          create_scale_setting("global"),
          create_coordinate_setting("global", "x", 0),
          create_coordinate_setting("global", "y", 0),
          {
            setting_id = "enable_shadows",
            type = "checkbox",
            default_value = true,
          }
        }
      },

      --- Health ---
      {
        setting_id = "options_health",
        type = "group",
        sub_widgets = {
          create_shadow_setting("health"),
          create_scale_setting("health"),
          create_coordinate_setting("health", "x", -100),
          create_coordinate_setting("health", "y", 170),
          {
            setting_id = "health_display_type",
            type = "dropdown",
            default_value = options_display_type.value,
            options = {
              { text = "display_type_value", value = options_display_type.value },
              { text = "display_type_percent", value = options_display_type.percent }
            }
          },
          {
            setting_id = "permanent_health_position",
            type = "dropdown",
            default_value = "top",
            options = {
              { text = "permanent_position_top", value = "top" },
              { text = "permanent_position_bottom", value = "bottom" }
            }
          },
          {
            setting_id = "health_always_show",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "health_hide_at_full",
                type = "checkbox",
                default_value = false,
                change = function(new_value)
                  mod:set("health_hide_at_full", new_value)
                end,
                get = function()
                  return mod:get("health_hide_at_full")
                end
              },
              {
                setting_id = "health_stay_time",
                type = "numeric",
                range = { 0, 5 },
                default_value = 1.5,
                decimals_number = 2,
                step_size_value = 0.25,
                change = function(new_value)
                  mod:set("health_stay_time", new_value)
                end,
                get = function()
                  return mod:get("health_stay_time") or 1.5
                end,
              }
            }
          },
          unpack(create_threshold_settings("health"))
        }
      },

      --- Toughness ---
      {
        setting_id = "options_toughness",
        type = "group",
        sub_widgets = {
          create_shadow_setting("toughness"),
          create_scale_setting("toughness"),
          create_coordinate_setting("toughness", "x", 100),
          create_coordinate_setting("toughness", "y", 170),
          {
            setting_id = "toughness_display_type",
            type = "dropdown",
            default_value = options_display_type.value,
            options = {
              { text = "display_type_value", value = options_display_type.value },
              { text = "display_type_percent", value = options_display_type.percent }
            }
          },
          {
            setting_id = "toughness_always_show",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "toughness_hide_at_full",
                type = "checkbox",
                default_value = false,
                change = function(new_value)
                  mod:set("toughness_hide_at_full", new_value)
                end,
                get = function()
                  return mod:get("toughness_hide_at_full")
                end
              },
              {
                setting_id = "toughness_stay_time",
                type = "numeric",
                range = { 0, 5 },
                default_value = 1.5,
                decimals_number = 2,
                step_size_value = 0.25,
                change = function(new_value)
                  mod:set("toughness_stay_time", new_value)
                end,
                get = function()
                  return mod:get("toughness_stay_time") or 1.5
                end
              }
            }
          },
          unpack(create_threshold_settings("toughness"))
        },
      },

      --- Coherency ---
      {
        setting_id = "options_coherency",
        type = "group",
        sub_widgets = {
          {
            setting_id = "coherency_type",
            type = "dropdown",
            default_value = options_coherency_type.archetype,
            options = {
              { text = "coherency_type_aura", value = options_coherency_type.aura, show_widgets = { 1, 2 } },
              { text = "coherency_type_archetype", value = options_coherency_type.archetype, show_widgets = { 1, 2 } },
              { text = "coherency_type_simple", value = options_coherency_type.simple, show_widgets = { 1, 2 } },
              { text = "coherency_type_off", value = options_coherency_type.off }
            },
            sub_widgets = {
              {
                setting_id = "hide_coherency_buff_bar",
                type = "checkbox",
                default_value = false
              },
              create_shadow_setting("coherency"),
              create_scale_setting("coherency"),
              create_coordinate_setting("coherency", "x", 0),
              create_coordinate_setting("coherency", "y", 250),
            }
          },
          {
            setting_id = "coherency_colors",
            type = "dropdown",
            default_value = "player_color",
            options = {
              { text = "coherency_colors_teammate", value = "player_color" },
              { text = "coherency_colors_health", value = "player_health" },
              { text = "coherency_colors_toughness", value = "player_toughness" },
              { text = "coherency_colors_static", value = "static_color", show_widgets = { 1, 2, 3 } }
            },
            sub_widgets = {
              create_color_setting("coherency_color_static", "red"),
              create_color_setting("coherency_color_static", "green"),
              create_color_setting("coherency_color_static", "blue")
            }
          }
        }
      },

      --- Ability ---
      {
        setting_id = "options_ability_cooldown",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_ability_cooldown",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "ability_cooldown_threshold",
                type = "numeric",
                range = { 0, 59 },
                default_value = 10,
                decimals_number = 0,
                step_size_value = 1
              },
              create_shadow_setting("ability"),
              create_scale_setting("ability"),
              create_coordinate_setting("ability", "x", 0),
              create_coordinate_setting("ability", "y", 115),
              unpack(create_threshold_settings("ability"))
            }
          },
        }
      },

      --- Ammo ---
      {
        setting_id = "options_ammo",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_ammo_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "show_ammo_icon",
                type = "checkbox",
                default_value = true
              },
              create_shadow_setting("ammo"),
              create_scale_setting("ammo"),
              create_coordinate_setting("ammo", "x", 100),
              create_coordinate_setting("ammo", "y", 250),
              unpack(create_threshold_settings("ammo"))
            }
          }
        }
      },

      --- Pocketable ---
      {
        setting_id = "options_pocketable",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_pocketable_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              create_shadow_setting("pocketable"),
              create_scale_setting("pocketable"),
              create_coordinate_setting("pocketable", "x", 0),
              create_coordinate_setting("pocketable", "y", 220)
            }
          }
        }
      },

      --- Peril ---
      {
        setting_id = "options_peril",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_peril_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              create_shadow_setting("peril"),
              create_scale_setting("peril"),
              create_coordinate_setting("peril", "x", 0),
              create_coordinate_setting("peril", "y", 45),
              unpack(create_threshold_settings("peril"))
            }
          }
        }
      },

      --- Grenade ---
      {
        setting_id = "options_grenade",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_grenade_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              create_shadow_setting("grenade"),
              create_scale_setting("grenade"),
              create_coordinate_setting("grenade", "x", -100),
              create_coordinate_setting("grenade", "y", 315),
              unpack(create_threshold_settings("grenade"))
            }
          }
        }
      },

      --- Reload ---
      {
        setting_id = "options_reload",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_reload_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "only_during_reload",
                type = "checkbox",
                default_value = true
              },
              create_shadow_setting("reload"),
              create_scale_setting("reload"),
              create_coordinate_setting("reload", "x", 0),
              create_coordinate_setting("reload", "y", 60),
              unpack(create_threshold_settings("reload"))
            }
          }
        }
      },

      --- Ally ---
      {
        setting_id = "options_ally",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_ally_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              create_scale_setting("ally"),
              {
                setting_id = "options_ally_1",
                type = "group",
                sub_widgets = {
                  create_coordinate_setting("ally_1", "x", -200),
                  create_coordinate_setting("ally_1", "y", 345)
                }
              },
              {
                setting_id = "options_ally_2",
                type = "group",
                sub_widgets = {
                  create_coordinate_setting("ally_2", "x", 0),
                  create_coordinate_setting("ally_2", "y", 445)
                }
              },
              {
                setting_id = "options_ally_3",
                type = "group",
                sub_widgets = {
                  create_coordinate_setting("ally_3", "x", 200),
                  create_coordinate_setting("ally_3", "y", 345)
                }
              }
            }
          }
        }
      }

    }
  }
}
