local mod = get_mod("crosshair_hud")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local function readable(text)
  local readable_string = ""
  local tokens = string.split(text, "_")
  for i, token in ipairs(tokens) do
    local first_letter = string.sub(token, 1, 1)
    token = string.format("%s%s", string.upper(first_letter), string.sub(token, 2))
    readable_string = string.trim(string.format("%s %s", readable_string, token))
  end

  return readable_string
end

local localizations = {
  crosshair_hud = {
    en = "Crosshair HUD",
    ["zh-cn"] = "准星 HUD",
  },
  crosshair_hud_description = {
    en = "Adds customizable Toughness, Health, Coherency, Ammo, Reload, Grenade and/or Ability indicators near the crosshair.",
    ["zh-cn"] = "在准星附近添加可以自定义的韧性、生命值、连携、弹药、装弹、手雷和技能指示器。",
  },

  x_offset = {
    en = "X Offset",
    ["zh-cn"] = "X 轴偏移",
  },
  x_offset_description = {
    en = "Adjusts horizontal position.\nNegative values move the display to the left; positive values to the right.",
    ["zh-cn"] = "调整水平位置。\n负值表示向左移动，正值表示向右移动。",
  },

  y_offset = {
    en = "Y Offset",
    ["zh-cn"] = "Y 轴偏移",
  },
  y_offset_description = {
    en = "Adjusts vertical position.\nNegative values move the display up; positive values down.",
    ["zh-cn"] = "调整垂直位置。\n负值表示向上移动，正值表示向下移动。",
  },

  health_display_type = {
    en = "Display Type",
    ["zh-cn"] = "显示类型",
  },
  toughness_display_type = {
    en = "Display Type",
    ["zh-cn"] = "显示类型",
  },
  display_type_value = {
    en = "Value",
    ["zh-cn"] = "数值",
  },
  display_type_percent = {
    en = "Percent",
    ["zh-cn"] = "百分比",
  },

  options_health = {
    en = "Health Settings",
    ["zh-cn"] = "生命值设置",
  },
  permanent_health_position = {
    en = "Permanent Health Position",
    ["zh-cn"] = "生命上限位置",
  },
  permanent_position_top = {
    en = "Top",
    ["zh-cn"] = "顶部",
  },
  permanent_position_bottom = {
    en = "Bottom",
    ["zh-cn"] = "底部",
  },
  health_always_show = {
    en = "Always Show Health",
    ["zh-cn"] = "总是显示生命值",
  },
  health_always_show_description = {
    en = "Always display current health, regardless of other health visibility settings.",
    ["zh-cn"] = "总是显示当前生命值，无视其他生命值显示设置。",
  },
  health_stay_time = {
    en = "Health Stay Time",
    ["zh-cn"] = "生命值保持时间",
  },
  health_stay_time_description = {
    en = "Amount of time, in seconds, that current health is displayed when receiving health damage.\nSet to 0 to disable.",
    ["zh-cn"] = "受到生命值伤害时，显示生命值的秒数。\n设置为 0 禁用。",
  },
  health_hide_at_full = {
    en = "Hide at Full Health",
    ["zh-cn"] = "满生命值时隐藏",
  },
  health_hide_at_full_description = {
    en = "Hides the display when health is at 100%.",
    ["zh-cn"] = "生命值为 100% 时不显示。",
  },

  options_toughness = {
    en = "Toughness Settings",
    ["zh-cn"] = "韧性设置",
  },
  toughness_always_show = {
    en = "Always Show Toughness",
    ["zh-cn"] = "总是显示韧性",
  },
  toughness_always_show_description = {
    en = "Always display current toughness, regardless of other toughness visibility settings.",
    ["zh-cn"] = "总是显示当前韧性，无视其他韧性显示设置。",
  },
  toughness_stay_time = {
    en = "Toughness Stay Time",
    ["zh-cn"] = "韧性保持时间",
  },
  toughness_stay_time_description = {
    en = "Amount of time, in seconds, that current toughness is displayed when receiving toughness damage.\nSet to 0 to disable.",
    ["zh-cn"] = "受到韧性伤害时，显示韧性的秒数。\n设置为 0 禁用。",
  },
  toughness_hide_at_full = {
    en = "Hide at Full Toughness",
    ["zh-cn"] = "满韧性时隐藏",
  },
  toughness_hide_at_full_description = {
    en = "Hides the display when toughness is at 100%.",
    ["zh-cn"] = "韧性为 100% 时不显示。",
  },

  options_coherency = {
    en = "Coherency Settings",
    ["zh-cn"] = "连携设置",
  },
  coherency_type = {
    en = "Coherency Indicator",
    ["zh-cn"] = "连携指示器",
  },
  coherency_type_description = {
    en = "Sets the indicator type for each teammate in coherency:"
        .. "\n{#color(255,180,0)}Simple{#reset()}: Plus (+) symbol"
        .. "\n{#color(255,180,0)}Archetype{#reset()}: Archetype (subclass) symbol"
        .. "\n{#color(255,180,0)}Aura{#reset()}: Icon representing the buff provided"
        .. "\n{#color(255,180,0)}Off{#reset()}: No coherency display",
    ["zh-cn"] = "设置队友连携指示器的类型："
        .. "\n{#color(255,180,0)}简单{#reset()}：显示为加号（+）"
        .. "\n{#color(255,180,0)}职业{#reset()}：显示为职业符号"
        .. "\n{#color(255,180,0)}光环{#reset()}：显示为连携提供的增益效果图标"
        .. "\n{#color(255,180,0)}关闭{#reset()}：不显示连携",
  },
  coherency_type_simple = {
    en = "Simple",
    ["zh-cn"] = "简单",
  },
  coherency_type_simple_description = {
    en = "Plus (+) symbol",
    ["zh-cn"] = "显示为加号（+）",
  },
  coherency_type_archetype = {
    en = "Archetype",
    ["zh-cn"] = "职业",
  },
  coherency_type_archetype_description = {
    en = "Archetype (subclass) symbol",
    ["zh-cn"] = "显示为职业符号",
  },
  coherency_type_aura = {
    en = "Aura",
    ["zh-cn"] = "光环",
  },
  coherency_type_aura_description = {
    en = "Icon representing the buff provided",
    ["zh-cn"] = "显示为连携提供的增益效果图标",
  },
  coherency_type_off = {
    en = "Off",
    ["zh-cn"] = "关闭",
  },
  coherency_type_off_description = {
    en = "No coherency display",
    ["zh-cn"] = "不显示连携",
  },
  hide_coherency_buff_bar = {
    en = "Hide Buff Icon",
    ["zh-cn"] = "隐藏状态图标",
  },
  hide_coherency_buff_bar_description = {
    en = "Hides the coherency buff icon in the buff bar."
        .. "\n{#color(255,180,0)}Requires reload (CTRL+SHIFT+R) or game restart{#reset()}",
    ["zh-cn"] = "在状态效果栏隐藏连携图标。"
        .. "\n{#color(255,180,0)}需要重新加载（Ctrl+Shift+R）或重启游戏{#reset()}",
  },
  coherency_colors = {
    en = "Indicator Colors",
    ["zh-cn"] = "连携颜色",
  },
  coherency_colors_teammate = {
    en = "Teammate Color",
    ["zh-cn"] = "队友颜色",
  },
  coherency_colors_health = {
    en = "Teammate Health",
    ["zh-cn"] = "队友生命值",
  },
  coherency_colors_toughness = {
    en = "Teammate Toughness",
    ["zh-cn"] = "队友韧性",
  },
  coherency_colors_static = {
    en = "Static Color",
    ["zh-cn"] = "静态颜色",
  },

  options_ability_cooldown = {
    en = "Ability Settings",
    ["zh-cn"] = "技能设置",
  },
  display_ability_cooldown = {
    en = "Display Ability Indicator",
    ["zh-cn"] = "显示技能指示器",
  },
  ability_cooldown_threshold = {
    en = "Cooldown Timer Threshold",
    ["zh-cn"] = "冷却时间阈值",
  },
  ability_cooldown_threshold_description = {
    en = "Amount of time remaining, in seconds, on ability cooldown before the timer will display."
        .. "\nSet to 0 to disable.",
    ["zh-cn"] = "技能冷却时间达到此秒数，才显示计时器。\n设置为 0 禁用。",
  },

  options_ammo = {
    en = "Ammo Settings",
    ["zh-cn"] = "弹药设置",
  },
  display_ammo_indicator = {
    en = "Display Ammo Indicator",
    ["zh-cn"] = "显示弹药指示器",
  },
  show_ammo_icon = {
    en = "Show Icon",
    ["zh-cn"] = "显示图标",
  },

  options_pocketable = {
    en = "Pocketable Settings",
    ["zh-cn"] = "携带品设置",
  },
  display_pocketable_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
  },

  options_peril = {
    en = "Peril / Overheat Settings",
    ["zh-cn"] = "危机 / 热量设置",
  },
  display_peril_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
  },

  options_grenade = {
    en = "Grenade Settings",
    ["zh-cn"] = "手雷设置",
  },
  display_grenade_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
  },

  options_reload = {
    en = "Reload Settings",
    ["zh-cn"] = "装弹设置",
  },
  display_reload_indicator = {
    en = "Display Reload Indicator",
    ["zh-cn"] = "显示装弹指示器",
  },
  only_during_reload = {
    en = "Only During Reload",
    ["zh-cn"] = "仅在装弹时显示",
  },
  only_during_reload_description = {
    en = "Only show the indicator while actively reloading."
        .. "\nDisabling this can help when customizing position.",
    ["zh-cn"] = "仅在装弹状态下显示。\n自定义位置时可以禁用此选项。",
  },

  custom_threshold_full = {
    en = "Full Threshold Color",
    ["zh-cn"] = "满阈值颜色",
  },
  custom_threshold_high = {
    en = "High Threshold Color",
    ["zh-cn"] = "高阈值颜色",
  },
  custom_threshold_low = {
    en = "Low Threshold Color",
    ["zh-cn"] = "低阈值颜色",
  },
  custom_threshold_critical = {
    en = "Critical Threshold Color",
    ["zh-cn"] = "空阈值颜色",
  },

  red = {
    en = "Red",
    ["zh-cn"] = "红色",
  },
  green = {
    en = "Green",
    ["zh-cn"] = "绿色",
  },
  blue = {
    en = "Blue",
    ["zh-cn"] = "蓝色",
  },

  options_ally = {
    en = "Ally Settings",
    ["zh-cn"] = "队友设置",
  },
  options_ally_1 = {
    en = "Ally 1",
    ["zh-cn"] = "队友 1",
  },
  options_ally_2 = {
    en = "Ally 2",
    ["zh-cn"] = "队友 2",
  },
  options_ally_3 = {
    en = "Ally 3",
    ["zh-cn"] = "队友 3",
  },
  display_ally_indicator = {
    en = "Display Ally Indicators",
    ["zh-cn"] = "显示队友指示器",
  },

  options_global = {
    en = "Miscellaneous",
    ["zh-cn"] = "杂项",
  },
  enable_shadows = {
    en = "Enable Shadows",
    ["zh-cn"] = "启用阴影",
  },
  enable_shadows_description = {
    en = "Toggles text and icon shadows.",
    ["zh-cn"] = "开关文本和图标的阴影。",
  },
  on = {
    en = "On",
    ["zh-cn"] = "开",
  },
  off = {
    en = "Off",
    ["zh-cn"] = "关",
  },
  global = {
    en = "Global",
    ["zh-cn"] = "全局",
  },

  scale = {
    en = "Scale",
    ["zh-cn"] = "缩放",
  },

  display_gauge = {
    en = "Display Gauge",
    ["zh-cn"] = "显示计量条",
  },
  mirror = {
    en = "Mirrored",
    ["zh-cn"] = "镜像",
  },
  display_wounds_count = {
    en = "Display Wounds Remaining"
  },
  color = {
    en = "Color"
  },
  display_permanent_health_text = {
    en = "Display Permanent Health Text"
  },
  display_peril_icon = {
    en = "Display Peril Icon"
  },
  display_grenade_icon = {
    en = "Display Grenade Icon"
  },

  options_archetype = {
    en = "Archetype Indicators"
  },
  options_archetype_psyker = {
    en = "Psyker"
  },
  display_archetype_indicator_psyker = {
    en = "Display Warp Charge Indicator"
  },
  archetype_psyker_pip_color = {
    en = "Pip Color"
  },
  archetype_psyker_frame_color = {
    en = "Frame Color"
  }
}

local colors = {}
local color_names = Color.list
for i, color_name in ipairs(color_names) do
  local color_values = Color[color_name](255, true)
  local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
  localizations[color_name] = {
    en = text
  }
end

return localizations