local mod = get_mod("psych_ward")

mod:add_global_localize_strings({
  loc_toggle_view_buttons = {
    en = "Vendors",
    ["zh-cn"] = "大厅功能",
    ru = "Торговцы",
    ja = "ベンダー",
    ["zh-tw"] = "大廳功能",
    ko = "로비 기능",
  }
})

return {
  psych_ward = {
    en = "Psych Ward",
    ["zh-cn"] = "快捷访问",
    ru = "Психушка",
    ["zh-tw"] = "靈能室",
    ko = "바로가기",
  },
  psych_ward_description = {
    en = "Provides access to many Hub features from the Character Select menu.",
    ["zh-cn"] = "直接在角色选择页面使用各种大厅功能。",
    ru = "Psych Ward - Позволяет войти прямо на стрельбище в Псайканиум, минуя Хаб.",
    ja = "キャラクター選択画面から様々なハブ機能へとアクセスできるようになります。",
    ["zh-tw"] = "啟用直接進入靈能室功能，無需進入大廳。",
    ko = "캐릭터 선택 메뉴에서 로비의 다양한 기능에 접근할 수 있습니다.",
  },
  horde_button = {
    en = "Mortis Trials",
    ["zh-cn"] = "死灵试炼",
    ru = "Стрельбище",
    ja = "モーティスの試練",
    ["zh-tw"] = "死神試煉",
    ko = "몰티스 시련",
  },
  mission_button = {
    en = "Mission Board",
    ja = "ミッションボード",
    ["zh-cn"] = "任务面板",
    ru = "Меню выбора миссий",
    ["zh-tw"] = "任務面板",
    ko = "미션 터미널",
  },
  vendor_button = {
    en = "Armoury",
    ["zh-cn"] = "军械交易所",
    ru = "Оружейная",
    ja = "武器交換",
    ["zh-tw"] = "軍械交易所",
    ko = "무기 교환소",
  },
  로 진입",
  },
  allow_chat_main_menu = {
    en = "Allow Chat in Character Select screen",
    ["zh-cn"] = "允许在角色选择界面使用聊天框",
    ja = "キャラクター選択画面でのチャットを許可",
    ["zh-tw"] = "允許在角色選擇界面使用聊天框",
    ko = "캐릭터 선택 화면에서 채팅 허용",
  },
}
