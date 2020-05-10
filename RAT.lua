--[[
-- Random Air Traffic
-- by Chump
--]]

-- TODO: on/off menu

local base = _G
local assert = base.assert
local ipairs = base.ipairs
local string = base.string
local table = base.table

RATPlanes = {
	debug = false,
	planes = {
		{"Yak-52", "RAT_Yak"},
		{"Christen Eagle II", "RAT_CE2"},
		{"Cessna_210N", "RAT_Cessna"}, -- Civil Aircraft Mod
		{"A_320", "RAT_A320"}, -- Civil Aircraft Mod
		{"C-101EB", "RAT_C101EB"},
		{"P-51D", "RAT_P51"}
	}
}

do
	local failMsg = " must be loaded prior to this script!"
	assert(mist ~= nil, "MiST" .. failMsg)
	assert(RAT ~= nil, "MOOSE" .. failMsg)
	assert(allSkins ~= nil, "allSkins" .. failMsg)

	function fromKobuleti(obj)
		createPlane(obj, "Kobuleti", "Batumi")
	end

	function fromBatumi(obj)
		createPlane(obj, "Batumi", "Kobuleti")
	end

	local count = 0

	function createPlane(obj, from, to)
		count = count + 1

		for num = 1, mist.random(3) do
			local alias = string.format("%s-%i-%i", obj[2], count, num)
			local plane = RAT:New(obj[2], alias)
			plane:ATC_Messages(false)
			plane:Commute(false)

			local planeType = allSkins.liveries[string.upper(obj[1])]
			if planeType and #planeType > 0 then
				local livery = planeType[mist.random(#planeType)]
				if RATPlanes.debug then env.info("RAT: " .. alias .. " using livery " .. livery) end
				plane:Livery(livery)
			end

			plane:RespawnAfterCrashON()
			plane:RespawnInAirNotAllowed()
			plane:SetAISkill("Random")
			plane:SetCoalitionAircraft("blue")
			plane:SetDeparture(from)
			plane:SetDestination(to)
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

			if RATPlanes.debug then env.info("RAT: Spawning " .. alias) end
		end
	end

--[[
	function destroyPlanes()
		for _, plane in RATPlanes.spawned do RAT:_Destroy(plane) end
	end
--]]

	function RATPlanes.init()
		if not RATPlanes.planes or #RATPlanes.planes == 0 then return end

		for _, plane in ipairs(RATPlanes.planes) do
			fromBatumi(plane)
			fromKobuleti(plane)
		end

		RATPlanes.showVersion()
	end

	function RATPlanes.showVersion()

		--[[ Changelog
			1.0 - Initial release
			1.1 - Moved allSkins to own object
		--]]

		RATPlanes.version = {}
		RATPlanes.version.major = 1
		RATPlanes.version.minor = 1 -- including revision
		env.info(string.format("RAT: v%i.%g is running.", RATPlanes.version.major, RATPlanes.version.minor))
	end

	RATPlanes.init()
end