local mod = get_mod("psych_ward")

local _button_offset_settings = {
  x = {
    range = { -1770, 0 }
  },
  y = {
    range = { -1050, 0 }
  }
}
local function _create_button_offset_setting(setting_id, axis, default_offset)
  local offset_setting_id = string.format("%s_%s_offset", setting_id, axis)
  local axis_offset_range = table.clone(_button_offset_settings[axis].range)

  return {
    setting_id = offset_setting_id,
    title = string.format("%s_offset", axis),
    type = "numeric",
    range = axis_offset_range,
    default_value = default_offset and default_offset[axis] or 0,
    decimals_number = 0,
    step_size_value = 1,
  }
end

local _button_size_settings = {
  width = {
    range = { 150, 250 }
  },
  height = {
    range = { 30, 70 }
  }
}
local function _create_button_size_setting(setting_id, property, default_size)
  local size_setting_id = string.format("%s_%s", setting_id, property)
  local property_size_range = table.clone(_button_size_settings[property].range)
  local default_value = default_size and default_size[property] or ((property_size_range[1] + property_size_range[2]) / 2)

  return {
    setting_id = size_setting_id,
    title = property,
    type = "numeric",
    range = property_size_range,
    default_value = default_value,
    decimals_number = 0,
    step_size_value = 1,
  }
end

local _button_registry = {
  horde = {
    offset = { x = -750, y = -75 },
  },
  mission = {
    offset = { x = -250, y = -75 },
  },
  vendor = {
    offset = { x = -5, y = -275 },
    size = { height = 40 },
  },
  contracts = {
    offset = { x = -1020, y = -1010 },
  },
  crafting = {
    offset = { x = -5, y = -325 },
    size = { height = 40 },
  },
  inventory = {
    offset = { x = -5, y = -380 },
    size = { height = 40 },
  },
  cosmetics = {
    offset = { x = -1270, y = -1010 },
  },
  penance = {
    offset = { x = -1520, y = -1010 },
  },
  expedition = {
    offset = { x = -500, y = -75 },
  },
  meatgrinder = {
    offset = { x = -1000, y = -75 },
  },
}
local function _create_button_settings()

  local button_widgets = {}
  for button_name, button_defaults in pairs(_button_registry) do
    local button_setting_id = string.format("%s_button", button_name)
    local default_offset = button_defaults.offset and table.clone(button_defaults.offset)
    local default_size = button_defaults.size

    table.insert(button_widgets, {
      setting_id = button_setting_id,
      type = "group",
      sub_widgets = {
        _create_button_offset_setting(button_setting_id, "x", default_offset),
        _create_button_offset_setting(button_setting_id, "y", default_offset),
        _create_button_size_setting(button_setting_id, "height", default_size),
        _create_button_size_setting(button_setting_id, "width", default_size),
      }
    })
  end

  return button_widgets
end

return {
  name = mod:localize("psych_ward"),
  description = mod:localize("psych_ward_description"),
  is_toggleable = false,
  options = {
    widgets = {
      {
        setting_id = "allow_chat_main_menu",
        type = "checkbox",
        default_value = false,
      },
      {
        setting_id = "button_placement",
        type = "group",
        default_value = false,
        sub_widgets = _create_button_settings()
      }
    }
  }
}