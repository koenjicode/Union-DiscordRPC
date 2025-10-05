local Union = {}
local UEHelpers = require("UEHelpers")

Union.Text          = require("Union.UnionText")
Union.Racer         = require("Union.UnionRacer")
Union.Math          = require("Union.UnionMath")
Union.Structures    = require("Union.UnionStructures")
Union.Localisation  = require("Union.UnionLocalisation")

local script_version = "ver. 0.02.00"

-- A table for all the key level states.
Union.DiscordLevelStates = {
    Menu = "PL_Menu",
    Race = "PL_Race",
    PreRace = "PL_PreRace",
    Unknown = "Unknown"
}

-- Menu states, they're not really being used right now but will be useful at a later date (hopefully)
Union.DiscordMenuStates = {
    None = 0,
    CustomizeGadgets = 1,
    CourseSelect = 2,
    Jukebox = 3,
    Boot = 4,
}

-- Stages that we should not display a name for. They  just dont have any names.
Union.BlacklistedStages = {
    STG1901 = true,
}

-- Generic validity check to see if an object is still accessible.
function Union.IsValidObject(obj)
    if not obj or not obj:IsValid() then
        return false
    end

    return true
end

-- Checks if Discord Rich Presence actually has made a change.
function Union.HasPresenceChanged(old, new)
    -- Covers first time runs.
    if old == nil then
        return true
    end

    for key, value in pairs(new) do
        if old[key] ~= value then
            return true
        end
    end

    -- Also check if old has any extra keys not in new.
    for key in pairs(old) do
        if new[key] == nil then
            return true
        end
    end

    return false
end

-- The current script version of the mod.
function Union.GetUnionDiscordVersion()
    return Union.Localisation.T("presence_uniondiscord", script_version)
end

-- Blacklisted stages will show up
function Union.IsStageBlacklisted(stage_id)
    return Union.BlacklistedStages[stage_id] or false
end

-- Grabbed from UEHelpers.lua
local function CacheDefaultObject(ObjectFullName, VariableName, ForceInvalidateCache)
    local obj = nil
    if not ForceInvalidateCache then
        obj = ModRef:GetSharedVariable(VariableName)
        if obj and obj:IsValid() then
            return obj
        end
    end
    obj = StaticFindObject(ObjectFullName)
    ModRef:SetSharedVariable(VariableName, obj)
    return obj
end

function Union.GetPersistentLevel()
    return UEHelpers.GetPersistentLevel()
end

function Union.GetKismetSystemLibrary()
    return UEHelpers.GetKismetSystemLibrary()
end

function Union.GetKismetTextLibrary()
    return UEHelpers.GetKismetTextLibrary()
end

function Union.GetKismetMapLibrary(ForceInvalidateCache)
    return CacheDefaultObject("/Script/Engine.Default__KismetMapLibrary", "Union_KismetArrayLibrary", ForceInvalidateCache)
end

function Union.GetDriverDataUtilityLibrary(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UNION.Default__DriverDataUtilityLibrary", "Union_DriverDataUtilityLibrary", ForceInvalidateCache)
end

function Union.GetAppSaveGameHelper(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UnionSystem.Default__AppSaveGameHelper", "Union_AppSaveGameHelper", ForceInvalidateCache)
end

function Union.GetDataTableFunctionLibrary(ForceInvalidateCache)
    return CacheDefaultObject("/Script/Engine.Default__DataTableFunctionLibrary", "Union_DataTableFunctionLibrary", ForceInvalidateCache)
end

function Union.GetLocalizationFunctionLibrary(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UnionSystem.Default__LocalizationFunctionLibrary", "Union_LocalizationFunctionLibrary", ForceInvalidateCache)
end

function Union.GetAppMenuDataAccessor(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UNION.Default__AppMenuDataAccessor", "Union_AppMenuDataAccessor", ForceInvalidateCache)
end

function Union.GetAppRaceConfigDataAccessor(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UNION.Default__AppRaceConfigDataAccessor", "Union_AppRaceConfigDataAccessor",
        ForceInvalidateCache)
end

function Union.GetPauseManager(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UnionRun.Default__PauseManager", "Union_PauseManager", ForceInvalidateCache)
end

function Union.GetSaveDataManageSubsystem(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UnionSystem.Default__SaveDataManageSubsystem", "Union_SaveDataManageSubsystem", ForceInvalidateCache)
end

function Union.GetUnionRacerFunction(ForceInvalidateCache)
    return CacheDefaultObject("/Script/UnionRun.Default__UnionRacerFunction", "Union_UnionRacerFunction", ForceInvalidateCache)
end

function Union.HasUnlockedSuperSonic()
    local appmenu = Union.GetAppMenuDataAccessor()
    return appmenu:GetTitleVisualId() == 1
end

function Union.IsGamePaused()
    local gameplay_statics = UEHelpers.GetGameplayStatics()
    return gameplay_statics:IsGamePaused(UEHelpers.GetWorld())
end

function Union.GetLanguageSetting()
    local loclibrary = Union.GetLocalizationFunctionLibrary()
    return loclibrary:GetTextLang()
end

function Union.GetAvailableStages() 
    local appraceconfig = Union.GetAppRaceConfigDataAccessor()
    return appraceconfig:GetSelectedStageSettings()
end

function Union.IsPlayingOnline()
    local appmenudata = Union.GetAppMenuDataAccessor()
    return appmenudata:GetSelectedTopMenuPlayMode() == 2
end

function Union.GetCurrentStage()
    local loaded_levels = Union.GetAvailableStages()
    return loaded_levels[1]:get()
end

function Union.GetCurrentStageFromUnionRacer(unionracer)
    local status = unionracer.RacerStatus
    local loaded_levels = Union.GetAvailableStages()

    local domain_index = nil
    if status.CurrentDomainIndex == 255 then
        domain_index = 0
    else
        domain_index = status.CurrentDomainIndex
    end
    
    return loaded_levels[domain_index + 1]:get()
end

function Union.GetSelectedGameMode()
    appracedata = Union.GetAppRaceConfigDataAccessor()
    return appracedata:GetSelectedGameModeId()
end

function Union.GetAppSaveGame()
    local savegame = Union.GetSaveDataManageSubsystem()
    return savegame._AppSaveGame
end

function Union.GetUnionRacers()
    local unionracerfunction = Union.GetUnionRacerFunction()
    return unionracerfunction:GetUnionRacers()
end

function Union.GetSpeedClass()
    appracedata = Union.GetAppRaceConfigDataAccessor()
    return appracedata:GetRaceSettingSpeedClass()
end

function Union.GetPlayerVehicleInPawn()
    return UEHelpers.GetPlayer()
end

function Union.GetPlayerUnionRacer()
    if Union.GetDiscordState() ~= Union.DiscordLevelStates.Race then
        print("Player is not in an environment where a Player character can be connected to.")
        return nil
    end

    local player_vehicle = Union.GetPlayerVehicleInPawn()
    if not Union.IsValidObject(player_vehicle) then
        print("Player Pawn cannot be found, will skip checking for a player character.")
        return nil
    end

    racer_map = Union.GetUnionRacers().RacerMap
    if not racer_map:IsValid() then
        print("No racer map has been built at this current stage, skipping.")
        return nil
    end
    
    found_racer = nil
    racer_map:ForEach(function(i, wracer)
        local racer = wracer:get()
        if racer.Vehicle:IsValid() then
            if player_vehicle:GetFullName() == racer.Vehicle:GetFullName() then
                found_racer = racer
                return true
            end
        end
    end)
    return found_racer
end

function Union.GetStageDataTable()
    local stagepath = "/Game/01_Union/Database/Stage/DataTable/CDT_StageDataAsset.CDT_StageDataAsset"
    return StaticFindObject(stagepath)
end

function Union.GetStageDataAssetByRowName(stageid)
    local stagetable = Union.GetStageDataTable()
    local rowname = "EStageID::" .. stageid
    return stagetable:FindRow(rowname)
end

function Union.GetStageName(stageid)
    local row = Union.GetStageDataAssetByRowName(stageid)
    return row.StageName
end

function Union.GetLastSelectedCharacter()
    local savegamehelper = Union.GetAppSaveGameHelper()
    local T = {}
    savegamehelper:GetUserCommonData(T)
    
    return T.SelectedDriverId
end

function Union.GetDriverNameFromID(driverid)
    local driverutility = Union.GetDriverDataUtilityLibrary()
    return driverutility.GetDriverNameText(driverid)
end

function Union.GetDiscordState()

    local persistentlevel = Union.GetPersistentLevel()
    local fullname = persistentlevel:GetFullName()
    
    -- Looks at the name of the Level between the '.' and ':PersistentLevel'
    local match = fullname:match("%.(.-):PersistentLevel")
    if not match then
        return Union.DiscordLevelStates.Unknown
    end

    -- Normalize against known levels
    for _, level in pairs(Union.DiscordLevelStates) do
        if match == level then
            return level
        end
    end

    return Union.DiscordLevelStates.Unknown
end

return Union
