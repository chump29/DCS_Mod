-- TODO: on/off menu

RATPlanes = {
	debug = false,
	paths = { -- NOTE: path MUST end in slash
		lfs.currentdir() .. "Bazar\\Liveries\\",
		lfs.writedir() .. "Mods\\aircraft\\Civil Aircraft Mod\\Liveries\\",
		"D:\\DCS.Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\Christen Eagle II\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\Yak-52\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\C-101\\Liveries\\"
	},
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
	for k, v in ipairs({[mist] = "MiST", [RAT] = "MOOSE"}) do assert(k ~= nil, v .. " must be loaded prior to this script!") end
	local lfs = require("lfs")

	function RATPlanes.getLiveries(path)
		if RATPlanes.debug then env.info("RAT: Scanning " .. path) end
		if not RATPlanes.liveries then RATPlanes.liveries = {} end
		local function invalid(obj) return obj == nil or obj == "." or obj == ".." end
		for airframe in lfs.dir(path) do
			if not invalid(airframe) and lfs.attributes(path .. airframe, "mode") == "directory" then
				for livery in lfs.dir(path .. airframe) do
					if not invalid(livery) and lfs.attributes(path .. airframe .. "\\" .. livery, "mode") == "directory" then
						if not RATPlanes.liveries[airframe] then RATPlanes.liveries[airframe] = {} end
						table.insert(RATPlanes.liveries[airframe], livery)
						if RATPlanes.debug then env.info("RAT: Inserted " .. livery .. " for " .. airframe) end
					end
				end
			end
		end
	end

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

			if RATPlanes.liveries[obj[1]] and #RATPlanes.liveries[obj[1]] > 0 then
				local livery = RATPlanes.liveries[obj[1]][mist.random(#RATPlanes.liveries[obj[1]])]
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

		for _, path in ipairs(RATPlanes.paths) do
			RATPlanes.getLiveries(path)
		end

		for _, plane in ipairs(RATPlanes.planes) do
			fromBatumi(plane)
			fromKobuleti(plane)
		end

		RATPlanes.showVersion()
	end

	function RATPlanes.showVersion()

		--[[ Changelog
			1.0 - Initial release
		--]]

		RATPlanes.version = {}
		RATPlanes.version.major = 1
		RATPlanes.version.minor = 0 -- including revision
		env.info(string.format("RAT: v%i.%g is running.", RATPlanes.version.major, RATPlanes.version.minor))
	end

	RATPlanes.init()
end