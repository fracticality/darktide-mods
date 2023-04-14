local mod = get_mod("crosshair_hud")

local validations = {
  {
    validation_name = "invalid_coherency_type",
    validation_func = function(data)
      local coherency_type = mod:get("coherency_type")
      if coherency_type and not mod.options_coherency_type[coherency_type] then
        mod:notify("Invalid Coherency Type [%s]; select a new one in the mod options menu.", coherency_type)
        mod:set("coherency_type", "off")
      end
    end
  }
}

local function _run_validations()
  local validations_n = #validations
  for i = 1, validations_n do
    local validation_data = validations[i]
    if not validation_data.validated then
      validation_data.validation_id = i
      validation_data:validation_func()

      validation_data.validated = true
    end

  end
end

return {
  data = validations,
  run = _run_validations
}
