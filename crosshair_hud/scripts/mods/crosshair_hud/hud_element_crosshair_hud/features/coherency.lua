local mod = get_mod("crosshair_hud")

local global_scale = mod:get("global_scale")
local coherency_scale = mod:get("coherency_scale") * global_scale

local global_offset = {
  mod:get("global_x_offset"),
  mod:get("global_y_offset")
}
local coherency_offset = {
  mod:get("coherency_x_offset"),
  mod:get("coherency_y_offset")
}

local feature_name = "coherency_indicator"
local feature = {
  name = feature_name
}

feature.scenegraph_definition = {
  [feature_name] = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = { 48 * coherency_scale, 32 * coherency_scale },
    position = {
      global_offset[1] + coherency_offset[1],
      global_offset[2] + coherency_offset[2],
      55
    }
  }
}

local template_base_path = "crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/features/templates/coherency/%s"
function feature.create_widget_definitions()

  local coherency_type = mod:get("coherency_type")
  if coherency_type == mod.options_coherency_type.off then
    return
  end

  local template_path = string.format(template_base_path, coherency_type)
  local template = mod:io_dofile(template_path)

  local feature_scenegraph_definition = feature.scenegraph_definition[feature_name]
  local scenegraph_overrides = template.scenegraph_overrides
  if scenegraph_overrides then
    table.merge_recursive(feature_scenegraph_definition, scenegraph_overrides)
  end

  feature.template = template

  return template.create_widget_definitions(feature_name)
end

function feature.update(parent, dt, t)
  local feature_template = feature.template
  feature_template.update(parent, dt, t)
end

return feature
