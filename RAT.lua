do
	assert(RAT ~= nil, "MOOSE must be loaded prior to this script!")

	function fromKobuleti(name)
		createPlane(name, "Kobuleti", "Batumi")
	end

	function fromBatumi(name)
		createPlane(name, "Batumi", "Kobuleti")
	end

	function createPlane(name, from, to)
		local plane = RAT:New(name)
		plane:ATC_Messages(false)
		plane:Commute()
		plane:RadioFrequency(124)
		plane:RespawnAfterCrashON()
		plane:SetCoalitionAircraft("blue")
		plane:SetDeparture(from)
		plane:SetDestination(to)
		plane:SetFLmax(50)
		plane:SetROT("passive")
		plane:SetSpawnDelay(mist.random(10, 30))
		plane:SetSpawnInterval(mist.random(30, 60))
		plane:SetTakeoffCold()
		plane:StatusReports(true)
		if not plane:Spawn(3) then env.info("RAT: Failed to spawn " .. name) end
	end

	fromBatumi("RAT_Yak")
	fromBatumi("RAT_Cessna")

	fromKobuleti("RAT_C130")
	fromKobuleti("RAT_A380")
end