local mod = get_mod("crosshair_hud")

local templates = {}

local function _create_template_entry(file_path)
  local template = mod:io_dofile(file_path)
  local template_name = template.name

  if not template_name then
    local message = "Template definition in file [\"%s\"] missing `name` property!"
    mod:error(message, file_path)
    mod:notify(message, file_path)

    return
  end

  if templates[template_name] then
    local message = "Template with name [%s] has already been defined."
    mod:error(message, template_name)
    mod:notify(message, template_name)

    return
  end

  templates[template_name] = template
end

_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/pocketable")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/ability")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/peril")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/reload")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/grenade")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/ammo")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/health")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/toughness")
_create_template_entry("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/coherency")

return templates