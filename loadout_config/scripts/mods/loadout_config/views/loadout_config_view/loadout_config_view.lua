local mod = get_mod("loadout_config")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UISettings = require("scripts/settings/ui/ui_settings")
local ITEM_TYPES = UISettings.ITEM_TYPES
local MasterItems = require("scripts/backend/master_items")
local ItemUtils = require("scripts/utilities/items")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local ItemSlotSettings = require("scripts/settings/item/item_slot_settings")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ViewElementPerksItem = require("scripts/ui/view_elements/view_element_perks_item/view_element_perks_item")
local ViewElementTraitInventory = require("scripts/ui/view_elements/view_element_trait_inventory/view_element_trait_inventory")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local LoadoutList = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_list/loadout_list")

local function sort_offer_by_display_name(a, b)
  local item_a = MasterItems.get_item(a.description.lootChoices[1])
  local item_b = MasterItems.get_item(b.description.lootChoices[1])
  return Localize(item_a.display_name) < Localize(item_b.display_name)
end

local _gadgets_list = table.filter(MasterItems.get_cached(), function(item)
  return item.item_type == ITEM_TYPES.GADGET and item.is_display_name_ref
end)
local _gadgets_list_size = table.size(_gadgets_list)

local function _get_random_gadget()
  local rand = math.random(_gadgets_list_size)

  local i = 1
  for gadget_name in pairs(_gadgets_list) do
    if i == rand then
      return table.clone(MasterItems.get_item(gadget_name))
    end
    i = i + 1
  end

end

local _use_override_speed = true
local function _sin_time_since_launch(optional_speed)
  optional_speed = _use_override_speed and 2 or optional_speed or 1
  local time_since_launch = Application.time_since_launch() * optional_speed
  return math.sin(time_since_launch)
end

local slot_buttons_settings = {
  ItemSlotSettings.slot_primary,
  ItemSlotSettings.slot_secondary,
  ItemSlotSettings.slot_attachment_1,
  ItemSlotSettings.slot_attachment_2,
  ItemSlotSettings.slot_attachment_3
}
local stat_slider_passes = {
  {
    pass_type = "rect",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      color = { 180, 3, 3, 3 },
      offset = { 0, 0, 1 }
    }
  },
  {
    pass_type = "rect",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "center",
      color = Color.terminal_background_gradient(180, true),
      size = { 104, 14 },
      offset = { 0, 0, 0 }
    }
  },
  {
    pass_type = "rect",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      size = { 35, 10 },
      color = Color.terminal_background_selected(255, true),
      offset = { 0, 0, 2 }
    },
    change_function = function(content, style)
      style.size[1] = content.value * 100
    end
  },

  {
    pass_type = "triangle",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      triangle_corners = {
        { -5, 0 },
        { 0, 5 },
        { 0, -5 }
      },
      color = Color.white(180, true),
      offset = { -5, 5, 2 }
    },
    change_function = function(content, style)
      if content.hotspot_left.is_hover then
        style.color = Color.white(255, true)
      else
        style.color = Color.white(180, true)
      end
    end
  },
  {
    pass_type = "hotspot",
    content_id = "hotspot_left",
    content = {
      on_hover_sound = UISoundEvents.default_mouse_hover
    },
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "left",
      size = { 5, 10 },
      offset = { -10, 0, 0 }
    },
    change_function = function(content, style, _, dt)
      local parent_content = content.parent
      local value = parent_content.value

      local is_held = content.is_held
      local on_pressed = content._input_pressed and not is_held
      local on_released = content.on_released

      if on_pressed then
        Managers.ui:play_2d_sound(UISoundEvents.default_click)
        parent_content.value = math.clamp(value - 0.01, 0, 1)
      elseif is_held then
        local held_dt = content.held_dt or 0
        held_dt = held_dt + dt
        content.held_dt = held_dt

        if held_dt > 0.75 then
          parent_content.value = math.clamp(value - 0.005, 0, 1)
        end
      elseif on_released then
        content.held_dt = 0
      end
    end
  },

  {
    pass_type = "triangle",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "right",
      triangle_corners = {
        { 5, 0 },
        { 0, 5 },
        { 0, -5 },
      },
      color = Color.white(255, true),
      offset = { 105, 5, 2 }
    },
    change_function = function(content, style)
      if content.hotspot_right.is_hover then
        style.color = Color.white(255, true)
      else
        style.color = Color.white(180, true)
      end
    end
  },
  {
    pass_type = "hotspot",
    content_id = "hotspot_right",
    content = {
      on_hover_sound = UISoundEvents.default_mouse_hover
    },
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "right",
      size = { 5, 10 },
      offset = { 10, 0, 0 }
    },
    change_function = function(content, style, _, dt)
      local parent_content = content.parent
      local value = parent_content.value

      local is_held = content.is_held
      local on_pressed = content._input_pressed and not is_held
      local on_released = content.on_released

      if on_pressed then
        Managers.ui:play_2d_sound(UISoundEvents.default_click)
        parent_content.value = math.clamp(value + 0.01, 0, 1)
      elseif is_held then
        local held_dt = content.held_dt or 0
        held_dt = held_dt + dt
        content.held_dt = held_dt

        if held_dt > 0.75 then
          parent_content.value = math.clamp(value + 0.005, 0, 1)
        end
      elseif on_released then
        content.held_dt = 0
      end
    end
  },

  {
    pass_type = "text",
    value_id = "stat_text",
    value = "",
    style = {
      text_vertical_alignment = "center",
      text_horizontal_alignment = "left",
      font_type = "machine_medium",
      font_size = 14,
      text_color = UIHudSettings.color_tint_main_1,
      offset = { 0, -15, 2 }
    },
  },

  {
    pass_type = "text",
    value_id = "text",
    style = {
      text_vertical_alignment = "center",
      text_horizontal_alignment = "center",
      font_type = "machine_medium",
      font_size = 18,
      text_color = UIHudSettings.color_tint_main_1,
      offset = { 0, 15, 2 }
    },
    change_function = function(content, style)
      local value = string.format("%d%%", (content.value or 0) * 100)
      content.text = value
    end
  }
}
local slot_button_passes = {

  {
    pass_type = "text",
    value_id = "text",
    value = "",
    style = {
      font_type = "machine_medium",
      text_horizontal_alignment = "center",
      text_vertical_alignment = "center",
      font_size = 18,
      text_color = UIHudSettings.color_tint_main_1,
      offset = { 0, 0, 1 }
    },
    change_function = function(content, style)
      if content.hotspot.is_selected or content.hotspot.is_hover then
        style.text_color = { 255, 255, 255, 255 }
      else
        style.text_color = UIHudSettings.color_tint_main_1
      end
    end
  },
  {
    pass_type = "texture",
    value = "content/ui/materials/frames/frame_tile_2px",
    value_id = "frame",
    style_id = "frame",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "center",
      color = Color.black(nil, true),
      offset = { 0, 0, 4 },
    },
    change_function = function(content, style)
      if content.hotspot.is_selected then
        style.color = Color.black(255, true)
      else
        style.color = Color.terminal_frame(255, true)
      end
    end
  },
  {
    style_id = "background",
    pass_type = "rect",
    style = {
      horizontal_alignment = "center",
      vertical_alignment = "center",
      color = Color.terminal_background(255, true),
      offset = { 0, 0, 0 }
    },
    change_function = function(content, style)
      if content.hotspot.is_selected then
        style.color = UIHudSettings.color_tint_main_4
      else
        style.color = Color.terminal_background(255, true)
      end
    end
  },
  {
    pass_type = "hotspot",
    content_id = "hotspot",
    content = {
      on_hover_sound = UISoundEvents.default_mouse_hover,
      on_pressed_sound = UISoundEvents.default_click
    },
    style = {
      horizontal_alignment = "center",
      vertical_alignment = "center"
    }
  },
  {
    value = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
    style_id = "gradient",
    pass_type = "texture_uv",
    style = {
      horizontal_alignment = "center",
      vertical_alignment = "center",
      uvs = {
        { 0, 0 },
        { 1, 1 }
      },
      size = { nil, 25 },
      color = Color.terminal_background_gradient(255, true),
      color_default = Color.terminal_background_gradient(255, true),
      color_selected = { 255, 0, 215, 255 },
      offset = { 0, 0, 1 }
    },
    change_function = function(content, style, _, dt)
      local is_hover = content.hotspot and content.hotspot.is_hover
      local hover_speed = 5
      local hover_progress = content.hover_progress or 0

      if is_hover then
        hover_progress = math.min(1, hover_progress + dt * hover_speed)
      else
        hover_progress = math.max(0, hover_progress - dt * hover_speed)
      end

      local hotspot = content.hotspot
      local on_pressed = hotspot.on_pressed
      local is_selected = hotspot.is_selected

      if on_pressed then
        hotspot.is_selected = not is_selected
      end

      if hotspot.is_selected then
        style.color = style.color_selected
      else
        style.color = style.color_default
      end

      style.uvs[2][1] = 1 - hover_progress
      style.uvs[2][2] = 1 - hover_progress

      content.hover_progress = hover_progress
    end
  },
}
local weapon_card_passes = {
  {
    pass_type = "rect",
    style_id = "title_border",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "center",
      color = Color.terminal_frame(255, true),
      size = { nil, 1 },
      offset = { 0, -50, 1 }
    }
  },
  {
    pass_type = "texture",
    value = "content/ui/materials/frames/frame_tile_2px",
    value_id = "frame",
    style_id = "frame",
    style = {
      vertical_alignment = "center",
      horizontal_alignment = "center",
      color = Color.terminal_frame(255, true),
      offset = { 0, 0, 4 },
    }
  },
  {
    style_id = "background",
    pass_type = "rect",
    style = {
      horizontal_alignment = "center",
      vertical_alignment = "center",
      size = { nil, 150 },
      color = Color.terminal_background(255, true),
      offset = { 0, 0, -1 }
    }
  },
  {
    value = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
    style_id = "gradient",
    pass_type = "texture_uv",
    style = {
      horizontal_alignment = "center",
      vertical_alignment = "center",
      uvs = {
        { 0, 0 },
        { 1, 1 }
      },
      size = { nil, 25 },
      color = Color.terminal_background_gradient(nil, true),
      color_default = Color.terminal_background_gradient(nil, true),
      color_selected = { 150, 32, 165, 218 },
      offset = {
        0,
        -62.5,
        0
      }
    }
  },
  {
    value = "content/ui/materials/icons/items/containers/item_container_landscape",
    value_id = "icon",
    style_id = "icon",
    pass_type = "texture",
    style = {
      material_values = {
        use_placeholder_texture = 1
      },
      horizontal_alignment = "center",
      vertical_alignment = "bottom",
      size = { 256, 128 },
      color = UIHudSettings.color_tint_main_1,
      offset = {
        0,
        -2,
        5
      }
    },
    visibility_function = function(content, style)
      local use_placeholder_texture = style.material_values.use_placeholder_texture

      if use_placeholder_texture and use_placeholder_texture == 0 then
        return true
      end

      return false
    end
  },
  {
    pass_type = "text",
    value_id = "text",
    value = "",
    style = {
      font_type = "machine_medium",
      text_horizontal_alignment = "center",
      text_vertical_alignment = "center",
      font_size = 18,
      text_color = UIHudSettings.color_tint_main_1,
      offset = { 0, -62.5, 1 }
    },
    change_function = function(content, style)
      local cards = content.cards
      local current_card_item = cards and cards[content.index]
      if not current_card_item then
        return
      end

      local display_name = current_card_item.display_name
      content.text = (display_name == "n/a" and "Attachment") or Localize(display_name)
    end
  },
  {
    pass_type = "hotspot",
    content_id = "prev_hotspot",
    content = {},
    style = {
      size = { 30, 125 },
      vertical_alignment = "bottom",
      horizontal_alignment = "left"
    },
    change_function = function(content, style)
      local parent_content = content.parent
      if content.on_released then
        local num_cards = table.size(parent_content.cards)
        parent_content.index = parent_content.index - 1
        if parent_content.index < 1 then
          parent_content.index = num_cards
        end
      end
    end
  },
  {
    pass_type = "hotspot",
    content_id = "next_hotspot",
    content = {},
    style = {
      size = { 30, 125 },
      vertical_alignment = "bottom",
      horizontal_alignment = "right"
    },
    change_function = function(content, style)
      local parent_content = content.parent
      if content.on_released then
        local num_cards = table.size(parent_content.cards)
        parent_content.index = parent_content.index + 1
        if parent_content.index > num_cards then
          parent_content.index = 1
        end
      end
    end
  },
  {
    value = "content/ui/materials/buttons/arrow_01",
    style_id = "prev_arrow",
    pass_type = "texture_uv",
    style = {
      uvs = {
        { 1, 0 },
        { 0, 1 }
      },
      vertical_alignment = "center",
      horizontal_alignment = "left",
      size = { 11.5, 17 },
      color = UIHudSettings.color_tint_main_1,
      offset = { 9.25, 12.5, 3 }
    },
    change_function = function(content, style)
      style.color[1] = content.prev_hotspot.is_hover and 255 or 80
    end
  },
  {
    value = "content/ui/materials/buttons/arrow_01",
    style_id = "next_arrow",
    pass_type = "texture_uv",
    style = {
      uvs = {
        { 0, 0 },
        { 1, 1 }
      },
      vertical_alignment = "center",
      horizontal_alignment = "right",
      size = { 11.5, 17 },
      color = UIHudSettings.color_tint_main_1,
      offset = { -9.25, 12.5, 3 }
    },
    change_function = function(content, style)
      style.color[1] = content.next_hotspot.is_hover and 255 or 80
    end
  },
  {
    pass_type = "rect",
    style_id = "prev_rect",
    style = {
      size = { 30, 125 },
      vertical_alignment = "center",
      horizontal_alignment = "left",
      color = UIHudSettings.color_tint_main_3,
      offset = { 0, 12.5, 1 }
    },
    change_function = function(content, style)
      style.color[1] = content.prev_hotspot.is_hover and 255 or 20
    end
  },
  {
    pass_type = "rect",
    style_id = "next_rect",
    style = {
      size = { 30, 125 },
      vertical_alignment = "center",
      horizontal_alignment = "right",
      color = UIHudSettings.color_tint_main_3,
      offset = { 0, 12.5, 1 }
    },
    change_function = function(content, style)
      style.color[1] = content.next_hotspot.is_hover and 255 or 20
    end
  }
}
local _definitions = {
  legend_inputs = {
    {
      input_action = "back",
      on_pressed_callback = "_on_back_pressed",
      display_name = "loc_class_selection_button_back",
      alignment = "left_alignment",
    },
  },
  scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    background = {
      parent = "screen",
      scale = "fit",
      size = { 1920, 1080 },
      position = { 0, 0, 0 }
    },
    loadout_list_root = {
      parent = "background",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 800, 0 },
      position = { 0, 100, 0 }
    },
    stat_slider_root = {
      parent = "background",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 800, 50 },
      position = { 0, 50, 0 }
    },
    stat_slider_header = {
      parent = "stat_slider_root",
      vertical_alignment = "top",
      horizontal_alignment = "left",
      size = { 150, 21 },
      position = { 0, -20, 0 }
    },
    stat_slider_1 = {
      parent = "stat_slider_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 100, 10 },
      position = { -300, 0, 1 }
    },
    stat_slider_2 = {
      parent = "stat_slider_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 100, 10 },
      position = { -150, 0, 1 }
    },
    stat_slider_3 = {
      parent = "stat_slider_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 100, 10 },
      position = { 0, 0, 1 }
    },
    stat_slider_4 = {
      parent = "stat_slider_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 100, 10 },
      position = { 150, 0, 1 }
    },
    stat_slider_5 = {
      parent = "stat_slider_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 100, 10 },
      position = { 300, 0, 1 }
    },
    slot_button_root = {
      parent = "background",
      vertical_alignment = "bottom",
      horizontal_alignment = "center",
      size = { 1000, 300 },
      position = { 0, -75, 0 }
    },
    slot_button_1 = {
      parent = "slot_button_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 320, 25 },
      position = { -165, 0, 0 }
    },
    slot_button_2 = {
      parent = "slot_button_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 320, 25 },
      position = { 165, 0, 0 }
    },
    slot_button_3 = {
      parent = "slot_button_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 320, 25 },
      position = { -330, 30, 0 }
    },
    slot_button_4 = {
      parent = "slot_button_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 320, 25 },
      position = { 0, 30, 0 }
    },
    slot_button_5 = {
      parent = "slot_button_root",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 320, 25 },
      position = { 330, 30, 0 }
    },
    selected_card = {
      parent = "background",
      vertical_alignment = "center",
      horizontal_alignment = "center",
      size = { 500, 150 },
      position = { -1, -49, 0 }
    },
    weapon_root = {
      parent = "background",
      vertical_alignment = "top",
      horizontal_alignment = "left",
      size = { 1850, 790 },
      position = { 50, 50, 0 }
    },
    offer_button_root = {
      parent = "selected_card",
      vertical_alignment = "top",
      horizontal_alignment = "center",
      size = { 800, 350 },
      position = { 50, -75, 0 }
    },
    offer_button = {
      parent = "offer_button_root",
      vertical_alignment = "top",
      horizontal_alignment = "left",
      size = { 144, 64 },
      position = { 0, 0, 0 }
    },
    perk_selection_root = {
      parent = "weapon_root",
      vertical_alignment = "center",
      horizontal_alignment = "left",
      size = { 0, 650 },
      position = { 0, 0, 1 }
    },
    trait_selection_root = {
      parent = "weapon_root",
      vertical_alignment = "center",
      horizontal_alignment = "right",
      size = { 0, 650 },
      position = { -450, 0, 1 }
    }
  },
  widget_definitions = {
    background = UIWidget.create_definition({
      {
        pass_type = "rect",
        style = {
          color = Color.terminal_background(180, true),
          offset = { 0, 0, 0 }
        }
      }
    }, "background"),
    --loadout_list = UIWidget.create_definition(TextInputPassTemplates.terminal_input_field, "loadout_list_root"),
    stat_slider_header = UIWidget.create_definition({
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
        value = Localize("loc_item_information_stats_title_modifiers"),
        style = {
          font_type = "machine_medium",
          font_size = 18,
          text_vertical_alignment = "center",
          text_horizontal_alignment = "center",
          text_color = Color.terminal_text_body(255, true),
          offset = { 0, 0, 1 }
        }
      }
    }, "stat_slider_header"),
    stat_slider_background = UIWidget.create_definition({
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
    }, "stat_slider_root"),
    --create_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "create_button", {
    --  text = "Create",
    --  hotspot = {
    --    on_pressed_sound = UISoundEvents.default_click
    --  }
    --}, nil, {
    --  background = {
    --    default_color = Color.terminal_background(255, true),
    --    selected_color = Color.terminal_background_selected(255, true)
    --  }
    --}),
    --reset_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "reset_button", {
    --  text = "Reset",
    --  hotspot = {
    --    on_pressed_sound = UISoundEvents.default_click
    --  }
    --}, nil, {
    --  background = {
    --    default_color = Color.terminal_background(255, true),
    --    selected_color = Color.terminal_background_selected(255, true)
    --  }
    --}),
    --delete_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "delete_button", {
    --  text = "Delete",
    --  hotspot = {
    --    on_pressed_sound = UISoundEvents.default_click
    --  }
    --}, nil, {
    --  background = {
    --    default_color = Color.terminal_background(255, true),
    --    selected_color = Color.terminal_background_selected(255, true)
    --  }
    --}),
    selected_card = UIWidget.create_definition(weapon_card_passes, "selected_card", {
      traits = {},
      perks = {},
      cards = {},
      index = 1
    }),
  }
}

local widget_definitions = _definitions.widget_definitions
for i, slot_button_settings in ipairs(slot_buttons_settings) do
  local scenegraph_id = string.format("slot_button_%s", i)
  widget_definitions[scenegraph_id] = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, scenegraph_id, {
    index = i,
    text = Localize(slot_button_settings.display_name),
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  })
end

for i = 1, 5 do
  local scenegraph_id = string.format("stat_slider_%s", i)
  widget_definitions[scenegraph_id] = UIWidget.create_definition(stat_slider_passes, scenegraph_id, {
    value = 0
  })
end

local LoadoutConfigView = class("LoadoutConfigView", "BaseView")

function LoadoutConfigView:init(settings)
  LoadoutConfigView.super.init(self, _definitions, settings)

  self._should_unload = Managers.ui:load_view("crafting_replace_perk_view", "loadout_config", function()
    self._is_replace_perk_view_loaded = true
  end)

  local player = self:_player()
  local profile = player:profile()
  self._profile = table.clone_instance(profile)

  Managers.event:register(self, "event_player_profile_updated", "event_player_profile_updated")
end

function LoadoutConfigView:destroy()
  Managers.event:unregister(self, "event_player_profile_updated")
end

function LoadoutConfigView:event_player_profile_updated(peer_id, local_player_id, new_profile)
  if peer_id ~= Network.peer_id() or local_player_id ~= 1 then
    return
  end

  local loadout = new_profile.loadout
  local selected_card = self._widgets_by_name.selected_card

  selected_card.content.cards = {
    loadout.slot_primary and loadout.slot_primary.__master_item,
    loadout.slot_secondary and loadout.slot_secondary.__master_item,
    loadout.slot_attachment_1 and loadout.slot_attachment_1.__master_item or _get_random_gadget(),
    loadout.slot_attachment_2 and loadout.slot_attachment_2.__master_item or _get_random_gadget(),
    loadout.slot_attachment_3 and loadout.slot_attachment_3.__master_item or _get_random_gadget(),
  }

  self._profile = table.clone_instance(new_profile)
end

function LoadoutConfigView:player_profile()
  return self._profile
end

function LoadoutConfigView:_setup_elements()
  self:_populate_weapon_cards()

  local loadout_list_context = {
    max_loadouts = 20,
    pressed_callback = callback(self, "_on_loadout_button_pressed"),
    reset_callback = callback(self, "_on_reset_button_pressed")
  }

  self._loadout_list = self:_add_element(LoadoutList, "loadout_list", 0, loadout_list_context , "loadout_list_root")
  self:_update_element_position("loadout_list_root", self._loadout_list)

  self._perk_selection = self:_add_element(ViewElementPerksItem, "perk_selection", 10, nil, "perk_selection_root")
  self:_update_element_position("perk_selection_root", self._perk_selection)

  self._trait_selection = self:_add_element(ViewElementTraitInventory, "trait_selection", 10, nil, "trait_selection_root")
  self._trait_selection._on_trait_hover = function(self, config)
    local trait_item = config.trait_item
    if not trait_item.value then
      trait_item = trait_item.__master_item
      trait_item.value = trait_item.rarity * 0.25
    end
    self._hovered_trait_item = config.trait_item
  end
  self:_update_element_position("trait_selection_root", self._trait_selection)
end

function LoadoutConfigView:on_enter()
  LoadoutConfigView.super.on_enter(self)

  self:_setup_input_legend()

  self._saved_loadouts = mod:get("saved_loadouts") or {}
  self._selected_card = self._widgets_by_name.selected_card

  local store_service = Managers.data_service.store
  store_service:get_credits_goods_store():next(function(data)
    self._offers = data.offers
    self:_setup_elements()
  end)

  self._is_open = true
  Imgui.open_imgui()
end

function LoadoutConfigView:_populate_weapon_cards()
  local player = self:_player()
  local profile = player:profile()
  local loadout = profile.loadout
  local selected_card = self._selected_card

  selected_card.content.cards = {
    loadout.slot_primary and loadout.slot_primary.__master_item,
    loadout.slot_secondary and loadout.slot_secondary.__master_item,
    loadout.slot_attachment_1 and loadout.slot_attachment_1.__master_item or _get_random_gadget(),
    loadout.slot_attachment_2 and loadout.slot_attachment_2.__master_item or _get_random_gadget(),
    loadout.slot_attachment_3 and loadout.slot_attachment_3.__master_item or _get_random_gadget(),
  }

  self._profile = profile

  local widgets_by_name = self._widgets_by_name
  for i = 1, #slot_buttons_settings do
    local widget_name = string.format("slot_button_%s", i)
    local widget = widgets_by_name[widget_name]
    widget.content.hotspot.pressed_callback = callback(self, "_on_slot_button_pressed", i)
  end

  local slot_primary_offer_widgets = {}
  local slot_secondary_offer_widgets = {}
  local slot_attachment_offer_widgets = {}

  local offer_widget_names = {}
  local widgets = self._widgets
  local offers = self._offers

  table.sort(offers, sort_offer_by_display_name)

  for i, offer in ipairs(offers) do
    local offer_description = offer.description
    local loot_choices = offer_description.lootChoices
    local item_id = loot_choices[1]
    local item = MasterItems.get_item(item_id)
    local item_type = item.item_type
    local hud_icon = item.hud_icon

    local slot_offer_widgets
    if item_type == ITEM_TYPES.WEAPON_MELEE then
      slot_offer_widgets = slot_primary_offer_widgets
    elseif item_type == ITEM_TYPES.WEAPON_RANGED then
      slot_offer_widgets = slot_secondary_offer_widgets
    elseif item_type == ITEM_TYPES.GADGET then
      slot_offer_widgets = slot_attachment_offer_widgets
    end

    local widget_definition = UIWidget.create_definition(ButtonPassTemplates.terminal_button_icon, "offer_button_root", {
      item = item,
      item_id = item_id,
      item_type = item_type,
      icon = hud_icon or "content/ui/materials/icons/weapons/hud/combat_blade_01",
      hotspot = {
        on_pressed_sound = UISoundEvents.default_click
      }
    }, { 128, 48 }, {
      icon = {
        size = { 128, 48 }
      }
    })

    local index = #slot_offer_widgets + 1
    local widget_id = string.format("offer_button_%s_%s", item_type, index)
    local widget = self:_create_widget(widget_id, widget_definition)
    local row = (index - 1) / 5

    widget.content.hotspot.pressed_callback = callback(self, "_on_offer_button_selected", widget)
    widget.offset = {
      (index - 1) % 5 * 140,
      math.floor(row) * -60,
      1
    }

    table.insert(offer_widget_names, widget_id)
    table.insert(slot_offer_widgets, widget)
    table.insert(widgets, widget)
  end

  self._offer_widget_names = offer_widget_names
end

function LoadoutConfigView:_on_loadout_button_pressed(loadout_widget)
  local content = loadout_widget.content
  local loadout_item_data = content.loadout_item_data
  local synchronizer_host = Managers.profile_synchronization:synchronizer_host()

  if synchronizer_host then
    local player = self:_player()
    local profile = table.clone_instance(self._profile)

    profile.loadout_item_data = table.merge(profile.loadout_item_data, loadout_item_data)
    synchronizer_host:override_singleplay_profile(Network.peer_id(), player:local_player_id(), profile)
  end

end

function LoadoutConfigView:_on_reset_button_pressed()
  self._reset_loadout = true
  self:_apply_custom_loadout()
end

function LoadoutConfigView:_on_offer_button_selected(offer_widget)
  local item_id = offer_widget.content.item_id
  local selected_item = self._selected_item

  if selected_item.name ~= item_id then
    local item = offer_widget.content.item
    local weapon_template = WeaponTemplate.weapon_template_from_item(item)
    local template_base_stats = weapon_template and weapon_template.base_stats
    local base_stats = template_base_stats and {}

    if base_stats then
      for stat_name in pairs(template_base_stats) do
        table.insert(base_stats, {
          name = stat_name,
          value = (mod:get("default_base_stat_value") or 100) / 100
        })
      end
    end

    item.perks = {}
    item.traits = {}
    item.base_stats = base_stats

    local selected_card = self._selected_card
    selected_card.content.cards[selected_card.content.index] = item

    self._loadout_list:clear_selection()
  end
end

function LoadoutConfigView:_on_slot_button_pressed(index)
  self._selected_card.content.index = index
end

function LoadoutConfigView:_load_selected_item_icon()
  local selected_card = self._selected_card

  local icon_load_id = selected_card.content.icon_load_id
  if icon_load_id then
    Managers.ui:unload_item_icon(icon_load_id)
  end

  local cb = callback(self, "_on_item_icon_loaded", selected_card)
  local unload_cb = callback(self, "_on_item_icon_unloaded", selected_card)

  selected_card.content.icon_load_id = Managers.ui:load_item_icon(self._selected_item, cb, nil, nil, nil, unload_cb)
end

function LoadoutConfigView:_on_item_icon_unloaded(selected_card)
  local material_values = selected_card.style.icon.material_values

  material_values.use_placeholder_texture = 1
  material_values.use_render_target = 0
  material_values.rows = nil
  material_values.columns = nil
  material_values.render_target = nil
end

function LoadoutConfigView:_on_item_icon_loaded(selected_card, grid_index, rows, columns, render_target)

  local material_values = selected_card.style.icon.material_values

  material_values.use_placeholder_texture = 0
  material_values.use_render_target = 1
  material_values.rows = rows
  material_values.columns = columns
  material_values.grid_index = grid_index - 1
  material_values.render_target = render_target
end

function LoadoutConfigView:_has_perk(perk_item)
  local selected_item = self._selected_item
  local selected_perks = selected_item.perks

  for i, selected_perk in ipairs(selected_perks) do
    if selected_perk.id == perk_item.name and selected_perk.rarity == perk_item.rarity then
      return true, i
    end
  end

  return false
end

function LoadoutConfigView:_has_trait(trait_item)
  local selected_item = self._selected_item
  local selected_traits = selected_item.traits

  for i, selected_trait in ipairs(selected_traits) do
    if selected_trait.id == trait_item.name and selected_trait.rarity == trait_item.rarity then
      return true, i
    end
  end

  return false
end

function LoadoutConfigView:_on_trait_selected(widget, config)
  local selected_item = self._selected_item
  local selected_traits = selected_item.traits
  local trait_item = config.trait_item
  local max_traits = selected_item.item_type == ITEM_TYPES.GADGET and 1 or 2
  local has_trait, index = self:_has_trait(trait_item)

  if has_trait then
    table.remove(selected_traits, index)

    return
  end

  if not self._enforce_override_restrictions or #selected_traits < max_traits then
    table.insert(selected_traits, {
      rarity = config.trait_item.rarity,
      id = config.trait_item.name,
      value = config.trait_item.value
    })
  end
end

function LoadoutConfigView:_update_trait_selection()
  local trait_category = ItemUtils.trait_category(self._selected_item)

  if not trait_category then
    local innate_trait_items = self._innate_traits_list or table.filter(MasterItems.get_cached(), function(item)
      return string.find(item.name, "inate")
    end)

    local innate_traits_list = {}
    for trait_name, trait_item in pairs(innate_trait_items) do
      innate_traits_list[trait_name] = {
        "seen",
        "seen",
        "seen",
        "seen"
      }
    end

    self._trait_selection:present_inventory(innate_traits_list, {
      item = self._selected_item,
      trait_ids = self._selected_item.traits or {}
    }, callback(self, "_on_trait_selected"))
    self._trait_selection:set_color_intensity_multiplier(1)
    self._trait_selection:_switch_to_rank_tab(4)

    self._innate_traits_list = innate_traits_list

    return
  end

  Managers.data_service.crafting:trait_sticker_book(trait_category):next(function(traits)
    self._traits_list = table.clone(traits)
    for trait_id, trait_data in pairs(traits) do
      for trait_rank, trait_status in ipairs(trait_data) do
        self._traits_list[trait_id][trait_rank] = "seen"
      end
    end

    self._trait_selection:present_inventory(self._traits_list, {
      item = self._selected_item,
      trait_ids = self._selected_item.traits or {}
    }, callback(self, "_on_trait_selected"))
    self._trait_selection:set_color_intensity_multiplier(1)
    self._trait_selection:_switch_to_rank_tab(4)
  end)
end

function LoadoutConfigView:_update_selected_item()
  local selected_card = self._selected_card
  local current_card_item = selected_card and selected_card.content.cards[selected_card.content.index]
  local selected_item = self._selected_item

  local base_stats = selected_item and selected_item.base_stats
  if base_stats then
    local widgets_by_name = self._widgets_by_name

    for i = 1, 5 do
      local widget_name = string.format("stat_slider_%s", i)
      local widget = widgets_by_name[widget_name]
      local content = widget.content
      local _, stat_data = table.find_by_key(base_stats, "name", content.stat_name)
      if stat_data then
        stat_data.value = content.value
      end
    end
  end

  if current_card_item and current_card_item ~= selected_item then
    current_card_item.traits = current_card_item.traits or {}
    current_card_item.perks = current_card_item.perks or {}

    --if not table.contains(current_card_item.slots, "slot_secondary") and current_card_item.item_type == ITEM_TYPES.WEAPON_MELEE then
    --  table.insert(current_card_item.slots, "slot_secondary")
    --end

    self._selected_item = current_card_item

    self:_load_selected_item_icon()
    self:_update_visible_offers()

    return true
  end
end

function LoadoutConfigView:_update_visible_offers()
  local selected_item = self._selected_item
  local selected_item_type = selected_item.item_type
  local selected_item_id = selected_item.name
  local offer_widget_names = self._offer_widget_names
  local widgets_by_name = self._widgets_by_name

  for i, widget_name in ipairs(offer_widget_names) do
    local widget = widgets_by_name[widget_name]
    local content = widget.content
    content.visible = content.item_type == selected_item_type
    content.hotspot.is_selected = content.item_id == selected_item_id
  end
end

function LoadoutConfigView:_on_perk_selected(widget, config)
  local selected_item = self._selected_item
  local selected_perks = selected_item.perks
  local perk_item = config.perk_item
  local max_perks = selected_item.item_type == ITEM_TYPES.GADGET and 3 or 2
  local has_perk, index = self:_has_perk(perk_item)

  if has_perk then
    table.remove(selected_perks, index)

    return
  end

  if not self._enforce_override_restrictions or #selected_perks < max_perks then
    table.insert(selected_perks, {
      rarity = perk_item.rarity,
      id = perk_item.name
    })
  end
end

function LoadoutConfigView:_update_perk_selection()
  local perk_selection = self._perk_selection
  local selected_item = self._selected_item
  local item_name = selected_item.name

  perk_selection:present_perks(item_name, {
    item = selected_item
  }, callback(self, "_on_perk_selected"))
end

function LoadoutConfigView:_update_selected_slot()
  local widgets_by_name = self._widgets_by_name
  local selected_card = widgets_by_name.selected_card

  for i = 1, #slot_buttons_settings do
    local key = string.format("slot_button_%s", i)
    local widget = widgets_by_name[key]
    widget.content.hotspot.is_selected = widget.content.index == selected_card.content.index
  end
end

function LoadoutConfigView:_update_base_stats()
  local widgets_by_name = self._widgets_by_name
  local selected_item = self._selected_item
  local weapon_template = WeaponTemplate.weapon_template_from_item(selected_item)
  local base_stats = weapon_template and weapon_template.base_stats
  local has_base_stats = not not base_stats

  widgets_by_name.stat_slider_header.content.visible = has_base_stats
  widgets_by_name.stat_slider_background.content.visible = has_base_stats

  if not has_base_stats then
    for i = 1, 5 do
      local widget_name = string.format("stat_slider_%s", i)
      local widget = widgets_by_name[widget_name]
      local content = widget.content

      content.visible = false
    end

    return
  end

  local i = 1
  for stat_name, stat_data in pairs(base_stats) do
    local widget_name = string.format("stat_slider_%s", i)
    local widget = widgets_by_name[widget_name]
    local content = widget.content
    local _, existing_stat_data = table.find_by_key(selected_item.base_stats or {}, "name", stat_name)

    content.value = existing_stat_data and math.round_with_precision(existing_stat_data.value, 2) or 1
    content.stat_text = Localize(stat_data.display_name)
    content.stat_name = stat_name
    content.visible = selected_item.item_type ~= ITEM_TYPES.GADGET

    i = i + 1
  end

end

function LoadoutConfigView:update(dt, t, input_service)
  if not self._is_replace_perk_view_loaded then
    return
  end

  LoadoutConfigView.super.update(self, dt, t, input_service)

  self._enforce_override_restrictions = mod:get("enforce_override_restrictions")

  local should_update_perks = self:_update_selected_item()
  if should_update_perks then
    self:_update_perk_selection()
    self:_update_trait_selection()
    self:_update_base_stats()
  end

  self:_update_selected_slot()
  self:_update_active_selections()

  local is_debug_mode = mod:get("debug_mode")
  if is_debug_mode then
    self:_update_debug_menu()
  end
end

function LoadoutConfigView:_update_active_selections()
  local perk_selection = self._perk_selection
  local perk_widgets = perk_selection and perk_selection:widgets() or {}
  for _, perk_widget in ipairs(perk_widgets) do
    local config = perk_widget.content.config
    local perk_item = config.perk_item
    local has_perk = self:_has_perk(perk_item)

    perk_widget.content.is_wasteful = nil
    perk_widget.content.marked = has_perk
    perk_widget.content.hotspot.is_selected = has_perk
  end

  local trait_selection = self._trait_selection
  local trait_widgets = trait_selection and trait_selection:widgets() or {}
  for i, trait_widget in ipairs(trait_widgets) do
    local config = trait_widget.content.config
    local trait_item = config.trait_item
    local has_trait = self:_has_trait(trait_item)

    trait_widget.content.is_wasteful = nil
    trait_widget.content.marked = has_trait
    trait_widget.content.hotspot.is_selected = has_trait
  end
end

local function _format_string(key, val)
  return string.format("[%s]: %s", key, val)
end

local function _table_to_tree_node(t)
  if not t then
    return
  end

  for key, value in pairs(t) do
    if type(value) == "table" then
      if Imgui.tree_node(key) then

        if type(value) == "table" then
          _table_to_tree_node(value)
        else
          Imgui.text(_format_string(key, value))
        end

        Imgui.tree_pop()
      end
    else
      Imgui.text(_format_string(key, value))
    end
  end
end
function LoadoutConfigView:_update_debug_menu()
  local is_top_view = Managers.ui:active_top_view() == "loadout_config"

  if not is_top_view then
    return
  end

  if self._is_open then
    local _, is_closed = Imgui.begin_window("Loadout Config [debug]")
    Imgui.set_window_size(640, 480)
    if is_closed then
      self:_on_back_pressed()

      return
    end

    local local_player = Managers.player:local_player_safe(1)
    local profile = local_player:profile()

    _table_to_tree_node({ ["Profile"] = profile })
    Imgui.text("-----------------------------------")
    _table_to_tree_node({ ["Selected Item"] = self._selected_item })
    Imgui.text("-----------------------------------")
    _table_to_tree_node({ ["Available Items"] = self._offers })
    Imgui.text("-----------------------------------")
    _table_to_tree_node({ ["Saved Loadouts"] = self._loadout_list and self._loadout_list._saved_loadouts })

    Imgui.end_window()
  end
end

function LoadoutConfigView:_setup_input_legend()
  local input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
  local legend_inputs = self._definitions.legend_inputs

  for i = 1, #legend_inputs do
    local legend_input = legend_inputs[i]
    local on_pressed_callback = legend_input.on_pressed_callback
        and callback(self, legend_input.on_pressed_callback)

    input_legend_element:add_entry(
        legend_input.display_name,
        legend_input.input_action,
        legend_input.visibility_function,
        on_pressed_callback,
        legend_input.alignment
    )
  end

  self._input_legend_element = input_legend_element
end

function LoadoutConfigView:_on_back_pressed()
  Managers.ui:close_view(self.view_name)
end

function LoadoutConfigView:on_exit()
  self._is_open = false
  Imgui.close_imgui()

  self:_apply_custom_loadout()

  LoadoutConfigView.super.on_exit(self)
end

function LoadoutConfigView:_pack_loadout_to_profile()
  local profile = self._profile

  if not profile then
    return
  end

  local loadout_item_ids = profile.loadout_item_ids
  local loadout_item_data = profile.loadout_item_data
  local selected_card = self._selected_card
  local items = selected_card and selected_card.content.cards

  if not items then
    return
  end

  for i = 1, #slot_buttons_settings do
    local item = items[i]

    if item then
      local item_name = item.name
      local item_perks = item.perks
      local item_traits = item.traits
      local num_perks = item_perks and #item_perks or 0
      local num_traits = item_traits and #item_traits or 0
      local item_rarity = math.min(num_perks + num_traits + 1, 5)
      local slot_settings = slot_buttons_settings[i]
      local slot_name = slot_settings.name
      local base_stats = item.base_stats

      loadout_item_ids[slot_name] = slot_name
      loadout_item_data[slot_name] = {
        id = item_name,
        overrides = {
          perks = item_perks,
          traits = item_traits,
          rarity = item_rarity,
          base_stats = base_stats
        }
      }
    end
  end

  return loadout_item_data
end

function LoadoutConfigView:_apply_custom_loadout()
  local player = Managers.player:local_player_safe(1)
  local synchronizer_host = Managers.profile_synchronization:synchronizer_host()

  if synchronizer_host then

    if self._reset_loadout then
      local local_player_id = 1
      local local_player = Managers.player:local_player_safe(local_player_id)
      local peer_id = local_player:peer_id()
      synchronizer_host:profile_changed(peer_id, local_player_id)

      self._reset_loadout = nil

      return
    end

    self:_pack_loadout_to_profile()
    local profile = self._profile

    synchronizer_host:override_singleplay_profile(Network.peer_id(), player:local_player_id(), profile)
  end
end

return LoadoutConfigView
