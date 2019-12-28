-- TODO: on/off menu

--RATPlanes = {}

do
	for k, v in ipairs({[mist] = "MiST", [RAT] = "MOOSE"}) do assert(k ~= nil, v .. " must be loaded prior to this script!") end

	function fromKobuleti(name)
		createPlane(name, "Kobuleti", "Batumi")
	end

	function fromBatumi(name)
		createPlane(name, "Batumi", "Kobuleti")
	end

	local count = 0
	local liveries = {}

	function createPlane(name, from, to)
		count = count + 1

		for num = 1, mist.random(3) do
			local alias = string.format("%s-%i-%i", name, count, num)
			local plane = RAT:New(name, alias)
			plane:ATC_Messages(false)
			plane:Commute(false)
			plane:Livery(liveries[name])
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
			plane:TimeDestroyInactive(60)
			if not plane:Spawn() then
				env.info("RAT: Failed to spawn " .. name)
				return
			end

--			table.insert(RATPlanes, {[alias] = plane})
		end
	end

--[[
	function destroyPlanes()
		for _, plane in RATPlanes do RAT:_Destroy(plane) end
	end
--]]

	liveries["RAT_Yak"] = {"Bare_Metall", "DOSAAF_RF", "DOSAAF_USSR", "Pobeda", "The First Flight", "The Yakovlevs"}
	liveries["RAT_CE2"] = {"C-FTIJ", "G-KLAW", "LV-X352", "MAG3", "N2FC", "N8EC", "N14KH", "N22XS", "N24AL", "N31PA", "N38RC", "N49AE", "N56CE", "N78JP", "N83FC", "N83TS", "N104GF", "N229HP", "N828DM", "NX110GM", "Top Gun F-14A", "Top Gun MiG-28", "TrackIR", "VARS", "Virtual Vultures", "WW1 Red Baron", "WW1 SE5a"}
	liveries["RAT_Cessna"] = {"D-EKVW", "Muster", "N9572H", "SEagle blue", "SEagle red", "USAF-Academy", "V5-BUG", "VH-JGA"}
	liveries["RAT_A320"] = {"Air Moldova", "American Airlines", "Cebu Pacific", "Delta Airlines", "Eurowings BVB09", "Eurowings Europa Park D", "Easy Jet Berlin", "Frontier", "jetBlue FDNY", "Jet Blue NY", "WOW"}

	fromBatumi("RAT_Yak")
	fromBatumi("RAT_CE2")
	fromBatumi("RAT_Cessna")
	fromBatumi("RAT_A320")

	fromKobuleti("RAT_Yak")
	fromKobuleti("RAT_CE2")
	fromKobuleti("RAT_Cessna")
	fromKobuleti("RAT_A320")

	env.info("RAT: running!")
end