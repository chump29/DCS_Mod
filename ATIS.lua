--[[
-- ATIS
-- by Chump
--]]

local ATISfreqs = {}

do

	local assert = _G.assert
	local dofile = _G.dofile
	local ipairs = _G.ipairs
	local math = _G.math
	local next = _G.next
	local pairs = _G.pairs
	local require = _G.require
	local string = _G.string
	local table = _G.table
	local tonumber = _G.tonumber
	local tostring = _G.tostring

	local failMsg = " must be loaded prior to this script!"
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(require ~= nil, "REQUIRE" .. failMsg) -- for dofile()

	local frequency_add = 250000 -- in Hz

	local function HzToMHz(freq)
		if not freq then return nil end
		return freq / 1000000
	end

	local function CountArray(arr)
		local count = 0
		for _, _ in pairs(arr) do
			count = count + 1
		end
		return count
	end

	local oldRadio = radio
	dofile(string.format("./Mods/terrains/%s/Radio.lua", env.mission.theatre))
	if not radio then
		env.info("ATIS: Could not load Radio data!")
		return
	end
	for _, obj in ipairs(radio) do
		if CountArray(obj.frequency) > 0 then
			local vhf = obj.frequency[VHF_HI]
			if vhf and vhf[2] then
				local atisFreq = HzToMHz(vhf[2] + frequency_add)
				local ATCfreqs = {}
				for _, freqData in pairs(obj.frequency) do
					table.insert(ATCfreqs, HzToMHz(freqData[2]))
				end
				ATISfreqs[obj.radioId] = {atisFreq = atisFreq, ATCfreqs = ATCfreqs}
			end
		end
	end
	radio = oldRadio

	if CountArray(ATISfreqs) == 0 then
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
		return ATISfreqs[string.format("airfield%i_0", id)]
	end

	local FindWhat = {
		["ILS"] = 1,
		["NDB"] = 2,
		["PRMG"] = 3
	}

	local function FindMe(what, freq, isInner)
		isInner = isInner or false
		for _, obj in pairs(ATISfreqs) do
			if what == FindWhat.ILS and obj.ils then
				for _, ils in ipairs(obj.ils) do
					if ils.freq == freq then
						return true
					end
				end
			elseif what == FindWhat.NDB and obj.ndb then
				for _, ndb in ipairs(obj.ndb) do
					if ndb.freq == freq and ndb.isInner == isInner then
						return true
					end
				end
			elseif what == FindWhat.PRMG and obj.prmg then
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

	local airbases = coalition.getAirbases(coalition.side.BLUE)
	if #airbases == 0 then
		env.info("ATIS: No coalition airbases found!")
	end

	for _, airbase in ipairs(airbases) do
		if airbase:getDesc().category == Airbase.Category.AIRDROME then
			local callsign = airbase:getCallsign()
			local obj = GetObj(airbase:getID())
			if obj then
				local atis = ATIS
					:New(callsign, obj.atisFreq)
					:SetSoundfilesPath("ATIS/")

				local name = "ATIS_" .. callsign
				if Group.getByName(name) then
					atis:SetRadioRelayUnitName(name)
				else
					env.info(string.format("ATIS: ATIS Group (%s) not found! Subtitles are disabled.", name))
				end

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
				-- TODO: store data in global variable for Map_Stuff markers
				env.info(string.format("ATIS: Broadcasting from %s on %.2f MHz", callsign, obj.atisFreq))
			else
				env.info("ATIS: Airfield Object not found!")
			end
		end
	end
	airbases = nil
	ATISfreqs = nil

end
