--[[
-- ATIS
-- by Chump
--]]

-- TODO: create unit at specified/all/etc airbases

do
	local base = _G
	local assert = base.assert
	local dofile = base.dofile
	local ipairs = base.ipairs
	local math = base.math
	local next = base.next
	local pairs = base.pairs
	local require = base.require
	local string = base.string
	local table = base.table
	local tonumber = base.tonumber
	local tostring = base.tostring

	local failMsg = " must be loaded prior to this script!"
	assert(ATIS ~= nil, "MOOSE" .. failMsg)
	assert(require ~= nil, "REQUIRE" .. failMsg)

	local freqs = {}

	local function HzToMHz(freq)
		if not freq then return nil end
		return freq / 1000000
	end

	dofile(string.format("./Mods/terrains/%s/Radio.lua", env.mission.theatre))
	if not radio then
		env.info("ATIS: Could not load Radio data!")
		return
	end
	for _, obj in ipairs(radio) do
		if #obj.frequency > 0 then
			local vhf = obj.frequency[VHF_HI]
			if vhf and vhf[2] then
				local atisFreq = HzToMHz(vhf[2] + 50000)
				local ATCfreqs = {}
				for _, freqData in pairs(obj.frequency) do
					table.insert(ATCfreqs, HzToMHz(freqData[2]))
				end
				freqs[obj.radioId] = {atisFreq = atisFreq, ATCfreqs = ATCfreqs}
			end
		end
	end
	radio = nil

	if #freqs == 0 then
		env.info("ATIS: No frequency data found!")
		return
	end

	local function GetRunway(direction)
		local runway = tostring(math.abs(direction + 180))
		if string.len(runway) == 3 then
			return tonumber(string.sub(runway, 1, 2))
		end
		return tonumber(string.sub(runway, 1, 1))
	end

	local function GetObj(id)
		if id == -1 then return nil end
		return freqs[string.format("airfield%i_0", id)]
	end

	local FindWhat = {
		["ILS"] = 1,
		["NDB"] = 2,
		["PRMG"] = 3
	}

	local function FindMe(what, freq, isInner)
		isInner = isInner or false
		for _, obj in pairs(freqs) do
			if what == FindWhat.ILS then
				for _, ils in ipairs(obj.ils) do
					if ils.freq == freq then
						return true
					end
				end
			elseif what == FindWhat.NDB then
				for _, ndb in ipairs(obj.ndb) do
					if ndb.freq == freq and ndb.isInner = isInner then
						return true
					end
				end
			elseif what == FindWhat.PRMG then
				for _, prmg in ipairs(obj.prmg) do
					if prmg.channel == freq then
						return true
					end
				end
			end
		end
		return nil
	end

	dofile(string.format("./Mods/terrains/%s/Beacons.lua", env.mission.theatre))
	if not beacons then
		env.info("ATIS: Could not load Beacons data!")
		return
	end
	for _, beacon in ipairs(beacons) do
		if string.find(beacon.beaconId, "airfield") then
			local id = tonumber(string.match(beacon.beaconId, "airfield(%d+)_")) or -1
			local obj = GetObj(id)
			if obj then
				local freq = HzToMHz(beacon.frequency)
				if beacon.type == BEACON_TYPE_TACAN then
					obj.tacan_channel = beacon.channel
				elseif beacon.type == BEACON_TYPE_VOR then
					obj.vor_freq = freq
				elseif beacon.type == BEACON_TYPE_ILS_LOCALIZER and not FindMe(FindWhat.ILS, freq) then
					if not obj.ils then obj.ils = {} end
					table.insert(obj.ils, {freq = freq, runway = GetRunway(beacon.direction)})
				elseif beacon.type == BEACON_TYPE_ILS_NEAR_HOMER and not FindMe(FindWhat.NDB, freq, true) then
					if not obj.ndb then obj.ndb = {} end
					table.insert(obj.ndb, {freq = freq, runway = GetRunway(beacon.direction), isInner = true})
				elseif beacon.type == BEACON_TYPE_ILS_FAR_HOMER and not FindMe(FindWhat.NDB, freq) then
					if not obj.ndb then obj.ndb = {} end
					table.insert(obj.ndb, {freq = freq, runway = GetRunway(beacon.direction)})
				elseif beacon.type == BEACON_TYPE_PRMG_LOCALIZER and not FindMe(FindWhat.PRMG, beacon.channel) then
					if not obj.prmg then obj.prmg = {} end
					table.insert(obj.prmg, {channel = beacon.channel, runway = GetRunway(beacon.direction)})
				elseif beacon.type == BEACON_TYPE_RSBN then
					obj.rsbn_channel = beacon.channel
				end
			end
		end
	end
	beacons = nil

	for _, airbase in ipairs(coalition.getAirbases(coalition.side.BLUE)) do
		if airbase:getDesc().category == Airbase.Category.AIRDROME then
			local callsign = airbase:getCallsign()
			local name = "ATIS_" .. callsign
			if Unit.getByName(name) then
				local obj = GetObj(airbase:getID())
				if obj then
					local atis = ATIS:New(callsign, obj.atisFreq)
					atis:SetSoundfilesPath("ATIS/")
					atis:SetRadioRelayUnitName(name)
					if #obj.ATCfreqs > 0 then
						atis:SetTowerFrequencies(obj.ATCfreqs)
					end
					if obj.tacan_channel then
						atis:SetTACAN(obj.tacan_channel)
					end
					if obj.vor_freq then
						atis:SetVOR(obj.vor_freq)
					end
					if obj.ils then
						for _, ils in ipairs(obj.ils) do
							atis:AddILS(ils.freq, ils.runway)
						end
					end
					if obj.ndb then
						for _, ndb in ipairs(obj.ndb) do
							if ndb.isInner then
								atis:AddNDBinner(ndb.freq, ndb.runway)
							else
								atis:AddNDBouter(ndb.freq, ndb.runway)
							end
						end
					end
					if obj.prmg then
						for _, prmg in ipairs(obj.prmg) do
							atis:AddPRMG(prmg.channel, prmg.runway)
						end
					end
					if obj.rsbn_channel then
						atis:SetRSBN(obj.rsbn_channel)
					end
					atis:Start()
					env.info(string.format("ATIS: Broadcasting from %s on %.2f MHz", callsign, obj.atisFreq))
				end
			end
		end
	end
	airbases = nil
	freqs = nil
end