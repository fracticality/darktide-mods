local mod = get_mod("psych_ward")

mod:add_global_localize_strings({
  loc_toggle_view_buttons = {
    en = "Vendors",
    ["zh-cn"] = "大厅功能",
    ru = "Торговцы",
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
    ru = "Позволяет войти прямо на стрельбище в Псайканиум, минуя Хаб.",
  },
  enter_psykhanium = {
    en = "Shooting Range",
    ["zh-cn"] = "训练场",
    ru = "Стрельбище",
  },
  vendor_button= {
    en = "Armoury",
    ["zh-cn"] = "军械交易所",
    ru = "Оружейная",
  },
  contracts_button = {
    en = "Contracts",
    ["zh-cn"] = "每周协议",
    ru = "Контракты",
  },
  crafting_button = {
    en = "Crafting",
    ["zh-cn"] = "锻造",
    ru = "Кузница",
  },
  inventory_button = {
    en = "Inventory",
    ["zh-cn"] = "库存",
    ru = "Инвентарь",
  },
}
