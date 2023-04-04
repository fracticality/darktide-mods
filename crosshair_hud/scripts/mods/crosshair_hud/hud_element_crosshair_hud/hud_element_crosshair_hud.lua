local mod = get_mod("crosshair_hud")

local _definitions = mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/hud_element_crosshair_hud_definitions")

local HudElementCrosshairHud = class("HudElementCrosshairHud", "HudElementBase")

function HudElementCrosshairHud:init(parent, draw_layer, start_scale)
  self._talents_by_unit = {}

  local templates = _definitions.templates
  local scenegraph_definition = _definitions.scenegraph_definition
  local widget_definitions = _definitions.widget_definitions
  local templates_by_name = {}

  for template_name, template in pairs(templates) do
    table.merge_recursive(scenegraph_definition, template.scenegraph_definition)

    templates_by_name[template_name] = template
    local definitions = template.create_widget_definitions()
    for widget_name, widget_definition in pairs(definitions) do
      widget_definitions[widget_name] = widget_definition
    end
  end
  self._templates_by_name = templates_by_name

  HudElementCrosshairHud.super.init(self, parent, draw_layer, start_scale, _definitions)
end

function HudElementCrosshairHud:update(dt, t, ui_renderer, render_settings, input_service)
  HudElementCrosshairHud.super.update(self, dt, t, ui_renderer, render_settings, input_service)

  for template_name, template in pairs(self._templates_by_name) do
    template.update(self, dt, t)
  end

end

local function _is_in_hub()
  local game_mode_name = Managers.state.game_mode:game_mode_name()
  return (game_mode_name == "hub" or game_mode_name == "prologue_hub")
end

function HudElementCrosshairHud:draw(dt, t, ui_renderer, render_settings, input_service)
  if _is_in_hub() then
    return
  end

  HudElementCrosshairHud.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return HudElementCrosshairHud
