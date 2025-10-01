local _mod_config = {
    -- Miku Miku Mode!!
    -- Default: false :(
    miku_miku_mode = false,
    
    -- EXPERIMENTAL MAY CRASH: Whether or not the game will discord to update asynchorously.
    -- This has the benefits of broadcasting the current crossworld your in at the cost of extra performance.
    -- Default: true
    allow_async_race_updates = true,
    
    -- You can adjust the frequency of Race Updates. You can lower this to save up on performance.
    -- Keep in mind, discord has a rate limits of 5 updates per 20 seconds.
    -- Default: 4000
    race_update_frequency = 4000,
}

return _mod_config