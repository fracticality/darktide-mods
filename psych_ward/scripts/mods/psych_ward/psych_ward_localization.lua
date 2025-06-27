local mod = get_mod("psych_ward")

mod:add_global_localize_strings({
  loc_toggle_view_buttons = {
    en = "Vendors",
    ["zh-cn"] = "大厅功能",
    ru = "Торговцы",
    ja = "ベンダー",
  }
})

return {
  psych_ward = {
    en = "Psych Ward",
    ["zh-cn"] = "快捷访问",
    ru = "Психушка",
  },
  psych_ward_description = {
    en = "Provides access to many Hub features from the Character Select menu.",
    ["zh-cn"] = "直接在角色选择页面使用各种大厅功能。",
    ru = "Psych Ward - Позволяет войти прямо на стрельбище в Псайканиум, минуя Хаб.",
    ja = "キャラクター選択画面から様々なハブ機能へとアクセスできるようになります。",
  },
  horde_button = {
    en = "Mortis Trials",
    ["zh-cn"] = "死灵试炼",
    ru = "Стрельбище",
    ja = "モーティスの試練",
  },
  mission_button = {
    en = "Mission Board",
    ja = "ミッションボード",
    ["zh-cn"] = "任务面板",
    ru = "Меню выбора миссий",
  },
  vendor_button= {
    en = "Armoury",
    ["zh-cn"] = "军械交易所",
    ru = "Оружейная",
    ja = "武器交換",
  },
  contracts_button = {
    en = "Contracts",
    ["zh-cn"] = "每周协议",
    ru = "Контракты",
    ja = "週間契約",
  },
  crafting_button = {
    en = "Crafting",
    ["zh-cn"] = "锻造",
    ru = "Кузница",
    ja = "クラフト",
  },
  cosmetics_button = {
    en = "Cosmetics",
    ru = "Интендант",
    ["zh-cn"] = "装饰品",
    ja = "装飾品",
  },
  penance_button = {
    en = "Penances",
    ru = "Искупления",
    ["zh-cn"] = "苦修",
    ja = "苦行",
  },
  inventory_button = {
    en = "Inventory",
    ["zh-cn"] = "库存",
    ru = "Инвентарь",
    ja = "インベントリ",
  },
  havoc_button = {
    en = "Havoc Mission",
    ["zh-cn"] = "浩劫任务",
    ja = "ハヴォック任務",
  },
  meatgrinder_button = {
    en = "Meat Grinder",
    ["zh-cn"] = "绞肉机",
    ja = "肉挽き機"
  },
  exit_text = {
    en = "Press %s to quit",
    ja = "%sで終了",
    ["zh-cn"] = "按下%s以退出",
    ru = "Нажмите %s, чтобы выйти",
  },
  cutscenes_hub_only = {
    en = "Only Viewable from the Hub",
    ["zh-cn"] = "仅可在大厅内查看",
    ru = "Можно посмотреть только в Хабе",
    ja = "ハブでのみ閲覧可能",
  },
  enter_hub = {
    en = "Enter Hub",
    ["zh-cn"] = "进入大厅",
    ja = "ハブに行く",
  },
  allow_chat_main_menu = {
    en = "Allow Chat in Character Select screen",
    ["zh-cn"] = "允许在角色选择界面使用聊天框",
    ja = "キャラクター選択画面でのチャットを許可",
  },
}
