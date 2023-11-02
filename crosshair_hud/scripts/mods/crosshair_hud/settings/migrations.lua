local mod = get_mod("crosshair_hud")
local mod_settings = Application.user_setting("mods_settings").crosshair_hud or {}

local migrations = {
  {
    name = "invalid_coherency_type",
    migration_func = function(data)
      local coherency_type = mod:get("coherency_type")
      if coherency_type and not mod.options_coherency_type[coherency_type] then
        mod:notify("Invalid Coherency Type [%s]; select a new one in the mod options menu.", coherency_type)
        mod:set("coherency_type", "off")
      end
      
      return true
    end
  },
  {
    name = "rename_threshold_empty_to_critical",
    migration_func = function(data)
      for setting_id, setting_value in pairs(mod_settings) do
        if string.find(setting_id, "empty") then
          local new_setting_id = string.gsub(setting_id, "empty", "critical")

          if mod:get(new_setting_id) == nil then
            mod:set(new_setting_id, setting_value)
          end

          mod:set(setting_id, nil)
        end
      end
      
      return true
    end
  },
  {
    name = "find_closest_colors",
    migration_func = function(data)
      local color_settings = {}
      for setting_id, setting_value in pairs(mod_settings) do
        if string.ends_with(setting_id, "_red") then
          local base_setting = string.sub(setting_id, 1, -5)
          color_settings[base_setting] = color_settings[base_setting] or {}
          color_settings[base_setting].red = setting_value
          mod:set(setting_id, nil)
        elseif string.ends_with(setting_id, "_green") then
          local base_setting = string.sub(setting_id, 1, -7)
          color_settings[base_setting] = color_settings[base_setting] or {}
          color_settings[base_setting].green = setting_value
          mod:set(setting_id, nil)
        elseif string.ends_with(setting_id, "_blue") then
          local base_setting = string.sub(setting_id, 1, -6)
          color_settings[base_setting] = color_settings[base_setting] or {}
          color_settings[base_setting].blue = setting_value
          mod:set(setting_id, nil)
        end
      end

      for color_id, color_setting in pairs(color_settings) do
        local lowest_deviation = math.huge
        local closest_color_name
        local color = { color_setting.red, color_setting.green, color_setting.blue }
        for i, color_name in ipairs(Color.list) do
          local color_values = Color[color_name](255, true)
          local dR = (color[1] - color_values[2]) * 0.30
          local dG = (color[2] - color_values[3]) * 0.59
          local dB = (color[3] - color_values[4]) * 0.11
          local deviation = ((dR * dR) + (dG * dG) + (dB * dB))
          if deviation < lowest_deviation then
            lowest_deviation = deviation
            closest_color_name = color_name
          end
        end

        if closest_color_name then
          mod:set(string.format("%s_color", color_id), closest_color_name)
        end
      end
      
      return true
    end
  }
}

for i, migration_data in ipairs(migrations) do
  migration_data.id = i
end

local function _run_migrations()
  local migrations_n = #migrations
  for i = 1, migrations_n do
    local migration_data = migrations[i]
    if not migration_data.is_migrated then
      
      local success, result = mod:pcall(function()
        return migration_data:migration_func()
      end)
      
      local is_migrated = success and result
      migration_data.is_migrated = is_migrated

      if not success then
        mod:error("migration [%s] failed: %s", migration_data.name, result)
      end
    end

  end
end

return {
  data = migrations,
  run = _run_migrations
}
