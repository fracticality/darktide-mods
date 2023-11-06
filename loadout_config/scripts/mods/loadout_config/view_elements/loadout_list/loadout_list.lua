local mod = get_mod("loadout_config")

local UIWidget = require("scripts/managers/ui/ui_widget")
local Archetypes = require("scripts/settings/archetype/archetypes")

local Definitions = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_list/loadout_list_definitions")
local ViewElementLoadoutList = class("ViewElementLoadoutList", "ViewElementBase")
--------------------------------------------------------------------------------
--- LIFECYCLE METHODS ----------------------------------------------------------
--------------------------------------------------------------------------------

function ViewElementLoadoutList:init(parent, draw_layer, scale, context)
  self._selected_loadout = nil

  self._external_pressed_callback = context.pressed_callback
  self._external_create_callback = context.create_callback
  self._external_reset_callback = context.reset_callback
  self._max_loadouts = context.max_loadouts or 20

  ViewElementLoadoutList.super.init(self, parent, draw_layer, scale, Definitions)

  self:_init_loadouts()

  local widgets_by_name = self._widgets_by_name
  local create_button = widgets_by_name.create_button
  local delete_button = widgets_by_name.delete_button
  local reset_button = widgets_by_name.reset_button

  create_button.content.hotspot.pressed_callback = callback(self, "_on_create_button_pressed")
  delete_button.content.hotspot.pressed_callback = callback(self, "_on_delete_button_pressed")
  reset_button.content.hotspot.pressed_callback = callback(self, "_on_reset_button_pressed")
end

function ViewElementLoadoutList:update(dt, t, input_service)
  self:_update_active_selection()

  ViewElementLoadoutList.super.update(self, dt, t, input_service)
end

function ViewElementLoadoutList:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
  ViewElementLoadoutList.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

  for i, loadout_widget in ipairs(self._loadout_widgets) do
    UIWidget.draw(loadout_widget, ui_renderer)
  end
end

function ViewElementLoadoutList:destroy(ui_renderer)
  mod:set("saved_loadouts", self._saved_loadouts)

  ViewElementLoadoutList.super.destroy(self, ui_renderer)
end

--------------------------------------------------------------------------------
--- /LIFECYCLE METHODS ---------------------------------------------------------
--------------------------------------------------------------------------------

function ViewElementLoadoutList:clear_selection()
  self._selected_loadout = nil
end

function ViewElementLoadoutList:archetype_name()
  local parent = self._parent
  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name

  return archetype_name
end

function ViewElementLoadoutList:set_pivot_offset(x, y)
  self:_set_scenegraph_position("pivot", x, y)
end

function ViewElementLoadoutList:_update_loadout_button_positions()
  local loadout_widgets = self._loadout_widgets
  for i, loadout_widget in ipairs(loadout_widgets) do
    loadout_widget.offset[1] = (i - 1) % 5 * 160
    loadout_widget.offset[2] = math.floor((i - 1) / 5) * 35
  end
end

function ViewElementLoadoutList:_init_loadouts()
  local saved_loadouts = mod:get("saved_loadouts")

  if not saved_loadouts then
    saved_loadouts = {}

    for archetype_name in pairs(Archetypes) do
      saved_loadouts[archetype_name] = {}
    end
  end

  self._saved_loadouts = saved_loadouts
  self._loadout_widgets = {}

  local parent = self._parent
  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_loadouts = saved_loadouts[archetype_name] or {}

  for _, loadout in ipairs(archetype_loadouts) do
    self:_create_loadout_button(loadout)
  end
end

function ViewElementLoadoutList:_on_reset_button_pressed()
  self._selected_loadout = nil

  local external_reset_callback = self._external_reset_callback
  if external_reset_callback then
    external_reset_callback()
  end
end

function ViewElementLoadoutList:_on_create_button_pressed()
  local loadout_widgets = self._loadout_widgets
  local index = #loadout_widgets + 1

  if index > self._max_loadouts then
    mod:notify("Loadout limit reached")
    return
  end

  local loadout_name = string.format("Loadout %s", index)
  local parent = self._parent
  local loadout_item_data = parent:_pack_loadout_to_profile()

  loadout_item_data = {
    slot_primary = loadout_item_data.slot_primary,
    slot_secondary = loadout_item_data.slot_secondary,
    slot_attachment_1 = loadout_item_data.slot_attachment_1,
    slot_attachment_2 = loadout_item_data.slot_attachment_2,
    slot_attachment_3 = loadout_item_data.slot_attachment_3
  }

  local loadout = {
    name = loadout_name,
    item_data = loadout_item_data
  }

  self._selected_loadout = index
  self:_create_loadout_button(loadout)

  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_loadouts = self._saved_loadouts[archetype_name]
  table.insert(archetype_loadouts, loadout)
end

function ViewElementLoadoutList:_on_delete_button_pressed()
  local saved_loadouts = self._saved_loadouts
  local selected_loadout_index = self._selected_loadout
  local loadout_widgets = self._loadout_widgets

  if not selected_loadout_index then
    return
  end

  local parent = self._parent
  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_loadouts = saved_loadouts[archetype_name]

  table.remove(archetype_loadouts, selected_loadout_index)
  table.remove(loadout_widgets, selected_loadout_index)

  for i, loadout_widget in ipairs(loadout_widgets) do
    loadout_widget.content.index = i
  end

  self._selected_loadout = nil

  self:_update_loadout_button_positions()
end

function ViewElementLoadoutList:_create_loadout_button(loadout)
  local loadout_widgets = self._loadout_widgets
  local index = #loadout_widgets + 1
  local loadout_widget_definition = Definitions.widget_blueprints.loadout_button({
    index = index,
    text = loadout.name,
    loadout_item_data = loadout.item_data
  })
  local widget_id = string.format("loadout_widget_%s", index)
  local widget = self:_create_widget(widget_id, loadout_widget_definition)

  widget.content.hotspot.pressed_callback = callback(self, "_on_loadout_button_pressed", widget)

  table.insert(loadout_widgets, widget)

  self:_update_loadout_button_positions()
end

function ViewElementLoadoutList:_on_loadout_button_pressed(loadout_button)
  local content = loadout_button.content

  self._selected_loadout = content.index

  local external_pressed_callback = self._external_pressed_callback

  if external_pressed_callback then
    external_pressed_callback(loadout_button)
  end
end

function ViewElementLoadoutList:_update_active_selection()
  local loadout_widgets = self._loadout_widgets or {}
  local selected_loadout_index = self._selected_loadout

  for i, loadout_widget in ipairs(loadout_widgets) do
    local content = loadout_widget.content
    local index = content.index

    content.hotspot.is_selected = index == selected_loadout_index
  end

  local widgets_by_name = self._widgets_by_name
  local delete_button = widgets_by_name.delete_button
  delete_button.content.hotspot.disabled = not self._selected_loadout

  local create_button = widgets_by_name.create_button
  create_button.content.hotspot.disabled = #loadout_widgets > self._max_loadouts
end

return ViewElementLoadoutList
