
-- Helper Functionality
local Union = require("Union.Union")
local settings = require "settings"

-- Discord Rich Presence
local discordRPC = require("discord_rpc")

local current_discord_main_state = Union.DiscordStates.Menu
local current_discord_sub_state = Union.DiscordSubStates.None

local start_timestamp = 0
local can_async_race_update = false

local function get_activity_info()

    local state = nil
    local details = nil
    
    if current_discord_main_state == Union.DiscordStates.Menu then
        state = Union.Localisation.T("presence_mainmenu")
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
        state = Union.Localisation.GetGameModeText(gamemode)
        
        local speed_class = Union.Structures.GetSpeedClassAsEnumFromID(Union.GetSpeedClass())
        details = Union.Localisation.T("presence_racing", Union.Localisation.GetSpeedClassText(speed_class))
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
    local selected_as_enum = Union.Structures.GetDriverAsEnumFromID(lastselected_id)
    smallimagekey = string.lower(selected_as_enum)

    local rawName = Union.GetDriverNameFromID(lastselected_id)
    local prettyName = Union.Text.ToTitleCase(rawName)
    
    smallimagetext = prettyName
    return smallimagekey, smallimagetext
end

local function get_large_activity_image()
    local largeimagekey = ""
    local largeimagetext = ""
    
    -- Show the course icon with its name translated.
    if current_discord_main_state == Union.DiscordStates.Race then
        local current_stage = Union.GetCurrentStage(Union.GetPlayerUnionRacer())
        local stage_as_enum = Union.Structures.GetStageAsEnumFromID(current_stage.StageId)
        
        largeimagekey = string.lower(stage_as_enum)
        
        local rawName = Union.GetStageName(stage_as_enum)
        local prettyName = Union.Text.ToTitleCase(rawName)
        
        largeimagetext = prettyName
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
local function start_timer()
    start_timestamp = os.time()
end

-- Removes the placed timestamp.
local function end_timer()
    start_timestamp = 0
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
    discord_initalised = true

    current_discord_sub_state = Union.DiscordSubStates.Boot
    update_rich_presence()
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    can_async_race_update = false
end)

RegisterHook("/Script/UNION.RaceSequenceStateReady:StartRace", function(Context)
    start_timer()
    update_rich_presence()
    
    can_async_race_update = true
end)



RegisterHook("/Script/UNION.CourseSelectWidgetBase:IsCourseSelecting", function(Context)
    print("Selecting a course.")
end)

--[[

RegisterHook("Function /Script/UNION.CharaMachineSelectsBase:OnPlayAnimationIn", function(Context)
    print("Is readying up.")
end)

]]

RegisterHook("/Script/UNION.RaceSequenceStateResult:UpdateResultData", function(Context)
    print("Game has been paused")
end)

-- Implement intro watching check.
--[[
NotifyOnNewObject("/Script/UNION.AdvertiseWidget", function(ConstructedObject)
    print(string.format("Constructed: %s\n", ConstructedObject:GetFullName()))
end)
]]


NotifyOnNewObject("/Script/UNION.TitleScene", function(ConstructedObject)
    current_discord_sub_state = Union.DiscordSubStates.None
    update_rich_presence()
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