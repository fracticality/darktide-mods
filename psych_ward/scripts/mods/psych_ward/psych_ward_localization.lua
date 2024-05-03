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
    ["zh-cn"] = "快速灵能室",
    ru = "Психушка",
  },
  psych_ward_description = {
    en = "Enables logging in straight to the Psykhanium, bypassing the Hub.",
    ["zh-cn"] = "启用直接进入灵能室功能，无需进入大厅。",
    ru = "Psych Ward - Позволяет войти прямо на стрельбище в Псайканиум, минуя Хаб.",
    ja = "ハブを介さず、サイカニウムへと直接入場できるようになります。",
  },
  psykhanium_button = {
    en = "Shooting Range",
    ["zh-cn"] = "训练场",
    ru = "Стрельбище",
    ja = "演習場",
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
  },
}
