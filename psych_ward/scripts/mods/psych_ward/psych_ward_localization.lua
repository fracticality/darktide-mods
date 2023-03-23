local mod = get_mod("psych_ward")

mod:add_global_localize_strings({
  loc_toggle_view_buttons = {
    en = "Vendors"
  }
})

return {
  psych_ward = {
    en = "Psych Ward"
  },
  psych_ward_description = {
    en = "Enables traveling to the Psykhanium and viewing various vendors without traveling to the Hub."
  },
  enter_psykhanium = {
    en = "Shooting Range"
  },
  vendor_button= {
    en = "Armoury"
  },
  contracts_button = {
    en = "Contracts"
  },
  crafting_button = {
    en = "Crafting"
  },
  inventory_button = {
    en = "Inventory"
  }
}