do
	assert(RAT ~= nil, "MOOSE must be loaded prior to this script!")

	function fromKobuleti(name, liveries)
		createPlane(name, "Kobuleti", "Batumi", liveries)
	end

	function fromBatumi(name, liveries)
		createPlane(name, "Batumi", "Kobuleti", liveries)
	end

	function createPlane(name, from, to, liveries)
		local plane = RAT:New(name)
		plane:ATC_Messages(false)
		plane:Commute(false)
		plane:Livery(liveries)
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
		if not plane:Spawn(3) then env.info("RAT: Failed to spawn " .. name) end
	end

	-- Spawn @ Batumi
	fromBatumi("RAT_Yak", {"BARE METALL", "DOSAAF_RF", "DOSAAF_USSR", "POBEDA", "The First Flight (Aerobatic team)", "The Yakovlevs"})
	fromBatumi("RAT_CE2", {"C-FTIJ", "G-KLAW", "LV-X352", "MAG3", "N2FC", "N8EC", "N14KH", "N22XS", "N24AL", "N31PA", "N38RC", "N49AE", "N56CE", "N78JP", "N83FC", "N83TS", "N104GF", "N229HP", "N828DM", "NX110GM", "Top Gun F-14A", "Top Gun MiG-28", "TrackIR", "Virtual Air Racing Series", "Virtual Vultures", "WW1 Red Baron", "WW1 SE5a"})

	-- Spawn @ Kobuleti
	fromKobuleti("RAT_Cessna", {"D-EKVW", "Greece Army", "Muster", "N9572H", "Silver Eagle Blue", "Silver Eagle Red", "U.S.A.F Academy", "V5-BUG", "VH-JGA"})
	fromKobuleti("RAT_A320", {"Air Moldova ER-AXP", "American Airlines N9023N", "cebu pacific  RP-C4107", "Delta Airlines N377NW", "Eurowings BVB 09 D-AIZR", "Eurowings Europa Park D-ABDQ", "easyJet BERLIN OE-IZQ", "Frontier N308FR", "jetBlue FDNY N615JB", "jetBlue New York Jets", "WOW TF-NEO"})
end