return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`psych_ward` encountered an error loading the Darktide Mod Framework.")

        new_mod("psych_ward", {
            mod_script       = "psych_ward/scripts/mods/psych_ward/psych_ward",
            mod_data         = "psych_ward/scripts/mods/psych_ward/psych_ward_data",
            mod_localization = "psych_ward/scripts/mods/psych_ward/psych_ward_localization",
        })
    end,
    packages = {}
}