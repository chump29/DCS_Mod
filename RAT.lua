--[[
-- Random Air Traffic
-- by Chump
--]]

RATPlanes = {
	debug = false,
	planes = {
		{"F-117A", "RAT_F117", 2},
		{"Ju 88", "RAT_Ju88", 2},
		{"Osprey", "RAT_Osprey", 2},
		{"Cessna", "RAT_Cessna"},
		{"A-320", "RAT_A320", 2}
	},
	zones = {
		"RAT_1",
		"RAT_2",
		"RAT_3"
	},
	from = "Kobuleti",
	to = nil
}

do

	local failMsg = " must be loaded prior to this script!"
	local assert = _G.assert
	assert(allSkins ~= nil, "allSkins" .. failMsg)
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local ipairs = _G.ipairs
	local string = _G.string
	local table = _G.table

	local count = 0

	local function CreatePlane(obj, from, to)
		local debug = RATPlanes.debug or false
		count = count + 1

		local max = obj[3] or mist.random(3)
		for num = 1, max do
			local alias = string.format("%s-%i-%i", obj[2], count, num)
			local plane = RAT:New(obj[2], alias)
			plane:ATC_Messages(false)
			plane:Commute(false)
			plane:ContinueJourney()
			plane:Invisible()

			local planeType = allSkins.liveries[string.upper(obj[1])]
			if planeType and #planeType > 0 then
				local livery = planeType[mist.random(#planeType)]
				if debug then env.info("RAT: " .. alias .. " using livery " .. livery) end
				plane:Livery(livery)
			end

			plane:RadioOFF()
			plane:RespawnAfterCrashON()
			plane:RespawnInAirNotAllowed()
			plane:SetAISkill("Random")
			plane:SetCoalitionAircraft("blue")
			plane:SetDeparture(from)

			if to then
				plane:SetDestination(to)
			elseif #RATPlanes.zones > 0 then
				plane:DestinationZone()
				plane:SetDestination(RATPlanes.zones)
			end

			plane:SetFL(mist.random(10, 100))
			plane:SetROT("evade")
			plane:SetSpawnDelay(mist.random(10, 30))
			plane:SetSpawnInterval(mist.random(30, 60))
			plane:SetTakeoffCold()
			plane:StatusReports(false)
			plane:TimeDestroyInactive(300)
			if not plane:Spawn() then
				env.info("RAT: Failed to spawn " .. alias)
				return
			end

			if not RATPlanes.spawned then RATPlanes.spawned = {} end
			table.insert(RATPlanes.spawned, {[alias] = plane})

			if debug then env.info(string.format("RAT: Spawning %s - %s > %s", obj[1], from, to or "Zone"))	end
		end
	end

	local function countArray(arr)
		local count = 0
		for _, _ in pairs(arr) do
			count = count + 1
		end
		return count
	end

	if not RATPlanes.planes or #RATPlanes.planes == 0 then
		env.info("RAT: No planes to spawn!")
		return
	end

	for _, plane in ipairs(RATPlanes.planes) do
		if RATPlanes.from then
			if Airbase.getByName(RATPlanes.from) then
				if RATPlanes.to and not Airbase.getByName(RATPlanes.to) then
					RATPlanes.to = nil
					env.info(string.format("RAT: Airbase %s not found!", RATPlanes.to))
					return
				end
				CreatePlane(plane, RATPlanes.from, RATPlanes.to)
			else
				env.info(string.format("RAT: Airbase %s not found!", RATPlanes.from))
				return
			end
		else
			env.info("RAT: Starting airbase not found!")
			return
		end
	end

	env.info("RAT is running.")

end
