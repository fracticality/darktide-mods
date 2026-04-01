local colours = {
    title = "200,140,20",
    subtitle = "226,199,126",
    text = "169,191,153",
    key = "140,180,220",
}

return {
    custom_hud = {
        en = "Custom HUD",
        ["zh-cn"] = "自定义 HUD",
        ru = "Настраиваемый интерфейс",
    },
    custom_hud_description = {
        en = "{#color(" .. colours.text .. ")}Allows custom placement and resizing of HUD elements. Press {#color(" .. colours.key .. ")}[F3]{#color(" .. colours.text .. ")} to enter edit mode.{#reset()}\n\n"
            .. "{#color(" .. colours.key .. ")}Click{#color(" .. colours.text .. ")} select, {#color(" .. colours.key .. ")}Ctrl+Click{#color(" .. colours.text .. ")} multi-select, {#color(" .. colours.key .. ")}Shift+Drag{#color(" .. colours.text .. ")} move, {#color(" .. colours.key .. ")}Scroll{#color(" .. colours.text .. ")} scale, {#color(" .. colours.key .. ")}Alt+Drag{#color(" .. colours.text .. ")} resize\n"
            .. "{#color(" .. colours.key .. ")}Arrows{#color(" .. colours.text .. ")} move ±1px, {#color(" .. colours.key .. ")}Alt+Arrows{#color(" .. colours.text .. ")} resize ±1px, {#color(" .. colours.key .. ")}Shift+Up/Down{#color(" .. colours.text .. ")} z-order\n"
            .. "{#color(" .. colours.key .. ")}Right-click{#color(" .. colours.text .. ")} hide, {#color(" .. colours.key .. ")}Double-click{#color(" .. colours.text .. ")} reset, {#color(" .. colours.key .. ")}Tab{#color(" .. colours.text .. ")} reset selected, {#color(" .. colours.key .. ")}Ctrl+Shift+C{#color(" .. colours.text .. ")} center{#reset()}",
        ["zh-cn"] = "允许自定义排列和调整 HUD 元素大小。",
        ru = "Позволяет перемещать и изменять размер элементов интерфейса.",
    },
    settings_header = {
        en = "{#color(" .. colours.title .. ")}Settings{#reset()}",
        ["zh-cn"] = "设置",
        ru = "Настройки",
    },
    toggle_hud_customization_key = {
        en = "Toggle HUD Customization",
        ["zh-cn"] = "开关 HUD 自定义",
        ru = "Переключение настройки интерфейса",
    },
    toggle_hud_customization_key_description = {
        en = "{#color(" .. colours.text .. ")}Toggles HUD customization on/off.{#reset()}\n\n"
            .. "{#color(" .. colours.title .. ")}Controls (in edit mode):{#reset()}\n"
            .. "{#color(" .. colours.key .. ")}  Click{#color(" .. colours.text .. ")} = Select element\n"
            .. "{#color(" .. colours.key .. ")}  Ctrl+Click{#color(" .. colours.text .. ")} = Multi-select\n"
            .. "{#color(" .. colours.key .. ")}  Shift+Drag{#color(" .. colours.text .. ")} = Move element\n"
            .. "{#color(" .. colours.key .. ")}  Scroll{#color(" .. colours.text .. ")} = Scale element\n"
            .. "{#color(" .. colours.key .. ")}  Alt+Drag edge/corner{#color(" .. colours.text .. ")} = Resize\n"
            .. "{#color(" .. colours.key .. ")}  Alt+Arrows{#color(" .. colours.text .. ")} = Resize ±1px\n"
            .. "{#color(" .. colours.key .. ")}  Arrows{#color(" .. colours.text .. ")} = Move ±1px\n"
            .. "{#color(" .. colours.key .. ")}  Shift+Up/Down{#color(" .. colours.text .. ")} = Z-order\n"
            .. "{#color(" .. colours.key .. ")}  Right-click{#color(" .. colours.text .. ")} = Toggle hidden\n"
            .. "{#color(" .. colours.key .. ")}  Double-click{#color(" .. colours.text .. ")} = Reset to default\n"
            .. "{#color(" .. colours.key .. ")}  Tab{#color(" .. colours.text .. ")} = Reset selected\n"
            .. "{#color(" .. colours.key .. ")}  Ctrl+Shift+C{#color(" .. colours.text .. ")} = Center on screen{#reset()}",
        ["zh-cn"] = "切换 HUD 自定义功能的开关。",
        ru = "Включение/отключение оверлея настройки интерфейса.",
    },
    toggle_hud_hidden_key = {
        en = "Toggle HUD",
        ["zh-cn"] = "开关 HUD",
        ru = "Переключение интерфейса",
    },
    toggle_hud_hidden_key_description = {
        en = "Toggles the HUD on/off.",
        ["zh-cn"] = "切换 HUD 的开关。",
        ru = "Включение/отключение игрового интерфейса.",
    },
    show_info_panel = {
        en = "Show Info Panel",
        ["zh-cn"] = "显示信息面板",
        ru = "Показать информационную панель",
    },
    show_info_panel_description = {
        en = "Show the floating info panel in edit mode. You can also toggle it with the /panel command.",
        ["zh-cn"] = "在编辑模式下显示所有 HUD 元素的位置、大小和状态面板。",
        ru = "Показывает панель со списком всех элементов интерфейса в режиме редактирования.",
    },
    panel_font = {
        en = "Panel Font",
        ["zh-cn"] = "面板字体",
        ru = "Шрифт панели",
    },
    panel_font_description = {
        en = "Choose the font used in the info panel overlay.",
        ["zh-cn"] = "选择信息面板中使用的字体。",
        ru = "Выберите шрифт для информационной панели.",
    },
    font_proxima_nova_bold = {
        en = "Proxima Nova Bold",
    },
    font_proxima_nova_light = {
        en = "Proxima Nova Light",
    },
    font_proxima_nova_medium = {
        en = "Proxima Nova Medium",
    },
    font_machine_medium = {
        en = "Machine Medium",
    },
    font_itc_novarese = {
        en = "ITC Novarese",
    },
    font_friz_quadrata = {
        en = "Friz Quadrata",
    },
    font_rexlia = {
        en = "Rexlia",
    },
    panel_font_size = {
        en = "Panel Font Size",
        ["zh-cn"] = "面板字体大小",
        ru = "Размер шрифта панели",
    },
    panel_font_size_description = {
        en = "Adjust the font size used in the info panel. Detail text is 3pt smaller.",
        ["zh-cn"] = "调整信息面板中使用的字体大小。",
        ru = "Настройте размер шрифта информационной панели.",
    },
    panel_scale = {
        en = "Panel Scale",
    },
    panel_scale_description = {
        en = "Scale the floating info panel, including row spacing and detail area sizing.",
    },
    panel_list_rows = {
        en = "Panel List Rows",
    },
    panel_list_rows_description = {
        en = "Limit how many list entries are shown before the panel starts scrolling.",
    },
    reset_hud = {
        en = "Reset HUD",
        ["zh-cn"] = "重置 HUD",
        ru = "Сброс интерфейса",
    },
    reset_hud_description = {
        en = "Restore the HUD to Fatshark defaults.",
        ["zh-cn"] = "恢复 HUD 为肥鲨默认值。",
        ru = "Вернуть интерфейс к стандартным настройкам Fatshark.",
    },
    opacity = {
        en = "Opacity Multiplier",
        ["zh-cn"] = "不透明度倍数",
        ru = "Множитель прозрачности",
    },
    opacity_description = {
        en = "Adjust the overall HUD opacity multiplier.",
        ["zh-cn"] = "调整元素不透明度。",
        ru = "Настройте прозрачность элементов.",
    },
    display_grid = {
        en = "Display Grid",
        ["zh-cn"] = "显示网格",
        ru = "Показать сетку",
    },
    display_grid_description = {
        en = "Toggles display of a customizable grid to aid in repositioning elements.",
        ["zh-cn"] = "开关用于辅助元素定位的可自定义网格。",
        ru = "Переключение отображения настроечной сетки для облегчения изменения положения элементов.",
    },
    snap_to_grid = {
        en = "Snap to Grid",
        ["zh-cn"] = "吸附到网格",
        ru = "Привязка к сетке",
    },
    snap_to_grid_description = {
        en = "Toggles snapping of elements to visible grid lines.",
        ["zh-cn"] = "开关是否将元素吸附到网格线上。",
        ru = "Переключение привязки элементов к видимым линиям сетки.",
    },
    grid_cols = {
        en = "Columns",
        ["zh-cn"] = "列",
        ru = "Столбцы",
    },
    grid_rows = {
        en = "Rows",
        ["zh-cn"] = "行",
        ru = "Ряды",
    }
}
