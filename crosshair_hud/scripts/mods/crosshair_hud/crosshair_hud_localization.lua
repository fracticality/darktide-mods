local mod = get_mod("crosshair_hud")
local InputUtils = require("scripts/managers/input/input_utils")

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
    ru = "Интерфейс вокруг прицела",
  },
  crosshair_hud_description = {
    en = "Adds customizable Toughness, Health, Coherency, Ammo, Reload, Grenade and/or Ability indicators near the crosshair.",
    ["zh-cn"] = "在准星附近添加可以自定义的韧性、生命值、连携、弹药、装弹、手雷和技能指示器。",
    ru = "Crosshair HUD - Добавляет настраиваемые индикаторы Выносливости, Здоровья, Сплочённости, Боеприпасов, Перезарядки, Гранат и/или Способностей рядом с перекрестием.",
  },

  x_offset = {
    en = "X Offset",
    ["zh-cn"] = "X 轴偏移",
    ru = "Смещение по горизонтали",
  },
  x_offset_description = {
    en = "Adjusts horizontal position.\nNegative values move the display to the left; positive values to the right.",
    ["zh-cn"] = "调整水平位置。\n负值表示向左移动，正值表示向右移动。",
    ru = "Отрегулируйте горизонтальное положение.\nОтрицательные значения перемещают интерфейс влево; положительные значения — вправо.",
  },

  y_offset = {
    en = "Y Offset",
    ["zh-cn"] = "Y 轴偏移",
    ru = "Смещение по вертикали",
  },
  y_offset_description = {
    en = "Adjusts vertical position.\nNegative values move the display up; positive values down.",
    ["zh-cn"] = "调整垂直位置。\n负值表示向上移动，正值表示向下移动。",
    ru = "Отрегулируйте вертикальное положение.\nОтрицательные значения перемещают интерфейс вверх; положительные значения — вниз.",
  },
  hide_sprint_buff = {
    en = "Hide Sprint Buff Icon",
    ["zh-cn"] = "隐藏疾跑效果图标",
    ru = "Спрятать значок баффа спринта",
  },
  hide_sprint_buff_description = {
    en = "Hides the sprint buff from the buff bar.",
    ["zh-cn"] = "在状态效果栏隐藏疾跑效果。",
    ru = "Скрывает бафф спринта с панели баффов.",
  },

  health_display_type = {
    en = "Display Type",
    ["zh-cn"] = "显示类型",
    ru = "Вид отображения",
  },
  toughness_display_type = {
    en = "Display Type",
    ["zh-cn"] = "显示类型",
    ru = "Вид отображения",
  },
  display_type_value = {
    en = "Value",
    ["zh-cn"] = "数值",
    ru = "Значения",
  },
  display_type_percent = {
    en = "Percent",
    ["zh-cn"] = "百分比",
    ru = "Проценты",
  },

  options_health = {
    en = "Health Settings",
    ["zh-cn"] = "生命值设置",
    ru = "Настройки Здоровья",
  },
  hide_health_text = {
    en = "Hide Health Text",
    ["zh-cn"] = "隐藏生命值文本",
    ru = "Скрыть текст Здоровья",
  },
  permanent_health_position = {
    en = "Permanent Health Position",
    ["zh-cn"] = "生命上限位置",
    ru = "Постоянная позиция Здоровья",
  },
  permanent_position_top = {
    en = "Top",
    ["zh-cn"] = "顶部",
    ru = "Сверху",
  },
  permanent_position_bottom = {
    en = "Bottom",
    ["zh-cn"] = "底部",
    ru = "Снизу",
  },
  health_always_show = {
    en = "Always Show Health",
    ["zh-cn"] = "总是显示生命值",
    ru = "Всегда показывать Здоровье",
  },
  health_always_show_description = {
    en = "Always display current health, regardless of other health visibility settings.",
    ["zh-cn"] = "总是显示当前生命值，无视其他生命值显示设置。",
    ru = "Всегда показывать текущее Здоровье, независимо от других настроек видимости состояния Здоровья.",
  },
  health_stay_time = {
    en = "Health Stay Time",
    ["zh-cn"] = "生命值保持时间",
    ru = "Время задержки Здоровья",
  },
  health_stay_time_description = {
    en = "Amount of time, in seconds, that current health is displayed when receiving health damage.\nSet to 0 to disable.",
    ["zh-cn"] = "受到生命值伤害时，显示生命值的秒数。\n设置为 0 禁用。",
    ru = "Количество времени в секундах, в течение которого отображается текущее Здоровье при получении урона Здоровью.\nУстановите значение на 0, чтобы отключить.",
  },
  health_hide_at_full = {
    en = "Hide at Full Health",
    ["zh-cn"] = "满生命值时隐藏",
    ru = "Скрыть при полном Здоровье",
  },
  health_hide_at_full_description = {
    en = "Hides the display when health is at 100%.",
    ["zh-cn"] = "生命值为 100% 时不显示。",
    ru = "Индикатор скрывается при полном Здоровье.",
  },

  options_toughness = {
    en = "Toughness Settings",
    ["zh-cn"] = "韧性设置",
    ru = "Настройки Стойкости",
  },
  hide_toughness_text = {
    en = "Hide Toughness Text",
    ["zh-cn"] = "隐藏韧性文本",
    ru = "Скрыть текст Стойкости",
  },
  toughness_always_show = {
    en = "Always Show Toughness",
    ["zh-cn"] = "总是显示韧性",
    ru = "Всегда показывать Стойкость",
  },
  toughness_always_show_description = {
    en = "Always display current toughness, regardless of other toughness visibility settings.",
    ["zh-cn"] = "总是显示当前韧性，无视其他韧性显示设置。",
    ru = "Всегда показывать текущую Стойкость, независимо от других настроек видимости Стойкость.",
  },
  toughness_stay_time = {
    en = "Toughness Stay Time",
    ["zh-cn"] = "韧性保持时间",
    ru = "Время задержки Стойкости",
  },
  toughness_stay_time_description = {
    en = "Amount of time, in seconds, that current toughness is displayed when receiving toughness damage.\nSet to 0 to disable.",
    ["zh-cn"] = "受到韧性伤害时，显示韧性的秒数。\n设置为 0 禁用。",
    ru = "Количество времени в секундах, в течение которого отображается текущая Стойкость при получении урона Стойкости.\nУстановите значение на 0, чтобы отключить.",
  },
  toughness_hide_at_full = {
    en = "Hide at Full Toughness",
    ["zh-cn"] = "满韧性时隐藏",
    ru = "Скрыть при полной Стойкости",
  },
  toughness_hide_at_full_description = {
    en = "Hides the display when toughness is at 100%.",
    ["zh-cn"] = "韧性为 100% 时不显示。",
    ru = "Индикатор скрывается при полной Стойкости.",
  },

  options_coherency = {
    en = "Coherency Settings",
    ["zh-cn"] = "连携设置",
    ru = "Настройки Сплочённости",
  },
  coherency_type = {
    en = "Coherency Indicator",
    ["zh-cn"] = "连携指示器",
    ru = "Индикатор Сплочённости",
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
    ru = "Устанавливает тип индикатора для каждого члена команды в Сплочённости:"
        .. "\n{#color(255,180,0)}Простой{#reset()}: Символ плюса (+)"
        .. "\n{#color(255,180,0)}Подкласс{#reset()}: Символ подкласса"
        .. "\n{#color(255,180,0)}Аура{#reset()}: Значок, представляющий предоставленный бафф"
        .. "\n{#color(255,180,0)}Выключено{#reset()}: Сплочённость не отображается",
  },
  coherency_type_simple = {
    en = "Simple",
    ["zh-cn"] = "简单",
    ru = "Простой",
  },
  coherency_type_simple_description = {
    en = "Plus (+) symbol",
    ["zh-cn"] = "显示为加号（+）",
    ru = "Символ плюса (+)",
  },
  coherency_type_archetype = {
    en = "Archetype",
    ["zh-cn"] = "职业",
    ru = "Подкласс",
  },
  coherency_type_archetype_description = {
    en = "Archetype (subclass) symbol",
    ["zh-cn"] = "显示为职业符号",
    ru = "Символ подкласса",
  },
  coherency_type_aura = {
    en = "Aura",
    ["zh-cn"] = "光环",
    ru = "Аура",
  },
  coherency_type_aura_description = {
    en = "Icon representing the buff provided",
    ["zh-cn"] = "显示为连携提供的增益效果图标",
    ru = "Значок, представляющий предоставленный бафф",
  },
  coherency_type_off = {
    en = "Off",
    ["zh-cn"] = "关闭",
    ru = "Выключено",
  },
  coherency_type_off_description = {
    en = "No coherency display",
    ["zh-cn"] = "不显示连携",
    ru = "Сплочённость не отображается",
  },
  hide_coherency_buff_bar = {
    en = "Hide Buff Icon",
    ["zh-cn"] = "隐藏状态图标",
    ru = "Скрыть значок баффа",
  },
  hide_coherency_buff_bar_description = {
    en = "Hides the coherency buff icon in the buff bar."
        .. "\n{#color(255,180,0)}Requires reload (CTRL+SHIFT+R) or game restart{#reset()}",
    ["zh-cn"] = "在状态效果栏隐藏连携图标。"
        .. "\n{#color(255,180,0)}需要重新加载（Ctrl+Shift+R）或重启游戏{#reset()}",
    ru = "Скрывает значок баффа Сплочённости в панели баффов."
        .. "\n{#color(255,180,0)}Требуется перезагрузка интерфейса (CTRL+SHIFT+R) или игры.{#reset()}",
  },
  coherency_colors = {
    en = "Indicator Colors",
    ["zh-cn"] = "连携颜色",
    ru = "Цвета индикатора",
  },
  coherency_colors_teammate = {
    en = "Teammate Color",
    ["zh-cn"] = "队友颜色",
    ru = "Цвет союзника",
  },
  coherency_colors_health = {
    en = "Teammate Health",
    ["zh-cn"] = "队友生命值",
    ru = "Здоровье союзника",
  },
  coherency_colors_toughness = {
    en = "Teammate Toughness",
    ["zh-cn"] = "队友韧性",
    ru = "Стойкость союзника",
  },
  coherency_colors_static = {
    en = "Static Color",
    ["zh-cn"] = "静态颜色",
    ru = "Статический цвет",
  },

  options_ability_cooldown = {
    en = "Ability Settings",
    ["zh-cn"] = "技能设置",
    ru = "Настройки Способности",
  },
  display_ability_cooldown = {
    en = "Display Ability Indicator",
    ["zh-cn"] = "显示技能指示器",
    ru = "Показывать индикатор Способности",
  },
  ability_cooldown_threshold = {
    en = "Cooldown Timer Threshold",
    ["zh-cn"] = "冷却时间阈值",
    ru = "Порог таймера перезарядки",
  },
  ability_cooldown_threshold_description = {
    en = "Amount of time remaining, in seconds, on ability cooldown before the timer will display."
        .. "\nSet to 0 to disable.",
    ["zh-cn"] = "技能冷却时间达到此秒数，才显示计时器。\n设置为 0 禁用。",
    ru = "Оставшееся время восстановления способности в секундах, прежде чем отобразится таймер."
        .. "\nУстановите значение на 0, чтобы отключить.",
  },

  options_ammo = {
    en = "Ammo Settings",
    ["zh-cn"] = "弹药设置",
    ru = "Настройки Боеприпасов",
  },
  display_ammo_indicator = {
    en = "Display Ammo Indicator",
    ["zh-cn"] = "显示弹药指示器",
    ru = "Показывать индикатор Боеприпасов",
  },
  show_ammo_icon = {
    en = "Show Icon",
    ["zh-cn"] = "显示图标",
    ru = "Показывать значок",
  },

  options_pocketable = {
    en = "Pocketable Settings",
    ["zh-cn"] = "携带品设置",
    ru = "Настройки подбираемых предметов",
  },
  display_pocketable_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
    ru = "Показывать индикатор",
  },

  options_stimm = {
    en = "Stimm Settings",
    ["zh-cn"] = "兴奋剂设置",
    ru = "Настройки Стимов",
  },
  display_stimm_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
    ru = "Показывать индикатор",
  },

  options_peril = {
    en = "Peril / Overheat Settings",
    ["zh-cn"] = "危机 / 热量设置",
    ru = "Настройки Угрозы/перегрева",
  },
  display_peril_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
    ru = "Показывать индикатор",
  },

  options_grenade = {
    en = "Grenade Settings",
    ["zh-cn"] = "手雷设置",
    ru = "Настройки гранат",
  },
  display_grenade_indicator = {
    en = "Display Indicator",
    ["zh-cn"] = "显示指示器",
    ru = "Показывать индикатор",
  },

  options_reload = {
    en = "Reload Settings",
    ["zh-cn"] = "装弹设置",
    ru = "Настройки перезарядки",
  },
  display_reload_indicator = {
    en = "Display Reload Indicator",
    ["zh-cn"] = "显示装弹指示器",
    ru = "Показывать индикатор перезарядки",
  },
  only_during_reload = {
    en = "Only During Reload",
    ["zh-cn"] = "仅在装弹时显示",
    ru = "Только во время перезарядки",
  },
  only_during_reload_description = {
    en = "Only show the indicator while actively reloading."
        .. "\nDisabling this can help when customizing position.",
    ["zh-cn"] = "仅在装弹状态下显示。\n自定义位置时可以禁用此选项。",
    ru = "Показывать индикатор только во время процесса перезарядки."
        .. "\nОтключение этого параметра может помочь при настройке положения.",
  },

  custom_threshold_bonus = {
    en = "Bonus Threshold Color",
    ["zh-cn"] = "超量阈值颜色",
    ru = "Цвет бонусного порогового значения",
  },
  custom_threshold_full = {
    en = "Full Threshold Color",
    ["zh-cn"] = "满阈值颜色",
    ru = "Цвет полного порогового значения",
  },
  custom_threshold_high = {
    en = "High Threshold Color",
    ["zh-cn"] = "高阈值颜色",
    ru = "Цвет высокого порогового значения",
  },
  custom_threshold_low = {
    en = "Low Threshold Color",
    ["zh-cn"] = "低阈值颜色",
    ru = "Цвет низкого порогового значения",
  },
  custom_threshold_critical = {
    en = "Critical Threshold Color",
    ["zh-cn"] = "空阈值颜色",
    ru = "Цвет критического порогового значения",
  },

  red = {
    en = "Red",
    ["zh-cn"] = "红色",
    ru = "Красный",
  },
  green = {
    en = "Green",
    ["zh-cn"] = "绿色",
    ru = "Зелёный",
  },
  blue = {
    en = "Blue",
    ["zh-cn"] = "蓝色",
    ru = "Синий",
  },

  options_ally = {
    en = "Ally Settings",
    ["zh-cn"] = "队友设置",
    ru = "Настройки союзника",
  },
  options_ally_1 = {
    en = "Ally 1",
    ["zh-cn"] = "队友 1",
    ru = "Союзник 1",
  },
  options_ally_2 = {
    en = "Ally 2",
    ["zh-cn"] = "队友 2",
    ru = "Союзник 2",
  },
  options_ally_3 = {
    en = "Ally 3",
    ["zh-cn"] = "队友 3",
    ru = "Союзник 3",
  },
  display_ally_indicator = {
    en = "Display Ally Indicators",
    ["zh-cn"] = "显示队友指示器",
    ru = "Показывать индикаторы союзников",
  },
  ally_health_display_type = {
    en = "Health Display Type",
    ["zh-cn"] = "生命值显示类型",
    ru = "Тип отображения Здоровья",
  },
  ally_toughness_display_type = {
    en = "Toughness Display Type",
    ["zh-cn"] = "韧性显示类型",
    ru = "Тип отображения Стойкости",
  },

  options_global = {
    en = "Miscellaneous",
    ["zh-cn"] = "杂项",
    ru = "Разное",
  },
  enable_shadows = {
    en = "Enable Shadows",
    ["zh-cn"] = "启用阴影",
    ru = "Включение теней",
  },
  enable_shadows_description = {
    en = "Toggles text and icon shadows.",
    ["zh-cn"] = "开关文本和图标的阴影。",
    ru = "Переключает отображение теней текста и значков",
  },
  on = {
    en = "On",
    ["zh-cn"] = "开",
    ru = "Включены",
  },
  off = {
    en = "Off",
    ["zh-cn"] = "关",
    ru = "Выключены",
  },
  global = {
    en = "Global",
    ["zh-cn"] = "全局",
    ru = "Глобально",
  },

  scale = {
    en = "Scale",
    ["zh-cn"] = "缩放",
    ru = "Размер",
  },

  display_gauge = {
    en = "Display Gauge",
    ["zh-cn"] = "显示计量条",
    ru = "Показывать датчик",
  },
  mirror = {
    en = "Mirrored",
    ["zh-cn"] = "镜像",
    ru = "Отзеркалено",
  },
  display_wounds_count = {
    en = "Display Wounds Remaining",
    ["zh-cn"] = "显示剩余生命格",
    ru = "Показывать оставшиеся Раны",
  },
  color = {
    en = "Color",
    ["zh-cn"] = "颜色",
    ru = "Цвет",
  },
  display_permanent_health_text = {
    en = "Display Permanent Health Text",
    ["zh-cn"] = "显示生命值上限文本",
    ru = "Показывать текст постоянного Здоровья",
  },
  customize_permanent_health_color = {
    en = "Customize Permanent Health Color",
    ["zh-cn"] = "自定义生命值上限颜色",
    ru = "Настроить цвет постоянного Здоровья",
  },
  permanent_health_color = {
    en = "Permanent Health Color",
    ["zh-cn"] = "生命值上限颜色",
    ru = "Цвет постоянного Здоровья",
  },
  display_peril_icon = {
    en = "Display Peril Icon",
    ["zh-cn"] = "显示危机值图标",
    ru = "Показывать значок Угрозы",
  },
  display_grenade_icon = {
    en = "Display Grenade Icon",
    ["zh-cn"] = "显示手雷图标",
    ru = "Показывать значок гранаты",
  },
  options_archetype_psyker = {
    en = "Psyker Indicators",
    ["zh-cn"] = "灵能者",
    ru = "Индикаторы псайкера",
  },
  display_warp_charge_indicator = {
    en = "Display Warp Charge Indicator",
    ["zh-cn"] = "显示亚空间充能指示器",
    ru = "Показывать индикатор Варп-заряда",
  },
  hide_warp_charges_buff = {
    en = "Hide Warp Charge Buff Icon",
    ["zh-cn"] = "隐藏亚空间充能效果图标",
    ru = "Скрыть значок баффа Варп-заряда",
  },
  hide_warp_charges_buff_description = {
    en = "Removes the Warp Charge buff from the buff bar.",
    ["zh-cn"] = "在状态效果栏隐藏亚空间充能效果。",
    ru = "Убирает значок баффа Варп-заряда с панели баффов.",
  },
  display_kinetic_flayer_indicator = {
    en = "Display Kinetic Flayer Cooldown",
    ["zh-cn"] = "显示动能剥皮者冷却",
    ru = "Показывать время восстановления Кинетического истребителя",
  },
  hide_kinetic_flayer_buff = {
    en = "Hide Kinetic Flayer Buff Icon",
    ["zh-cn"] = "隐藏动能剥皮者增益图标",
    ru = "Скрыть значок баффа Кинетического истребителя",
  },
  move_independently = {
    en = "Move Independently",
    ["zh-cn"] = "独立移动",
    ru = "Двигать независимо",
  },
  move_independently_description = {
    en = "Move gauge and text independently from one another.",
    ["zh-cn"] = "彼此独立地移动指示器和文本。",
    ru = "Двигать датчик и текст независимо друг от друга",
  },
  scale_independently = {
    en = "Scale Independently",
    ["zh-cn"] = "独立缩放",
    ru = "Изменять размер независимо",
  },
  scale_independently_description = {
    en = "Scale gauge and text independently from one another.",
    ["zh-cn"] = "彼此独立地缩放指示器和文本。",
    ru = "Изменять размер датчика и текста независимо друг от друга",
  }
}

local color_names = Color.list
for i, color_name in ipairs(color_names) do
  local color_values = Color[color_name](255, true)
  local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
  localizations[color_name] = {
    en = text
  }
end

return localizations
