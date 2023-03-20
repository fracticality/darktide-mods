return {
  crosshair_hud = {
    en = "CrosshairHUD"
  },
  crosshair_hud_description = {
    en = "Provides a toughness counter on/near the crosshair.\nTemporarily displays health when receiving health damage."
  },

  x_offset = {
    en = "X Offset"
  },
  x_offset_description = {
    en = "Adjusts horizontal position.\nNegative values move the display to the left; positive values to the right."
  },

  y_offset = {
    en = "Y Offset"
  },
  y_offset_description = {
    en = "Adjusts vertical position.\nNegative values move the display up; positive values down."
  },

  health_display_type = {
    en = "Display Type"
  },
  toughness_display_type = {
    en = "Display Type"
  },
  display_type_value = {
    en = "Value"
  },
  display_type_percent = {
    en = "Percent"
  },

  options_health = {
    en = "Health Settings"
  },
  health_always_show = {
    en = "Always Show Health"
  },
  health_always_show_description = {
    en = "Always display current health, regardless of other health visibility settings."
  },
  health_stay_time = {
    en = "Health Stay Time"
  },
  health_stay_time_description = {
    en = "Amount of time, in seconds, that current health is displayed when receiving health damage.\nSet to 0 to disable."
  },
  health_hide_at_full = {
    en = "Hide at Full Health"
  },
  health_hide_at_full_description = {
    en = "Hides the display when health is at 100%."
  },

  options_toughness = {
    en = "Toughness Settings"
  },
  toughness_always_show = {
    en = "Always Show Toughness"
  },
  toughness_always_show_description = {
    en = "Always display current toughness, regardless of other toughness visibility settings."
  },
  toughness_stay_time = {
    en = "Toughness Stay Time"
  },
  toughness_stay_time_description = {
    en = "Amount of time, in seconds, that current toughness is displayed when receiving toughness damage.\nSet to 0 to disable."
  },
  toughness_hide_at_full = {
    en = "Hide at Full Toughness"
  },
  toughness_hide_at_full_description = {
    en = "Hides the display when toughness is at 100%."
  },

  options_coherency = {
    en = "Coherency Settings"
  },
  coherency_type = {
    en = "Coherency Indicator"
  },
  coherency_type_description = {
    en = "Sets the indicator type for each teammate in coherency:"
        .. "\n{#color(255,180,0)}Simple{#reset()}: Plus (+) symbol"
        .. "\n{#color(255,180,0)}Archetype{#reset()}: Archetype (subclass) symbol"
        .. "\n{#color(255,180,0)}Aura{#reset()}: Icon representing the buff provided"
        .. "\n{#color(255,180,0)}Off{#reset()}: No coherency display"
  },
  coherency_type_simple = {
    en = "Simple"
  },
  coherency_type_simple_description = {
    en = "Plus (+) symbol"
  },
  coherency_type_archetype = {
    en = "Archetype"
  },
  coherency_type_archetype_description = {
    en = "Archetype (subclass) symbol"
  },
  coherency_type_aura = {
    en = "Aura"
  },
  coherency_type_aura_description = {
    en = "Icon representing the buff provided"
  },
  coherency_type_archetype = {
    en = "Archetype"
  },
  coherency_type_off = {
    en = "Off"
  },
  coherency_colors = {
    en = "Indicator Colors"
  },
  coherency_colors_teammate = {
    en = "Teammate Color"
  },
  coherency_colors_health = {
    en = "Teammate Health"
  },
  coherency_colors_toughness = {
    en = "Teammate Toughness"
  },
  coherency_colors_static = {
    en = "Static Color"
  },

  options_ability_cooldown = {
    en = "Ability Settings"
  },
  display_ability_cooldown = {
    en = "Display Ability Indicator"
  },
  ability_cooldown_threshold = {
    en = "Cooldown Timer Threshold"
  },
  ability_cooldown_threshold_description = {
    en = "Amount of time remaining, in seconds, on ability cooldown before the timer will display."
        .. "\nSet to 0 to disable."
  },

  options_ammo = {
    en = "Ammo Settings"
  },
  display_ammo_indicator = {
    en = "Display Ammo Indicator"
  },

  options_reload = {
    en = "Reload Settings"
  },
  display_reload_indicator = {
    en = "Display Reload Indicator"
  },
  only_during_reload = {
    en = "Only During Reload"
  },
  only_during_reload_description = {
    en = "Only show the indicator while actively reloading."
        .. "\nDisabling this can help when customizing position."
  },

  custom_threshold_full = {
    en = "Full Threshold Color"
  },
  custom_threshold_high = {
    en = "High Threshold Color"
  },
  custom_threshold_low = {
    en = "Low Threshold Color"
  },
  custom_threshold_empty = {
    en = "Empty Threshold Color"
  },

  red = {
    en = "Red"
  },
  green = {
    en = "Green"
  },
  blue = {
    en = "Blue"
  },

  options_global = {
    en = "Miscellaneous"
  },
  enable_shadows = {
    en = "Enable Shadows"
  },
  enable_shadows_description = {
    en = "Toggles text and icon shadows."
  },

}