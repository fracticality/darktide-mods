local mod = get_mod("crosshair_hud")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen
}

local widget_definitions = {}

local features_file = "crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/features/features"

return {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions,
  features_file = features_file
}