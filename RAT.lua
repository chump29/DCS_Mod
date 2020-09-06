--[[
-- Random Air Traffic
-- by Chump
--]]

RATPlanes = {
	debug = false,
	planes = {
		{"Yak-52", "RAT_Yak"},
		{"Christen Eagle II", "RAT_CE2"},
		{"I-16", "RAT_I16"}
	},
	zones = {
		"RAT1",
		"RAT2",
		"RAT3"
	}
}

do

	local assert = _G.assert
	local ipairs = _G.ipairs
	local string = _G.string
	local table = _G.table

	local failMsg = " must be loaded prior to this script!"
	assert(allSkins ~= nil, "allSkins" .. failMsg)
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local count = 0

	local function CreatePlane(obj, from, to)
		local debug = RATPlanes.debug or false
		count = count + 1

		for num = 1, mist.random(3) do
			local alias = string.format("%s-%i-%i", obj[2], count, num)
			local plane = RAT:New(obj[2], alias)
			plane:ATC_Messages(false)
			plane:Commute(false)

			local planeType = allSkins.liveries[string.upper(obj[1])]
			if planeType and #planeType > 0 then
				local livery = planeType[mist.random(#planeType)]
				if debug then env.info("RAT: " .. alias .. " using livery " .. livery) end
				plane:Livery(livery)
			end

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

			if debug then env.info("RAT: Spawning " .. alias) end
		end
	end

	local function FromTo(obj, from, to)
		CreatePlane(obj, from, to)
		if debug then env.info(string.format("RAT: %s > %s", from, to or "Zone")) end
	end

	local function countArray(arr)
		local count = 0
		for _, _ in pairs(arr) do
			count = count + 1
		end
		return count
	end

	local function TurnOff()
		if not RATPlanes.isOn then return end
		for _, plane in pairs(RATPlanes.spawned) do
			plane:destroy()
		end
		RATPlanes.spawned = nil
		RATPlanes.isOn = false
		env.info("RAT: Turned off!")
	end

	if not RATPlanes.planes or #RATPlanes.planes == 0 then
		env.info("RAT: No planes to spawn!")
		return
	end

	local function TurnOn(obj)
		if RATPlanes.isOn then return end
		local fromMenu = obj.fromMenu or false
		for _, plane in ipairs(RATPlanes.planes) do
			FromTo(plane, "Kobuleti", nil)
		end
		RATPlanes.isOn = true
		if RATPlanes.debug and fromMenu then
			env.info("RAT: Turned on!")
		end
	end

	MENU_COALITION_COMMAND:New(BLUE, "RAT Off", nil, TurnOff)
	MENU_COALITION_COMMAND:New(BLUE, "RAT On", nil, TurnOn, {fromMenu = true})

	TurnOn()

	env.info("RAT is running.")

end
