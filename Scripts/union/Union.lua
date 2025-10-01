-- Union.lua
local Union = {}
local UEHelpers = require("UEHelpers")

Union.Text          = require("Union.UnionText")
Union.Racer         = require("Union.UnionRacer")
Union.Math          = require("Union.UnionMath")
Union.Structures    = require("Union.UnionStructures")
Union.Localisation  = require("Union.UnionLocalisation")

local script_version = "Crossworld Hub Beta ver. 0.01.01"

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
    return CacheDefaultObject("/Script/UNION.Default__AppRaceConfigDataAccessor", "Union_AppRaceConfigDataAccessor", ForceInvalidateCache)
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

function Union.GetLanguageSetting()
    local loclibrary = Union.GetLocalizationFunctionLibrary()
    return loclibrary:GetTextLang()
end

function Union.UnionGetAvailableStages() 
    local appraceconfig = Union.GetAppRaceConfigDataAccessor()
    return appraceconfig:GetSelectedStageSettings()
end

function Union.IsPlayingOnline()
    local appmenudata = Union.GetAppMenuDataAccessor()
    return appmenudata:GetSelectedTopMenuPlayMode() == 2
end

function Union.GetCurrentStage(fromunionplayer)
    local status = fromunionplayer.RacerStatus
    
    local domainindex = nil
    if status.CurrentDomainIndex == 255 then
        domainindex = 0
    else
        domainindex = status.CurrentDomainIndex
    end
    
    local loadedlevels = Union.UnionGetAvailableStages()
    return loadedlevels[domainindex + 1]:get()
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
    if Union.GetDiscordState() ~= Union.DiscordStates.Race then
        return nil
    end
    
    local playervehicle = Union.GetPlayerVehicleInPawn()
    racermap = Union.GetUnionRacers().RacerMap
    racermap:ForEach(function(i, wracer)
        local racer = wracer:get()
        if racer.Vehicle:IsValid() then
            if playervehicle:GetFullName() == racer.Vehicle:GetFullName() then
                return racer
            end
        end
    end)
    
    return nil
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
        return Union.DiscordStates.Unknown
    end

    -- Normalize against known levels
    for _, level in pairs(Union.DiscordStates) do
        if match == level then
            return level
        end
    end

    return Union.DiscordStates.Unknown
end

return Union
