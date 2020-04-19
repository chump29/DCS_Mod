--[[
-- ATIS
-- by Chump
--]]

do
	local base = _G
	local assert = base.assert
	local dofile = base.dofile
	local ipairs = base.ipairs
	local next = base.next
	local string = base.string
	local require = base.require

	local failMsg = " must be loaded prior to this script!"
	assert(ATIS ~= nil, "MOOSE" .. failMsg)
	assert(require ~= nil, "REQUIRE" .. failMsg)

	local freqs = {}

	dofile(string.format("./Mods/terrains/%s/Radio.lua", env.mission.theatre))
	if not radio then
		env.info("ATIS: Could not load radio frequencies!")
		return
	end
	for _, obj in ipairs(radio) do
		if next(obj.frequency) ~= nil then
			local freq = obj.frequency[VHF_HI][2]
			if freq >= 116000000 and freq <= 149900000 then
				freqs[obj.radioId] = freq
			end
		end
	end
	radio = nil

	local function GetFreq(id)
		local freq
		if next(freqs) ~= nil then
			local key = string.format("airfield%i_0", id)
			freq = (freqs[key] + 50000) / 1000000
		end
		return freq
	end

	for _, airbase in ipairs(coalition.getAirbases(coalition.side.BLUE)) do
		if airbase:getDesc().category == Airbase.Category.AIRDROME then
			local callsign = airbase:getCallsign()
			local name = "ATIS_" .. callsign
			if Unit.getByName(name) then
				local obj = ATIS:New(callsign, GetFreq(airbase:getID()))
				obj:SetSoundfilesPath("ATIS/")
				obj:SetRadioRelayUnitName(name)
				obj:Start()
			end
		end
	end

	env.info("ATIS is broadcasting.")
end