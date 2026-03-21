local mod = get_mod("psych_ward")

return {
  name = mod:localize("psych_ward"),
  description = mod:localize("psych_ward_description"),
  is_toggleable = false,
  options = {
    widgets = {
      {
        setting_id = "allow_chat_main_menu",
        type = "checkbox",
        default_value = true,
      },
      -- INVENTORY BUTTON
      {
        setting_id = "pw_inventory_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_inventory_button_pos_h",
            type = "numeric",
            default_value = -5,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_inventory_button_pos_v",
            type = "numeric",
            default_value = -370,
            range = {-1050, 0},
            step_size_value = 5,
          },
          {
            setting_id = "pw_inventory_button_size_h",
            type = "numeric",
            default_value = 200,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_inventory_button_size_v",
            type = "numeric",
            default_value = 40,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- CRAFTING BUTTON
      {
        setting_id = "pw_crafting_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_crafting_button_pos_h",
            type = "numeric",
            default_value = -5,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_crafting_button_pos_v",
            type = "numeric",
            default_value = -320,
            range = {-1050, 0},
            step_size_value = 5,
          },
          {
            setting_id = "pw_crafting_button_size_h",
            type = "numeric",
            default_value = 200,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_crafting_button_size_v",
            type = "numeric",
            default_value = 40,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- VENDOR BUTTON
      {
        setting_id = "pw_vendor_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_vendor_button_pos_h",
            type = "numeric",
            default_value = -5,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_vendor_button_pos_v",
            type = "numeric",
            default_value = -270,
            range = {-1050, 0},
            step_size_value = 5,
          },
          {
            setting_id = "pw_vendor_button_size_h",
            type = "numeric",
            default_value = 200,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_vendor_button_size_v",
            type = "numeric",
            default_value = 40,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },

      -- MISSION BUTTON
      {
        setting_id = "pw_mission_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_mission_button_pos_h",
            type = "numeric",
            default_value = -200,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_mission_button_pos_v",
            type = "numeric",
            default_value = 40,
            range = {-1050, 150},
            step_size_value = 5,
          },
          {
            setting_id = "pw_mission_button_size_h",
            type = "numeric",
            default_value = 250,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_mission_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- MORTIS BUTTON
      {
        setting_id = "pw_mortis_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_mortis_button_pos_h",
            type = "numeric",
            default_value = -465,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_mortis_button_pos_v",
            type = "numeric",
            default_value = 40,
            range = {-1050, 150},
            step_size_value = 5,
          },
          {
            setting_id = "pw_mortis_button_size_h",
            type = "numeric",
            default_value = 250,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_mortis_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- EXPEDITIONS BUTTON
      {
        setting_id = "pw_expeditions_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_expeditions_button_pos_h",
            type = "numeric",
            default_value = -730,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_expeditions_button_pos_v",
            type = "numeric",
            default_value = 40,
            range = {-1050, 150},
            step_size_value = 5,
          },
          {
            setting_id = "pw_expeditions_button_size_h",
            type = "numeric",
            default_value = 250,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_expeditions_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- MEATGRINDER BUTTON
      {
        setting_id = "pw_meatgrinder_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_meatgrinder_button_pos_h",
            type = "numeric",
            default_value = 0,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_meatgrinder_button_pos_v",
            type = "numeric",
            default_value = -15,
            range = {-1050, 150},
            step_size_value = 5,
          },
          {
            setting_id = "pw_meatgrinder_button_size_h",
            type = "numeric",
            default_value = 220,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_meatgrinder_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },

      -- CONTRACTS BUTTON
      {
        setting_id = "pw_contracts_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_contracts_button_pos_h",
            type = "numeric",
            default_value = -670,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_contracts_button_pos_v",
            type = "numeric",
            default_value = -1020,
            range = {-1050, 0},
            step_size_value = 5,
          },
          {
            setting_id = "pw_contracts_button_size_h",
            type = "numeric",
            default_value = 220,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_contracts_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- PENANCES BUTTON
      {
        setting_id = "pw_penance_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_penance_button_pos_h",
            type = "numeric",
            default_value = -435,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_penance_button_pos_v",
            type = "numeric",
            default_value = -1020,
            range = {-1050, 0},
            step_size_value = 5,
          },
          {
            setting_id = "pw_penance_button_size_h",
            type = "numeric",
            default_value = 220,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_penance_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
      -- COSMETICS BUTTON
      {
        setting_id = "pw_cosmetics_button_pos_size",
        type = "group",
        sub_widgets = {
          {
            setting_id = "pw_cosmetics_button_pos_h",
            type = "numeric",
            default_value = -200,
            range = {-950, 950},
            step_size_value = 5,
          },
          {
            setting_id = "pw_cosmetics_button_pos_v",
            type = "numeric",
            default_value = -1020,
            range = {-1050, 0},
            step_size_value = 5,
          },
          {
            setting_id = "pw_cosmetics_button_size_h",
            type = "numeric",
            default_value = 220,
            range = {150, 250},
            step_size_value = 1,
          },
          {
            setting_id = "pw_cosmetics_button_size_v",
            type = "numeric",
            default_value = 50,
            range = {30, 70},
            step_size_value = 1,
          },
        },
      },
    }
  }
}
