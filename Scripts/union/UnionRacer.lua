local UnionRacer = {}

local UnionMath = require("Union.UnionMath")
local UnionStructures = require("Union.UnionStructures")

local function IsValidUnionRacer(unionracer)
    if not unionracer or not unionracer:IsValid() then
        return false
    end
    
    return true
end

function UnionRacer.GetLapCount(unionracer)
    local status = unionracer.RacerStatus
    return UnionMath.Clamp(status.CurrentLapCount, 1, 3)
end

function UnionRacer.GetDriverID(unionracer, useoriginalid)
    local status = unionracer.RacerStatus
    local driverid = nil
    
    if useoriginalid then
        local objname = "/Script/UNION.Default__DriverDataUtilityLibrary"
        local obj = StaticFindObject(objname)
        
        driverid = obj.GetOriginalDriverId(status.DriverId)
        
    else
        driverid = status.DriverId
    end
    
    return driverid
end

function UnionRacer.GetRacePosition(unionracer)
    local situation = unionracer.RaceSituation
    return situation.Rank
end

function UnionRacer.GetDriverName(unionracer)
    local status = unionracer.RacerStatus
    return status:GetRacerName()
end

function UnionRacer.HasFinishedRace(unionracer)
    local status = unionracer.RacerStatus
    return status.bInGoal
end

return UnionRacer