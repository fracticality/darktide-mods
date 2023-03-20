return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`crosshair_hud` encountered an error loading the Darktide Mod Framework.")

        new_mod("crosshair_hud", {
            mod_script       = "crosshair_hud/scripts/mods/crosshair_hud/crosshair_hud",
            mod_data         = "crosshair_hud/scripts/mods/crosshair_hud/crosshair_hud_data",
            mod_localization = "crosshair_hud/scripts/mods/crosshair_hud/crosshair_hud_localization",
        })
    end,
    packages = {},
}
