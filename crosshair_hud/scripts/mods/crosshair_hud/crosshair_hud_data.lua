local mod = get_mod("crosshair_hud")

local options_display_type = table.enum("percent", "value", "hide")
mod.options_display_type = options_display_type

local options_coherency_type = {
  simple = "simple",
  archetype = "archetype",
  aura = "aura",
  off = "off"
}
mod.options_coherency_type = options_coherency_type

local migrations = mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/settings/migrations")
if migrations then
  migrations.run()
end

local color_options = {}
for i, color_name in ipairs(Color.list) do
  table.insert(color_options, {
    text = color_name,
    value = color_name
  })
end
table.sort(color_options, function(a, b)
  return a.text < b.text
end)

local function get_color_options()
  return table.clone(color_options)
end

local function get_stat_overlay_options()
  return table.clone({
    { text = "none", value = "none" },
    { text = "critical_strike_chance", value = "critical_strike_chance" },
    { text = "warp_damage", value = "warp_damage" },
    { text = "critical_strike_damage", value = "critical_strike_damage" }
  })
end

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

local width = 1920
local height = 1080
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
local function create_threshold_settings(setting_id, include_bonus)
  local custom_setting_id = "custom_threshold_" .. setting_id
  local settings = {}

  if include_bonus then
    local threshold_id = custom_setting_id .. "_bonus"
    table.insert(settings, {
      setting_id = threshold_id,
      title = "custom_threshold_bonus",
      type = "checkbox",
      default_value = false,
      sub_widgets = {
        {
          setting_id = threshold_id .."_color",
          title = "color",
          type = "dropdown",
          default_value = "ui_terminal",
          options = get_color_options()
        }
      }
    })
  end

  for _, threshold in ipairs(_thresholds) do
    local threshold_id = custom_setting_id .. "_" .. threshold
    local setting = {
      setting_id = threshold_id,
      title = "custom_threshold_" .. threshold,
      type = "checkbox",
      default_value = false,
      sub_widgets = {
        {
          setting_id = threshold_id .. "_color",
          title = "color",
          type = "dropdown",
          default_value = "ui_terminal",
          options = get_color_options()
        }
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
          },
          {
            setting_id = "hide_sprint_buff",
            type = "checkbox",
            default_value = false
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
            setting_id = "display_health_gauge",
            title = "display_gauge",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "mirror_health_gauge",
                title = "mirror",
                type = "checkbox",
                default_value = false
              },
              {
                setting_id = "independent_health_gauge_scaling",
                title = "scale_independently",
                tooltip = "scale_independently_description",
                type = "checkbox",
                default_value = false,
                sub_widgets = {
                  create_scale_setting("health_gauge")
                }
              },
              {
                setting_id = "independent_health_gauge",
                title = "move_independently",
                tooltip = "move_independently_description",
                type = "checkbox",
                default_value = false,
                sub_widgets = {
                  create_coordinate_setting("health_gauge", "x", -30),
                  create_coordinate_setting("health_gauge", "y", 0),
                }
              }
            }
          },
          {
            setting_id = "health_display_type",
            type = "dropdown",
            default_value = options_display_type.value,
            options = {
              { text = "display_type_value", value = options_display_type.value },
              { text = "display_type_percent", value = options_display_type.percent },
              { text = "hide_health_text", value = options_display_type.hide }
            }
          },
          {
            setting_id = "display_permanent_health_text",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "customize_permanent_health_color",
                type = "checkbox",
                default_value = false,
                sub_widgets = {
                  {
                    setting_id = "permanent_health_color",
                    type = "dropdown",
                    default_value = "ui_terminal",
                    options = get_color_options()
                  }
                }
              },
              {
                setting_id = "permanent_health_position",
                type = "dropdown",
                default_value = "top",
                options = {
                  { text = "permanent_position_top", value = "top" },
                  { text = "permanent_position_bottom", value = "bottom" },
                }
              },
            }
          },
          {
            setting_id = "display_wounds_count",
            type = "checkbox",
            default_value = true
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
            setting_id = "display_toughness_gauge",
            title = "display_gauge",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "mirror_toughness_gauge",
                title = "mirror",
                type = "checkbox",
                default_value = false
              },
              {
                setting_id = "independent_toughness_gauge_scaling",
                title = "scale_independently",
                tootlip = "scale_independently_description",
                type = "checkbox",
                default_value = false,
                sub_widgets = {
                  create_scale_setting("toughness_gauge")
                }
              },
              {
                setting_id = "independent_toughness_gauge",
                title = "move_independently",
                tooltip = "move_independently_description",
                type = "checkbox",
                default_value = false,
                sub_widgets = {
                  create_coordinate_setting("toughness_gauge", "x", 30),
                  create_coordinate_setting("toughness_gauge", "y", 0),
                }
              }
            }
          },
          {
            setting_id = "toughness_display_type",
            type = "dropdown",
            default_value = options_display_type.value,
            options = {
              { text = "display_type_value", value = options_display_type.value },
              { text = "display_type_percent", value = options_display_type.percent },
              { text = "hide_toughness_text", value = options_display_type.hide }
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
          unpack(create_threshold_settings("toughness", true))
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
              { text = "coherency_colors_static", value = "static_color", show_widgets = { 1 } }
            },
            sub_widgets = {
              {
                setting_id = "coherency_color_static_color",
                title = "coherency_colors_static",
                type = "dropdown",
                default_value = "ui_terminal",
                options = get_color_options()
              }
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
                range = { 0, 120 },
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

      --- Stimm ---
      {
        setting_id = "options_stimm",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_stimm_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              create_shadow_setting("stimm"),
              create_scale_setting("stimm"),
              create_coordinate_setting("stimm", "x", 0),
              create_coordinate_setting("stimm", "y", 240)
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
              {
                setting_id = "display_peril_icon",
                type = "checkbox",
                default_value = true,
              },
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
              {
                setting_id = "display_grenade_icon",
                type = "checkbox",
                default_value = true
              },
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
              create_coordinate_setting("reload", "y", 60)
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
              },
              {
                setting_id = "ally_health_display_type",
                type = "dropdown",
                default_value = options_display_type.value,
                options = {
                  { text = "display_type_value", value = options_display_type.value },
                  { text = "display_type_percent", value = options_display_type.percent },
                  { text = "hide_health_text", value = options_display_type.hide }
                }
              },
              {
                setting_id = "ally_toughness_display_type",
                type = "dropdown",
                default_value = options_display_type.value,
                options = {
                  { text = "display_type_value", value = options_display_type.value },
                  { text = "display_type_percent", value = options_display_type.percent },
                  { text = "hide_toughness_text", value = options_display_type.hide }
                }
              }
            }
          }
        }
      },

      --- Stat Overlay ---
      --{
      --  setting_id = "options_stat_overlay",
      --  type = "group",
      --  sub_widgets = {
      --    {
      --      setting_id = "display_stat_overlay_1",
      --      type = "dropdown",
      --      default_value = "none",
      --      options = get_stat_overlay_options()
      --    },
      --    {
      --      setting_id = "display_stat_overlay_2",
      --      type = "dropdown",
      --      default_value = "none",
      --      options = get_stat_overlay_options()
      --    },
      --    {
      --      setting_id = "display_stat_overlay_3",
      --      type = "dropdown",
      --      default_value = "none",
      --      options = get_stat_overlay_options()
      --    }
      --  }
      --},

      --- Archetypes ---
      {
        setting_id = "options_archetype_psyker",
        type = "group",
        sub_widgets = {
          {
            setting_id = "display_warp_charge_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "hide_warp_charges_buff",
                type = "checkbox",
                default_value = false
              },
              create_shadow_setting("warp_charge"),
              create_scale_setting("warp_charge"),
              create_coordinate_setting("warp_charge", "x", 0),
              create_coordinate_setting("warp_charge", "y", 0),
            }
          },
          {
            setting_id = "display_kinetic_flayer_indicator",
            type = "checkbox",
            default_value = true,
            sub_widgets = {
              {
                setting_id = "hide_kinetic_flayer_buff",
                type = "checkbox",
                default_value = false
              },
              create_shadow_setting("kinetic_flayer"),
              create_scale_setting("kinetic_flayer"),
              create_coordinate_setting("kinetic_flayer", "x", 0),
              create_coordinate_setting("kinetic_flayer", "y", 0)
            }
          }
        }
      },
      --{
      --  setting_id = "options_archetype_veteran",
      --  type = "group",
      --  sub_widgets = {
      --    {
      --      setting_id = "display_archetype_indicator_veteran",
      --      type = "checkbox",
      --      default_value = true,
      --      sub_widgets = {
      --        create_shadow_setting("archetype_veteran"),
      --        create_scale_setting("archetype_veteran"),
      --        create_coordinate_setting("archetype_veteran", "x", 0),
      --        create_coordinate_setting("archetype_veteran", "y", 0),
      --      }
      --    }
      --  }
      --},
      --{
      --  setting_id = "options_archetype_zealot",
      --  type = "group",
      --  sub_widgets = {
      --    {
      --      setting_id = "display_archetype_indicator_zealot",
      --      type = "checkbox",
      --      default_value = true,
      --      sub_widgets = {
      --        create_shadow_setting("archetype_zealot"),
      --        create_scale_setting("archetype_zealot"),
      --        create_coordinate_setting("archetype_zealot", "x", 0),
      --        create_coordinate_setting("archetype_zealot", "y", 0),
      --      }
      --    }
      --  }
      --},
      --{
      --  setting_id = "options_archetype_ogryn",
      --  type = "group",
      --  sub_widgets = {
      --    {
      --      setting_id = "display_archetype_indicator_ogryn",
      --      type = "checkbox",
      --      default_value = true,
      --      sub_widgets = {
      --        create_shadow_setting("archetype_ogryn"),
      --        create_scale_setting("archetype_ogryn"),
      --        create_coordinate_setting("archetype_ogryn", "x", 0),
      --        create_coordinate_setting("archetype_ogryn", "y", 0),
      --      }
      --    }
      --  }
      --}
    }
  }
}
