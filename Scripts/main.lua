
-- Helper Functionality
local Union = require("Union.Union")
local settings = require "settings"

-- Discord Rich Presence
local discordRPC = require("discord_rpc")
local current_discord_main_state = Union.DiscordLevelStates.Menu

local start_timestamp = 0
local can_async_race_update = false
local is_beta_build = true

-- Puts a timestamp based on the users system clock.
local function start_timer()
    start_timestamp = os.time()
end

-- Removes the placed timestamp.
local function end_timer()
    start_timestamp = 0
end

local function get_menu_activity()
    state = Union.Localisation.T("presence_mainmenu")
    if Union.IsPlayingOnline() then
        details = Union.Localisation.T("presence_menu_online")
    else
        details = Union.Localisation.T("presence_menu_offline")
    end
    return state, details
end

local function get_race_activity()
    local raw_gamemode = Union.GetSelectedGameMode()
    local gamemode = Union.Structures.GetGameModeAsEnumFromID(raw_gamemode)
    
    state = Union.Localisation.GetGameModeText(gamemode)
    
    -- If we finished a race, stop the timer, disable async updates, and display that we finished it on discord.
    if Union.Racer.HasFinishedRace(Union.GetPlayerUnionRacer()) then
        end_timer()
        can_async_race_update = false
        details = Union.Localisation.T("presence_finish")
    else
        local speed_class = Union.Structures.GetSpeedClassAsEnumFromID(Union.GetSpeedClass())
        details = Union.Localisation.T("presence_racing", Union.Localisation.GetSpeedClassText(speed_class))
    end
    
    return state, details
end

local function get_activity_info()
    -- If we're in a Menu, show what we're doing!
    -- BETA NOTE: For the beta release, we'll disable live updates for now, but it won't always be like this.
    if not is_beta_build then
        if current_discord_main_state == Union.DiscordLevelStates.Menu then
            return get_menu_activity()
        end
    end
    
    -- If we're in a race, get our Game Mode, and what we're doing.
    if current_discord_main_state == Union.DiscordLevelStates.Race then
        return get_race_activity()
    end
    
    -- If we're unsure what the game mode is, we're just waiting. Don't show anything fancy!
    return "Waiting", ""
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
    -- BETA NOTE: At some point we'd want to keep track of this as we can get a direct reference to our selected character in menus.
    -- But for now we won't do so.
    if current_discord_main_state ~= Union.DiscordLevelStates.Race then
        if is_beta_build then
            return "", ""
        end
    end
    
    return get_race_activity_smallimage()
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
    -- Different racers can be in different domains, so we grab the current stage based on our current character.
    local current_stage = Union.GetCurrentStage(Union.GetPlayerUnionRacer())
    local stage_as_enum = Union.Structures.GetStageAsEnumFromID(current_stage.StageId)
    -- Discord is mean to us if we don't convert this to be lower ):
    largeimagekey = string.lower(stage_as_enum)

    -- Some maps don't actually have a name so we don't display anything if we hover over them, lets opt for a name that conjures mystery.
    if  Union.Structures.IsStageBlacklisted(stage_as_enum) then
        return largeimagekey, "???"
    else
        local rawName = Union.GetStageName(stage_as_enum)
        local prettyName = Union.Text.ToTitleCase(rawName)
        return largeimagekey, prettyName
    end
end

local function get_large_activity_image()
    -- If we're in a race, show the image of the stage we're on.
    if current_discord_main_state == Union.DiscordLevelStates.Race then
        get_race_activity_largeimage()
    end
    
    -- Outside of races, show the default large activity image.
    return get_default_activity_largeimage()
end

-- Get Party info
local function get_party_info()
    local party_id = 0
    local party_size = 1
    local party_max = 1

    if Union.IsPlayingOnline() then
        -- TODO: Check the game mode and adjust the size based on how many players are present.
    end
    
    return party_id, party_size, party_max
end

local function update_discord_state()
    current_discord_main_state = Union.GetDiscordState()
end

local function update_rich_presence()
    if not discord_initalised then
        return
    end

    update_discord_state()

    local current_state, current_details = get_activity_info()
    local current_largeimagekey, current_largeimagetext = get_large_activity_image()
    local current_smallimagekey, current_smallimagetext = get_small_activity_image()
    -- local current_partyid, current_partysize, current_partymax = get_party_info()
     
    discordRPC.updatePresence({
        state = current_state,
        details = current_details,
        startTimestamp = start_timestamp,
        endTimestamp = 0,
        largeImageKey = current_largeimagekey,
        largeImageText = current_largeimagetext,
        smallImageKey = current_smallimagekey,
        smallImageText = current_smallimagetext,
        -- partyId = current_partyid,
        -- partySize = current_partysize,
        -- partyMax = current_partymax,
    })
    discordRPC.runCallbacks()
    print("Discord Callback made.")
   
end

local function init()
    print(discordRPC._VERSION)
    discordRPC.initialize(1411894625878413392, false, 2486820)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    can_async_race_update = false
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

RegisterKeyBind(Key.F9, update_rich_presence)