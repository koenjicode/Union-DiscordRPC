
-- Helper Functionality
local Union = require("Union.Union")
local settings = require "settings"

-- Discord Rich Presence
local discordRPC = require("discord_rpc")

local current_discord_main_state = Union.DiscordStates.Menu
local current_discord_sub_state = Union.DiscordSubStates.None

local union_racer = nil
local union_stage = nil

local start_timestamp = 0

local current_language = "en"

local function print_test()
    union_racer = Union.GetPlayerUnionRacer()
    union_stage = Union.GetCurrentStage(union_racer)

    print(string.format("Union Racer: %s\n", union_racer:GetFullName()))

    
    local rawName = Union.Racer.GetDriverName(union_racer)
    local prettyName = Union.Text.ToTitleCase(rawName)

    print(string.format("Driver Name: %s\n", prettyName))

    print(string.format("Speed Class: %s\n", Union.GetSpeedClass()))
    print(string.format("Stage: %s\n", union_stage.StageId))
    print(string.format("Unlocked Super Sonic: %s\n", Union.HasUnlockedSuperSonic()))
end

local function get_activity_info()

    local state = nil
    local details = nil
    
    if current_discord_main_state == Union.DiscordStates.Menu then
        state = "Main Menu"
        if Union.IsPlayingOnline() then
            details = Union.Localisation.T("presence_menu_online")
        else
            details = Union.Localisation.T("presence_menu_offline")
        end
        
        print(details)
        return state, details
    end
    
    -- If we're in a race, get our Game Mode, and what we're doing.
    if current_discord_main_state == Union.DiscordStates.Race then
        local raw_gamemode = Union.GetSelectedGameMode()
        local gamemode = Union.Structures.GetGameModeAsEnumFromID(raw_gamemode)
        
        print(gamemode)
        
        state = "Game Mode"
        details = "Game Mode Detail Here"
        return state, details
    end
    
    state = "Waiting"
    details = ""
    return state, details
end


local function get_small_activity_image()
    local smallimagekey = ""
    local smallimagetext = ""
    
    -- Gets the last selected character directly from your save file.
    local lastselected_id = Union.GetLastSelectedCharacter()
    smallimagekey = Union.Structures.GetDriverAsEnumFromID(lastselected_id)

    local rawName = Union.GetDriverNameFromID(lastselected_id)
    local prettyName = Union.Text.ToTitleCase(rawName)
    
    smallimagetext = prettyName
    
    --[[
    
    if current_discord_main_state == Union.DiscordStates.Race then
        local player_char = Union.GetPlayerUnionRacer()
        
        if player_char:IsValid() then
            local raw_driverid = Union.Racer.GetDriverID(player_char, true)
            smallimagekey = Union.Structures.GetDriverAsEnumFromID(raw_driverid)
            smallimagetext = Union.Racer.GetDriverName(player_char)

            return smallimagekey, smallimagetext
        end
    end
    
    ]]
    
    -- Return empty if we don't have any character info.
    return smallimagekey, smallimagetext
end

local function get_large_activity_image()
    local largeimagekey = ""
    local largeimagetext = ""
    
    -- Show the course icon with its name translated.
    if current_discord_main_state == Union.DiscordStates.Race then
        local current_stage = Union.GetCurrentStage(Union.GetPlayerUnionRacer())

        largeimagekey = Union.Structures.GetStageAsEnumFromID(current_stage.StageId)
        largeimagetext = Union.GetStageName(current_stage.StageId)
        return largeimagekey, largeimagetext
    end
    
    -- If we're not on a course, lets show our default image instead.
    if settings.miku_miku_mode then
        largeimagekey = "main3"
    else
        if Union.HasUnlockedSuperSonic() then
            largeimagekey = "main2"
        else
            largeimagekey = "main"
        end
    end
    
    -- Default to using Discord Version here.
    largeimagetext = Union.GetUnionDiscordVersion()
    return largeimagekey, largeimagetext
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


local function set_discord_substate(sub_state)
    current_discord_sub_state = sub_state
end

-- Puts a timestamp based on the users system clock.
local function start_timestamp()
    start_timestamp = os.time()
    return
end

-- Removes the placed timestamp.
local function end_timestamp()
    start_timestamp = 0
    return
end

local function update_rich_presence()

    if not discord_initalised then
        return
    end

    update_discord_state()

    local current_state, current_details = get_activity_info()
    local current_largeimagekey, current_largeimagetext = get_large_activity_image()
    local current_smallimagekey, current_smallimagetext = get_small_activity_image()
    local current_partyid, current_partysize, current_partymax = get_party_info()
     
    discordRPC.updatePresence({
        state = current_state,
        details = current_details,
        startTimestamp = start_timestamp,
        endTimestamp = 0,
        largeImageKey = current_largeimagekey,
        largeImageText = current_largeimagetext,
        smallImageKey = current_smallimagekey,
        smallImageText = current_smallimagetext,
        partyId = current_partyid,
        partySize = current_partysize,
        partyMax = current_partymax,
    })
    discordRPC.runCallbacks()
   
end

local function init()
    print(discordRPC._VERSION)
    discordRPC.initialize(1411894625878413392, false, 2486820)
    discord_initalised = true
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    set_discord_substate(Union.DiscordSubStates.None)
end)

RegisterHook("Function /Script/UNION.RaceSequenceStateReady:StartRace", function(Context)
    start_timestamp()
    update_rich_presence()
end)

init()

RegisterKeyBind(Key.F9, update_rich_presence)