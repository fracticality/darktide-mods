local mod = get_mod("crosshair_hud")

local _definitions = mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/hud_element_crosshair_hud_definitions")

local HudElementCrosshairHud = class("HudElementCrosshairHud", "HudElementBase")

function HudElementCrosshairHud:init(parent, draw_layer, start_scale)
  self._start_scale = start_scale
  self:init_features()

  HudElementCrosshairHud.super.init(self, parent, draw_layer, start_scale, _definitions)
end

function HudElementCrosshairHud:init_features()
  local features_file = _definitions.features_file
  local scenegraph_definition = _definitions.scenegraph_definition
  local widget_definitions = _definitions.widget_definitions
  local features = mod:io_dofile(features_file)
  local features_by_name = {}

  for feature_name, feature in pairs(features) do
    local definitions = feature.create_widget_definitions()

    if definitions then
      table.merge_recursive(scenegraph_definition, feature.scenegraph_definition)

      for widget_name, widget_definition in pairs(definitions) do
        widget_definitions[widget_name] = widget_definition
      end

      features_by_name[feature_name] = feature
    end
  end
  self._features_by_name = features_by_name
end

function HudElementCrosshairHud:update(dt, t, ui_renderer, render_settings, input_service)
  if self.needs_refresh then
    self.needs_refresh = nil
    self:init(self._parent, self._draw_layer, self._start_scale)

    return
  end

  HudElementCrosshairHud.super.update(self, dt, t, ui_renderer, render_settings, input_service)

  for feature_name, feature in pairs(self._features_by_name) do
    feature.update(self, dt, t)
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
