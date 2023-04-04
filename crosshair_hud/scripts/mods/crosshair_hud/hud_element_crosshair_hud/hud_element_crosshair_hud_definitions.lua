local mod = get_mod("crosshair_hud")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen
}

local widget_definitions = {}

local templates = mod:io_dofile("crosshair_hud/scripts/mods/crosshair_hud/hud_element_crosshair_hud/templates/templates")

return {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions,
  templates = templates
}