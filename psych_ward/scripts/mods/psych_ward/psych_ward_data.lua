local mod = get_mod("psych_ward")

return {
  name = mod:localize("psych_ward"),
  description = mod:localize("psych_ward_description"),
  is_toggleable = false,
  options = {
    widgets = {
      {
        setting_id = "allow_chat_main_menu",
        type = "checkbox",
        default_value = true,
      },
    }
  }
}