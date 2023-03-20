return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`custom_hud` encountered an error loading the Darktide Mod Framework.")

        new_mod("custom_hud", {
            mod_script       = "custom_hud/scripts/mods/custom_hud/custom_hud",
            mod_data         = "custom_hud/scripts/mods/custom_hud/custom_hud_data",
            mod_localization = "custom_hud/scripts/mods/custom_hud/custom_hud_localization",
        })
    end,
    packages = {}
}