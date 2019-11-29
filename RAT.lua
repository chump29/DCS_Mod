-- TODO: on/off menu
-- RAT:_Destroy(group)

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

		local plane = RAT:New(name, string.format("%s-%i", name, count))
		plane:ATC_Messages(false)
		plane:Commute(false)
		plane:Livery(liveries[name])
		plane:RespawnAfterCrashON()
		plane:SetAISkill("Random")
		plane:SetCoalitionAircraft("blue")
		plane:SetDeparture(from)
		plane:SetDestination(to)
		plane:SetFL(mist.random(10, 50))
		plane:SetROT("evade")
		plane:SetSpawnDelay(mist.random(10, 30))
		plane:SetSpawnInterval(mist.random(30, 60))
		plane:SetTakeoffCold()
		plane:StatusReports(false)
		if not plane:Spawn() then env.info("RAT: Failed to spawn " .. name) end
	end

	liveries["RAT_Yak"] = {"Bare_Metall", "DOSAAF_RF", "DOSAAF_USSR", "Pobeda", "The First Flight", "The Yakovlevs"}
	liveries["RAT_CE2"] = {"C-FTIJ", "G-KLAW", "LV-X352", "MAG3", "N2FC", "N8EC", "N14KH", "N22XS", "N24AL", "N31PA", "N38RC", "N49AE", "N56CE", "N78JP", "N83FC", "N83TS", "N104GF", "N229HP", "N828DM", "NX110GM", "Top Gun F-14A", "Top Gun MiG-28", "TrackIR", "VARS", "Virtual Vultures", "WW1 Red Baron", "WW1 SE5a"}
	liveries["RAT_Cessna"] = {"D-EKVW", "Muster", "N9572H", "SEagle blue", "SEagle red", "USAF-Academy", "V5-BUG", "VH-JGA"}
	liveries["RAT_A320"] = {"Air Moldova", "American Airlines", "Cebu Pacific", "Delta Airlines", "Eurowings BVB09", "Eurowings Europa Park D", "Easy Jet Berlin", "Frontier", "jetBlue FDNY", "Jet Blue NY", "WOW"}

	-- Spawn @ Batumi
	for _ = 1, 2 do
		fromBatumi("RAT_Yak")
		fromBatumi("RAT_CE2")
	end
	for _ = 1, 3 do
		fromBatumi("RAT_Cessna")
		fromBatumi("RAT_A320")
	end

	-- Spawn @ Kobuleti
	for _ = 1, 2 do
		fromKobuleti("RAT_Yak")
		fromKobuleti("RAT_CE2")
	end
	for _ = 1, 3 do
		fromKobuleti("RAT_Cessna")
		fromKobuleti("RAT_A320")
	end
end