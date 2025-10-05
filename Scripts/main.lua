
-- Helper Functionality
local Union = require("Union.Union")
local settings = require "settings"

-- Discord Rich Presence
local discordRPC = require("discord_rpc")
local current_discord_main_state = Union.DiscordLevelStates.Menu

local start_timestamp = 0
local can_async_race_update = false
local developer_mode = true

-- Puts a timestamp based on the users system clock.
local function start_timer()
    start_timestamp = os.time()
end

-- Removes the placed timestamp.
local function end_timer()
    start_timestamp = 0
end

local function get_menu_activity()
    -- Simplified for now, but update at a later date.
    state = Union.Localisation.T("presence_wait")
    return state, ""
end

local function get_race_activity()
    local raw_gamemode = Union.GetSelectedGameMode()
    local gamemode = Union.Structures.GetGameModeAsEnumFromID(raw_gamemode)

    state = Union.Localisation.GetGameModeText(gamemode)
    

    -- If we finished a race, stop the timer, disable async updates, and display that we finished it on discord.
    local player = Union.GetPlayerUnionRacer()
    if player and player:IsValid() then
        if Union.Racer.HasFinishedRace(player) then
            end_timer()
            can_async_race_update = false
            details = Union.Localisation.T("presence_finish")
            return state, details
        else
            local speed_class = Union.Structures.GetSpeedClassAsEnumFromID(Union.GetSpeedClass())
            details = Union.Localisation.T("presence_racing", Union.Localisation.GetSpeedClassText(speed_class))
            return state, details
        end
    end

    -- If we're in a state where we don't have a valid player character, we'll assume we're waiting on something.
    return state, Union.Localisation.GetWaiting()
end

local function get_activity_info()
    -- BETA NOTE: For the beta release, we'll disable live updates for now, but it won't always be like this.
    -- If we're in a race, get our Game Mode, and what we're doing.
    if current_discord_main_state == Union.DiscordLevelStates.Menu then
        return get_menu_activity()
    end

    if current_discord_main_state == Union.DiscordLevelStates.Race then
        return get_race_activity()
    end

    -- If we're unsure what the game mode is, we're just waiting. Don't show anything fancy!
    return Union.Localisation.GetWaiting(), ""
end

local function get_race_activity_smallimage()
    -- Gets the last selected character directly from your save file.
    local lastselected_id = Union.GetLastSelectedCharacter()
    local selected_as_enum = Union.Structures.GetDriverAsEnumFromID(lastselected_id)
    smallimagekey = string.lower(selected_as_enum)

    local rawName = Union.GetDriverNameFromID(lastselected_id)
    local prettyName = Union.Text.ToTitleCase(rawName)

    smallimagetext = prettyName
    return smallimagekey, smallimagetext
end

local function get_small_activity_image()
    if current_discord_main_state == Union.DiscordLevelStates.Race then
        return get_race_activity_smallimage()
    end

    return "", ""
end

local function get_default_activity_largeimage()
    local ver_info = Union.GetUnionDiscordVersion()
    -- Ready? Miku Miku Moooooooooode!
    if settings.miku_miku_mode then
        return "main3", ver_info
    end

    -- If Miku mode is disabled (shame on you), we check if Super Sonic is unlocked instead.
    local largeimagekey = nil
    if Union.HasUnlockedSuperSonic() then
        largeimagekey = "main2"
    else
        largeimagekey = "main"
    end

    return largeimagekey, ver_info
end

local function get_race_activity_largeimage()
    -- Usually we get the Player Union Racer to identify which domain we're in.
    -- But on client restart, we're not actually going to have this information. 
    -- We can still get the map in a different way, so we can still show that info to the player.
    local player = Union.GetPlayerUnionRacer()
    local stage = nil
    if Union.IsValidObject(player) then
        -- As mentioned, different racers can be on different domains.
        -- so we grab the current stage based on our current character.
        stage = Union.GetCurrentStageFromUnionRacer(Union.GetPlayerUnionRacer())
    else
        stage = Union.GetCurrentStage()
    end

    -- Discord is mean to us if we don't convert this to be lower ):
    local as_enum = Union.Structures.GetStageAsEnumFromID(stage.StageId)
    largeimagekey = string.lower(as_enum)

    -- Some maps don't actually have a name so we don't display anything if we hover over them.
    -- lets opt for a name that conjures mystery (mysssteeerry...).
    if  Union.IsStageBlacklisted(as_enum) then
        return largeimagekey, "???"
    else
        local rawName = Union.GetStageName(as_enum)
        local prettyName = Union.Text.ToTitleCase(rawName)
        return largeimagekey, prettyName
    end
end

local function get_large_activity_image()
    -- If we're in a race, show the image of the stage we're on.
    if current_discord_main_state == Union.DiscordLevelStates.Race then
        return get_race_activity_largeimage()
    end

    -- Outside of races, show the default large activity image.
    return get_default_activity_largeimage()
end

local function update_rich_presence()
    -- Update our discord main state, before we try and find info.
    current_discord_main_state = Union.GetDiscordState()

    -- Get all related discord information and then update our presence for everyone to see!
    local state, details = get_activity_info()
    local largeimagekey, largeimagetext = get_large_activity_image()
    local smallimagekey, smallimagetext = get_small_activity_image()

    discordRPC.updatePresence({
        state = state,
        details = details,
        startTimestamp = start_timestamp,
        endTimestamp = 0,
        largeImageKey = largeimagekey,
        largeImageText = largeimagetext,
        smallImageKey = smallimagekey,
        smallImageText = smallimagetext,
    })

    -- Display the changes on discord, and lets leave a callback note.
    discordRPC.runCallbacks()
    print(string.format("Discord Callback made: %s", os.date()))
end

local function init()
    -- Initalise discord, so we know that it's running.
    discordRPC.initialize(1411894625878413392, false, 2486820)
    print(string.format("Discord initalised, using %s", discordRPC._VERSION))
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    print("Client restarted, race check.")
    end_timer()
    can_async_race_update = false
    update_rich_presence()
end)

RegisterHook("/Script/UNION.RaceSequenceStateReady:StartRace", function(Context)
    start_timer()
    update_rich_presence()
    can_async_race_update = true
end)

init()

if settings.allow_async_race_updates then
    LoopAsync(settings.race_update_frequency, function()
        if can_async_race_update then
            update_rich_presence()
        end
        return false
    end)
end