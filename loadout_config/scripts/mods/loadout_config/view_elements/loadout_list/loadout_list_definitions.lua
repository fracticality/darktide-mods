local mod = get_mod("loadout_config")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  pivot = {
    parent = "screen",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 0, 0 },
    position = { 0, 0, 0 }
  },
  header = {
    parent = "pivot",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 150, 26 },
    position = { 0, 0, 0 }
  },
  create_button = {
    parent = "header",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 150, 20 },
    position = { 155, 2.5, 0 }
  },
  delete_button = {
    parent = "create_button",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 150, 20 },
    position = { 155, 0, 0 }
  },
  reset_button = {
    parent = "delete_button",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 150, 20 },
    position = { 155, 0, 0 }
  },
  background = {
    parent = "header",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 800, 140 },
    position = { 0, 25, 0 }
  },
  button_root = {
    parent = "background",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 150, 25 },
    position = { 5, 5, 1 }
  }
}

local widget_blueprints = {
  loadout_button = function(content_overrides)
    return UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "button_root", content_overrides)
  end
}

local widget_definitions = {
  header = UIWidget.create_definition({
    {
      pass_type = "rect",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = Color.terminal_background(255, true),
        offset = { 0, 0, 0 }
      }
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/frames/frame_tile_2px",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = Color.terminal_frame(255, true),
        offset = { 0, 0, 2 }
      }
    },
    {
      pass_type = "text",
      value = mod:localize("loadouts_header"),
      style = {
        font_type = "machine_medium",
        font_size = 18,
        text_vertical_alignment = "center",
        text_horizontal_alignment = "center",
        text_color = Color.terminal_text_body(255, true),
        offset = { 0, 0, 1 }
      }
    }
  }, "header"),
  background = UIWidget.create_definition({
    {
      pass_type = "rect",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = Color.terminal_background(255, true),
        offset = { 0, 0, 0 }
      }
    },
    {
      pass_type = "texture",
      value = "content/ui/materials/frames/frame_tile_2px",
      style = {
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = Color.terminal_frame(255, true),
        offset = { 0, 0, 2 }
      }
    }
  }, "background"),
  create_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "create_button", {
    text = "Create",
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  }),
  reset_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "reset_button", {
    text = "Reset",
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  }),
  delete_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "delete_button", {
    text = "Delete",
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  }),
}

local definitions = {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions,
  widget_blueprints = widget_blueprints
}

return definitions
