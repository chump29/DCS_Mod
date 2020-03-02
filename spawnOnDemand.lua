--[[
-- Spawn On Demand
-- by Chump
--]]

-- TODO: add light/heavy vehicle categories
-- TODO: add location/spawnNum/noRoute to all spawners
-- TODO: fix scenarios (vehicles)
-- TODO: finish crash crew/find models

local base = _G
local assert = base.assert
local dofile = base.dofile
local ipairs = base.ipairs
local math = base.math
local pairs = base.pairs
local string = base.string
local table = base.table
local tonumber = base.tonumber
local tostring = base.tostring
local type = base.type

spawnOnDemand = {}

do

	-- SETTINGS --
	local settings = {

		-- Planes
		showPlanesF10 = true,					-- Show plane options in F10 menu [default: true]
		planeNumber = 0,						-- Number of planes to spawn per flight group (0 = Random, 1 - 4) [default: 0]
		planeMinDist = 10,						-- Minimum distance planes will spawn away from player (in nautical miles) [default: 10]
		planeMaxDist = 20,						-- Maximum distance planes will spawn away from player (in nautical miles) [default: 20]
		planeSkill = "Random",					-- Skill of AI planes (Average, Good, High, Excellent, Random) [default: Random]
		planeShoot = true,						-- Determines if the planes have weapons and will shoot at the enemy [default: true]
		planeRouteLength = 10,					-- Maximum distance for plane route (in nautical miles) [default: 10]
		planeRouteLoop = true,					-- Determines if the planes have a looped route [default: true]
		planeFrequency = 124,					-- Frequency of friendly flight groups (in MHz AM) [default: 124]
		planeBeacon = false,					-- Determines if enemy planes have beacons transmitting on random frequencies [default: false]
		planeSpawnType = "Random",				-- Determines how flight groups will spawn (Parking, ParkingHot, Runway, Air, Random) [default: Random]
												-- NOTE: Parking/ParkingHot/Runway use closest 1) coalition, or if none found 2) neutral airbase to player

		-- Vehicles
		showVehiclesF10 = true,					-- Show vehicle options in F10 menu [default: true]
		vehicleNumber = 0,						-- Number of vehicles to spawn per group (0 = Random, 1 - 6) [default: 0]
		vehicleMinDist = 2,						-- Minimum distance vehicles will spawn away from player (in nautical miles) [default: 1]
		vehicleMaxDist = 10,					-- Maximum distance vehicles will spawn away from player (in nautical miles) [default: 10]
		vehicleSkill = "Random",				-- Skill of AI vehicles (Average, Good, High, Excellent, Random) [default: Random]
		vehicleOnOffRoad = "on_road",			-- Determines if the vehicles will use roads or not (on_road, off_road, Random) [default: Random]
		vehicleShoot = true,					-- Determines if the vehicles will shoot at the enemy [default: true]
		vehicleRouteLength = 10,				-- Maximum distance for vehicle route (in nautical miles) [default: 10]
		vehicleRouteLoop = false,				-- Determines if the vehicles have a looped route [default: false]
		vehicleBeacon = true,					-- Determines if enemy vehicles have beacons transmitting on random frequencies [default: true]

		-- Troops (infantry is always troop #1, manpad is always troop #2, RPG is always troop #3, M249 is always enemy troop #4 if player is red)
		showTroopsF10 = true,					-- Show troop options in F10 menu [default: true]
		troopNumber = 0, 						-- Number of troops to spawn per group (any number over three will be additional Infantry AK/M4 soldiers, 0 = Random, 1 - 6) [default: 0]
		troopMinDist = 1, 						-- Minimum distance troops will spawn away from player (in nautical miles) [default: 1]
		troopMaxDist = 10, 						-- Maximum distance troops will spawn away from player (in nautical miles) [default: 10]
		troopSkill = "Random",					-- Skill of AI troops (Average, Good, High, Excellent, Random) [default: Random]
		troopOnOffRoad = "Random",				-- Determines if the troops will use roads or not (on_road, off_road, Random) [default: Random]
		troopShoot = true,						-- Determines if the troops will shoot at the enemy [default: true]
		troopRouteLength = 10,					-- Maximum distance for troop route (in nautical miles) [default: 10]
		troopRouteLoop = false,					-- Determines if the troops have a looped route [default: false]
		troopBeacon = true,						-- Determines if enemy troops have beacons transmitting on random frequencies [default: true]

		-- Helicopters
		showHelosF10 = true,					-- Show helicopter options in F10 menu [default: true]
		heloNumber = 0,							-- Number of helicopters to spawn per flight group (0 = Random, 1 - 4) [default: 0]
		heloMinDist = 10,						-- Minimum distance helicopters will spawn away from player (in nautical miles) [default: 10]
		heloMaxDist = 20,						-- Maximum distance helicopters will spawn away from player (in nautical miles) [default: 20]
		heloSkill = "Random",					-- Skill of AI helicopters (Average, Good, High, Excellent, Random) [default: Random]
		heloShoot = true,						-- Determines if the helicopters have weapons and will shoot at the enemy [default: true]
		heloRouteLength = 10,					-- Maximum distance for helicopter route (in nautical miles) [default: 10]
		heloRouteLoop = true,					-- Determines if the helicopters have a looped route [default: true]
		heloFrequency = 124,					-- Frequency of friendly flight groups (in MHz AM) [default: 124]
		heloBeacon = false,						-- Determines if enemy helicopters have beacons transmitting on random frequencies [default: false]
		heloSpawnType = "Random",				-- Determines how flight groups will spawn (Parking, ParkingHot, Runway, Air, Random) [default: Random]
												-- NOTE: Parking/ParkingHot/Runway use closest 1) coalition, or if none found 2) neutral airbase to player

		-- Ships
		showShipsF10 = false,					-- Show ship options in F10 menu [default: true]
		shipNumber = 0,							-- Number of ships to spawn per group (0 = Random, 1 - 6) [default: 0]
		shipMinDist = 10,						-- Minimum distance ships will spawn away from player (in nautical miles) [default: 10]
		shipMaxDist = 20,						-- Maximum distance ships will spawn away from player (in nautical miles) [default: 20]
		shipSkill = "Random",					-- Skill of AI ships (Average, Good, High, Excellent, Random) [default: Random]
		shipShoot = true,						-- Determines if the ships will shoot at the enemy [default: true]
		shipRouteLength = 10,					-- Maximum distance for ships route (in nautical miles) [default: 10]
		shipRouteLoop = true,					-- Determines if the ships have a looped route [default: true]

		-- AWACS
		awacsMinDist = 5,						-- Minimum distance AWACS will spawn away from player (in nautical miles) [default: 5]
		awacsMaxDist = 10,						-- Maximum distance AWACS will spawn away from player (in nautical miles) [default: 10]
		awacsSkill = "Random",					-- Skill of AI AWACS (Average, Good, High, Excellent, Random) [default: Random]
		awacsFrequency = 124,					-- Frequency of friendly AWACS (in MHz) [default 124]
		awacsBeacon = false,					-- Determines if enemy AWACS have beacons transmitting on random frequencies [default: false]
		awacsInvisible = true,					-- Determines if AWACS is invisible to AI [default: true]

		-- Tankers
		tankerMinDist = 1,						-- Minimum distance tankers will spawn away from player (in nautical miles) [default: 1]
		tankerMaxDist = 5,						-- Maximum distance tankers will spawn away from player (in nautical miles) [default: 5]
		tankerSkill = "Excellent",				-- Skill of AI tankers (Average, Good, High, Excellent, Random) [default: Excellent]
		tankerFrequency = 251,					-- Frequency of friendly tanker (in MHz) [default 251]
		tankerBeacon = true,					-- Determines if tankers have TACAN transmitting on random frequencies [default: true]
		tankerInvisible = true,					-- Determines if tanker is invisible to AI [default: true]

		-- Player Warnings
		showLowFuel = true,						-- Determines if low fuel warning is shown to player [default: true]
		lowFuelPercent = 10,					-- Number (in percentage) that determines if low fuel warning is shown to player [default: 10]

		-- Sounds (must be included in the .miz file)
		soundMessage = "static-short.ogg",		-- Sound used for all message transmissions (leave blank if message sound is not desired)
		soundBeacon = "beacon.ogg",				-- Sound used for beacons (required for beacons to function)

		-- War
		showWarF10 = true,						-- Show war option in F10 menu [default: true]
		warGroupsMin = 20,						-- Minimum number of groups spawned [default: 25]
		warGroupsMax = 40,						-- Maximum number of groups spawned [default: 50]
		warDistribution = {20, 40, 30, 10, 0},	-- Distribution (out of a combined 100, 0 = disable) of planes vs. vehicles vs. troops vs. helicopters vs. ships [default: {40, 30, 10, 10, 10}]
		warTeams = 2,							-- Spawn group teams (0 = friendly, 1 = enemy, 2 = both) [default: 2]
		warFlag = 1234,							-- Flag number set when war has been won [default: 1234]
		warAWACS = true,						-- Spawn AWACS during war [default: true]
		warTankers = true,						-- Spawn tankers during war [default: true]
		warFriendlyMinDist = 1,					-- Minimum distance friendly ground groups will spawn away from player during war (in nautical miles) [default: 1]  \
		warFriendlyMaxDist = 5,					-- Maximum distance friendly ground groups will spawn away from player during war (in nautical miles) [default: 5]  / Front
		warEnemyMinDist = 5,					-- Minimum distance enemy ground groups will spawn away from player during war (in nautical miles) [default: 5]     \ Lines
		warEnemyMaxDist = 10,					-- Maximum distance enemy ground groups will spawn away from player during war (in nautical miles) [default: 10]    /

		-- Support
		showSupportF10 = true,					-- Show support options in F10 menu [default: true]
		casWaitTime = 300,						-- Close Air Support time on station/time between calls (in seconds) [default: 300]
		afacWaitTime = 300,						-- Airborne Forward Air Controller time on station/time between calls (in seconds) [default: 300]
		afacSmoke = true,						-- Determines if AFAC target is marked by smoke [default: true]
		artyMaxDist = 5,						-- Maximum distance for artillery targets from player (in nautical miles) [default: 5]
		artyRounds = 12,						-- Number of artillery rounds to fire [default: 12]
		artyWaitTime = 120,						-- Artillery time between calls (in seconds) [default: 120]
		artySmoke = true,						-- Determines if artillery target is marked by smoke [defult: true]
		artySmokeColor = "Random",				-- Determines the artillery target smoke color (Green, Red, White, Orange, Blue) [default: Random]

		-- Scenarios
		showScenariosF10 = false,				--* Show scenario options in F10 menu [default: true]
		carBombMinTime = 300,					-- Minimum time (in seconds) to destroy car bomb before it explodes [default: 300]
		carBombMaxTime = 600,					-- Maximum time (in seconds) to destroy car bomb before it explodes [default: 600]
		carBombModel = "SEMI_RED",				-- Model to use for car bomb vehicle [default: SEMI_RED]
		vipNumVehicles = 5,						-- Number of vehicles in convoy [default: 5]
		vipModel = "Mercedes700K",				-- Model to use for VIP vehicle [default: Mercedes700K]
		vipEscortModel = "DODGE_TECH",			-- Model to use for VIP escort [default: DODGE_TECH]
		boatsNumVehicles = 5,					-- Number of boats in convoy [default: 5]
		boatsModel = "speedboat",				-- Model to use for boats [default: speedboat]

		-- Other
		showF10 = true,							-- Show F10 menu [default: true]
		maxSpawnTries = 100,					-- Maximum number of tries to spawn AI [default: 100]

		-- Airbases
		airbaseEnemyMinDist = 10,				-- Minimum distance to search for enemy airbases to use (in nautical miles) [default: 10]
		airbaseEnemyMaxDist = 20,				-- Maximum distance to search for enemy airbases to use (in nautical miles) [default: 20]
		airbaseFriendlyMaxDist = 20,			-- Maximum distance to search for friendly airbases to use (in nautical miles) [default: 20]
		airbaseSpawnNum = 2,					-- Maximum number of groups to spawn at airbases [default: 2]

		-- Crash Crew
		crashCrewLand = true,					-- Determines if crash crew is dispatched for crashes on land [default: true]
		crashCrewWater = true,					-- Determines if crash crew is dispatched for crashes on water [default: true]
		crashCrewBeacon = false,				-- Determines if SAR beacon is turned on to a random frequency [default: false]

		-- Debug
		showF10Debug = false,					-- Show F10 debug menu [default: false]
		debug = false							-- Turn debug logging on/off [default: false]

	}
	-- /SETTINGS --

	-- ensure that dependencies are loaded
	local failMsg = " must be loaded prior to this script!"
	assert(mist ~= nil, "MiST" .. failMsg)
	assert(ctld ~= nil, "CTLD" .. failMsg)
	assert(allSkins ~= nil, "AllSkins" .. failMsg)

	function spawnOnDemand.showStatus()
		local msg = "No status to show."
		local spawnedGroups = spawnOnDemand.spawnedGroups
		local spawnedGroupsCount = #spawnedGroups -- TODO: see if units are alive

		-- loop through spawned groups
		if spawnedGroupsCount > 0 then

			-- generate status lines
			msg = {string.format("Status:%s* = Friendly", string.rep("    ", 6))} -- horizontal spacing
			local footer = ""
			local groups = {}
			for index, spawnedGroup in pairs(spawnedGroups) do
				if index == 36 then -- maximum groups + 1 to show
					local diff = spawnedGroupsCount - index + 1
					footer = string.format("\n... and %i more", diff)
					break
				end
				if spawnedGroup.groupName then
					local group = Group.getByName(spawnedGroup.groupName)
					if group then
						local units = group:getUnits()
						if units and #units > 0 then
							local unitName = units[1]:getName() -- leader
							local groupID = string.match(spawnedGroup.groupName, "#(%d+)") or 0 -- not using group:getID() due to custom IDs
							local dist = spawnOnDemand.getDistanceFromPlayer(unitName)
							if dist ~= "N/A" then
								local strDist, _ = string.gsub(dist, "nm", "")
								local str = string.format("\n#%i: %i %s - %s", groupID, #units, spawnedGroup.friendlyName, dist)
								if spawnedGroup.isCarBomb then
									str = string.format("\n#%i: %s - %s", groupID, spawnedGroup.friendlyName, dist)
								end
								table.insert(groups, {
									str = str,
									dist = tonumber(strDist)
								})
							end
						end
					end
				else
					local msg = string.format("ERROR: spawnedGroup.groupName (#%i) is nil", index)
					spawnOnDemand.toPlayer(msg)
					spawnOnDemand.toLog(msg)
				end
			end

			-- sort by distance
			if #groups > 0 then
				table.sort(groups, function(o1, o2) return o1.dist < o2.dist end) -- ascending
				for _, group in ipairs(groups) do
					table.insert(msg, group.str)
				end
			end

			-- insert footer
			table.insert(msg, footer)

			-- TODO: this would not be needed if deaths were accounted for before entering logic body
			if #msg == 1 then -- only has header
				msg = nil
			end

			-- convert to string
			msg = table.concat(msg)

		end

		-- TODO: this would not be needed if deaths were accounted for before entering logic body
		if not msg then
			msg = "No status to show."
		end

		-- show message
		spawnOnDemand.toPlayer(msg)

	end

	function spawnOnDemand.isWar()
		local retVal = false
		if spawnOnDemand.settings.winID > 0 then
			retVal = true
		end
		return retVal
	end

	function spawnOnDemand.startWar(obj)
		obj = obj or {}
		local warType = obj.warType or spawnOnDemand.settings.warTypes.USER
		local spawnGroupTypes = spawnOnDemand.tableLength(spawnOnDemand.settings.groupTypes) - 2 -- exclude AWACS & Tankers

		-- check for existing war
		if spawnOnDemand.isWar() then
			spawnOnDemand.toPlayer("The current war is not over!")
			return nil
		end

		-- get player coalition
		local coa = spawnOnDemand.group:getCoalition()

		-- get war type for distributions
		local dist = spawnOnDemand.settings.warDistribution -- default to user-defined
		if warType == spawnOnDemand.settings.warTypes.AIR then
			dist = {80, 0, 0, 20, 0}
		elseif warType == spawnOnDemand.settings.warTypes.GROUND then
			dist = {0, 80, 20, 0, 0}
		elseif warType == spawnOnDemand.settings.warTypes.SEA then
			dist = {0, 0, 0, 0, 100}
		end

		-- create group distributions (borrowed and modified without permission from Random_Flight_Plan_Traffic)
		local types = {}
		local val = 0
		local index = 1
		for i = 1, spawnGroupTypes do
			if dist[i] > 0 then
				local num = dist[i] + val
				types[index] = {i, val + 1, num}
				val = num
				index = index + 1
			end
		end

		-- check that we have groups to spawn
		if index == 1 then
			spawnOnDemand.toPlayer("No groups to spawn!")
			return nil
		end

		-- spawn AWACS
		if spawnOnDemand.settings.warAWACS then

			-- friendly
			if spawnOnDemand.settings.warTeams == 0 or spawnOnDemand.settings.warTeams == 2 then
				spawnOnDemand.counts.friendly = spawnOnDemand.counts.friendly + 1
				mist.scheduleFunction(spawnOnDemand.spawnWar, {spawnOnDemand.settings.groupTypes.AWACS, true}, timer.getTime() + mist.random(10)) -- try to spread out a bit over ~10s
			end

			-- enemy
			if spawnOnDemand.settings.warTeams == 1 or spawnOnDemand.settings.warTeams == 2 then
				spawnOnDemand.counts.enemy = spawnOnDemand.counts.enemy + 1
				mist.scheduleFunction(spawnOnDemand.spawnWar, {spawnOnDemand.settings.groupTypes.AWACS}, timer.getTime() + mist.random(10)) -- try to spread out a bit over ~10s
			end

		end

		-- spawn tankers
		if spawnOnDemand.settings.warTankers then

			-- friendly
			if spawnOnDemand.settings.warTeams == 0 or spawnOnDemand.settings.warTeams == 2 then
				spawnOnDemand.counts.friendly = spawnOnDemand.counts.friendly + 1
				mist.scheduleFunction(spawnOnDemand.spawnWar, {spawnOnDemand.settings.groupTypes.TANKER, true}, timer.getTime() + mist.random(10)) -- try to spread out a bit over ~10s
			end

			-- enemy
			if spawnOnDemand.settings.warTeams == 1 or spawnOnDemand.settings.warTeams == 2 then
				spawnOnDemand.counts.enemy = spawnOnDemand.counts.enemy + 1
				mist.scheduleFunction(spawnOnDemand.spawnWar, {spawnOnDemand.settings.groupTypes.TANKER}, timer.getTime() + mist.random(10)) -- try to spread out a bit over ~10s
			end

		end

		-- get random number of groups
		local rand = mist.random(spawnOnDemand.settings.warGroupsMin, spawnOnDemand.settings.warGroupsMax)
		for _ = 1, rand do

			-- get random team
			local friendly = false -- default to spawnOnDemand.settings.warTeams = 1
			if spawnOnDemand.settings.warTeams == 2 then
				if mist.random(2) == coa then
					friendly = true
				end
			elseif spawnOnDemand.settings.warTeams == 0 then
				friendly = true
			end
			if friendly then
				spawnOnDemand.counts.friendly = spawnOnDemand.counts.friendly + 1
			else
				spawnOnDemand.counts.enemy = spawnOnDemand.counts.enemy + 1
			end

			-- keep it fair
			local num = rand * .1 -- teams can only be 10% unbalanced (groups, not units)
			if spawnOnDemand.settings.warTeams == 2 and math.abs(spawnOnDemand.counts.friendly - spawnOnDemand.counts.enemy) >= num then
				if spawnOnDemand.counts.friendly > spawnOnDemand.counts.enemy then
					if friendly then
						spawnOnDemand.counts.friendly = spawnOnDemand.counts.friendly - 1
						spawnOnDemand.counts.enemy = spawnOnDemand.counts.enemy + 1
						friendly = false
					end
				else
					if not friendly then
						spawnOnDemand.counts.enemy = spawnOnDemand.counts.enemy - 1
						spawnOnDemand.counts.friendly = spawnOnDemand.counts.friendly + 1
						friendly = true
					end
				end
			end

			-- get random spawn type
			local groupType
			local t = mist.random(types[#types][3])
			for i = 1, #types do
				if ((t >= types[i][2]) and (t <= types[i][3])) then
					groupType = types[i][1]
					break
				end
			end
			if groupType == nil then -- no distribution found
				num = mist.random(spawnGroupTypes) -- reuse var
				groupType = spawnOnDemand.settings.groupTypes[num]
				spawnOnDemand.toLog("Distribution not found! Randomly generating group type...")
			end

			-- random AA
			local aa = false
			if groupType == spawnOnDemand.settings.groupTypes.VEHICLES then
				if mist.random(2) == 1 then -- 50/50
					aa = true
				end
			end

			-- schedule spawn
			mist.scheduleFunction(spawnOnDemand.spawnWar, {groupType, friendly, aa}, timer.getTime() + mist.random(90)) -- try to spread out a bit over ~90s

		end

		-- find opposite coalition
		local c = coalition.side.BLUE
		if c == coa then
			c = coalition.side.RED
		end

		-- schedule win check
		spawnOnDemand.settings.winID = mist.scheduleFunction(spawnOnDemand.checkWin, {c}, timer.getTime() + 90, 60) -- execute in 90 seconds, then every 60 seconds

		-- reset flag
		trigger.action.setUserFlag(spawnOnDemand.settings.warFlag, false)

		-- notify coalition
		spawnOnDemand.toCoalition("Let the war begin!")

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(string.format("%i groups are spawning for war.", rand))
		end

	end

	function spawnOnDemand.spawnWar(groupType, isFriendly, isAA)
		groupType = groupType or spawnOnDemand.settings.groupTypes.PLANES
		isFriendly = isFriendly or false
		isAA = isAA or false
		local noRoute = false
		if isAA and mist.random(2) == 1 then -- 50/50
			noRoute = true
		end
		local obj = {isFriendly = isFriendly, useSound = false, showText = false, noRoute = noRoute}
		if groupType == spawnOnDemand.settings.groupTypes.PLANES then
			spawnOnDemand.spawnPlanes(obj)
		elseif groupType == spawnOnDemand.settings.groupTypes.VEHICLES then
			obj.isAA = isAA
			spawnOnDemand.spawnVehicles(obj)
		elseif groupType == spawnOnDemand.settings.groupTypes.TROOPS then
			spawnOnDemand.spawnTroops(obj)
		elseif groupType == spawnOnDemand.settings.groupTypes.HELOS then
			spawnOnDemand.spawnHelos(obj)
		elseif groupType == spawnOnDemand.settings.groupTypes.SHIPS then
			spawnOnDemand.spawnShips(obj)
		elseif spawnOnDemand.settings.groupTypes.AWACS then
			spawnOnDemand.spawnAWACS(obj)
		elseif spawnOnDemand.settings.groupTypes.TANKER then
			spawnOnDemand.spawnTanker(obj)
		else
			-- should never happen
			spawnOnDemand.toLog("ERROR: GroupType not found to spawn in war!")
		end
	end

	function spawnOnDemand.areAnyGroupsAlive(coa)
		local retVal = false
		local groups = coalition.getGroups(coa)
		for x = 1, #groups do
			if groups[x]:isExist() then -- Group.isExist() returns dead groups
				local units = groups[x]:getUnits()
				for y = 1, #units do
					if units[y]:isExist() and units[y]:isActive() and units[y]:getLife() > 1 then
						retVal = true
						break -- only need to verify if a single unit is alive
					end
				end
				if retVal then break end -- only need to verify if a single unit is alive
			end
		end
		return retVal
	end

	function spawnOnDemand.checkWin(coa)
		if not spawnOnDemand.areAnyGroupsAlive(coa) then

			-- reset
			mist.removeFunction(spawnOnDemand.settings.winID) -- mist does not return anything
			spawnOnDemand.settings.winID = 0
			spawnOnDemand.counts.friendly = 0
			spawnOnDemand.counts.enemy = 0
			spawnOnDemand.onGround.friendly = 0
			spawnOnDemand.onGround.enemy = 0

			-- ensure that player unit exists
			if spawnOnDemand.unit:isExist() then

				-- set flag
				trigger.action.setUserFlag(spawnOnDemand.settings.warFlag, true)

				-- notify coalition
				spawnOnDemand.toCoalition("Enemy defeated! *** RTB ***", 15)

			end

			-- for debug
			if spawnOnDemand.settings.debug then
				spawnOnDemand.toLog("The war was won!")
			end

		else

			-- check if only AWACS/Tankers are left and invisibility is on
			if spawnOnDemand.settings.awacsInvisible or spawnOnDemand.settings.tankerInvisible then
				local groups = {}
				local groupNum = 0
				local other = 0
				for _, spawnedGroup in ipairs(spawnOnDemand.spawnedGroups) do
					if spawnedGroup.groupType == spawnOnDemand.settings.groupTypes.AWACS or spawnedGroup.groupType == spawnOnDemand.settings.groupTypes.TANKER then
						table.insert(groups, spawnedGroup.groupName)
						groupNum = groupNum + 1 -- instead of iterating over table to get size
					else
						other = other + 1
					end
				end
				if other == 0 and groupNum > 0 then
					for _, groupName in ipairs(groups) do
						local group = Group.getByName(groupName)
						if group then
							local controller = group:getController()
							spawnOnDemand.setInvisible(controller, false)
						else
							spawnOnDemand.toLog(string.format("AWACS/Tanker controller for %s not found!", groupName))
						end
					end
					if spawnOnDemand.settings.debug then
						spawnOnDemand.toLog("AWACS/Tankers are the only units left on the team. Turning off invisibility for AWACS/Tankers.")
					end
				end
			end

		end
	end

	function spawnOnDemand.showFriendly(str, isFriendly)
		if string.len(str) > 0 and isFriendly ~= nil then
			if isFriendly then
				str = str .. "*"
			end
		end
		return str
	end

	function spawnOnDemand.getWarPoint(isFriendly)
		local retVal
		if isFriendly then
			retVal = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.warFriendlyMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.warFriendlyMinDist))
		else
			retVal = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.warEnemyMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.warEnemyMinDist))
		end
		return retVal
	end

	function spawnOnDemand.spawnPlanes(obj)
		obj = obj or {}
		local isCargo = obj.isCargo or false
		local isFriendly = obj.isFriendly or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned plane group #%i", spawnOnDemand.spawnedGroupID)
		local planeData = spawnOnDemand.getRandomPlanes(isCargo, isFriendly)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.plane)
		newGroupData.task = mist.utils.deepCopy(planeData.task)
		newGroupData.name = groupName
		if isFriendly then
			newGroupData.frequency = spawnOnDemand.settings.planeFrequency
		end

		-- set units
		local units = {}
		local skill -- default to Random
		local planeSkill = spawnOnDemand.settings.planeSkill
		if planeSkill ~= "Random" then
			skill = planeSkill
		end

		-- get random distance
		local point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.planeMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.planeMinDist))

		-- create units
		for index, plane in ipairs(planeData.planes) do
			plane = mist.utils.deepCopy(plane)
			spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
			local pylons = plane.pylons or {}
			local flare = plane.flare or 0
			local ammoType = plane.ammoType or 0
			local chaff = plane.chaff or 0
			local gun = plane.gun or 100
			local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.plane)
			unit.alt = land.getHeight(point) + mist.random(153, 3048) -- 500ft to 10,000ft (in m)
			if not spawnOnDemand.settings.planeShoot or isCargo then
				pylons = nil -- clear
				unit.hardpoint_racks = nil -- clear
			end
			local type = plane.type
			local skins = allSkins.liveries[type]
			if skins then
				unit.livery_id = skins[mist.random(#skins)]
			end
			local skills = spawnOnDemand.settings.skills
			unit.skill = skill or skills[mist.random(#skills)]
			unit.speed = mist.random(93, 257) -- 180kts to 500kts (in mps)
			unit.AddPropAircraft = spawnOnDemand.getAircraftProps(type)
			unit.type = type
			unit.x = point.x
			unit.name = string.format("%s (#%i)", plane.type, spawnOnDemand.spawnedUnitID)
			unit.payload = {
				pylons = pylons,
				fuel = plane.fuel,
				flare = flare,
				ammo_type = ammoType,
				chaff = chaff,
				gun = gun
			}
			unit.y = point.y - index * 20 -- meters behind
			unit.heading = mist.utils.toRadian(mist.random(0, 359)) -- in radians
			table.insert(newGroupData.units, unit)
			table.insert(units, unit.name)
		end

		-- create route
		local points = {}
		local start = mist.fixedWing.buildWP(point) -- starting point
		local spawnType = spawnOnDemand.getSpawnType(isFriendly, true)
		if spawnType and spawnType.type and spawnType.action then
			start.type = spawnType.type
			start.action = spawnType.action
			start.airdromeId = spawnType.id
			start.x = spawnType.x
			start.y = spawnType.y
		end
		start.task = {
			id = "ComboTask",
			params = {
				tasks = planeData.tasks or nil
			}
		}
		table.insert(points, start)
		local len = mist.utils.NMToMeters(mist.random(0, spawnOnDemand.settings.planeRouteLength))
		local newPoint = mist.getRandPointInCircle(point, len) -- get random waypoint
		local speed = mist.random(93, 257) -- 180kts to 500kts (in mps)
		local alt = mist.random(61, 3048) -- 200ft to 10,000ft (in m)
		table.insert(points, mist.fixedWing.buildWP(newPoint, "turning_point", speed, alt, "radio"))
		newGroupData.route.points = points

		-- spawn group
		local group = coalition.addGroup(planeData.countryID, Group.Category.AIRPLANE, newGroupData)
		group = Group.getByName(groupName) -- coalition.addGroup() doesn't like to return a real object here for some reason, fetch again
		if not group then
			local msg = "Error spawning plane(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		controller:setOption(AI.Option.Air.id.FLARE_USING, AI.Option.Air.val.FLARE_USING.AGAINST_FIRED_MISSILE)
		controller:setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
		controller:setOption(AI.Option.Air.id.MISSILE_ATTACK, AI.Option.Air.val.MISSILE_ATTACK.TARGET_THREAT_EST)
		controller:setOption(AI.Option.Air.id.PROHIBIT_WP_PASS_REPORT, true)
		if not isCargo and spawnOnDemand.settings.planeShoot then
			controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		else
			controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		end

		-- set commands
		if spawnOnDemand.settings.planeRouteLoop then
			spawnOnDemand.doRouteLoop(controller)
		end

		-- create beacon
		local vhf
		local freq = ""
		if not isFriendly and spawnOnDemand.settings.planeBeacon then
			vhf = spawnOnDemand.createVHFBeacon(controller)
			if vhf then
				freq = " [" .. vhf .. "]"
			end
		end

		-- define plane type
		local planeType = "Cargo plane"
		if not isCargo then
			planeType = "Fighter plane(s)"
		end

		local firstUnit = newGroupData.units[1]

		-- create spawned group object
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(planeType, isFriendly), freq),
			display = spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			vhf = vhf,
			groupType = spawnOnDemand.settings.groupTypes.PLANES,
			spawnType = spawnType.type,
			isCargo = isCargo,
			type = planeType
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %i %s spawned (%s) %s away!", spawnOnDemand.spawnedGroupID, #newGroupData.units, spawnedGroup.friendlyName, spawnedGroup.spawnType, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, planeData.countryID)

	end

	function spawnOnDemand.spawnVehicles(obj)
		obj = obj or {}
		local isCargo = obj.isCargo or false
		local isFriendly = obj.isFriendly or false
		local isAA = obj.isAA or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end
		local isCarBomb = obj.isCarBomb or false
		local isVIP = obj.isVIP or false
		local location = obj.location
		local spawnNum = obj.spawnNum
		local noRoute = obj.noRoute or false

		-- get random distance
		local point = location
		if not point then
			local isValid = false
			for _ = 1, spawnOnDemand.settings.maxSpawnTries do
				if spawnOnDemand.isWar() then
					point = spawnOnDemand.getWarPoint(isFriendly)
				else
				 	point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.vehicleMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.vehicleMinDist))
				end
			 	local sType = land.getSurfaceType(point)
			 	if sType ~= land.SurfaceType.SHALLOW_WATER and sType ~= land.SurfaceType.WATER then
			 		isValid = true
			 		break
			 	end
			end
			if not isValid then
				local msg = "Unable to find valid vehicle spawn location!"
				spawnOnDemand.toPlayer(msg, nil, useSound, showText)
				spawnOnDemand.toLog(msg)
				return nil
			end
		end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned vehicle group #%i", spawnOnDemand.spawnedGroupID)
		local vehicleData = spawnOnDemand.getRandomVehicles(isCargo, isFriendly, isAA)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.vehicle)
		newGroupData.name = groupName

		-- alter vehicles for scenarios
		local vip
		if isCarBomb then
			vehicleData.vehicles = {} -- clear
			table.insert(vehicleData.vehicles, spawnOnDemand.settings.carBombModel)
		elseif isVIP then
			vehicleData.vehicles = {} -- clear
			local num = spawnOnDemand.settings.vipNumVehicles
			local firstHalf = math.floor(num / 2)
			for _ = 1, firstHalf do
				table.insert(vehicleData.vehicles, spawnOnDemand.settings.vipEscortModel)
			end
			table.insert(vehicleData.vehicles, spawnOnDemand.settings.vipModel)
			vip = firstHalf + 1
			local secondHalf = num - vip
			for _ = 1, secondHalf do
				table.insert(vehicleData.vehicles, spawnOnDemand.settings.vipEscortModel)
			end
		end

		-- limiter
		if spawnNum then
			local newVehicles = {}
			for vehicleCount, vehicle in ipairs(vehicleData.vehicles) do
				if vehicleCount > spawnNum then break end
				table.insert(newVehicles, vehicle)
			end
			vehicleData.vehicles = newVehicles
		end

		-- set units
		local units = {}
		local skill -- default to Random
		local vehicleSkill = spawnOnDemand.settings.vehicleSkill
		if vehicleSkill ~= "Random" then
			skill = vehicleSkill
		end
		for index, vehicle in ipairs(vehicleData.vehicles) do
			vehicle = mist.utils.deepCopy(vehicle)
			spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
			local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.vehicle)
			unit.type = vehicle
			local skills = spawnOnDemand.settings.skills
			unit.skill = skill or skills[mist.random(#skills)]
			unit.y = point.y - index * 20 -- meters behind
			unit.x = point.x - index * 20 -- meters left
			unit.name = string.format("%s (#%i)", vehicle, spawnOnDemand.spawnedUnitID)
			if index == vip then
				vip = unit.name -- reuse
			end
			table.insert(newGroupData.units, unit)
			table.insert(units, unit.name)
		end

		-- spawn group
		local group = coalition.addGroup(vehicleData.countryID, Group.Category.GROUND, newGroupData)
		if not group then
			local msg = "Error spawning vehicle(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- create route
		if not noRoute then
			local formation -- default to Random
			local vehicleOnOffRoad = spawnOnDemand.settings.vehicleOnOffRoad
			if vehicleOnOffRoad ~= "Random" then
				formation = vehicleOnOffRoad
			end
			local formations = spawnOnDemand.settings.formations
			mist.groupRandomDistSelf(
				group,
				mist.utils.NMToMeters(mist.random(0, spawnOnDemand.settings.vehicleRouteLength)),
				formation or formations[mist.random(#formations)],
				mist.random(0, 359), -- in degrees
				mist.random(8, 72) -- 5mph - 45mph [in kph]
			)
		end

		-- set options
		local controller = group:getController()
		if not isVIP then
			controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, 60) -- disperse for 60 seconds
		else
			controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED) -- always ready
		end
		if not isCargo and spawnOnDemand.settings.vehicleShoot then
			controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
			if isAA then
				controller:setOption(AI.Option.Ground.id.ENGAGE_AIR_WEAPONS, true)
			end
		else
			controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
		end

		-- set commands
		if not noRoute then
			if spawnOnDemand.settings.vehicleRouteLoop or isCarBomb or isVIP then
				spawnOnDemand.doRouteLoop(controller)
			end
		end

		-- create beacon
		local vhf
		local freq = ""
		if not isFriendly and spawnOnDemand.settings.vehicleBeacon then
			vhf = spawnOnDemand.createVHFBeacon(controller)
			if vhf then
				freq = " [" .. vhf .. "]"
			end
		end

		-- define vehicle type
		local vehicleType
		local display
		if isCarBomb then
			vehicleType = "Car Bomb"
			display = vehicleType
		elseif isVIP then
			vehicleType = "VIP vehicle(s)"
			display = "VIP"
		else
			vehicleType = "Cargo"
			local aa = ""
			if not isCargo then
				vehicleType = "Armored"
				if isAA then
					aa = " AA"
				end
			end
			vehicleType = string.format("%s%s vehicle(s)", vehicleType, aa)
		end

		-- create spawned group object
		local firstUnit = newGroupData.units[1]
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(vehicleType, isFriendly), freq),
			display = display or spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			vhf = vhf,
			groupType = spawnOnDemand.settings.groupTypes.VEHICLES,
			isCargo = isCargo,
			isAA = isAA,
			isCarBomb = isCarBomb,
			isVIP = isVIP,
			vipName = vip,
			type = vehicleType
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %i %s spawned %s away!", spawnOnDemand.spawnedGroupID, #newGroupData.units, spawnedGroup.friendlyName, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, vehicleData.countryID)

	end

	function spawnOnDemand.spawnTroops(obj)
		obj = obj or {}
		local isFriendly = obj.isFriendly or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end

		-- get random distance
		local point
		local isValid = false
		for _ = 1, spawnOnDemand.settings.maxSpawnTries do
			if spawnOnDemand.isWar() then
				point = spawnOnDemand.getWarPoint(isFriendly)
			else
			 	point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.troopMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.troopMinDist))
			end
		 	local sType = land.getSurfaceType(point)
		 	if sType ~= land.SurfaceType.SHALLOW_WATER and sType ~= land.SurfaceType.WATER then
		 		isValid = true
		 		break
		 	end
		end
		if not isValid then
			local msg = "Unable to find valid troop spawn location!"
			spawnOnDemand.toPlayer(msg, nil, useSound, showText)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned troop group #%i", spawnOnDemand.spawnedGroupID)
		local troopData = spawnOnDemand.getRandomTroops(isFriendly)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.vehicle)
		newGroupData.name = groupName

		-- create units
		local units = {}
		local skill -- default to Random
		local troopSkill = spawnOnDemand.settings.troopSkill
		if troopSkill ~= "Random" then
			skill = troopSkill
		end
		for index, troop in ipairs(troopData.troops) do
			troop = mist.utils.deepCopy(troop)

			-- spawn around first person (borrowed without permission from CTLD)
			local _angle = math.pi * 2 * (index - 1) / #troopData.troops
			local _xOffset = math.cos(_angle) * 30
			local _yOffset = math.sin(_angle) * 30

			-- create unit
			spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
			local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.vehicle)
			unit.type = troop
			local skills = spawnOnDemand.settings.skills
			unit.skill = skill or skills[mist.random(#skills)]
			unit.y = point.y + _yOffset
			unit.x = point.x + _xOffset
			unit.name = string.format("%s (#%i)", troop, spawnOnDemand.spawnedUnitID)

			table.insert(newGroupData.units, unit)
			table.insert(units, unit.name)

		end

		-- spawn group
		local group = coalition.addGroup(troopData.countryID, Group.Category.GROUND, newGroupData)
		if not group then
			local msg = "Error spawning troop(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- create route
		local formation -- default to Random
		local troopOnOffRoad = spawnOnDemand.settings.troopOnOffRoad
		if troopOnOffRoad ~= "Random" then
			formation = troopOnOffRoad
		end
		local formations = spawnOnDemand.settings.formations
		mist.groupRandomDistSelf(
			groupName,
			mist.utils.NMToMeters(mist.random(0, spawnOnDemand.settings.troopRouteLength)),
			formation or formations[mist.random(#formations)],
			mist.random(0, 359), -- in degrees
			mist.random(8, 16) -- 5mph - 10mph [in kph]
		)

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, 60) -- disperse for 60 seconds
		if spawnOnDemand.settings.troopShoot then
			controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
			controller:setOption(AI.Option.Ground.id.ENGAGE_AIR_WEAPONS, true)
		else
			controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
		end

		-- set commands
		if spawnOnDemand.settings.troopRouteLoop then
			spawnOnDemand.doRouteLoop(controller)
		end

		-- create beacon
		local vhf
		local freq = ""
		if not isFriendly and spawnOnDemand.settings.troopBeacon then
			vhf = spawnOnDemand.createVHFBeacon(controller)
			if vhf then
				freq = " [" .. vhf .. "]"
			end
		end

		-- define troop type
		local str = "Troop(s)"

		local firstUnit = newGroupData.units[1]

		-- create spawned group object
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(str, isFriendly), freq),
			display = spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			vhf = vhf,
			groupType = spawnOnDemand.settings.groupTypes.TROOPS,
			type = str
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %i %s spawned %s away!", spawnOnDemand.spawnedGroupID, #newGroupData.units, spawnedGroup.friendlyName, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, troopData.countryID)

	end

	function spawnOnDemand.spawnHelos(obj)
		obj = obj or {}
		local isCargo = obj.isCargo or false
		local isFriendly = obj.isFriendly or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned helo group #%i", spawnOnDemand.spawnedGroupID)
		local heloData = spawnOnDemand.getRandomHelos(isCargo, isFriendly)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.plane) -- same
		newGroupData.task = mist.utils.deepCopy(heloData.task)
		newGroupData.name = groupName
		if isFriendly then
			newGroupData.frequency = spawnOnDemand.settings.heloFrequency
		end

		-- get random distance
		local point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.heloMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.heloMinDist))

		-- set units
		local units = {}
		local skill -- default to Random
		local heloSkill = spawnOnDemand.settings.heloSkill
		if heloSkill ~= "Random" then
			skill = heloSkill
		end
		for index, helo in ipairs(heloData.helos) do
			helo = mist.utils.deepCopy(helo)
			spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
			local pylons = helo.pylons or nil
			local flare = helo.flare or 0
			local ammoType = helo.ammoType or 0
			local chaff = helo.chaff or 0
			local gun = helo.gun or 100
			if not spawnOnDemand.settings.heloShoot then
				pylons = nil -- clear
			end
			local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.plane) -- same
			unit.alt = land.getHeight(point) + mist.random(15, 305) -- 50ft to 1,000ft (in m)
			local type = helo.type
			local skins = allSkins.liveries[type]
			if skins then
				unit.livery_id = skins[mist.random(#skins)]
			end
			local skills = spawnOnDemand.settings.skills
			unit.skill = skill or skills[mist.random(#skills)]
			unit.ropeLength = 5 -- in m
			unit.speed = mist.random(31, 62) -- 60kts to 120kts (in mps)
			unit.AddPropAircraft = spawnOnDemand.getAircraftProps(type)
			unit.type = type
			unit.x = point.x
			unit.name = string.format("%s (#%i)", helo.type, spawnOnDemand.spawnedUnitID)
			unit.payload = {
				pylons = pylons,
				fuel = helo.fuel,
				flare = flare,
				ammo_type = ammoType,
				chaff = chaff,
				gun = gun
			}
			unit.y = point.y - index * 20 -- meters behind
			unit.heading = mist.utils.toRadian(mist.random(0, 359)) -- in radians
			table.insert(newGroupData.units, unit)
			table.insert(units, unit.name)
		end

		-- create route
		local points = {}
		local start = mist.heli.buildWP(point) -- starting point
		local spawnType = spawnOnDemand.getSpawnType(isFriendly, false)
		if spawnType and spawnType.type and spawnType.action then
			start.type = spawnType.type
			start.action = spawnType.action
			start.airdromeId = spawnType.id
			start.x = spawnType.x
			start.y = spawnType.y
		end
		start.task = {
			id = "ComboTask",
			params = {
				tasks = heloData.tasks or nil
			}
		}
		table.insert(points, start)
		local len = mist.utils.NMToMeters(mist.random(0, spawnOnDemand.settings.heloRouteLength))
		local newPoint = mist.getRandPointInCircle(point, len) -- get random waypoint
		local speed = mist.random(31, 62) -- 60 kts - 120 kts [in mps]
		local alt = mist.random(6, 305) -- 20 ft - 1,000 ft [in m]
		table.insert(points, mist.heli.buildWP(newPoint, "turning_point", speed, alt, "radio"))
		newGroupData.route.points = points

		-- spawn group
		local group = coalition.addGroup(heloData.countryID, Group.Category.HELICOPTER, newGroupData)
		group = Group.getByName(groupName) -- coalition.addGroup() doesn't like to return a real object here for some reason, fetch again
		if not group then
			local msg = "Error spawning helicopter(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		controller:setOption(AI.Option.Air.id.FLARE_USING, AI.Option.Air.val.FLARE_USING.AGAINST_FIRED_MISSILE)
		controller:setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
		controller:setOption(AI.Option.Air.id.MISSILE_ATTACK, AI.Option.Air.val.MISSILE_ATTACK.TARGET_THREAT_EST)
		controller:setOption(AI.Option.Air.id.PROHIBIT_WP_PASS_REPORT, true)
		if not isCargo and spawnOnDemand.settings.heloShoot then
			controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		else
			controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		end

		-- set commands
		if spawnOnDemand.settings.troopRouteLoop then
			spawnOnDemand.doRouteLoop(controller)
		end

		-- create beacon
		local vhf
		local freq = ""
		if not isFriendly and spawnOnDemand.settings.heloBeacon then
			vhf = spawnOnDemand.createVHFBeacon(controller)
			if vhf then
				freq = " [" .. vhf .. "]"
			end
		end

		-- define helo type
		local heloType = "Cargo helicopter"
		if not isCargo then
			heloType = "Attack helicopter(s)"
		end

		local firstUnit = newGroupData.units[1]

		-- create spawned group object
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(heloType, isFriendly), freq),
			display = spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			vhf = vhf,
			groupType = spawnOnDemand.settings.groupTypes.HELOS,
			spawnType = spawnType.type,
			isCargo = isCargo,
			type = heloType
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %i %s spawned (%s) %s away!", spawnOnDemand.spawnedGroupID, #newGroupData.units, spawnedGroup.friendlyName, spawnedGroup.spawnType, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, heloData.countryID)

	end

	function spawnOnDemand.spawnShips(obj)
		obj = obj or {}
		local isCargo = obj.isCargo or false
		local isFriendly = obj.isFriendly or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end
		local isConvoy = obj.isConvoy or false

		-- get random distance
		local point
		local isValid = false
		for _ = 1, spawnOnDemand.settings.maxSpawnTries do
			if spawnOnDemand.isWar() then
				point = spawnOnDemand.getWarPoint(isFriendly)
			else
			 	point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.shipMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.shipMinDist))
			end
		 	local sType = land.getSurfaceType(point)
		 	if sType == land.SurfaceType.WATER or sType == land.SurfaceType.SHALLOW_WATER then -- includes ocean/lakes/rivers
		 		isValid = true
		 		break
		 	end
		end
		if not isValid then
			local msg = "Unable to find valid ship spawn location!"
			spawnOnDemand.toPlayer(msg, nil, useSound, showText)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned ship group #%i", spawnOnDemand.spawnedGroupID)
		local shipData = spawnOnDemand.getRandomShips(isCargo, isFriendly)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.ship)
		newGroupData.name = groupName

		-- alter ships for scenario
		if isConvoy then
			shipData.ships = {} -- clear
			for _ = 1, spawnOnDemand.settings.boatsNumVehicles do
				table.insert(shipData.ships, spawnOnDemand.settings.boatsModel)
			end
		end

		-- set units
		local units = {}
		local skill -- default to Random
		local shipSkill = spawnOnDemand.settings.shipSkill
		if shipSkill ~= "Random" then
			skill = shipSkill
		end
		for index, ship in ipairs(shipData.ships) do
			ship = mist.utils.deepCopy(ship)
			spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
			local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.ship)
			unit.type = ship
			local skills = spawnOnDemand.settings.skills
			unit.skill = skill or skills[mist.random(#skills)]
			unit.y = point.y - index * 100 -- meters behind
			unit.x = point.x - index * 100 -- meters left
			unit.name = string.format("%s (#%i)", ship, spawnOnDemand.spawnedUnitID)
			table.insert(newGroupData.units, unit)
			table.insert(units, unit.name)
		end

		-- spawn group
		local group = coalition.addGroup(shipData.countryID, Group.Category.SHIP, newGroupData)
		if not group then
			local msg = "Error spawning ship(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- create route
		mist.groupRandomDistSelf(
			group,
			mist.utils.NMToMeters(mist.random(0, spawnOnDemand.settings.shipRouteLength)),
			"echelon_left",
			mist.random(0, 359), -- in degrees
			mist.random(9, 47) -- 5kts - 25kts [in kph]
		)

		-- set options
		local controller = group:getController()
		if not isCargo and spawnOnDemand.settings.shipShoot then
			controller:setOption(AI.Option.Naval.id.ROE, AI.Option.Naval.val.ROE.OPEN_FIRE)
		else
			controller:setOption(AI.Option.Naval.id.ROE, AI.Option.Naval.val.ROE.WEAPON_HOLD)
		end

		-- set commands
		if spawnOnDemand.settings.shipRouteLoop or isConvoy then
			spawnOnDemand.doRouteLoop(controller)
		end

		-- define ship type
		local shipType = "Cargo"
		if isConvoy then
			shipType = "Convoy of"
		elseif not isCargo then
			shipType = "Navy"
		end
		shipType = string.format("%s ship(s)", shipType)

		-- create spawned group object
		local firstUnit = newGroupData.units[1]
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = spawnOnDemand.showFriendly(shipType, isFriendly),
			display = spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			vhf = vhf,
			groupType = spawnOnDemand.settings.groupTypes.SHIPS,
			isCargo = isCargo,
			isConvoy = isConvoy,
			type = shipType
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %i %s spawned %s away!", spawnOnDemand.spawnedGroupID, #newGroupData.units, spawnedGroup.friendlyName, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, shipData.countryID)

	end

	function spawnOnDemand.spawnAWACS(obj)
		obj = obj or {}
		local isFriendly = obj.isFriendly or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned AWACS #%i", spawnOnDemand.spawnedGroupID)
		local planeData = spawnOnDemand.getAWACS(isFriendly)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.plane)
		newGroupData.task = mist.utils.deepCopy(planeData.task)
		newGroupData.name = groupName
		if isFriendly then
			newGroupData.frequency = spawnOnDemand.settings.awacsFrequency
		end

		-- set units
		local units = {}
		local skill -- default to Random
		local planeSkill = spawnOnDemand.settings.awacsSkill
		if planeSkill ~= "Random" then
			skill = planeSkill
		end

		-- get random distance
		local point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.awacsMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.awacsMinDist))

		-- create units
		local plane = mist.utils.deepCopy(planeData.plane)
		spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
		local flare = plane.flare or 0
		local ammoType = plane.ammoType or 0
		local chaff = plane.chaff or 0
		local gun = plane.gun or 100
		local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.plane)
		local alt = land.getHeight(point) + mist.random(4572, 9144) -- 15,000ft to 30,000ft (in m)
		unit.alt = alt
		unit.hardpoint_racks = nil -- clear
		local skins = allSkins.liveries[plane.type]
		if skins then
			unit.livery_id = skins[mist.random(#skins)]
		end
		local skills = spawnOnDemand.settings.skills
		unit.skill = skill or skills[mist.random(#skills)]
		local speed = mist.random(103, 154) -- 200kts to 300kts (in mps)
		unit.speed = speed
		unit.AddPropAircraft = nil -- clear
		unit.type = plane.type
		unit.x = point.x
		unit.name = string.format("%s (#%i)", plane.type, spawnOnDemand.spawnedUnitID)
		unit.payload = {
			pylons = nil, -- clear
			fuel = plane.fuel,
			flare = flare,
			chaff = chaff,
			gun = gun
		}
		unit.y = point.y
		unit.heading = mist.utils.toRadian(mist.random(0, 359)) -- in radians
		table.insert(newGroupData.units, unit)
		table.insert(units, unit.name)

		-- create route
		local points = {}
		local start = mist.fixedWing.buildWP(point) -- starting point
		local spawnType = planeData.spawn
		start.type = spawnType.type
		start.action = spawnType.action
		local tasks = planeData.tasks
		tasks[2].params.altitude = alt
		tasks[2].params.speed = speed
		start.task = {
			id = "ComboTask",
			params = {
				tasks = tasks
			}
		}
		table.insert(points, start)
		newGroupData.route.points = points

		-- spawn group
		local group = coalition.addGroup(planeData.countryID, Group.Category.AIRPLANE, newGroupData)
		group = Group.getByName(groupName) -- coalition.addGroup() doesn't like to return a real object here for some reason, fetch again
		if not group then
			local msg = "Error spawning plane(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		controller:setOption(AI.Option.Air.id.PROHIBIT_WP_PASS_REPORT, true)
		if spawnOnDemand.settings.awacsInvisible then
			spawnOnDemand.setInvisible(controller, true)
		end

		-- create beacon
		local vhf
		local freq = ""
		if not isFriendly and spawnOnDemand.settings.awacsBeacon then
			vhf = spawnOnDemand.createVHFBeacon(controller)
			if vhf then
				freq = " [" .. vhf .. "]"
			end
		end

		-- define plane type
		local planeType = "AWACS"

		local firstUnit = newGroupData.units[1]

		-- create spawned group object
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(planeType, isFriendly), freq),
			display = spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			vhf = vhf,
			groupType = spawnOnDemand.settings.groupTypes.AWACS,
			spawnType = spawnType.type,
			type = planeType
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %s spawned (%s) %s away!", spawnOnDemand.spawnedGroupID, spawnedGroup.friendlyName, spawnedGroup.spawnType, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, planeData.countryID)

	end

	function spawnOnDemand.spawnTanker(obj)
		local debug = spawnOnDemand.settings.debug

		for _, group in ipairs(spawnOnDemand.spawnedGroups) do
			if group.tacan then
				spawnOnDemand.toPlayer("Only one Tanker can be in the air at a time!", 5, useSound, showText)
				return nil
			end
		end

		obj = obj or {}
		local isFriendly = obj.isFriendly or false
		local useSound = obj.useSound
		if useSound == nil then useSound = true end
		local showText = obj.showText
		if showText == nil then showText = true end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned Tanker #%i", spawnOnDemand.spawnedGroupID)
		local planeData = spawnOnDemand.getTanker(isFriendly)
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.plane)
		newGroupData.task = mist.utils.deepCopy(planeData.task)
		newGroupData.name = groupName
		if isFriendly then
			newGroupData.frequency = spawnOnDemand.settings.tankerFrequency
		end

		-- set units
		local units = {}
		local skill -- default to Random
		local planeSkill = spawnOnDemand.settings.tankerSkill
		if planeSkill ~= "Random" then
			skill = planeSkill
		end

		-- get random distance
		local point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(spawnOnDemand.settings.tankerMaxDist), mist.utils.NMToMeters(spawnOnDemand.settings.tankerMinDist)) --vec2

		-- create units
		local plane = mist.utils.deepCopy(planeData.plane)
		spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
		local flare = plane.flare or 0
		local ammoType = plane.ammoType or 0
		local chaff = plane.chaff or 0
		local gun = plane.gun or 100
		local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.plane)
		local alt = land.getHeight(point) + mist.random(4572, 7620) -- 15,000ft to 25,000ft (in m)
		alt = (alt + 500) / 1000 * 1000 -- round up to nearest thousand
		unit.alt = alt
		unit.hardpoint_racks = nil -- clear
		local skins = allSkins.liveries[plane.type]
		if skins then
			unit.livery_id = skins[mist.random(#skins)]
		end
		local skills = spawnOnDemand.settings.skills
		unit.skill = skill or skills[mist.random(#skills)]
		local speed = mist.utils.knotsToMps(220) -- in mps
		unit.speed = speed
		unit.AddPropAircraft = nil -- clear
		unit.type = plane.type
		unit.x = point.x
		unit.name = string.format("%s (#%i)", plane.type, spawnOnDemand.spawnedUnitID)
		unit.payload = {
			pylons = nil, -- clear
			fuel = plane.fuel,
			flare = flare,
			chaff = chaff,
			gun = gun
		}
		unit.y = point.y

		local heading = {
			[1] = 0, -- n
			[2] = 90, -- e
			[3] = 180, -- s
			[4] = 270 -- w
		}
		local chosenHeading = heading[mist.random(#heading)]
		unit.heading = mist.utils.toRadian(chosenHeading) -- in radians

		table.insert(newGroupData.units, unit)
		table.insert(units, unit.name)

		-- create route
		local points = {}
		local start = mist.fixedWing.buildWP(point, "turning_point", speed, alt, "radio") -- starting point
		local spawnType = planeData.spawn
		start.action = spawnType.action
		local tasks = planeData.tasks

		tasks[2].params.altitude = alt
		tasks[2].params.speed = speed
		start.task = {
			id = "ComboTask",
			params = {
				tasks = tasks
			},
			x = point.x,
			y = point.y,
			speed_locked = true,
			ETA = 0,
			ETA_locked = true
		}
		table.insert(points, start)

		local len = mist.utils.NMToMeters(20) -- in m
		local newPoint = { -- vec3
			x = point.x,
			y = alt,
			z = point.y
		}
		if chosenHeading == 0 then
			newPoint.x = point.x + len -- south to north
		elseif chosenHeading == 90 then
			newPoint.z = point.y + len -- west to east
		elseif chosenHeading == 180 then
			newPoint.x = point.x - len -- north to south
		elseif chosenHeading == 270 then
			newPoint.z = point.y - len -- east to west
		else
			-- should never happen
			spawnOnDemand.toLog("ERROR: Cannot find initial heading!")
		end

		if debug then
			trigger.action.markToAll(spawnOnDemand.spawnedUnitID, "WP1", mist.utils.makeVec3(point, alt))
			trigger.action.markToAll(spawnOnDemand.spawnedUnitID + 1000, "WP2", newPoint)
		end

		table.insert(points, mist.fixedWing.buildWP(newPoint, "turning_point", speed, alt, "radio"))
		newGroupData.route.points = points

		-- spawn group
		local group = coalition.addGroup(planeData.countryID, Group.Category.AIRPLANE, newGroupData)
		group = Group.getByName(groupName) -- coalition.addGroup() doesn't like to return a real object here for some reason, fetch again
		if not group then
			local msg = "Error spawning plane(s)!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		controller:setOption(AI.Option.Air.id.PROHIBIT_WP_PASS_REPORT, true)
		if spawnOnDemand.settings.tankerInvisible then
			spawnOnDemand.setInvisible(controller, true)
		end

		-- create tacan (blue only)
		local tacan
		local freq = ""
		if spawnOnDemand.group:getCoalition() == coalition.side.BLUE and isFriendly and spawnOnDemand.settings.tankerBeacon then
			tacan = spawnOnDemand.createTacanBeacon()
			if tacan then
				freq = " [" .. tacan.channel .. "Y]"
				local command = mist.utils.deepCopy(spawnOnDemand.templates.tasks.TACAN)
				command.frequency = tacan.frequency
				command.callsign = tacan.callsign
				command.channel = tacan.channel
				command.unitId = group:getUnits()[1]:getID()
				if controller then
					controller:setCommand(command)
				end
			end
		end

		-- define plane type
		local planeType = "Tanker"

		local firstUnit = newGroupData.units[1]

		-- create spawned group object
		local spawnedGroup = {
			groupName = groupName,
			friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(planeType, isFriendly), freq),
			display = spawnOnDemand.showFriendly(firstUnit.type, isFriendly),
			units = units,
			isFriendly = isFriendly,
			tacan = tacan,
			groupType = spawnOnDemand.settings.groupTypes.TANKER,
			spawnType = spawnType.type,
			type = planeType
		}
		table.insert(spawnOnDemand.spawnedGroups, spawnedGroup)

		-- notify player
		local msg = string.format("#%i: %s spawned %s away!", spawnOnDemand.spawnedGroupID, spawnedGroup.friendlyName, spawnOnDemand.getDistanceFromPlayer(firstUnit.name))
		spawnOnDemand.toPlayer(msg, 5, useSound, showText)

		-- for debug
		if debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, planeData.countryID)

	end

	function spawnOnDemand.spawnCAS()

		-- check if CAS is on hold
		if spawnOnDemand.settings.CASholdTimer > 0 then
			local secs = math.ceil(spawnOnDemand.settings.casWaitTime - (timer.getTime() - spawnOnDemand.settings.CASholdTimer))
			spawnOnDemand.toPlayer(string.format("CAS is unavailable at this time. %i seconds left...", secs))
			return nil
		end

		-- check if CAS already spawned
		if spawnOnDemand.settings.CAStimer > 0 then
			spawnOnDemand.toPlayer("CAS mission already active...")
			return nil
		end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned CAS group #%i", spawnOnDemand.spawnedGroupID)
		local planeData = spawnOnDemand.getRandomCAS()
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.plane)
		newGroupData.task = mist.utils.deepCopy(planeData.task)
		newGroupData.name = groupName
		newGroupData.frequency = spawnOnDemand.settings.planeFrequency

		-- get random distance
		local point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(1))

		-- create unit
		local plane = mist.utils.deepCopy(planeData.planes[1])
		spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
		local flare = plane.flare or 0
		local ammoType = plane.ammoType or 0
		local chaff = plane.chaff or 0
		local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.plane)
		local alt = land.getHeight(point) + mist.random(153, 3048) -- 500ft to 10,000ft (in m)
		local speed = mist.random(93, 257) -- 180kts to 500kts (in mps)
		unit.alt = alt
		local skins = allSkins.liveries[plane.type]
		if skins then
			unit.livery_id = skins[mist.random(#skins)]
		end
		unit.skill = spawnOnDemand.settings.skills[4] -- Excellent
		unit.speed = speed
		unit.type = plane.type
		unit.x = point.x
		unit.name = plane.type
		unit.payload = {
			pylons = plane.pylons,
			fuel = plane.fuel,
			flare = flare,
			ammo_type = ammoType,
			chaff = chaff,
			gun = 100
		}
		unit.y = point.y
		unit.heading = mist.utils.toRadian(mist.random(0, 359)) -- in radians
		table.insert(newGroupData.units, unit)

		-- create route
		local points = {}
		local start = mist.fixedWing.buildWP(point) -- starting point
		local spawnType = planeData.spawn
		start.type = spawnType.type
		start.action = spawnType.action
		local tasks = planeData.tasks
		tasks[1].params.x = point.x
		tasks[1].params.y = point.y
		tasks[3].params.altitude = alt
		tasks[3].params.speed = speed
		start.task = {
			id = "ComboTask",
			params = {
				tasks = tasks
			}
		}
		table.insert(points, start)
		newGroupData.route.points = points

		-- spawn group
		local group = coalition.addGroup(planeData.countryID, Group.Category.AIRPLANE, newGroupData)
		group = Group.getByName(groupName) -- coalition.addGroup() doesn't like to return a real object here for some reason, fetch again
		if not group then
			local msg = "Error spawning CAS plane!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- get unit
		unit = group:getUnits()[1]

		-- set timer
		spawnOnDemand.settings.CAStimer = mist.scheduleFunction(spawnOnDemand.destroyCAS, {unit}, timer.getTime() + spawnOnDemand.settings.casWaitTime)

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		controller:setOption(AI.Option.Air.id.PROHIBIT_AA, true)
		controller:setOption(AI.Option.Air.id.FLARE_USING, AI.Option.Air.val.FLARE_USING.AGAINST_FIRED_MISSILE)
		controller:setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
		controller:setOption(AI.Option.Air.id.MISSILE_ATTACK, AI.Option.Air.val.MISSILE_ATTACK.TARGET_THREAT_EST)
		controller:setOption(AI.Option.Air.id.PROHIBIT_WP_PASS_REPORT, true)

		-- notify coalition
		local msg = string.format("CAS (%s) on station!", unit:getDesc().typeName)
		spawnOnDemand.toCoalition(msg, 5)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, planeData.countryID)

	end

	function spawnOnDemand.destroyCAS(unit)
		if unit and unit:isExist() then

			-- destroy unit (no events)
			unit:destroy()

			-- notify coalition
			local msg = "CAS offline"
			spawnOnDemand.toCoalition(msg)

			-- for debug
			if spawnOnDemand.settings.debug then
				spawnOnDemand.toLog(msg)
			end

		end

		-- reset timer
		spawnOnDemand.settings.CAStimer = 0

		-- start hold timer
		spawnOnDemand.settings.CASholdTimer = timer.getTime()
		mist.scheduleFunction(spawnOnDemand.resetCASholdTimer, nil, timer.getTime() + spawnOnDemand.settings.casWaitTime)

	end

	function spawnOnDemand.resetCASholdTimer()
		spawnOnDemand.settings.CASholdTimer = 0
	end

	function spawnOnDemand.spawnArty()

		-- check if arty is on hold
		if spawnOnDemand.settings.artyHoldTimer > 0 then
			local secs = math.ceil(spawnOnDemand.settings.artyWaitTime - (timer.getTime() - spawnOnDemand.settings.artyHoldTimer))
			spawnOnDemand.toPlayer(string.format("Artillery is reloading. %i seconds left...", secs))
			return nil
		end

		-- check if arty is already active
		if spawnOnDemand.settings.artyTimer > 0 then
			spawnOnDemand.toPlayer("Artillery is already firing...")
			return nil
		end

		-- get closest enemy unit
		local side = coalition.side.RED
		if spawnOnDemand.group:getCoalition() == side then
			side = coalition.side.BLUE
		end
		local groups = coalition.getGroups(side, Group.Category.GROUND)
		local allUnits = {}
		for x = 1, #groups do
			local group = groups[x]
			if group:isExist() then
				local units = group:getUnits()
				for y = 1, #units do
					local unit = units[y]
					if unit:isExist() and unit:isActive() and unit:getLife() > 1 then
						local unitName = unit:getName()
						local dist = spawnOnDemand.getDistanceFromPlayer(unitName)
						if dist ~= "N/A" then
							local strDist, _ = string.gsub(dist, "nm", "")
							local iDist = tonumber(strDist)
							if iDist <= spawnOnDemand.settings.artyMaxDist then
								table.insert(allUnits, {
									name = unitName,
									dist = iDist
								})
							end
						end
					end
				end
			end
		end
		if #allUnits > 0 then

			-- sort by distance
			table.sort(allUnits, function(o1, o2) return o1.dist < o2.dist end) -- ascending

			-- get closest unit name
			local unitName = allUnits[1].name

			-- create smoke
			local marked = ""
			if spawnOnDemand.settings.artySmoke then

				-- determine color
				local color -- default to random
				local colors = spawnOnDemand.settings.smokeColor
				for _, c in ipairs(colors) do
					if c.name == string.lower(spawnOnDemand.settings.artySmokeColor) then
						color = c
						break
					end
				end
				if not color then
					color = colors[mist.random(#colors)]
				end

				-- pop smoke on unit
				local unit = Unit.getByName(unitName)
				if unit then
					local point = unit:getPoint()
					trigger.action.smoke({x = point.x, y = point.y + 2, z = point.z}, color.value)
					marked = string.format("marked with %s smoke ", color.name)
				end

			end

			-- create barrage
			spawnOnDemand.settings.artyTimer = mist.scheduleFunction(spawnOnDemand.fireArty, {unitName}, timer.getTime() + 10, 3) -- 10s initial delay, fire every 3s

			-- notify coalition
			local msg = string.format("%s %sin the open. Firing for effect.", Unit.getByName(unitName):getDesc().typeName, marked)
			spawnOnDemand.toCoalition(msg)

			-- for debug
			if spawnOnDemand.settings.debug then
				spawnOnDemand.toLog(msg)
			end

		else
			spawnOnDemand.toPlayer("No enemies in range!")
		end

	end

	function spawnOnDemand.fireArty(unitName)
		local debug = spawnOnDemand.settings.debug
		local destroyed = false

		-- get unit
		local unit = Unit.getByName(unitName)
		if unit then

			-- get coordinates
			local unitPoint = unit:getPoint()
			local randPoint = mist.getRandPointInCircle(unitPoint, mist.utils.feetToMeters(200))
			local explosionPoint = {
				x = randPoint.x,
				y = unitPoint.y,
				z = randPoint.y
			}

			-- create explosion
			trigger.action.explosion(explosionPoint, 50)

			-- increment counter
			spawnOnDemand.settings.artyNum = spawnOnDemand.settings.artyNum + 1

		else

			-- cease fire
			spawnOnDemand.settings.artyNum = spawnOnDemand.settings.artyRounds
			destroyed = true

			-- notify coalition
			local msg = "Splash target!"
			spawnOnDemand.toCoalition(msg)

			-- for debug
			if debug then
				spawnOnDemand.toLog(msg)
			end

		end

		-- clear timer/counter
		if spawnOnDemand.settings.artyNum == spawnOnDemand.settings.artyRounds then
			mist.removeFunction(spawnOnDemand.settings.artyTimer)
			spawnOnDemand.settings.artyTimer = 0
			spawnOnDemand.settings.artyNum = 0
			spawnOnDemand.settings.artyHoldTimer = timer.getTime()
			mist.scheduleFunction(spawnOnDemand.resetArtyHoldTimer, nil, timer.getTime() + spawnOnDemand.settings.artyWaitTime)

			if not destroyed then

				-- notify player
				local msg = "Rounds complete."
				spawnOnDemand.toPlayer(msg)

				-- for debug
				if debug then
					spawnOnDemand.toLog(msg)
				end

			end

		end

	end

	function spawnOnDemand.resetArtyHoldTimer()
		spawnOnDemand.settings.artyHoldTimer = 0
	end

	function spawnOnDemand.spawnAFAC()

		-- check if AFAC is on hold
		if spawnOnDemand.settings.AFACholdTimer > 0 then
			local secs = math.ceil(spawnOnDemand.settings.afacWaitTime - (timer.getTime() - spawnOnDemand.settings.AFACholdTimer))
			spawnOnDemand.toPlayer(string.format("AFAC is unavailable at this time. %i seconds left...", secs))
			return nil
		end

		-- check if AFAC already spawned
		if spawnOnDemand.settings.AFACtimer > 0 then
			spawnOnDemand.toPlayer("AFAC mission already active...")
			return nil
		end

		-- create group
		spawnOnDemand.spawnedGroupID = spawnOnDemand.spawnedGroupID + 1
		local groupName = string.format("Spawned AFAC group #%i", spawnOnDemand.spawnedGroupID)
		local planeData = spawnOnDemand.getRandomAFAC()
		local newGroupData = mist.utils.deepCopy(spawnOnDemand.templates.group.plane)
		newGroupData.task = mist.utils.deepCopy(planeData.task)
		newGroupData.name = groupName
		newGroupData.frequency = 123000000

		-- get random distance
		local point = mist.getRandPointInCircle(spawnOnDemand.unit:getPosition().p, mist.utils.NMToMeters(1))

		-- create unit
		local plane = mist.utils.deepCopy(planeData.planes[1])
		spawnOnDemand.spawnedUnitID = spawnOnDemand.spawnedUnitID + 1
		local flare = plane.flare or 0
		local chaff = plane.chaff or 0
		local unit = mist.utils.deepCopy(spawnOnDemand.templates.unit.plane)
		local alt = land.getHeight(point) + mist.random(1524, 3048) -- 5,000ft to 10,000ft (in m)
		local speed = mist.random(29, 60) -- 56kts - 117kts (in mps)
		unit.alt = alt
		unit.hardpoint_racks = nil
		local skins = allSkins.liveries[plane.type]
		if skins then
			unit.livery_id = skins[mist.random(#skins)]
		end
		unit.skill = spawnOnDemand.settings.skills[4] -- Excellent
		unit.speed = speed
		unit.AddPropAircraft = nil
		unit.type = plane.type
		unit.x = point.x
		unit.name = plane.type
		unit.payload = {
			pylons = plane.pylons,
			fuel = plane.fuel,
			flare = flare,
			chaff = chaff,
			gun = 100
		}
		unit.y = point.y
		unit.heading = mist.utils.toRadian(mist.random(0, 359)) -- in radians
		table.insert(newGroupData.units, unit)

		-- create route
		local points = {}
		local start = mist.fixedWing.buildWP(point) -- starting point
		local spawnType = planeData.spawn
		start.type = spawnType.type
		start.action = spawnType.action
		local tasks = planeData.tasks
		tasks[1].params.x = point.x
		tasks[1].params.y = point.y
		tasks[3].params.altitude = alt
		tasks[3].params.speed = speed
		start.task = {
			id = "ComboTask",
			params = {
				tasks = tasks
			}
		}
		table.insert(points, start)
		newGroupData.route.points = points

		-- spawn group
		local group = coalition.addGroup(planeData.countryID, Group.Category.AIRPLANE, newGroupData)
		group = Group.getByName(groupName) -- coalition.addGroup() doesn't like to return a real object here for some reason, fetch again
		if not group then
			local msg = "Error spawning AFAC plane!"
			spawnOnDemand.toPlayer(msg)
			spawnOnDemand.toLog(msg)
			return nil
		end

		-- get unit
		unit = group:getUnits()[1]

		-- set timer
		spawnOnDemand.settings.AFACtimer = mist.scheduleFunction(spawnOnDemand.destroyAFAC, {unit}, timer.getTime() + spawnOnDemand.settings.afacWaitTime)

		-- set options
		local controller = group:getController()
		controller:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.NO_REACTION)

		-- set CTLD options
		ctld.JTAC_maxDistance = 18520 -- 10nm
		local color = spawnOnDemand.settings.smokeColor[mist.random(#spawnOnDemand.settings.smokeColor)]

		-- generate laser code
		local code = tonumber("1" .. mist.random(6) .. mist.random(8) .. mist.random(8))

		-- notify coalition
		local msg = string.format("AFAC (%s) on station [%i / %s]!", unit:getDesc().typeName, code, color.name)
		spawnOnDemand.toCoalition(msg, 5)

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end

		-- enable auto JTAC
		ctld.JTACAutoLase(groupName, code, spawnOnDemand.settings.afacSmoke, "vehicle", color.value)

		-- return object
		return spawnOnDemand.convertForMistDB(newGroupData, planeData.countryID)

	end

	function spawnOnDemand.destroyAFAC(unit)
		if unit and unit:isExist() and unit:getGroup() then

			-- disable auto JTAC
			ctld.JTACAutoLaseStop(unit:getGroup():getName())

			-- destroy unit (no events)
			unit:destroy()

			-- notify coalition
			local msg = "AFAC offline"
			spawnOnDemand.toCoalition(msg)

			-- for debug
			if spawnOnDemand.settings.debug then
				spawnOnDemand.toLog(msg)
			end

		end

		-- reset timer
		spawnOnDemand.settings.AFACtimer = 0

		-- start hold timer
		spawnOnDemand.settings.AFACholdTimer = timer.getTime()
		mist.scheduleFunction(spawnOnDemand.resetAFACholdTimer, nil, timer.getTime() + spawnOnDemand.settings.afacWaitTime)

	end

	function spawnOnDemand.resetAFACholdTimer()
		spawnOnDemand.settings.AFACholdTimer = 0
	end

	function spawnOnDemand.scenarioCarBomb()

		-- check if car bomb has already been spawned
		if spawnOnDemand.settings.carBombTimer > 0 then
			spawnOnDemand.toPlayer("Car bomb scenario is already active...")
			return nil
		end

		-- spawn car bomb
		local groupName = spawnOnDemand.spawnVehicles({isCarBomb = true, isCargo = true})

		-- determine time
		local time = mist.random(spawnOnDemand.settings.carBombMinTime, spawnOnDemand.settings.carBombMaxTime)

		-- create car bomb object
		spawnOnDemand.settings.carBomb = {
			groupName = groupName,
			time = timer.getTime() + time -- in seconds
		}

		-- calculate time
		local msg
		if time > 59 then
			local timeM = math.floor(time / 60)
			local timeS = time - 60 * timeM
			msg = string.format("%i:%02.f", timeM, timeS)
		else
			msg = string.format("%i seconds", time)
		end

		-- notify player
		spawnOnDemand.toPlayer(string.format("* You have %s to destroy it before it explodes! *", msg))

		-- for debug
		if debug then
			spawnOnDemand.toLog(string.format("Car bomb (%s) set to explode in %i seconds!", groupName, time))
		end

		-- start car bomb timer
		spawnOnDemand.settings.carBombTimer = mist.scheduleFunction(spawnOnDemand.checkCarBomb, nil, timer.getTime() + 1, 1) -- executes every second

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog("Car bomb timer started.")
		end

	end

	function spawnOnDemand.checkCarBomb()
		local debug = spawnOnDemand.settings.debug

		-- check for car bomb
		local carBomb = spawnOnDemand.settings.carBomb
		if carBomb then

			-- has time expired?
			if timer.getTime() >= carBomb.time then
				local groupName = carBomb.groupName
				local group = Group.getByName(groupName)
				if group then

					-- get unit
					local unit = group:getUnits()[1]
					if unit and unit:isExist() then

						-- set as exploded (death event clears object)
						carBomb.exploded = true -- must be set before event fires

						-- explode unit
						trigger.action.explosion(unit:getPoint(), 10000)

						-- notify player
						local msg = "Car bomb has exploded!"
						spawnOnDemand.toPlayer(msg)

						-- for debug
						if debug then
							msg = string.format("Car bomb (%s) exploded!", groupName) -- be more specific
							spawnOnDemand.toLog(msg)
						end

					else

						if debug then
							spawnOnDemand.toLog(string.format("Car bomb (%s) is already dead.", groupName))
						end

					end

				end

			end

		else

			-- remove timer
			mist.removeFunction(spawnOnDemand.settings.carBombTimer) -- mist does not return anything
			spawnOnDemand.settings.carBombTimer = 0

			-- for debug
			if debug then
				spawnOnDemand.toLog("Car bomb timer stopped.")
			end

		end

	end

	function spawnOnDemand.scenarioVIP()

		-- check if car VIP has already been spawned
		if spawnOnDemand.settings.vip then
			spawnOnDemand.toPlayer("VIP scenario is already active...")
			return nil
		end

		-- spawn VIP
		spawnOnDemand.settings.vip = spawnOnDemand.spawnVehicles({isVIP = true})

	end

	function spawnOnDemand.scenarioBoats()

		-- check if boats have already been spawned
		if spawnOnDemand.settings.boats then
			spawnOnDemand.toPlayer("Boat scenario is already active...")
			return nil
		end

		-- spawn boats
		spawnOnDemand.settings.boats = spawnOnDemand.spawnShips({isConvoy = true})

	end

	function spawnOnDemand.convertForMistDB(newGroupData, countryID)
		local debug = spawnOnDemand.settings.debug
		local groupName

		-- check for group
		local group = Group.getByName(newGroupData.name)
		if group then
			groupName = newGroupData.name

			-- check if already in MiST DB
			if not mist.DBs.groupsByName[groupName] then

				local groupData = mist.utils.deepCopy(newGroupData)

				-- get country
				local ctry
				for name, id in pairs(country.id) do
					if id == countryID then
						ctry = string.lower(name)
						break
					end
				end
				groupData.country = ctry

				groupData.groupName = groupName

				-- get coalition
				local coa
				for name, id in pairs(coalition.side) do
					if id == group:getCoalition() then
						coa = string.lower(name)
						break
					end
				end
				groupData.coalition = coa

				groupData.groupId = group:getID()

				-- get category
				local groupCategory
				for name, id in pairs(Group.Category) do
					if id == group:getCategory() then
						groupCategory = string.lower(name)
						if StaticObject.getByName(groupName) then
							groupCategory = "static"
						elseif groupCategory == "airplane" then
							groupCategory = "plane"
						elseif groupCategory == "ground" then
							groupCategory = "vehicle"
						-- ship = ship
						end
						break
					end
				end
				groupData.category = groupCategory

				groupData.countryId = countryID
				groupData.startTime = groupData.start_time

				-- sanitize group
				groupData.visible = nil
				groupData.taskSelected = nil
				groupData.tasks = nil
				groupData.name = nil
				groupData.start_time = nil
				groupData.route = nil
				groupData.communication = nil

				for _, unitData in pairs(groupData.units) do
					local unit = Unit.getByName(unitData.name)
					if unit then
						unitData.point = mist.utils.makeVec2(unit:getPoint())
						unitData.groupId = group:getID()
						unitData.coalition = coa
						unitData.groupName = groupName
						unitData.countryId = countryID
						unitData.unitId = tonumber(unit:getID()) -- returns a string for some reason
						unitData.category = groupCategory
						unitData.unitName = unitData.name
						unitData.country = ctry
						--onboard_num
						--callsign

						-- sanitize unit
						unitData.transportable = nil
						unitData.name = nil
						unitData.hardpoint_racks = nil
						unitData.payload = nil

					end
				end

				-- add to MiST DBs
				mist.DBs.groupsByName[groupName] = groupData -- mist.DBs.groupsByName
				for _, unit in pairs(groupData.units) do

					-- mist.DBs.unitsByName
					if not mist.DBs.unitsByName[unit.unitName] then
						mist.DBs.unitsByName[unit.unitName] = unit
					else

						-- for debug
						if debug then
							spawnOnDemand.toLog(string.format("Unit (%s) already exists in unitsByName DB.", unit.unitName))
						end

					end

					-- mist.DBs.MEunitsByName
					if not mist.DBs.MEunitsByName[unit.unitName] then
						mist.DBs.MEunitsByName[unit.unitName] = unit
					else

						-- for debug
						if debug then
							spawnOnDemand.toLog(string.format("Unit (%s) already exists in MEunitsByName DB.", unit.unitName))
						end

					end

					-- mist.DBs.MEunitsById
					if not mist.DBs.MEunitsById[unit.unitId] then
						mist.DBs.MEunitsByName[unit.unitId] = unit
					else

						-- for debug
						if debug then
							spawnOnDemand.toLog(string.format("Unit (%i) already exists in MEunitsById DB.", unit.unitId))
						end

					end

				end

				-- for debug
				if debug then
					local unitNum = #groupData.units
					if mist.DBs.groupsByName[groupName] and unitNum > 0 then
						spawnOnDemand.toLog(string.format("Group (%s) with %i units added to groupsByName DB.", groupName, unitNum))
					else
						spawnOnDemand.toLog(string.format("Group (%s) with %i units not found in groupsByName DB!", groupName, unitNum))
					end
				end

			else

				-- for debug
				if debug then
					spawnOnDemand.toLog(string.format("Group (%s) already exists in groupsByName DB."), groupName)
				end

			end

		else

			-- for debug
			if debug then
				spawnOnDemand.toLog(string.format("Group (%s) not found, cannot add to MiST DBs!", newGroupData.name))
			end

		end
		return groupName
	end

	function spawnOnDemand.setInvisible(controller, state)
		local invisible = {
			id = "SetInvisible",
			params = {
				value = state
			}
		}
		controller:setCommand(invisible)
	end

	function spawnOnDemand.doRouteLoop(controller, pattern)
		pattern = pattern or AI.Task.OrbitPattern.RACE_TRACK -- two points
		local from = 2
		local to = 1
		if pattern == AI.Task.OrbitPattern.CIRCLE then -- four waypoints
			from = 4
		end
		local switchWaypoint = {
			id = "SwitchWaypoint",
			params = {
				fromWaypointIndex = from,
				goToWaypointIndex = to
			}
		}
		controller:setCommand(switchWaypoint)
	end

	function spawnOnDemand.getAirbase(isFriendly)
		local retVal

		-- get airbases
		local airbases = {}
		if spawnOnDemand.group:getCoalition() == coalition.side.BLUE then
			if isFriendly then
				airbases = coalition.getAirbases(coalition.side.BLUE)
			else
				airbases = coalition.getAirbases(coalition.side.RED)
			end
		else -- red
			if isFriendly then
				airbases = coalition.getAirbases(coalition.side.RED)
			else
				airbases = coalition.getAirbases(coalition.side.BLUE)
			end
		end

		-- if none found, use neutral airbases
		if #airbases == 0 then
			airbases = coalition.getAirbases(coalition.side.NEUTRAL)
		end

		-- find closest airbase
		if #airbases > 0 then
			local bases = {}

			-- set min/max search distance (default to friendly)
			local min = 0
			local max = mist.utils.NMToMeters(spawnOnDemand.settings.airbaseFriendlyMaxDist)
			if not isFriendly then
				min = mist.utils.NMToMeters(spawnOnDemand.settings.airbaseEnemyMinDist)
				max = mist.utils.NMToMeters(spawnOnDemand.settings.airbaseEnemyMaxDist)
			end

			for _, airbase in ipairs(airbases) do
				if airbase:getDesc().category == Airbase.Category.AIRDROME then -- not using HELIPAD or SHIP
					local playerPosition = spawnOnDemand.unit:getPosition().p
					local airbasePosition = airbase:getPosition().p
					local dist = mist.utils.get2DDist(playerPosition, airbasePosition) -- in m
					table.insert(bases, {
						dist = dist,
						id = airbase:getID(),
						x = airbasePosition.x,
						y = airbasePosition.z
					})
				end
			end
			if #bases > 0 then
				table.sort(bases, function(o1, o2) return o1.dist < o2.dist end) -- ascending
				local base = bases[1]
				if base.dist >= min and base.dist <= max then
					retVal = base
					retVal.dist = nil -- clear
				end
			end
		end

		return retVal
	end

	function spawnOnDemand.getSpawnType(isFriendly, isPlane)
		local retVal

		-- get spawn type/action
		local debug = spawnOnDemand.settings.debug
		local spawnTypes = spawnOnDemand.settings.spawnTypes

		-- determine side
		local side
		if spawnOnDemand.group:getCoalition() == coalition.side.BLUE then
			if isFriendly then
				side = 0
				retVal = spawnOnDemand.base.last.blue
			else
				side = 1
				retVal = spawnOnDemand.base.last.red
			end
		else
			if isFriendly then
				side = 1
				retVal = spawnOnDemand.base.last.red
			else
				side = 0
				retVal = spawnOnDemand.base.last.blue
			end
		end

		-- refresh airbase data if needed (to reduce processing lag) [airbases refresh due to player moving/airbases changing coalitions]
		local time = timer.getTime()
		if (side == 0 and spawnOnDemand.base.time.blue <= time) or (side == 1 and spawnOnDemand.base.time.red <= time) then
			retVal = spawnOnDemand.getAirbase(isFriendly)
			time = time + 60 -- refresh time (in seconds)
			if side == 0 then
				spawnOnDemand.base.last.blue = retVal
				spawnOnDemand.base.time.blue = time
			else -- 1
				spawnOnDemand.base.last.red = retVal
				spawnOnDemand.base.time.red = time
			end
			if debug then
				local str
				if side == 0 then
					str = "blue"
				else -- 1
					str = "red"
				end
				spawnOnDemand.toLog(string.format("Refreshed %s airbase data.", str))
			end
		end

		if retVal then
			local spawnType -- default to Random
			local planeSpawnType
			if isPlane then
				planeSpawnType = spawnOnDemand.settings.planeSpawnType
			else
				planeSpawnType = spawnOnDemand.settings.heloSpawnType
			end
			if planeSpawnType ~= "Random" then
				spawnType = planeSpawnType
			end
			local st

			-- deter too many groups (for each side) spawned at the same airport
			local maxGroups = spawnOnDemand.settings.airbaseSpawnNum
			if (isFriendly and spawnOnDemand.onGround.friendly < maxGroups) or (not isFriendly and spawnOnDemand.onGround.enemy < maxGroups) then

				-- get spawn type
				if spawnType then -- specified, find it
					for _, t in ipairs(spawnTypes) do
						if t[1] == spawnType then
							st = t
							break
						end
					end
				else -- random
					st = spawnTypes[mist.random(#spawnTypes)]
				end

				-- increment count on ground
				if st[1] ~= spawnTypes[4][1] then
					if isFriendly then
						spawnOnDemand.onGround.friendly = spawnOnDemand.onGround.friendly + 1
					else
						spawnOnDemand.onGround.enemy = spawnOnDemand.onGround.enemy + 1
					end
				end

			else
				st = spawnTypes[4] -- Air
				if debug then
					spawnOnDemand.toLog("Too many groups are spawned on the ground! Defaulting to Air spawn.")
				end
			end

			-- get spawn type data
			if st then
				retVal.type = st[2]
				retVal.action = st[3]
			else
				spawnOnDemand.toLog("ERROR: Spawn type not found! Defaulting to Air spawn.")
				retVal = nil -- reset
			end

		else
			retVal = nil -- reset
			if debug then
				spawnOnDemand.toLog("Airbase not found within range! Defaulting to Air spawn.")
			end
		end

		-- default to Air spawn
		if not retVal then
			retVal = {}
			local obj = spawnTypes[4] -- Air
			retVal.type = obj[2]
			retVal.action = obj[3]
		end

		return retVal
	end

	function spawnOnDemand.getRandomCountryID(isFriendly)
		local randCountryID
		local blue = env.mission.coalitions.blue
		local red = env.mission.coalitions.red
		if spawnOnDemand.group:getCoalition() == coalition.side.BLUE then
			if isFriendly then
				randCountryID = blue[mist.random(#blue)]
			else
				randCountryID = red[mist.random(#red)]
			end
		else -- red
			if isFriendly then
				randCountryID = red[mist.random(#red)]
			else
				randCountryID = blue[mist.random(#blue)]
			end
		end
		return randCountryID
	end

	function spawnOnDemand.getRandomPlanes(isCargo, isFriendly)
		local data = {}
		data.planes = {}
		local p = spawnOnDemand.planes

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- build table of planes
		local planes = {}
		if isCargo then

			-- define cargo planes
			planes = p.cargo

		else

			-- define fighter/attack planes
			planes = p.other

		end

		-- determine number of planes
		local num = 1
		if not isCargo then
			num = spawnOnDemand.settings.planeNumber
			if num == 0 then
				num = mist.random(4) -- max for group
			end
		end

		-- get random plane(s)
		local plane = planes[mist.random(#planes)]
		for _ = 1, num do
			table.insert(data.planes, plane)
		end

		-- set tasking
		data.task = plane.task or "Nothing"
		if data.task == "CAS" then
			data.tasks = mist.utils.deepCopy(spawnOnDemand.templates.tasks.CAS)
		elseif data.task == "CAP" then
			data.tasks = mist.utils.deepCopy(spawnOnDemand.templates.tasks.CAP)
		end

		return data
	end

	function spawnOnDemand.getRandomVehicles(isCargo, isFriendly, isAA)
		local data = {}
		data.vehicles = {}
		local v = spawnOnDemand.vehicles

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- build table of vehicles
		local vehicles = {}
		if isCargo then

			-- define cargo vehicles
			vehicles = v.cargo

		else

			if isAA then

				-- define AA vehicles
				vehicles = v.aa

			else

				-- define armored vehicles
				vehicles = v.other

			end

		end

		-- get random vehicles
		local num = spawnOnDemand.settings.vehicleNumber
		if num == 0 then
			num = mist.random(6)
		end
		for _ = 1, num do
			table.insert(data.vehicles, vehicles[mist.random(#vehicles)])
		end

		return data
	end

	function spawnOnDemand.getRandomTroops(isFriendly)
		local data = {}
		data.troops = {}

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- build table of troops
		local isBlue = true
		if spawnOnDemand.group:getCoalition() ~= coalition.side.BLUE then
			isBlue = false
		end
		local num = spawnOnDemand.settings.troopNumber
		if num == 0 then
			num = mist.random(6)
		end
		for i = 1, num do
			if i == 2 then
				if isBlue then
					table.insert(data.troops, "SA-18 Igla-S manpad")
				else
					table.insert(data.troops, "Stinger manpad")
				end
			elseif i == 3 then
				table.insert(data.troops, "Paratrooper RPG-16")
			elseif i == 4 and not isBlue then
				table.insert(data.troops, "Soldier M249")
			else
				if isBlue then
					table.insert(data.troops, "Infantry AK")
				else
					table.insert(data.troops, "Soldier M4")
				end
			end
		end

		return data
	end

	function spawnOnDemand.getRandomHelos(isCargo, isFriendly)
		local data = {}
		data.helos = {}
		local h = spawnOnDemand.helos

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- build table of helos
		local helos = {}
		if isCargo then

			-- define cargo helos
			helos = h.cargo

		else

			-- define attack helos
			helos = h.other

		end

		-- determine number of helos
		local num = 1
		if not isCargo then
			num = spawnOnDemand.settings.heloNumber
			if num == 0 then
				num = mist.random(4) -- max for group
			end
		end

		-- get random helo(s)
		local helo = helos[mist.random(#helos)]
		for _ = 1, num do
			table.insert(data.helos, helo)
		end

		-- set tasking
		data.task = helo.task or "Nothing"
		if data.task == "CAS" then
			data.tasks = mist.utils.deepCopy(spawnOnDemand.templates.tasks.CAS)
		elseif data.task == "CAP" then
			data.tasks = mist.utils.deepCopy(spawnOnDemand.templates.tasks.CAP)
		end

		return data
	end

	function spawnOnDemand.getRandomShips(isCargo, isFriendly)
		local data = {}
		data.ships = {}
		local v = spawnOnDemand.ships

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- build table of ships
		local ships = {}
		if isCargo then

			-- define cargo ships
			ships = v.cargo

		else

			-- define navy ships
			ships = v.other

		end

		-- get random ships
		local num = spawnOnDemand.settings.shipNumber
		if num == 0 then
			num = mist.random(6)
		end
		for _ = 1, num do
			table.insert(data.ships, ships[mist.random(#ships)])
		end

		return data
	end

	function spawnOnDemand.getAWACS(isFriendly)
		local data = {}

		-- determine side
		local planes
		if spawnOnDemand.group:getCoalition() == coalition.side.BLUE then
			if isFriendly then
				planes = spawnOnDemand.AWACS.blue
			else
				planes = spawnOnDemand.AWACS.red
			end
		else
			if isFriendly then
				planes = spawnOnDemand.AWACS.red
			else
				planes = spawnOnDemand.AWACS.blue
			end
		end

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- get random plane
		data.plane = planes[mist.random(#planes)]

		-- set tasking
		data.task = "AWACS"
		data.tasks = spawnOnDemand.templates.tasks.AWACS

		-- set spawn type
		local obj = spawnOnDemand.settings.spawnTypes[4] -- Air
		data.spawn = {}
		data.spawn.type = obj[2]
		data.spawn.action = obj[3]

		return data
	end

	function spawnOnDemand.getTanker(isFriendly)
		local data = {}

		-- determine side
		local planes
		if spawnOnDemand.group:getCoalition() == coalition.side.BLUE then
			if isFriendly then
				planes = spawnOnDemand.tankers.blue
			else
				planes = spawnOnDemand.tankers.red
			end
		else
			if isFriendly then
				planes = spawnOnDemand.tankers.red
			else
				planes = spawnOnDemand.tankers.blue
			end
		end

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(isFriendly)

		-- get random plane
		data.plane = planes[mist.random(#planes)]

		-- set tasking
		data.task = "Refueling"
		data.tasks = spawnOnDemand.templates.tasks.tanker

		-- set spawn type
		local obj = spawnOnDemand.settings.spawnTypes[4] -- Air
		data.spawn = {}
		data.spawn.type = obj[2]
		data.spawn.action = obj[3]

		return data
	end

	function spawnOnDemand.getRandomCAS()
		local data = {}
		data.planes = {}
		local planes = spawnOnDemand.planes.CAS

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(true) -- always friendly

		-- get random plane
		local plane = planes[mist.random(#planes)]
		table.insert(data.planes, plane)

		-- set tasking
		data.task = plane.task
		data.tasks = mist.utils.deepCopy(spawnOnDemand.templates.tasks.CAS)
		data.tasks[1].id = "EngageTargetsInZone"
		data.tasks[1].auto = false
		data.tasks[1].params.targetTypes[1] = "Infantry"
		data.tasks[1].params.targetTypes[2] = "Ground vehicles"
		data.tasks[1].params.targetTypes[3] = "Air Defence"
		data.tasks[1].params.zoneRadius = mist.utils.NMToMeters(5)
		local orbit = mist.utils.deepCopy(spawnOnDemand.templates.tasks.AWACS[2])
		orbit.number = 3
		table.insert(data.tasks, orbit)

		-- set spawn type
		local obj = spawnOnDemand.settings.spawnTypes[4] -- Air
		data.spawn = {}
		data.spawn.type = obj[2]
		data.spawn.action = obj[3]

		return data
	end

	function spawnOnDemand.getRandomAFAC()
		local data = {}
		data.planes = {}
		local planes = spawnOnDemand.planes.AFAC

		-- get random countryID
		data.countryID = spawnOnDemand.getRandomCountryID(true) -- always friendly

		-- get random plane
		local plane = planes[mist.random(#planes)]
		table.insert(data.planes, plane)

		-- set tasking
		data.task = plane.task
		data.tasks = mist.utils.deepCopy(spawnOnDemand.templates.tasks.AFAC)
		local orbit = mist.utils.deepCopy(spawnOnDemand.templates.tasks.AWACS[2])
		orbit.number = 5
		table.insert(data.tasks, orbit)

		-- set spawn type
		local obj = spawnOnDemand.settings.spawnTypes[4] -- Air
		data.spawn = {}
		data.spawn.type = obj[2]
		data.spawn.action = obj[3]

		return data
	end

	function spawnOnDemand.getAircraftProps(type)
		local props
		if type == "AJS37" then
			props = {
				WeapSafeHeight = 0 -- Low
			}
		elseif type == "AV8BNA" then
			props = {
				EWDispenserTBL = 2,
				EWDispenserBR = 2,
				EWDispenserTFR = 1,
				EWDispenserTFL = 1,
				EWDispenserBL = 2,
				EWDispenserTBR = 2,
				RocketBurst = 1
			}
		elseif type == "C-101CC" or type == "C-101EB" then
			props = {
				SoloFlight = true,
				MountIFRHood = false,
				CameraRecorder = false
			}
		elseif type == "L-39C" or type == "L-39ZA" then
			props = {
				SoloFlight = true,
				DismountIFRHood = true
			}
		elseif type == "Mi-8MT" then
			props = {
				LeftEngineResource = 90,
                RightEngineResource = 90,
                GunnersAISkill = 90,
				ExhaustScreen = true,
				AdditionalArmor = true,
				CargoHalfdoor = true
			}
		elseif type == "UH-1H" then
			props = {
				EngineResource = 90,
				GunnersAISkill = 90,
				ExhaustScreen = true
			}
		elseif type == "MiG-19P" then
			props = {
				MountSIRENA = true
			}
		elseif type == "F-5E-3" then
			props = {
				LAU68ROF = 0,
				ChaffSalvo = 0,
				ChaffSalvoInt = 0,
				LAU3ROF = 0,
				ChaffBurstInt = 0,
				LaserCode100 = 6,
				LaserCode1 = 8,
				ChaffBurst = 0,
				FlareBurst = 0,
				LaserCode10 = 8,
				FlareBurstInt = 0
			}
		end
		return props
	end

	function spawnOnDemand.toLog(str)
		if str and string.len(str) > 0 then
			env.info(string.format("SpawnOnDemand: %s", str))
		end
	end

	function spawnOnDemand.toPlayer(str, delay, useSound, showText)
		if str and string.len(str) > 0 then
			local group = spawnOnDemand.group
			delay = delay or 10
			if useSound == nil then useSound = true end
			if showText == nil then showText = true end
			if not group:isExist() then return end -- avoids errors when player dies
			local groupID = group:getID()
			local sound = spawnOnDemand.settings.soundMessage
			if useSound then
				if string.len(sound) > 0 then
					trigger.action.outSoundForGroup(groupID, "l10n/DEFAULT/" .. sound)
				end
			end
			if showText then
				trigger.action.outTextForGroup(groupID, str, delay)
			end
		end
	end

	function spawnOnDemand.toCoalition(str, delay, useSound, showText)
		if str and string.len(str) > 0 then
			delay = delay or 10
			if useSound == nil then useSound = true end
			if showText == nil then showText = true end
			local group = spawnOnDemand.group
			local coa = group:getCoalition()
			local sound = spawnOnDemand.settings.soundMessage
			if useSound then
				if string.len(sound) > 0 then
					trigger.action.outSoundForCoalition(coa, "l10n/DEFAULT/" .. sound)
				end
			end
			if showText then
				trigger.action.outTextForCoalition(coa, str, delay, false)
			end
		end
	end

	function spawnOnDemand.getDistanceFromPlayer(unitName)
		local retVal = "N/A"
		local unit = spawnOnDemand.unit
		local enemy = Unit.getByName(unitName)
		if unit:isExist() and unit:isActive() and unit:getLife() > 1 and enemy then
			local playerPosition = unit:getPosition().p
			local unitPosition = enemy:getPosition().p
			local dist2D = mist.utils.get2DDist(playerPosition, unitPosition)
			local distToNM = mist.utils.metersToNM(dist2D)
			local dist = mist.utils.round(distToNM, 1)
			retVal = string.format("%gnm", dist)
		end
		return retVal
	end

	function spawnOnDemand.getSettings() -- HUGE
		spawnOnDemand.settings = {}

		-- war types
		spawnOnDemand.settings.warTypes = {
			["AIR"] = 1,
			["GROUND"] = 2,
			["SEA"] = 3,
			["USER"] = 4
		}

		-- skills
		spawnOnDemand.settings.skills = {"Average", "Good", "High", "Excellent"}

		-- formations
		spawnOnDemand.settings.formations = {"on_road", "off_road"}

		-- plane spawn types
		spawnOnDemand.settings.spawnTypes = {}
		local spawnTypes = spawnOnDemand.settings.spawnTypes
		table.insert(spawnTypes, {"Parking", "TakeOffParking", "From Parking Area"})
		table.insert(spawnTypes, {"ParkingHot", "TakeOffParkingHot", "From Parking Area Hot"})
		table.insert(spawnTypes, {"Runway", "TakeOff", "From Runway"})
		table.insert(spawnTypes, {"Air", "Turning Point", "Turning Point"})

		-- group types enum
		spawnOnDemand.settings.groupTypes = {
			["PLANES"] = 1,
			["VEHICLES"] = 2,
			["TROOPS"] = 3,
			["HELOS"] = 4,
			["SHIPS"] = 5,
			["AWACS"] = 6, -- does not get included when determining spawn group type during war
			["TANKER"] = 7 -- does not get included when determining spawn group type during war
		}

		-- smoke color
		spawnOnDemand.settings.smokeColor = {}
		local smokeColor = spawnOnDemand.settings.smokeColor
		table.insert(smokeColor, {name = "green", value = trigger.smokeColor.Green})
		table.insert(smokeColor, {name = "red", value = trigger.smokeColor.Red})
		table.insert(smokeColor, {name = "white", value = trigger.smokeColor.White})
		table.insert(smokeColor, {name = "orange", value = trigger.smokeColor.Orange})
		table.insert(smokeColor, {name = "blue", value = trigger.smokeColor.Blue})

		-- templates
		spawnOnDemand.templates = {}
		spawnOnDemand.templates.group = {}
		spawnOnDemand.templates.group.plane = {
			modulation = 0,
			tasks = {},
			radioSet = true,
			task = "",
			uncontrolled = false,
			route = {
				points = {}
			},
			hidden = false,
			units = {},
			name = "",
			communication = true,
			start_time = 0,
			frequency = 0,
			taskSelected = true
		}
		spawnOnDemand.templates.group.vehicle = {
			visible = false,
			taskSelected = true,
			tasks = {},
			hidden = false,
			units = {},
			name = "",
			start_time = 0,
			task = "Ground Nothing"
		}
		spawnOnDemand.templates.group.ship = {
			visible = false,
			tasks = {},
			hidden = false,
			units = {},
			name = "",
			start_time = 0
		}
		spawnOnDemand.templates.unit = {}
		spawnOnDemand.templates.unit.plane = {
			alt = 0,
			hardpoint_racks = true,
			alt_type = "RADIO",
			livery_id = "",
			skill = "",
			speed = 0,
			AddPropAircraft = {},
			type = "",
			psi = 0,
			x = 0,
			name = "",
			payload = {},
			y = 0,
			heading = 0
		}
		spawnOnDemand.templates.unit.vehicle = {
			type = "",
			transportable = {
				randomTransportable = false
			},
			skill = "",
			y = 0,
			x = 0,
			name = "",
			playerCanDrive = false,
			heading = 0
		}
		spawnOnDemand.templates.unit.ship = {
			type = "",
			transportable = {
				randomTransportable = false
			},
			skill = "",
			y = 0,
			x = 0,
			name = "",
			heading = 0
		}
		spawnOnDemand.templates.tasks = {}
		spawnOnDemand.templates.tasks.CAS = {
            [1] = {
                number = 1,
                key = "CAS",
                id = "EngageTargets",
                enabled = true,
                auto = true,
                params = {
                    targetTypes = {
                        [1] = "Helicopters",
                        [2] = "Ground Units",
                        [3] = "Light armed ships"
                    },
                    priority = 0
                }
            },
            [2] = {
                number = 2,
                auto = true,
                id = "WrappedAction",
                enabled = true,
                params = {
                    action = {
                        id = "EPLRS",
                        params = {
                            value = true,
                            groupId = 1
                        }
                    }
                }
            }
		}
		spawnOnDemand.templates.tasks.CAP = {
            [1] = {
                enabled = true,
                key = "CAP",
                id = "EngageTargets",
                number = 1,
                auto = true,
                params = {
                    targetTypes = {
                        [1] = "Air"
                    },
                    priority = 0
                }
            }
		}
		spawnOnDemand.templates.tasks.AWACS = {
			[1] = {
				number = 1,
				auto = true,
				id = "AWACS",
				enabled = true
			},
			[2] = {
				number = 2,
				auto = false,
				id = "Orbit",
				enabled = true,
				params = {
					altitude = 0,
					pattern = "Circle",
					speed = 0,
					speedEdited = true
				}
			}
		}
		spawnOnDemand.templates.tasks.tanker = {
			[1] = {
				number = 1,
				auto = true,
				id = "Tanker",
				enabled = true
			},
			[2] = {
				number = 2,
				auto = false,
				id = "Orbit",
				enabled = true,
				params = {
					altitude = 0,
					altitudeEdited = true,
					pattern = "Race-Track",
					speed = 0,
					speedEdited = true
				}
			},
            [3] = {
            	enabled = true,
            	auto = false,
            	id = "WrappedAction",
            	number = 3,
            	params = {
            		action = {
            			id = "SetImmortal",
            			params = {
            				value = true
            			}
            		}
            	}
            }
		}
		spawnOnDemand.templates.tasks.TACAN = {
			id = "ActivateBeacon",
			params = {
				type = 4, --BEACON_TYPE_TACAN
				system = 4, -- TACAN_TANKER
				AA = true,
				callsign = "",
				frequency = 0,
				channel = 0,
				modeChannel = "Y",
				unitId = 0,
				bearing = true,
			}
		}
		spawnOnDemand.templates.tasks.AFAC = {
            [1] = {
                number = 1,
                id = "FAC",
                enabled = true,
                auto = true,
                params = {
                	number = 1,
                	designation = "Auto",
                	modulation = 0,
                	callname = 6,
                	datalink = true,
                	frequency = 123000000
                }
            },
            [2] = {
                number = 2,
                auto = true,
                id = "WrappedAction",
                enabled = true,
                params = {
                    action = {
                        id = "EPLRS",
                        params = {
                            value = true,
                            groupId = 1
                        }
                    }
                }
            },
            [3] = {
            	enabled = true,
            	auto = false,
            	id = "WrappedAction",
            	number = 3,
            	params = {
            		action = {
            			id = "SetInvisible",
            			params = {
            				value = true
            			}
            		}
            	}
            },
            [4] = {
            	enabled = true,
            	auto = false,
            	id = "WrappedAction",
            	number = 4,
            	params = {
            		action = {
            			id = "SetImmortal",
            			params = {
            				value = true
            			}
            		}
            	}
            }
		}

		-- planes
		spawnOnDemand.planes = {}
		spawnOnDemand.planes.cargo = {}
		table.insert(spawnOnDemand.planes.cargo, {type = "An-26B", fuel = 5500, flare = 384, chaff = 384})
		table.insert(spawnOnDemand.planes.cargo, {type = "An-30M", fuel = 8300, flare = 192, chaff = 192})
		table.insert(spawnOnDemand.planes.cargo, {type = "C-130", fuel = 20830, flare = 60, chaff = 120})
		table.insert(spawnOnDemand.planes.cargo, {type = "C-17A", fuel = 132405, flare = 60, chaff = 120})
		--table.insert(spawnOnDemand.planes.cargo, {type = "DC3", fuel = 1094}) -- mod
		table.insert(spawnOnDemand.planes.cargo, {type = "IL-76MD", fuel = 80000, flare = 96, chaff = 96})
		table.insert(spawnOnDemand.planes.cargo, {type = "Yak-40", fuel = 3080})

		-- Civil Aircraft Mod
		table.insert(spawnOnDemand.planes.cargo, {type = "A_380", fuel = 90700})
		table.insert(spawnOnDemand.planes.cargo, {type = "B_727", fuel = 90700})
		table.insert(spawnOnDemand.planes.cargo, {type = "B_737", fuel = 90700})
		table.insert(spawnOnDemand.planes.cargo, {type = "B_747", fuel = 90700})
		table.insert(spawnOnDemand.planes.cargo, {type = "B_757", fuel = 90700})
		table.insert(spawnOnDemand.planes.cargo, {type = "Cessna_210N", fuel = 5500})

		-- attack
		spawnOnDemand.planes.other = {}
		table.insert(spawnOnDemand.planes.other, {type = "A-10C", fuel = 5029, flare = 120, chaff = 240, ammoType = 1, pylons = { -- ammoType 1 = Combat Mix
				[1] = {["CLSID"] = "ALQ_184"},
				[2] = {["CLSID"] = "{69926055-0DA8-4530-9F2F-C86B157EA9F6}"}, -- LAU-131 M151 HE
				[3] = {["CLSID"] = "{E6A6262A-CA08-4B3D-B030-E1A993B98452}"}, -- AGM-65D
				[4] = {["CLSID"] = "{60CC734F-0AFA-4E2E-82B8-93B941AB11CF}"}, [8] = {["CLSID"] = "{60CC734F-0AFA-4E2E-82B8-93B941AB11CF}"}, -- 3 x Mk82
				[5] = {["CLSID"] = "{GBU-38}"}, [7] = {["CLSID"] = "{GBU-38}"},
				[9] = {["CLSID"] = "LAU_88_AGM_65H_2_R"},
				[10] = {["CLSID"] = "{A111396E-D3E8-4b9c-8AC9-2432489304D5}"}, -- AAQ-28
				[11] = {["CLSID"] = "{DB434044-F5D0-4F1F-9BA9-B73027E18DD3}"} -- LAU-105 AIM9M [NEGATIVE WEIGHT OF PAYLOAD]
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "AJS37", fuel = 4476, flare = 36, chaff = 105, pylons = {
				[2] = {["CLSID"] = "{ARAKM70BHE}"}, [3] = {["CLSID"] = "{ARAKM70BHE}"},
				[4] = {["CLSID"] = "{VIGGEN_X-TANK}"},
				[5] = {["CLSID"] = "{ARAKM70BHE}"}, [6] = {["CLSID"] = "{ARAKM70BHE}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "AV8BNA", fuel = 3520, flare = 120, chaff = 60, pylons = {
				[1] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}, [8] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}, -- AIM-9M
				[2] = {["CLSID"] = "{0D33DDAE-524F-4A4E-B5B8-621754FE3ADE}"}, [3] = {["CLSID"] = "{0D33DDAE-524F-4A4E-B5B8-621754FE3ADE}"}, -- GBU-16
				[6] = {["CLSID"] = "{0D33DDAE-524F-4A4E-B5B8-621754FE3ADE}"}, [7] = {["CLSID"] = "{0D33DDAE-524F-4A4E-B5B8-621754FE3ADE}"},
				[4] = {["CLSID"] = "{GAU_12_Equalizer}"},
				[5] = {["CLSID"] = "{A111396E-D3E8-4b9c-8AC9-2432489304D5}"} -- AN/AAQ-28 litening
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "C-101CC", fuel = 1885, pylons = {
				[1] = {["CLSID"] = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, [7] = {["CLSID"] = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, -- LAU-161 M151
				[2] = {["CLSID"] = "{A021F29D-18AB-4d3e-985C-FC9C60E35E9E}"}, [6] = {["CLSID"] = "{A021F29D-18AB-4d3e-985C-FC9C60E35E9E}"}, -- LAU-68 M151
				[3] = {["CLSID"] = "BIN_200"}, [5] = {["CLSID"] = "BIN_200"},
				[4] = {["CLSID"] = "{C-101-DEFA553}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "F-5E-3", fuel = 2046, flare = 15, chaff = 30, ammoType = 2, pylons = { -- ammoType 2 = Combat Mix
				[1] = {["CLSID"] = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}"}, [7] = {["CLSID"] = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}"}, -- AIM-9P
				[2] = {["CLSID"] = "{LAU3_HE5}"}, [3] = {["CLSID"] = "{LAU3_HE5}"}, [5] = {["CLSID"] = "{LAU3_HE5}"}, [6] = {["CLSID"] = "{LAU3_HE5}"}, -- MK5 HEAT
				[4] = {["CLSID"] = "{0395076D-2F77-4420-9D33-087A4398130B}"} -- 275gal
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "F-86F Sabre", fuel = 1282, pylons = {
				[1] = {["CLSID"] = "{HVARx2}"}, [2] = {["CLSID"] = "{HVARx2}"}, [3] = {["CLSID"] = "{HVARx2}"}, [4] = {["CLSID"] = "{HVARx2}"},
				[7] = {["CLSID"] = "{HVARx2}"}, [8] = {["CLSID"] = "{HVARx2}"}, [10] = {["CLSID"] = "{HVARx2}"}, [9] = {["CLSID"] = "{HVARx2}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "L-39ZA", fuel = 980, pylons = {
				[1] = {["CLSID"] = "{UB-16-57UMP}"}, [5] = {["CLSID"] = "{UB-16-57UMP}"},
				[2] = {["CLSID"] = "{FB3CE165-BF07-4979-887C-92B87F13276B}"}, [4] = {["CLSID"] = "{FB3CE165-BF07-4979-887C-92B87F13276B}"} -- FAB-100
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "MQ-9 Reaper", fuel = 1300, pylons = {
				[1] = {["CLSID"] = "{88D18A5E-99C8-4B04-B40B-1C02F2018B6E}"}, [4] = {["CLSID"] = "{88D18A5E-99C8-4B04-B40B-1C02F2018B6E}"}, -- AGM-114K
				[2] = {["CLSID"] = "AGM114x2_OH_58"}, [3] = {["CLSID"] = "AGM114x2_OH_58"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.other, {type = "MiG-21Bis",	fuel = 2280, flare = 32, chaff = 32, ammoType = 2, pylons = { -- ammoType 2 = A/G
				[1] = {["CLSID"] = "{4203753F-8198-4E85-9924-6F8FF679F9FF}"}, [5] = {["CLSID"] = "{4203753F-8198-4E85-9924-6F8FF679F9FF}"}, -- RBK-250
				[2] = {["CLSID"] = "{UB-32_S5M}"}, [4] = {["CLSID"] = "{UB-32_S5M}"},
				[3] = {["CLSID"] = "{PTB_800_MIG21}"},
				[6] = {["CLSID"] = "{ASO-2}"}
		}, task = "CAS"})
		-- fighter
		table.insert(spawnOnDemand.planes.other, {type = "AJS37", fuel = 4476, flare = 36, chaff = 105, pylons = {
				[1] = {["CLSID"] = "{Robot24J}"}, [7] = {["CLSID"] = "{Robot24J}"},
				[2] = {["CLSID"] = "{Robot74}"}, [3] = {["CLSID"] = "{Robot74}"},
				[4] = {["CLSID"] = "{VIGGEN_X-TANK}"},
				[5] = {["CLSID"] = "{Robot74}"}, [6] = {["CLSID"] = "{Robot74}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "AV8BNA", fuel = 3520, flare = 120, chaff = 60, pylons = {
				[1] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}, [8] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}, -- AIM-9M
				[2] = {["CLSID"] = "{LAU_7_AGM_122_SIDEARM}"}, [7] = {["CLSID"] = "{LAU_7_AGM_122_SIDEARM}"},
				[3] = {["CLSID"] = "LAU_117_AGM_65G"}, [6] = {["CLSID"] = "LAU_117_AGM_65G"},
				[4] = {["CLSID"] = "{GAU_12_Equalizer}"}, [5] = {["CLSID"] = "{ALQ_164_RF_Jammer}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "C-101CC", fuel = 1885, pylons = {
				[1] = {["CLSID"] = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}"}, [7] = {["CLSID"] = "{9BFD8C90-F7AE-4e90-833B-BFD0CED0E536}"}, -- AIM-9P
				[4] = {["CLSID"] = "{AN-M3}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "F-5E-3", fuel = 2046, flare = 15, chaff = 30, ammoType = 2, pylons = { -- ammoType 2 = Combat Mix
				[1] = {["CLSID"] = "{AIM-9P5}"}, [7] = {["CLSID"] = "{AIM-9P5}"},
				[3] = {["CLSID"] = "{PTB-150GAL}"}, [4] = {["CLSID"] = "{PTB-150GAL}"}, [5] = {["CLSID"] = "{PTB-150GAL}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "F-86F Sabre", fuel = 1282, pylons = {
				[5] = {["CLSID"] = "{GAR-8}"}, [6] = {["CLSID"] = "{GAR-8}"},
				[7] = {["CLSID"] = "{PTB_120_F86F35}"}, [4] = {["CLSID"] = "{PTB_120_F86F35}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "L-39C", fuel = 980, pylons = {
				[1] = {["CLSID"] = "{R-3S}"}, [3] = {["CLSID"] = "{R-3S}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "M-2000C", fuel = 3165, flare = 16, chaff = 112, pylons = {
				[8] = {["CLSID"] = "{Matra_S530D}"}, [2] = {["CLSID"] = "{Matra_S530D}"}, -- [NEGATIVE WEIGHT OF PAYLOAD]
				[9] = {["CLSID"] = "{MMagicII}"}, [1] = {["CLSID"] = "{MMagicII}"},
				[5] = {["CLSID"] = "{M2KC_RPL_522}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "MiG-15bis", fuel = 1172, pylons = {
				[1] = {["CLSID"] = "PTB300_MIG15"}, [2] = {["CLSID"] = "PTB300_MIG15"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "MiG-21Bis", fuel = 2280, flare = 32, chaff = 32, ammoType = 3, pylons = { -- ammoType 3 = A/A
				[1] = {["CLSID"] = "{R-60 2L}"}, [2] = {["CLSID"] = "{R-3R}"},
				[3] = {["CLSID"] = "{PTB_490C_MIG21}"},
				[4] = {["CLSID"] = "{R-3R}"}, [5] = {["CLSID"] = "{R-60 2R}"},
				[6] = {["CLSID"] = "{ASO-2}"}
		}, task = "CAP"})
		table.insert(spawnOnDemand.planes.other, {type = "MiG-19P", fuel = 1800, ammoType = 1, pylons = { -- ammoType 1 = AP-T, APHE, HEI-T, HEI-T, HEI-T
				[1] = {["CLSID"] = "{K-13A}"}, [6] = {["CLSID"] = "{K-13A}"},
				[2] = {["CLSID"] = "PTB760_MIG19"}, [5] = {["CLSID"] = "PTB760_MIG19"}
		}, task = "CAP"})
		-- CAS
		-- TODO: use random selection from "attack" instead of duplicate definition? (what about payload)
		spawnOnDemand.planes.CAS = {}
		table.insert(spawnOnDemand.planes.CAS, {type = "A-10C", fuel = 2515, flare = 120, chaff = 240, ammoType = 1, pylons = { -- ammoType 1 = Combat Mix
				[1] = {["CLSID"] = "ALQ_184"},
				[3] = {["CLSID"] = "LAU_88_AGM_65D_ONE"}, [9] = {["CLSID"] = "LAU_88_AGM_65D_ONE"},
				[5] = {["CLSID"] = "{BDU-50LGB}"}, [7] = {["CLSID"] = "{BDU-50LGB}"},
				[10] = {["CLSID"] = "{A111396E-D3E8-4b9c-8AC9-2432489304D5}"} -- AAQ-28
		}, task = "CAS"})
		table.insert(spawnOnDemand.planes.CAS, {type = "AV8BNA", fuel = 3520, flare = 120, chaff = 60, pylons = {
				[1] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}, [8] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}, -- AIM-9M
				[2] = {["CLSID"] = "{LAU_7_AGM_122_SIDEARM}"}, [7] = {["CLSID"] = "{LAU_7_AGM_122_SIDEARM}"},
				[3] = {["CLSID"] = "LAU_117_AGM_65G"}, [6] = {["CLSID"] = "LAU_117_AGM_65G"},
				[4] = {["CLSID"] = "{GAU_12_Equalizer}"}, [5] = {["CLSID"] = "{ALQ_164_RF_Jammer}"}
		}, task = "CAS"})
		-- AFAC
		spawnOnDemand.planes.AFAC = {}
		table.insert(spawnOnDemand.planes.AFAC, {type = "MQ-9 Reaper", fuel = 1300, pylons = {}, task = "AFAC"})
		table.insert(spawnOnDemand.planes.AFAC, {type = "RQ-1A Predator", fuel = 200, pylons = {}, task = "AFAC"})

		-- vehicles
		spawnOnDemand.vehicles = {}
		spawnOnDemand.vehicles.cargo = {}
		--table.insert(spawnOnDemand.vehicles.cargo, "SEMI_BLUE") -- Semi Truck Blue (ranger)
		--table.insert(spawnOnDemand.vehicles.cargo, "SEMI_RED") -- Semi Truck Red (ranger)
		table.insert(spawnOnDemand.vehicles.cargo, "GAZ-3307")
		table.insert(spawnOnDemand.vehicles.cargo, "MAZ-6303")
		table.insert(spawnOnDemand.vehicles.cargo, "UAZ-469")
		table.insert(spawnOnDemand.vehicles.cargo, "VAZ Car") -- VAZ-2109 (wheels not animated)
		table.insert(spawnOnDemand.vehicles.cargo, "Trolley bus") -- ZIU-9
		table.insert(spawnOnDemand.vehicles.cargo, "ZIL-4331") -- ZIL-4334
		--table.insert(spawnOnDemand.vehicles.cargo, "Mercedes700K") -- (markindel)
		-- aa
		spawnOnDemand.vehicles.aa = {}
		table.insert(spawnOnDemand.vehicles.aa, "ZSU-23-4 Shilka")--aa
		table.insert(spawnOnDemand.vehicles.aa, "Strela-10M3")--sam
		table.insert(spawnOnDemand.vehicles.aa, "Strela-1 9P31")--sam
		table.insert(spawnOnDemand.vehicles.aa, "2S6 Tunguska")--sam
		table.insert(spawnOnDemand.vehicles.aa, "Ural-375 ZU-23")--aa
		table.insert(spawnOnDemand.vehicles.aa, "Osa 9A33 ln")--sam
		table.insert(spawnOnDemand.vehicles.aa, "Tor 9A331")--sam
		-- other
		spawnOnDemand.vehicles.other = {}
		table.insert(spawnOnDemand.vehicles.other, "BTR-80")
		table.insert(spawnOnDemand.vehicles.other, "BRDM-2")
		--table.insert(spawnOnDemand.vehicles.other, "DODGE_TECH") -- Technical large 12.7mm (ranger)
		table.insert(spawnOnDemand.vehicles.other, "M1043 HMMWV Armament")
		table.insert(spawnOnDemand.vehicles.other, "M1126 Stryker ICV")
		--table.insert(spawnOnDemand.vehicles.other, "TOYO_TECH") -- Technical Small 12.7mm (ranger)

		-- helicopters
		spawnOnDemand.helos = {}
		spawnOnDemand.helos.cargo = {}
		table.insert(spawnOnDemand.helos.cargo, {type = "CH-47D", fuel = 3600, flare = 120, chaff = 120})
		table.insert(spawnOnDemand.helos.cargo, {type = "CH-53E", fuel = 1908, flare = 60, chaff = 60})
		table.insert(spawnOnDemand.helos.cargo, {type = "Ka-27", fuel = 2616})
		table.insert(spawnOnDemand.helos.cargo, {type = "Mi-26", fuel = 9600, flare = 192})
		table.insert(spawnOnDemand.helos.cargo, {type = "UH-60A", fuel = 1100, flare = 30, chaff = 30})
		-- attack
		spawnOnDemand.helos.other = {}
		table.insert(spawnOnDemand.helos.other, {type = "AH-1W", fuel = 1250, flare = 30, chaff = 30, pylons = {
				[1] = {["CLSID"] = "{88D18A5E-99C8-4B04-B40B-1C02F2018B6E}"}, [4] = {["CLSID"] = "{88D18A5E-99C8-4B04-B40B-1C02F2018B6E}"}, -- AGM-114
				[2] = {["CLSID"] = "{M260_HYDRA}"}, [3] = {["CLSID"] = "{M260_HYDRA}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "AH-64D", fuel = 1157, flare = 30, chaff = 30, pylons = {
				[1] = {["CLSID"] = "{88D18A5E-99C8-4B04-B40B-1C02F2018B6E}"}, [4] = {["CLSID"] = "{88D18A5E-99C8-4B04-B40B-1C02F2018B6E}"}, -- AGM-114K
				[2] = {["CLSID"] = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"}, [3] = {["CLSID"] = "{FD90A1DC-9147-49FA-BF56-CB83EF0BD32B}"} -- MK151 HE
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "Ka-50", fuel = 1450, flare = 128, chaff = 0, pylons = {
				[1] = {["CLSID"] = "{A6FD14D3-6D30-4C85-88A7-8D17BEE120E2}"}, [4] = {["CLSID"] = "{A6FD14D3-6D30-4C85-88A7-8D17BEE120E2}"}, -- 9A4172 Vikhr
				[2] = {["CLSID"] = "{6A4B9E69-64FE-439a-9163-3A87FB6A4D81}"}, [3] = {["CLSID"] = "{6A4B9E69-64FE-439a-9163-3A87FB6A4D81}"} -- S-8KOM
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "Mi-24V", fuel = 1704, flare = 192, chaff = 0, pylons = {
				[1] = {["CLSID"] = "{B919B0F4-7C25-455E-9A02-CEA51DB895E3}"}, [2] = {["CLSID"] = "{B919B0F4-7C25-455E-9A02-CEA51DB895E3}"},
				[5] = {["CLSID"] = "{B919B0F4-7C25-455E-9A02-CEA51DB895E3}"}, [6] = {["CLSID"] = "{B919B0F4-7C25-455E-9A02-CEA51DB895E3}"}, -- 9M114 Shturm-V
				[3] = {["CLSID"] = "{637334E4-AB5A-47C0-83A6-51B7F1DF3CD5}"}, [4] = {["CLSID"] = "{637334E4-AB5A-47C0-83A6-51B7F1DF3CD5}"} -- S-5KO
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "Mi-8MT", fuel = 1929, flare = 192, pylons = {
				[1] = {["CLSID"] = "GUV_VOG"}, [6] = {["CLSID"] = "GUV_VOG"},
				[2] = {["CLSID"] = "GUV_YakB_GSHP"}, [5] = {["CLSID"] = "GUV_YakB_GSHP"},
				[3] = {["CLSID"] = "{6A4B9E69-64FE-439a-9163-3A87FB6A4D81}"}, [4] = {["CLSID"] = "{6A4B9E69-64FE-439a-9163-3A87FB6A4D81}"}, -- S-8KOM
				[7] = {["CLSID"] = "KORD_12_7"}, -- door gunners
				[8] = {["CLSID"] = "PKT_7_62"} -- rear gunner
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "SA342L", fuel = 375, flare = 32, pylons = {
				[2] = {["CLSID"] = "{LAU_SNEB68G}"},
				[6] = {["CLSID"] = "{IR_Deflector}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "SA342M", fuel = 291, flare = 32, pylons = {
				[1] = {["CLSID"] = "{HOT3D}"}, [3] = {["CLSID"] = "{HOT3D}"},
				[2] = {["CLSID"] = "{HOT3G}"}, [4] = {["CLSID"] = "{HOT3G}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "SA342Mistral", fuel = 416, flare = 32, pylons = {
				[1] = {["CLSID"] = "{MBDA_MistralD}"}, [2] = {["CLSID"] = "{MBDA_MistralD}"},
				[3] = {["CLSID"] = "{MBDA_MistralD}"}, [4] = {["CLSID"] = "{MBDA_MistralD}"},
				[6] = {["CLSID"] = "{IR_Deflector}"}
		}, task = "CAS"})
		table.insert(spawnOnDemand.helos.other, {type = "UH-1H", fuel = 631, flare = 60, pylons = {
				[1] = {["CLSID"] = "M134_L"}, [6] = {["CLSID"] = "M134_R"},
				[2] = {["CLSID"] = "M261_MK151"}, [5] = {["CLSID"] = "M261_MK151"},
				[3] = {["CLSID"] = "M60_SIDE_L"}, [4] = {["CLSID"] = "M60_SIDE_R"} -- door gunners
		}, task = "CAS"})

		-- ships
		spawnOnDemand.ships = {}
		spawnOnDemand.ships.cargo = {}
		--table.insert(spawnOnDemand.ships.cargo, "Cruise_Ship") -- cruise ship (crazyeddie)
		table.insert(spawnOnDemand.ships.cargo, "Dry-cargo ship-1") -- dry cargo
		table.insert(spawnOnDemand.ships.cargo, "Dry-cargo ship-2") -- dry cargo
		table.insert(spawnOnDemand.ships.cargo, "ELNYA") -- tanker
		table.insert(spawnOnDemand.ships.cargo, "KILO") -- unarmed, sub
		table.insert(spawnOnDemand.ships.cargo, "SOM") -- SSK 641B, unarmed, sub
		table.insert(spawnOnDemand.ships.cargo, "ZWEZDNY") -- cruise ship
		--table.insert(spawnOnDemand.ships.cargo, "Amerigo Vespucci Full Sail") -- (markindel)
		--table.insert(spawnOnDemand.ships.cargo, "Amerigo Vespucci Furled Sails") -- (markindel)
		--table.insert(spawnOnDemand.ships.cargo, "USS_Constitution") -- (markindel)
		-- navy
		spawnOnDemand.ships.other = {}
		table.insert(spawnOnDemand.ships.other, "speedboat") -- armed
		table.insert(spawnOnDemand.ships.other, "PERRY") -- frigate
		--table.insert(spawnOnDemand.ships.other, "Rebel_Boat") -- fishing (upuaut)
		--table.insert(spawnOnDemand.ships.other, "Supply Ship") -- armed (upuaut)
		table.insert(spawnOnDemand.ships.other, "TICONDEROG") -- normandy, cruiser
		--table.insert(spawnOnDemand.ships.other, "VINSON") -- carrier
		--table.insert(spawnOnDemand.ships.other, "KUZNECOW") -- carrier
		table.insert(spawnOnDemand.ships.other, "MOLNIYA") -- corvette
		table.insert(spawnOnDemand.ships.other, "MOSCOW") -- cruiser
		table.insert(spawnOnDemand.ships.other, "NEUSTRASH") -- frigate
		table.insert(spawnOnDemand.ships.other, "PIOTR") -- cruiser
		table.insert(spawnOnDemand.ships.other, "REZKY") -- frigate

		-- AWACS
		spawnOnDemand.AWACS = {}
		spawnOnDemand.AWACS.blue = {}
		table.insert(spawnOnDemand.AWACS.blue, {type = "E-3A", fuel = 65000, flare = 60, chaff = 120})
		spawnOnDemand.AWACS.red = {}
		table.insert(spawnOnDemand.AWACS.red, {type = "A-50", fuel = 70000, flare = 192, chaff = 192})

		-- Tankers
		spawnOnDemand.tankers = {}
		spawnOnDemand.tankers.blue = {}
		--table.insert(spawnOnDemand.tankers.blue, {type = "KC130", fuel = 30000, flare = 60, chaff = 120})
		table.insert(spawnOnDemand.tankers.blue, {type = "KC-135", fuel = 90700})
		--table.insert(spawnOnDemand.tankers.blue, {type = "KC135MPRS", fuel = 90700, flare = 60, chaff = 120})
		spawnOnDemand.tankers.red = {}
		table.insert(spawnOnDemand.tankers.red, {type = "IL-78M", fuel = 90000, flare = 96, chaff = 96})

		-- localizing settings
		local settings = settings or {}

		-- plane settings
		spawnOnDemand.settings.showPlanesF10 = settings.showPlanesF10
		if spawnOnDemand.settings.showPlanesF10 == nil then spawnOnDemand.settings.showPlanesF10 = true end
		spawnOnDemand.settings.planeNumber = settings.planeNumber or 0
		if spawnOnDemand.settings.planeNumber < 0 or spawnOnDemand.settings.planeNumber > 4 then
			spawnOnDemand.settings.planeNumber = 0
		end
		spawnOnDemand.settings.planeMinDist = settings.planeMinDist or 10
		if spawnOnDemand.settings.planeMinDist < 0 then
			spawnOnDemand.settings.planeMinDist = 10
		end
		spawnOnDemand.settings.planeMaxDist = settings.planeMaxDist or 20
		if spawnOnDemand.settings.planeMaxDist < 0 or spawnOnDemand.settings.planeMaxDist < spawnOnDemand.settings.planeMinDist then
			spawnOnDemand.settings.planeMaxDist = 20
		end
		spawnOnDemand.settings.planeSkill = settings.planeSkill or "Random"
		spawnOnDemand.settings.planeShoot = settings.planeShoot
		if spawnOnDemand.settings.planeShoot == nil then spawnOnDemand.settings.planeShoot = true end
		spawnOnDemand.settings.planeRouteLength = settings.planeRouteLength or 10
		if spawnOnDemand.settings.planeRouteLength < 0 then
			spawnOnDemand.settings.planeRouteLength = 10
		end
		spawnOnDemand.settings.planeRouteLoop = settings.planeRouteLoop
		if spawnOnDemand.settings.planeRouteLoop == nil then spawnOnDemand.settings.planeRouteLoop = true end
		spawnOnDemand.settings.planeFrequency = settings.planeFrequency or 124
		if spawnOnDemand.settings.planeFrequency <= 0 then
			spawnOnDemand.settings.planeFrequency = 124
		end
		spawnOnDemand.settings.planeBeacon = settings.planeBeacon or false
		spawnOnDemand.settings.planeSpawnType = settings.planeSpawnType or "Random"

		-- vehicle settings
		spawnOnDemand.settings.showVehiclesF10 = settings.showVehiclesF10
		if spawnOnDemand.settings.showVehiclesF10 == nil then spawnOnDemand.settings.showVehiclesF10 = true end
		spawnOnDemand.settings.vehicleNumber = settings.vehicleNumber or 0
		if spawnOnDemand.settings.vehicleNumber < 0 or spawnOnDemand.settings.vehicleNumber > 6 then
			spawnOnDemand.settings.vehicleNumber = 0
		end
		spawnOnDemand.settings.vehicleMinDist = settings.vehicleMinDist or 1
		if spawnOnDemand.settings.vehicleMinDist < 0 then
			spawnOnDemand.settings.vehicleMinDist = 1
		end
		spawnOnDemand.settings.vehicleMaxDist = settings.vehicleMaxDist or 10
		if spawnOnDemand.settings.vehicleMaxDist < 0 or spawnOnDemand.settings.vehicleMaxDist < spawnOnDemand.settings.vehicleMinDist then
			spawnOnDemand.settings.vehicleMaxDist = 10
		end
		spawnOnDemand.settings.vehicleSkill = settings.vehicleSkill or "Random"
		spawnOnDemand.settings.vehicleShoot = settings.vehicleShoot
		if spawnOnDemand.settings.vehicleShoot == nil then spawnOnDemand.settings.vehicleShoot = true end
		spawnOnDemand.settings.vehicleOnOffRoad = settings.vehicleOnOffRoad or "Random"
		spawnOnDemand.settings.vehicleRouteLength = settings.vehicleRouteLength or 10
		if spawnOnDemand.settings.vehicleRouteLength < 0 then
			spawnOnDemand.settings.vehicleRouteLength = 10
		end
		spawnOnDemand.settings.vehicleRouteLoop = settings.vehicleRouteLoop or false
		if spawnOnDemand.settings.vehicleRouteLoop == nil then spawnOnDemand.settings.vehicleRouteLoop = true end
		spawnOnDemand.settings.vehicleBeacon = settings.vehicleBeacon
		if spawnOnDemand.settings.vehicleBeacon == nil then spawnOnDemand.settings.vehicleBeacon = true end

		-- troop settings
		spawnOnDemand.settings.showTroopsF10 = settings.showTroopsF10
		if spawnOnDemand.settings.showTroopsF10 == nil then spawnOnDemand.settings.showTroopsF10 = true end
		spawnOnDemand.settings.troopNumber = settings.troopNumber or 0
		if spawnOnDemand.settings.troopNumber < 0 or spawnOnDemand.settings.troopNumber > 6 then
			spawnOnDemand.settings.troopNumber = 0
		end
		spawnOnDemand.settings.troopMinDist = settings.troopMinDist or 1
		if spawnOnDemand.settings.troopMinDist < 0 then
			spawnOnDemand.settings.troopMinDist = 1
		end
		spawnOnDemand.settings.troopMaxDist = settings.troopMaxDist or 10
		if spawnOnDemand.settings.troopMaxDist < 0 or spawnOnDemand.settings.troopMaxDist < spawnOnDemand.settings.troopMinDist then
			spawnOnDemand.settings.troopMaxDist = 10
		end
		spawnOnDemand.settings.troopSkill = settings.troopSkill or "Random"
		spawnOnDemand.settings.troopShoot = settings.troopShoot
		if spawnOnDemand.settings.troopShoot == nil then spawnOnDemand.settings.troopShoot = true end
		spawnOnDemand.settings.troopOnOffRoad = settings.troopOnOffRoad or "Random"
		spawnOnDemand.settings.troopRouteLength = settings.troopRouteLength or 10
		if spawnOnDemand.settings.troopRouteLength < 0 then
			spawnOnDemand.settings.troopRouteLength = 10
		end
		spawnOnDemand.settings.troopRouteLoop = settings.troopRouteLoop or false
		spawnOnDemand.settings.troopBeacon = settings.troopBeacon
		if spawnOnDemand.settings.troopBeacon == nil then spawnOnDemand.settings.troopBeacon = true end

		-- helicopter settings
		spawnOnDemand.settings.showHelosF10 = settings.showHelosF10
		if spawnOnDemand.settings.showHelosF10 == nil then spawnOnDemand.settings.showHelosF10 = true end
		spawnOnDemand.settings.heloNumber = settings.heloNumber or 0
		if spawnOnDemand.settings.heloNumber < 0 or spawnOnDemand.settings.heloNumber > 4 then
			spawnOnDemand.settings.heloNumber = 0
		end
		spawnOnDemand.settings.heloMinDist = settings.heloMinDist or 10
		if spawnOnDemand.settings.heloMinDist < 0 then
			spawnOnDemand.settings.heloMinDist = 10
		end
		spawnOnDemand.settings.heloMaxDist = settings.heloMaxDist or 20
		if spawnOnDemand.settings.heloMaxDist < 0 or spawnOnDemand.settings.heloMaxDist < spawnOnDemand.settings.heloMinDist then
			spawnOnDemand.settings.heloMaxDist = 20
		end
		spawnOnDemand.settings.heloSkill = settings.heloSkill or "Random"
		spawnOnDemand.settings.heloShoot = settings.heloShoot
		if spawnOnDemand.settings.heloShoot == nil then spawnOnDemand.settings.heloShoot = true end
		spawnOnDemand.settings.heloRouteLength = settings.heloRouteLength or 10
		if spawnOnDemand.settings.heloRouteLength < 0 then
			spawnOnDemand.settings.heloRouteLength = 10
		end
		spawnOnDemand.settings.troopRouteLoop = settings.troopRouteLoop
		if spawnOnDemand.settings.troopRouteLoop == nil then spawnOnDemand.settings.troopRouteLoop = true end
		spawnOnDemand.settings.heloFrequency = settings.heloFrequency or 124
		if spawnOnDemand.settings.heloFrequency <= 0 then
			spawnOnDemand.settings.heloFrequency = 124
		end
		spawnOnDemand.settings.heloBeacon = settings.heloBeacon or false
		spawnOnDemand.settings.heloSpawnType = settings.heloSpawnType or "Random"

		-- ship settings
		spawnOnDemand.settings.showShipsF10 = settings.showShipsF10
		if spawnOnDemand.settings.showShipsF10 == nil then spawnOnDemand.settings.showShipsF10 = true end
		spawnOnDemand.settings.shipNumber = settings.shipNumber or 0
		if spawnOnDemand.settings.shipNumber < 0 or spawnOnDemand.settings.shipNumber > 6 then
			spawnOnDemand.settings.shipNumber = 0
		end
		spawnOnDemand.settings.shipMinDist = settings.shipMinDist or 10
		if spawnOnDemand.settings.shipMinDist < 0 then
			spawnOnDemand.settins.shipMinDist = 10
		end
		spawnOnDemand.settings.shipMaxDist = settings.shipMaxDist or 20
		if spawnOnDemand.settings.shipMaxDist < 0 or spawnOnDemand.settings.shipMaxDist < spawnOnDemand.settings.shipMinDist then
			spawnOnDemand.settings.shipMaxDist = 20
		end
		spawnOnDemand.settings.shipSkill = settings.shipSkill or "Random"
		spawnOnDemand.settings.shipShoot = settings.shipShoot
		if spawnOnDemand.settings.shipShoot == nil then spawnOnDemand.settings.shipShoot = true end
		spawnOnDemand.settings.shipRouteLength = settings.shipRouteLength or 10
		if spawnOnDemand.settings.shipRouteLength < 0 then
			spawnOnDemand.settings.shipRouteLength = 10
		end
		spawnOnDemand.settings.shipRouteLoop = settings.shipRouteLoop
		if spawnOnDemand.settings.shipRouteLoop == nil then spawnOnDemand.settings.shipRouteLoop = true end

		-- AWACS settings
		spawnOnDemand.settings.awacsMinDist = settings.awacsMinDist or 5
		if spawnOnDemand.settings.awacsMinDist < 0 then
			spawnOnDemand.settings.awacsMinDist = 5
		end
		spawnOnDemand.settings.awacsMaxDist = settings.awacsMaxDist or 10
		if spawnOnDemand.settings.awacsMaxDist < 0 or spawnOnDemand.settings.awacsMaxDist < spawnOnDemand.settings.awacsMinDist then
			spawnOnDemand.settings.awacsMaxDist = 10
		end
		spawnOnDemand.settings.awacsSkill = settings.awacsSkill or "Random"
		spawnOnDemand.settings.awacsFrequency = settings.awacsFrequency or 124
		if spawnOnDemand.settings.awacsFrequency <= 0 then
			spawnOnDemand.settings.awacsFrequency = 124
		end
		spawnOnDemand.settings.awacsBeacon = settings.awacsBeacon or false
		spawnOnDemand.settings.awacsInvisible = settings.awacsInvisible
		if spawnOnDemand.settings.awacsInvisible == nil then spawnOnDemand.settings.awacsInvisible = true end

		-- Tanker settings
		spawnOnDemand.settings.tankerMinDist = settings.tankerMinDist or 5
		if spawnOnDemand.settings.tankerMinDist < 0 then
			spawnOnDemand.settings.tankerMinDist = 5
		end
		spawnOnDemand.settings.tankerMaxDist = settings.tankerMaxDist or 10
		if spawnOnDemand.settings.tankerMaxDist < 0 or spawnOnDemand.settings.tankerMaxDist < spawnOnDemand.settings.tankerMinDist then
			spawnOnDemand.settings.tankerMaxDist = 10
		end
		spawnOnDemand.settings.tankerSkill = settings.tankerSkill or "Excellent"
		spawnOnDemand.settings.tankerFrequency = settings.tankerFrequency or 251
		if spawnOnDemand.settings.tankerFrequency <= 0 then
			spawnOnDemand.settings.tankerFrequency = 251
		end
		spawnOnDemand.settings.tankerBeacon = spawnOnDemand.settings.tankerBeacon or true
		spawnOnDemand.settings.tankerInvisible = settings.tankerInvisible
		if spawnOnDemand.settings.tankerInvisible == nil then spawnOnDemand.settings.tankerInvisible = true end

		-- player warning settings
		spawnOnDemand.settings.showLowFuel = settings.showLowFuel
		if spawnOnDemand.settings.showLowFuel == nil then spawnOnDemand.settings.showLowFuel = true end
		spawnOnDemand.settings.lowFuelPercent = settings.lowFuelPercent or 10
		if spawnOnDemand.settings.lowFuelPercent < 0 then -- NOTE: no max because external fuel tanks can return value over 100%
			spawnOnDemand.settings.lowFuelPercent = 10
		end

		-- war settings
		spawnOnDemand.settings.showWarF10 = settings.showWarF10
		if spawnOnDemand.settings.showWarF10 == nil then spawnOnDemand.settings.showWarF10 = true end
		spawnOnDemand.settings.warGroupsMin = settings.warGroupsMin or 25
		if spawnOnDemand.settings.warGroupsMin < 0 then
			spawnOnDemand.settings.warGroupsMin = 25
		end
		spawnOnDemand.settings.warGroupsMax = settings.warGroupsMax or 50
		if spawnOnDemand.settings.warGroupsMax < 0 or spawnOnDemand.settings.warGroupsMax < spawnOnDemand.settings.warGroupsMin then
			spawnOnDemand.settings.warGroupsMax = 50
		end
		spawnOnDemand.settings.warDistribution = settings.warDistribution or {40, 30, 10, 10, 10}
		if type(spawnOnDemand.settings.warDistribution) ~= "table" or #spawnOnDemand.settings.warDistribution == 0 then
			spawnOnDemand.settings.warDistribution = {40, 30, 10, 10, 10}
		end
		local total = 0
		for i = 1, #spawnOnDemand.settings.warDistribution do
			total = total + spawnOnDemand.settings.warDistribution[i]
		end
		if total < 0 or total > 100 then
			spawnOnDemand.settings.warDistribution = {40, 30, 10, 10, 10}
		end
		spawnOnDemand.settings.warTeams = settings.warTeams or 2
		if spawnOnDemand.settings.warTeams < 0 or spawnOnDemand.settings.warTeams > 2 then
			spawnOnDemand.settings.warTeams = 2
		end
		spawnOnDemand.settings.warFlag = settings.warFlag or 1234
		if spawnOnDemand.settings.warFlag <= 0 then
			spawnOnDemand.settings.warFlag = 1234
		end
		trigger.action.setUserFlag(spawnOnDemand.settings.warFlag, false)
		spawnOnDemand.settings.winID = 0
		spawnOnDemand.settings.warAWACS = settings.warAWACS
		if spawnOnDemand.settings.warAWACS == nil then spawnOnDemand.settings.warAWACS = true end
		spawnOnDemand.settings.warTankers = settings.warTankers
		if spawnOnDemand.settings.warTankers == nil then spawnOnDemand.settings.warTankers = true end
		spawnOnDemand.settings.warFriendlyMinDist = settings.warFriendlyMinDist or 1
		if spawnOnDemand.settings.warFriendlyMinDist <= 0 then
			spawnOnDemand.settings.warFriendlyMinDist = 1
		end
		spawnOnDemand.settings.warFriendlyMaxDist = settings.warFriendlyMaxDist or 5
		if spawnOnDemand.settings.warFriendlyMaxDist <= 0 or spawnOnDemand.settings.warFriendlyMaxDist < spawnOnDemand.settings.warFriendlyMinDist then
			spawnOnDemand.settings.warFriendlyMaxDist = 5
		end
		spawnOnDemand.settings.warEnemyMinDist = settings.warEnemyMinDist or 5
		if spawnOnDemand.settings.warEnemyMinDist <= 0 then
			spawnOnDemand.settings.warEnemyMinDist = 5
		end
		spawnOnDemand.settings.warEnemyMaxDist = settings.warEnemyMaxDist or 10
		if spawnOnDemand.settings.warEnemyMaxDist <= 0 or spawnOnDemand.settings.warEnemyMaxDist < spawnOnDemand.settings.warEnemyMinDist then
			spawnOnDemand.settings.warEnemyMaxDist = 10
		end

		-- CAS settings
		spawnOnDemand.settings.showSupportF10 = settings.showSupportF10
		if spawnOnDemand.settings.showSupportF10 == nil then spawnOnDemand.settings.showSupportF10 = true end
		spawnOnDemand.settings.casWaitTime = settings.casWaitTime or 300
		if spawnOnDemand.settings.casWaitTime <= 0 then
			spawnOnDemand.settings.casWaitTime = 300
		end
		spawnOnDemand.settings.afacWaitTime = settings.afacWaitTime or 300
		if spawnOnDemand.settings.afacWaitTime <= 0 then
			spawnOnDemand.settings.afacWaitTime = 300
		end
		spawnOnDemand.settings.afacSmoke = settings.afacSmoke
		if spawnOnDemand.settings.afacSmoke == nil then spawnOnDemand.settings.afacSmoke = true end
		spawnOnDemand.settings.artyMaxDist = settings.artyMaxDist or 5
		if spawnOnDemand.settings.artyMaxDist <= 0 then
			spawnOnDemand.settings.artyMaxDist = 5
		end
		spawnOnDemand.settings.artyRounds = settings.artyRounds or 12
		if spawnOnDemand.settings.artyRounds <= 0 then
			spawnOnDemand.settings.artyRounds = 12
		end
		spawnOnDemand.settings.artyWaitTime = settings.artyWaitTime or 120
		if spawnOnDemand.settings.artyWaitTime <= 0 then
			spawnOnDemand.settings.artyWaitTime = 120
		end
		spawnOnDemand.settings.artySmoke = settings.artySmoke
		if spawnOnDemand.settings.artySmoke == nil then spawnOnDemand.settings.artySmoke = true end
		spawnOnDemand.settings.artySmokeColor = settings.artySmokeColor or "Random"
		spawnOnDemand.settings.CAStimer = 0
		spawnOnDemand.settings.CASholdTimer = 0
		spawnOnDemand.settings.AFACtimer = 0
		spawnOnDemand.settings.AFACholdTimer = 0
		spawnOnDemand.settings.artyTimer = 0
		spawnOnDemand.settings.artyHoldTimer = 0
		spawnOnDemand.settings.artyNum = 0

		-- scenario settings
		spawnOnDemand.settings.showScenariosF10 = settings.showScenariosF10
		if spawnOnDemand.settings.showScenariosF10 == nil then spawnOnDemand.settings.showScenariosF10 = true end
		spawnOnDemand.settings.carBombMinTime = settings.carBombMinTime or 300
		if spawnOnDemand.settings.carBombMinTime < 0 then
			spawnOnDemand.settings.carBombMinTime = 300
		end
		spawnOnDemand.settings.carBombMaxTime = settings.carBombMaxTime or 600
		if spawnOnDemand.settings.carBombMaxTime < 0 or spawnOnDemand.settings.carBombMaxTime < spawnOnDemand.settings.carBombMinTime then
			spawnOnDemand.settings.carBombMaxTime = 600
		end
		spawnOnDemand.settings.carBombModel = settings.carBombModel or "SEMI_RED"
		spawnOnDemand.settings.carBombTimer = 0
		spawnOnDemand.settings.carBomb = nil
		spawnOnDemand.settings.vipNumVehicles = settings.vipNumVehicles or 5
		if spawnOnDemand.settings.vipNumVehicles < 1 then
			spawnOnDemand.settings.vipNumVehicles = 5
		end
		spawnOnDemand.settings.vipModel = settings.vipModel or "Mercedes700K"
		spawnOnDemand.settings.vipEscortModel = settings.vipEscortModel or "DODGE_TECH"
		spawnOnDemand.settings.vip = nil
		spawnOnDemand.settings.boatsNumVehicles = settings.boatsNumVehicles or 5
		if spawnOnDemand.settings.boatsNumVehicles < 0 then
			spawnOnDemand.settings.boatsNumVehicles = 5
		end
		spawnOnDemand.settings.boatsModel = settings.boatsModel or "speedboat"
		spawnOnDemand.settings.boats = nil

		-- other settings
		spawnOnDemand.settings.showF10 = settings.showF10
		if spawnOnDemand.settings.showF10 == nil then spawnOnDemand.settings.showF10 = true end
		spawnOnDemand.settings.showF10Debug = settings.showF10Debug or false
		spawnOnDemand.settings.maxSpawnTries = settings.maxSpawnTries or 100
		if spawnOnDemand.settings.maxSpawnTries <= 0 then
			spawnOnDemand.settings.maxSpawnTries = 100
		end

		-- airbase settings
		spawnOnDemand.settings.airbaseEnemyMinDist = settings.airbaseEnemyMinDist or 10
		if spawnOnDemand.settings.airbaseEnemyMinDist < 0 then
			spawnOnDemand.settings.airbaseEnemyMinDist = 10
		end
		spawnOnDemand.settings.airbaseEnemyMaxDist = settings.airbaseEnemyMaxDist or 20
		if spawnOnDemand.settings.airbaseEnemyMaxDist < 0 or spawnOnDemand.settings.airbaseEnemyMaxDist < spawnOnDemand.settings.airbaseEnemyMinDist then
			spawnOnDemand.settings.airbaseEnemyMaxDist = 20
		end
		spawnOnDemand.settings.airbaseFriendlyMaxDist = settings.airbaseFriendlyMaxDist or 20
		if spawnOnDemand.settings.airbaseFriendlyMaxDist < 0 then
			spawnOnDemand.settings.airbaseFriendlyMaxDist = 20
		end
		spawnOnDemand.settings.airbaseSpawnNum = settings.airbaseSpawnNum or 2
		if spawnOnDemand.settings.airbaseSpawnNum < 0 then
			spawnOnDemand.settings.airbaseSpawnNum = 2
		end

		-- crash crew
		spawnOnDemand.settings.crashCrewLand = settings.crashCrewLand
		if spawnOnDemand.settings.crashCrewLand == nil then spawnOnDemand.settings.crashCrewLand = true end
		spawnOnDemand.settings.crashCrewWater = settings.crashCrewWater
		if spawnOnDemand.settings.crashCrewWater == nil then spawnOnDemand.settings.crashCrewWater = true end
		spawnOnDemand.settings.crashCrewBeacon = settings.crashCrewBeacon
		if spawnOnDemand.settings.crashCrewBeacon == nil then spawnOnDemand.settings.crashCrewBeacon = false end

		-- sound settings
		spawnOnDemand.settings.soundMessage = settings.soundMessage or ""

		-- beacon settings
		if spawnOnDemand.settings.planeBeacon or spawnOnDemand.settings.vehicleBeacon or spawnOnDemand.settings.troopBeacon or spawnOnDemand.settings.heloBeacon or spawnOnDemand.settings.awacsBeacon or spawnOnDemand.settings.tankerBeacon then
			spawnOnDemand.settings.soundBeacon = settings.soundBeacon or ""
			spawnOnDemand.settings.freqs = {}
			spawnOnDemand.settings.freqs.used = {}
			spawnOnDemand.generateVHFFreqs()
			spawnOnDemand.generateTacanFreqs()
		end

		-- zero spawned groups
		spawnOnDemand.spawnedGroups = {}
		spawnOnDemand.spawnedGroupID = 0
		spawnOnDemand.spawnedUnitID = 0
		spawnOnDemand.checks = {}

		-- for counts
		spawnOnDemand.counts = {}
		spawnOnDemand.counts.friendly = 0
		spawnOnDemand.counts.enemy = 0
		spawnOnDemand.onGround = {}
		spawnOnDemand.onGround.friendly = 0
		spawnOnDemand.onGround.enemy = 0
		spawnOnDemand.base = {}
		spawnOnDemand.base.time = {}
		spawnOnDemand.base.time.blue = timer.getTime()
		spawnOnDemand.base.time.red = timer.getTime()
		spawnOnDemand.base.last = {}
		spawnOnDemand.base.last.blue = nil
		spawnOnDemand.base.last.red = nil

		-- for debug
		spawnOnDemand.settings.debug = settings.debug or false
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog("Settings loaded.")
		end

	end

	function spawnOnDemand.createTacanBeacon()
		local tacan = spawnOnDemand.settings.freqs.tacan

		if not tacan or #tacan == 0 then
			spawnOnDemand.toLog("ERROR: TACAN frequencies not found!")
			return nil
		end

		local freq
		local found = false
		for x = 1, #tacan do
			freq = tacan[mist.random(#tacan)]
			if not spawnOnDemand.settings.freqs.used.tacan[freq.channel] then
				spawnOnDemand.settings.freqs.used.tacan[freq.channel] = freq.frequency -- value is never used
				found = true
				break
			end
		end
		if not found then
			spawnOnDemand.toLog("Unused TACAN frequency not found!")
			return nil
		end
		return freq
	end

	function spawnOnDemand.generateTacanFreqs()
		spawnOnDemand.settings.freqs.tacan = {}

		-- 18-58 (1105-1145)
		local base = 1087
		for channel = 18, 58 do
			local freq = {
				channel = channel,
				frequency = base + channel
			}
			table.insert(spawnOnDemand.settings.freqs.tacan, freq)
		end

		-- 71-126 (1032-1087)
		base = 961
		for channel = 71, 126 do
			local freq = {
				channel = channel,
				frequency = (base + channel) * 1000000, -- in MHz
				callsign = tostring(channel)
			}
			table.insert(spawnOnDemand.settings.freqs.tacan, freq)
		end

		spawnOnDemand.settings.freqs.used.tacan = {}

		-- freqs to avoid per FAA
		for i = 1, 17 do
			spawnOnDemand.settings.freqs.used.tacan[i] = "reserved" -- value is never used
		end
		for i = 59, 70 do
			spawnOnDemand.settings.freqs.used.tacan[i] = "reserved"
		end
	end

	function spawnOnDemand.generateVHFFreqs()
		spawnOnDemand.settings.freqs.vhf = {}
		local debug = spawnOnDemand.settings.debug

		-- beacons already used in theater
		local mapFreqs = {}

		if require then -- check for sanitize
			if env.mission.theatre == "Caucasus" then
				dofile("./Mods/terrains/Caucasus/Beacons.lua")
			elseif env.mission.theatre == "Nevada" then
				dofile("./Mods/terrains/Nevada/Beacons.lua")
			elseif env.mission.theatre == "Normandy" then
				dofile("./Mods/terrains/Normandy/Beacons.lua")
			elseif env.mission.theatre == "PersianGulf" then
				dofile("./Mods/terrains/PersianGulf/Beacons.lua")
			else
				spawnOnDemand.toLog("ERROR: Theatre not found!")
				return nil
			end
		end

		if beacons then
			for name, data in pairs(beacons) do
				if string.find(string.upper(data.type), "HOMER") ~= nil and data.frequency and data.callsign then
					mapFreqs[tostring(math.floor(data.frequency))] = data.callsign
				end
			end
		end

		-- for debug
		if debug then

			-- get freq count (due to named keys)
			local count = 0
			for _, _ in pairs(mapFreqs) do count = count + 1 end
			spawnOnDemand.toLog(string.format("%i VHF frequencies excluded.", count))

		end

		-- set frequencies based on type
		local lower = 0
		local upper = 0
		local interval = 0
		local typeName = spawnOnDemand.unit:getDesc().typeName
		if typeName == "UH-1H" then
			-- 190 - 1,750 kHz x 10 kHz
			lower = 190000
			upper = 1750000
			interval = 10000
		elseif typeName == "Mi-8MT" then
			-- 150 - 1,290 kHz x 1 kHz
			lower = 150000
			upper = 1290000
			interval = 1000
		elseif typeName == "F-86F Sabre" then
			-- 100 - 1,750 kHz x 10 kHz
			lower = 100000
			upper = 1750000
			interval = 10000
		elseif typeName == "MiG-15bis" or typeName == "MiG-19P" then
			-- 150 - 1,300 kHz x 10 kHz
			lower = 150000
			upper = 1300000
			interval = 10000
		elseif typeName == "L-39C" or typeName == "L-39ZA" then
			-- 100 - 1,799 kHz x 10 kHz
			lower = 100
			upper = 1799000
			interval = 10000
		elseif typeName == "C-101EB" or typeName == "C-101CC" then
			-- 100 - 999.5 kHz x 500 Hz
			lower = 100000
			upper = 999500
			interval = 500
		elseif typeName == "A-10C" or typeName == "F-5E-3" then -- UHF
			-- 225 - 399.975 MHz x 25 kHz
			lower = 225000000
			upper = 399975000
			interval = 25000
		else -- Ka-50 has presets only, default if none specified above
			-- 0 (100) - 999.9 kHz x 100 Hz (SA342)
			lower = 100
			upper = 999900
			interval = 100
		end

		-- for debug
		if debug then
			spawnOnDemand.toLog(string.format("Generating VHF frequencies for %s (%i-%ix%i)", typeName, lower, upper, interval))
		end

		-- generate frequencies
		for freq = lower, upper, interval do
			if not mapFreqs[tostring(freq)] then
				table.insert(spawnOnDemand.settings.freqs.vhf, freq)
			end
		end

		spawnOnDemand.settings.freqs.used.vhf = {}

		-- for debug
		if debug then
			spawnOnDemand.toLog(string.format("%i VHF frequencies generated.", #spawnOnDemand.settings.freqs.vhf))
		end

	end

	function spawnOnDemand.createVHFBeacon(controller)
		local vhf = spawnOnDemand.settings.freqs.vhf

		if not vhf or #vhf == 0 then
			spawnOnDemand.toLog("ERROR: VHF frequencies not found!")
			return nil
		end

		local freq = 0
		local sound = spawnOnDemand.settings.soundBeacon
		if string.len(sound) > 0 then
			local found = false
			for x = 1, #vhf do
				freq = vhf[mist.random(#vhf)]
				if not spawnOnDemand.settings.freqs.used.vhf[freq] then
					spawnOnDemand.settings.freqs.used.vhf[freq] = freq -- value is never used
					found = true
					break
				end
			end
			if not found then
				spawnOnDemand.toLog("Unused VHF frequency not found!")
				return nil
			end
			local freqCommand = {
				id = "SetFrequency",
				params = {
					frequency = freq,
					modulation = radio.modulation.AM
				}
			}
			local msgCommand = {
				id = "TransmitMessage",
		        params = {
		            loop = true,
		            file = "l10n/DEFAULT/" .. sound
		        }
			}
		    controller:setCommand(freqCommand)
		    controller:setCommand(msgCommand)
		end
		return spawnOnDemand.parseFreq(freq)
	end

	function spawnOnDemand.reassignVHFFreqs()
		for _, spawnedGroup in ipairs(spawnOnDemand.spawnedGroups) do -- byref
			local isFriendly = spawnedGroup.isFriendly
			if not isFriendly then
				local groupType = spawnedGroup.groupType
				if (groupType == spawnOnDemand.settings.groupTypes.PLANES and spawnOnDemand.settings.planeBeacon) or
				   (groupType == spawnOnDemand.settings.groupTypes.VEHICLES and spawnOnDemand.settings.vehicleBeacon) or
				   (groupType == spawnOnDemand.settings.groupTypes.TROOPS and spawnOnDemand.settings.troopBeacon) or
				   (groupType == spawnOnDemand.settings.groupTypes.HELOS and spawnOnDemand.settings.heloBeacon) or
				   (groupType == spawnOnDemand.settings.groupTypes.AWACS and spawnOnDemand.settings.awacsBeacon) then
					local group = Group.getByName(spawnedGroup.groupName)
					if group and group:isExist() then
						local controller = group:getController()
						if controller then

							-- stop current transmission
							local stopCommand = {
								id = "StopTransmission"
							}
							controller:setCommand(stopCommand)

							-- create new frequency/transmission
							local vhf = spawnOnDemand.createVHFBeacon(controller)
							local freq = ""
							if vhf then
								freq = " [" .. vhf .. "]"
							end
							spawnedGroup.vhf = vhf

							-- create new friendly name
							local isCargo = spawnedGroup.isCargo
							local str = "N/A" -- should never be displayed
							if groupType == spawnOnDemand.settings.groupTypes.PLANES then
								str = "Cargo plane"
								if not isCargo then
									str = "Fighter plane(s)"
								end
							elseif groupType == spawnOnDemand.settings.groupTypes.VEHICLES then
								str = "Cargo"
								if not isCargo then
									str = "Armored"
								end
								local aa = ""
								if spawnedGroup.isAA then
									aa = " AA"
								end
								str = string.format("%s%s vehicle(s)", str, aa)
							elseif groupType == spawnOnDemand.settings.groupTypes.TROOPS then
								str = "Troop(s)"
							elseif groupType == spawnOnDemand.settings.groupTypes.HELOS then
								str = "Cargo helicopter"
								if not isCargo then
									str = "Attack helicopter(s)"
								end
							elseif groupType == spawnOnDemand.settings.groupTypes.SHIPS then
								str = "Cargo"
								if not isCargo then
									str = "Navy"
								end
								str = string.format("%s ship(s)", str)
							else -- spawnOnDemand.settings.groupTypes.AWACS
								str = "AWACS"
							end
							spawnedGroup.friendlyName = string.format("%s%s", spawnOnDemand.showFriendly(str, isFriendly), freq)

						end
					end
				end
			end
		end

		-- for debug
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog("All active frequencies reset.")
		end

	end

	function spawnOnDemand.parseFreq(freq)
		local f
		if freq > 0 then
			if tostring(freq):len() > 6 then
				f = string.format("%01.2f MHz", freq / 1000000)
			else
				f = string.format("%01g kHz", freq / 1000)
			end
		end
		return f
	end

	function spawnOnDemand.getPlayerData()

		-- get unit
		spawnOnDemand.unit = world.getPlayer() -- NOTE: only for SP (or server host)

		-- TODO: workaround for MP player
		if not spawnOnDemand.unit then
			spawnOnDemand.toLog("SP not found. Checking MP...")
			local playerName = "Chump"
			for i, unit in pairs(coalition.getPlayers(coalition.side.BLUE)) do -- check blue side first
				local unitName = unit:getPlayerName()
				if unitName and unitName == playerName then
					spawnOnDemand.unit = unit
					break
				end
			end
			if not spawnOnDemand.unit then
				for i, unit in pairs(coalition.getPlayers(coalition.side.RED)) do -- check red side next
					local unitName = unit:getPlayerName()
					if unitName and unitName == playerName then
						spawnOnDemand.unit = unit
						break
					end
				end
			end
		end

		if not spawnOnDemand.unit then
			mist.scheduleFunction(spawnOnDemand.init, nil, timer.getTime() + 5)
--			spawnOnDemand.toLog("*** RETRYING ***")
			return false
--		else
--			spawnOnDemand.toLog("*** FOUND ***")
		end

		-- TODO: use world.event.S_EVENT_TOOK_CONTROL or world.event.S_EVENT_PLAYER_ENTER_UNIT if SP (in case spectator is chosen at first, errors now)
		assert(spawnOnDemand.unit ~= nil, "Player unit not found!")

		-- get group
		spawnOnDemand.group = spawnOnDemand.unit:getGroup()
		assert(spawnOnDemand.group ~= nil, "Player group not found!")

		return true

	end

	function spawnOnDemand.generateF10Menu()
		if spawnOnDemand.settings.showF10 then

			-- submenu display
			local menu = "SpawnOnDemand"

			-- get groupID
			local groupID = spawnOnDemand.group:getID()

			-- remove to avoid duplicates after respawning
			missionCommands.removeItem(menu)

			-- add submenu
			local main = missionCommands.addSubMenuForGroup(groupID, menu)

			-- add status command
			missionCommands.addCommandForGroup(groupID, "Status", main, spawnOnDemand.showStatus)

			local path

			-- add planes
			if spawnOnDemand.settings.showPlanesF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Plane Groups", main)
				missionCommands.addCommandForGroup(groupID, "Cargo", path, spawnOnDemand.spawnPlanes, {isCargo = true})
				missionCommands.addCommandForGroup(groupID, "Cargo - Friendly", path, spawnOnDemand.spawnPlanes, {isCargo = true, isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "Fighter(s)", path, spawnOnDemand.spawnPlanes)
				missionCommands.addCommandForGroup(groupID, "Fighter(s) - Friendly", path, spawnOnDemand.spawnPlanes, {isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "AWACS", path, spawnOnDemand.spawnAWACS)
				missionCommands.addCommandForGroup(groupID, "AWACS - Friendly", path, spawnOnDemand.spawnAWACS, {isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "Tanker", path, spawnOnDemand.spawnTanker)
				missionCommands.addCommandForGroup(groupID, "Tanker - Friendly", path, spawnOnDemand.spawnTanker, {isFriendly = true})
			end

			-- add vehicles
			if spawnOnDemand.settings.showVehiclesF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Vehicle Groups", main)
				missionCommands.addCommandForGroup(groupID, "Cargo", path, spawnOnDemand.spawnVehicles, {isCargo = true})
				missionCommands.addCommandForGroup(groupID, "Cargo - Friendly", path, spawnOnDemand.spawnVehicles, {isCargo = true, isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "Armor", path, spawnOnDemand.spawnVehicles)
				missionCommands.addCommandForGroup(groupID, "Armor - Friendly", path, spawnOnDemand.spawnVehicles, {isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "AAA/SAM (Stationary)", path, spawnOnDemand.spawnVehicles, {isAA = true, noRoute = true})
				missionCommands.addCommandForGroup(groupID, "AAA/SAM (Moving)", path, spawnOnDemand.spawnVehicles, {isAA = true})
				missionCommands.addCommandForGroup(groupID, "AAA/SAM - Friendly (Stationary)", path, spawnOnDemand.spawnVehicles, {isFriendly = true, isAA = true, noRoute = true})
				missionCommands.addCommandForGroup(groupID, "AAA/SAM - Friendly (Moving)", path, spawnOnDemand.spawnVehicles, {isFriendly = true, isAA = true})
			end

			-- add troops
			if spawnOnDemand.settings.showTroopsF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Troop Groups", main)
				missionCommands.addCommandForGroup(groupID, "Troop(s)", path, spawnOnDemand.spawnTroops)
				missionCommands.addCommandForGroup(groupID, "Troop(s) - Friendly", path, spawnOnDemand.spawnTroops, {isFriendly = true})
			end

			-- add helos
			if spawnOnDemand.settings.showHelosF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Helicopter Groups", main)
				missionCommands.addCommandForGroup(groupID, "Cargo", path, spawnOnDemand.spawnHelos, {isCargo = true})
				missionCommands.addCommandForGroup(groupID, "Cargo - Friendly", path, spawnOnDemand.spawnHelos, {isCargo = true, isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "Attack(s)", path, spawnOnDemand.spawnHelos)
				missionCommands.addCommandForGroup(groupID, "Attack(s) - Friendly", path, spawnOnDemand.spawnHelos, {isFriendly = true})
			end

			-- add ships
			if spawnOnDemand.settings.showShipsF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Ship Groups", main)
				missionCommands.addCommandForGroup(groupID, "Civil", path, spawnOnDemand.spawnShips, {isCargo = true})
				missionCommands.addCommandForGroup(groupID, "Civil - Friendly", path, spawnOnDemand.spawnShips, {isCargo = true, isFriendly = true})
				missionCommands.addCommandForGroup(groupID, "Navy", path, spawnOnDemand.spawnShips)
				missionCommands.addCommandForGroup(groupID, "Navy - Friendly", path, spawnOnDemand.spawnShips, {isFriendly = true})
			end

			-- add war
			if spawnOnDemand.settings.showWarF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "War", main)
				missionCommands.addCommandForGroup(groupID, "Air", path, spawnOnDemand.startWar, {warType = spawnOnDemand.settings.warTypes.AIR})
				missionCommands.addCommandForGroup(groupID, "Ground", path, spawnOnDemand.startWar, {warType = spawnOnDemand.settings.warTypes.GROUND})
				missionCommands.addCommandForGroup(groupID, "Sea", path, spawnOnDemand.startWar, {warType = spawnOnDemand.settings.warTypes.SEA})
				missionCommands.addCommandForGroup(groupID, "User-Defined", path, spawnOnDemand.startWar)
			end

			-- add support
			if spawnOnDemand.settings.showSupportF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Support", main)
				missionCommands.addCommandForGroup(groupID, "CAS", path, spawnOnDemand.spawnCAS)
				missionCommands.addCommandForGroup(groupID, "Artillery", path, spawnOnDemand.spawnArty)
				missionCommands.addCommandForGroup(groupID, "AFAC", path, spawnOnDemand.spawnAFAC)
			end

			-- add scenarios
			if spawnOnDemand.settings.showScenariosF10 then
				path = missionCommands.addSubMenuForGroup(groupID, "Scenarios", main)
				missionCommands.addCommandForGroup(groupID, "Car Bomb", path, spawnOnDemand.scenarioCarBomb)
				missionCommands.addCommandForGroup(groupID, "VIP", path, spawnOnDemand.scenarioVIP)
				missionCommands.addCommandForGroup(groupID, "Boat Convoy", path, spawnOnDemand.scenarioBoats)
			end

			-- for debug
			if spawnOnDemand.settings.showF10Debug then

				-- add debug
				path = missionCommands.addSubMenuForGroup(groupID, "Debug", main)
				missionCommands.addCommandForGroup(groupID, "Destroy all", path, spawnOnDemand.destroyAll)
				missionCommands.addCommandForGroup(groupID, "Destroy me", path, spawnOnDemand.destroyMe)
				missionCommands.addCommandForGroup(groupID, "Print vars", path, spawnOnDemand.printVars)

				-- for debug
				if spawnOnDemand.settings.debug then
					spawnOnDemand.toLog("F10 menu loaded.")
				end

			end

		end
	end

	function spawnOnDemand.init()

		-- get player unit/group
		local x = spawnOnDemand.getPlayerData()
		if not x then return end

		-- get settings
		spawnOnDemand.getSettings()

		-- populate F10 menu
		spawnOnDemand.generateF10Menu()

		-- load event handler
		mist.addEventHandler(spawnOnDemand.events)

		-- check AI behavior
		mist.scheduleFunction(spawnOnDemand.checkAI, nil, timer.getTime() + 30, 30) -- executes every 30 seconds

		-- init player warnings
		spawnOnDemand.initPlayerWarnings()

		-- show version info
		spawnOnDemand.showVersion()

	end

	function spawnOnDemand.initPlayerWarnings()
		if spawnOnDemand.settings.showLowFuel then
			mist.scheduleFunction(spawnOnDemand.checkFuel, nil, timer.getTime() + 60, 60) -- executes every 60 seconds
		end
	end

	function spawnOnDemand.checkFuel()

		-- low fuel warning
		local unit = spawnOnDemand.unit
		if unit:isExist() and unit:isActive() and unit:getLife() > 1 then

			local fuel = unit:getFuel()
			local iFuel = spawnOnDemand.settings.lowFuelPercent
			local dFuel = iFuel / 100

			if fuel <= dFuel then

				-- notify player
				local msg = string.format("[Co-Pilot] LOW FUEL (%i%%)", iFuel)
				spawnOnDemand.toPlayer(msg)

				-- for debug
				if spawnOnDemand.settings.debug then
					spawnOnDemand.toLog(msg)
				end

			end

		end

	end

	function spawnOnDemand.findSpawnedGroup(groupName)
		local group
		local copy = mist.utils.deepCopy(spawnOnDemand.spawnedGroups)
		for _, spawnedGroup in ipairs(copy) do
			if groupName == spawnedGroup.groupName then
				group = spawnedGroup
				break
			end
		end
		return group
	end

	function spawnOnDemand.findSpawnedGroupIndex(sGroup)
		local idx
		local copy = mist.utils.deepCopy(spawnOnDemand.spawnedGroups)
		for index, spawnedGroup in pairs(copy) do -- not using ipairs() due to index difference
			if sGroup.groupName == spawnedGroup.groupName then
				idx = index
				break
			end
		end
		return idx
	end

	function spawnOnDemand.findSpawnedGroupUnitIndex(sGroup, uName)
		local idx
		local copy = mist.utils.deepCopy(sGroup.units)
		for index, unit in pairs(copy) do -- not using ipairs() due to index difference
			if uName == unit then
				idx = index
				break
			end
		end
		return idx
	end

	function spawnOnDemand.removeUnit(groupName, unitName)
		local group
		local unit
		if groupName and unitName then

			-- get group
			group = spawnOnDemand.findSpawnedGroup(groupName)

			-- check group
			if group then

				-- remove unit from group
				local index = spawnOnDemand.findSpawnedGroupUnitIndex(group, unitName)
				if index then
					table.remove(group.units, index)
				end

				-- remove AI check
				unit = Unit.getByName(unitName)
				if unit then
					spawnOnDemand.checks[unit:getID()] = nil
				end

				-- check unit count
				if #group.units == 0 then
					index = spawnOnDemand.findSpawnedGroupIndex(group)
					if index then

						-- remove used beacon
						if group.vhf then
							spawnOnDemand.settings.freqs.used.vhf[group.vhf] = nil
						end

						-- remove group
						table.remove(spawnOnDemand.spawnedGroups, index)

					end
				end

			end

		end
		return group, unit
	end

	function spawnOnDemand.countUnitsInGroup(group)
		local count = 0
		if group then
			local units = group:getUnits()
			if units then
				for _, unit in ipairs(units) do
					if unit:isExist() and unit:isActive() and unit:getLife() > 1 then -- doing this because getUnits() seems to return dead ones
						count = count + 1
					end
				end
			else
				env.error("No units found!")
			end
		else
			env.error("Cannot find group!")
		end
		return count
	end

	function spawnOnDemand.crashCrew(unit)
		local pos = unit:getPosition().p
		local type = land.getSurfaceType({x = pos.x, y = pos.z})

		if (type == land.SurfaceType.SHALLOW_WATER or type == land.SurfaceType.WATER) and spawnOnDemand.settings.crashCrewWater then
			--local model =
		elseif spawnOnDemand.settings.crashCrewLand then
			--local model =
		else
			return
		end

		local msg = "Crash crew dispatched!"

		-- TODO: beacon
		--msg = string.format("%s [%s]", msg, freq)

		spawnOnDemand.toCoalition(msg)
		if spawnOnDemand.settings.debug then
			spawnOnDemand.toLog(msg)
		end
	end

	function spawnOnDemand.events(event)
		local unit = spawnOnDemand.unit
		local group = spawnOnDemand.group

		-- check if player is still alive
		if unit and group then

			local debug = spawnOnDemand.settings.debug
			local weapon = event.weapon

			if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then -- respawn

				-- reset script values to new unit
				spawnOnDemand.getPlayerData()
				spawnOnDemand.generateF10Menu()
				if spawnOnDemand.settings.planeBeacon or spawnOnDemand.settings.vehicleBeacon or spawnOnDemand.settings.troopBeacon or spawnOnDemand.settings.heloBeacon or spawnOnDemand.settings.awacsBeacon then
					spawnOnDemand.generateVHFFreqs()
					spawnOnDemand.reassignVHFFreqs()
				end

				-- for debug
				if debug then
					spawnOnDemand.toLog("Refreshed player data.")
				end

			elseif event.id == world.event.S_EVENT_DEAD then

				if unit:getPlayerName() then
					--spawnOnDemand.crashCrew(unit)
					return
				end

				local i = event.initiator
				if i:getCategory() == Object.Category.UNIT then
					local group = i:getGroup()
					local unitsAlive = spawnOnDemand.countUnitsInGroup(group)
					if unitsAlive == 0 then
						local groupName = group:getName()
						local myGroup = spawnOnDemand.findSpawnedGroup(groupName)
						if myGroup and myGroup.type then
							groupName = myGroup.type
						end
						spawnOnDemand.removeUnit(groupName, i:getName())
						if myGroup.tacan then
							spawnOnDemand.settings.freqs.used.tacan[myGroup.tacan.channel] = nil -- clear
						end
						local msg = string.format("%s destroyed!", groupName)
						spawnOnDemand.toCoalition(msg)
					end
				end

			end

		end

	end

	function spawnOnDemand.checkAI()
		local spawnedGroups = spawnOnDemand.spawnedGroups
		if #spawnedGroups > 0 then
			local debug = spawnOnDemand.settings.debug
			for _, groupData in ipairs(spawnedGroups) do
				if groupData.groupType == spawnOnDemand.settings.groupTypes.PLANES then
					local groupName = groupData.groupName
					local group = Group.getByName(groupName)
					if group then
						local units = group:getUnits()
						for _, unit in ipairs(units) do
							if unit then
								local msg

								-- gather info
								local unitName = unit:getName()
								local position = unit:getPosition().p
								local height = position.y - land.getHeight({x = position.x, y = position.z}) -- in m
								local speed = mist.vec.mag(unit:getVelocity())
								local inAir = unit:inAir()
								local unitID = unit:getID()
								local dist = spawnOnDemand.getDistanceFromPlayer(unitName)
								local maxDist = 100 -- from player (in nm)
								local iDist = 0 -- set to maxDist to destroy N/A units
								if dist ~= "N/A" then
									iDist, _ = string.gsub(dist, "nm", "", 1)
									iDist = tonumber(iDist)
								end

								-- perform checks
								if env.mission.theatre == "Caucasus" and height < .3 then -- 1ft (NOTE: heights in Nevada are negative)
									msg = string.format("*** %s was removed due to being too low (%gft).", unitName, mist.utils.metersToFeet(height))
								elseif spawnOnDemand.unit:isExist() and iDist >= maxDist then
									msg = string.format("*** %s was removed due to being too far away (%s).", unitName, dist)
								elseif not inAir and speed <= 2 then -- 5mph (in mps)
									local health = unit:getLife()
									local startHealth = unit:getLife0()
									if health < (startHealth * .1) then -- 10%
										msg = string.format("*** %s was removed due to low health/speed (%g/%g, %gmps).", unitName, health, startHealth, speed)
									elseif groupData.spawnType ~= spawnOnDemand.settings.spawnTypes[4][2]  then -- spawn on ground
										if spawnOnDemand.checks[unitID] ~= nil then
											spawnOnDemand.checks[unitID] = spawnOnDemand.checks[unitID] + 1 -- increment
										else
											spawnOnDemand.checks[unitID] = 1 -- initialize
										end

										-- check for idle unit
										if spawnOnDemand.checks[unitID] == 10 then -- 5 mins
											spawnOnDemand.checks[unitID] = nil -- reset
											msg = string.format("*** %s was removed due to ground maneuvering complications.", unitName)
										end

									end

								elseif spawnOnDemand.checks[unitID] ~= nil then

									-- unit was misbehaving before, but now it's all good!
									spawnOnDemand.checks[unitID] = nil -- reset

									-- for debug
									if debug then
										spawnOnDemand.toLog(string.format("Strike reset for %s.", unitName))
									end

								end

								-- for debug
								if spawnOnDemand.checks[unitID] ~= nil and debug then
									spawnOnDemand.toLog(string.format("%s has strike #%i.", unitName, spawnOnDemand.checks[unitID]))
								end

								-- remove unit
								if msg then

									-- destroy unit
									unit:destroy() -- no events
									spawnOnDemand.removeUnit(groupName, unitName)

									-- notify coalition
									spawnOnDemand.toCoalition(msg)

									-- for debug
									if debug then
										spawnOnDemand.toLog(msg)
									end

								end
							end
						end
					end
				end
			end
		end
	end

	function spawnOnDemand.tableLength(tbl)
		local len = 0
		for _, _ in pairs(tbl) do
			len = len + 1
		end
		return len
	end

	-- for debug menu
	function spawnOnDemand.destroyAll()
		local spawnedGroups = spawnOnDemand.spawnedGroups
		if #spawnedGroups == 0 then
			spawnOnDemand.toPlayer("Nothing to destroy.")
		else
			for _, groupData in ipairs(spawnedGroups) do
				local group = Group.getByName(groupData.groupName)
				if group then
					local units = group:getUnits()
					for _, unit in ipairs(units) do
						trigger.action.explosion(unit:getPosition().p, 100)
					end
				end
			end
		end
	end
	function spawnOnDemand.destroyMe()
		local unit = spawnOnDemand.unit
		if unit:isExist() then
			trigger.action.explosion(unit:getPosition().p, 100)
		else
			spawnOnDemand.toPlayer("Nothing to destroy.")
		end
	end
	function spawnOnDemand.printVars()
		spawnOnDemand.toPlayer(string.format("spawnedGroups: %i\nfriendly: %i\nenemy: %i",
			#spawnOnDemand.spawnedGroups,
			spawnOnDemand.counts.friendly,
			spawnOnDemand.counts.enemy
		))
		if #spawnOnDemand.spawnedGroups > 0 then
			spawnOnDemand.toLog(mist.utils.serialize("spawnedGroups", spawnOnDemand.spawnedGroups))
		end
	end

	-- changelog
	function spawnOnDemand.showVersion()
		--[[
			v0.1.0  - Added planes options
			v0.2.0  - Added vehicles options
			v0.3.0  - Added troops options
			v0.4.0  - Added friendly/enemy logic
			v0.5.0  - Added VHF AM beacons on enemies
			v0.6.0  - Added incoming missile warning functionality
			v0.7.0  - Added war options
			v0.7.1  - Sorted status by distance
			v0.7.2  - Added used beacon exclusions by map
			v0.7.3  - Added ADF frequency ranges by typeName
			v0.7.4  - Added war group spawn fairness
			v0.8.0  - Added hit message functionality
			v0.8.1  - Vehicles/troops no longer spawn in water
			v0.8.2  - Added war spawn options
			v0.8.3  - Added attack planes, tasks
			v0.8.4  - Optimized code
			v0.9.0  - Added helicopters options
			v0.91.0 - Added war distribution
			v1.0.0  - Added airbase spawning
			v1.0.1  - Added AI behavior checks
			v1.0.2  - Added player protection on ground from missiles
			v1.0.3  - Added win flag option
			v1.0.4  - Added ability to read beacon data from file
			v1.0.5  - Reset active frequencies on respawn
			v1.0.6  - Added war team spawn option
			v1.0.7  - Added F10 debug options
			v1.0.8  - Added maximum airbase spawn number
			v1.1.0  - Added AWACS options
			v1.1.1  - Added more skins (NOTE: lots of custom ones)
			v1.1.2  - Added friendly/enemy war spawn distance options
			v1.1.3  - Added groupType enum
			v1.1.4  - AWACS not invisible if last units on team
			v1.1.5  - Added airbase min/max search distance options
			v1.1.6  - Added incoming weapon category/guidance information
			v1.1.7  - Updated payloads/skins
			v1.1.8  - Bug fixes
			v1.2.0  - Added support options
			v1.2.1  - Added route loop options
			v1.2.2  - Added player warning options
			v1.2.3  - Bug fixes
			v1.2.4  - Added CAS wait time and artillery target smoke
			v1.2.5  - Added groupName return for spawned groups
			v1.2.6  - Bug fixes
			v1.2.7  - Added check to add spawned groups to MiST groupsByName/unitsByName/MEunitsByName/MEunitsById DBs
			v1.2.8  - Updated aircraft/properties/skins
			v1.2.9  - Added toCoalition() functionality
			v1.2.10 - Added F10 options for groups
			v1.3.0  - Added scenario options
			v1.3.1  - Added car bomb scenario
			v1.3.2  - Added war type options
			v1.3.3  - Added VIP scenario
			v1.4.0  - Added ship options
			v1.4.1  - Added boat convoy scenario
			v1.4.2  - Added crash crew
			v1.4.3  - Added AFAC
			v1.4.4  - Generating radom AFAC laser code
			v1.5.0  - Cleaned up code
			v1.5.1  - Added MiG-19P, removed mods (until working again)
			v1.5.2  - Removed Hawk
			v1.5.3  - Cleaned up skins (using only defaults)
			v1.5.4  - Added option for ground units to attack air units
			v1.5.5  - Updated plane propeties
			v1.5.6  - Added route patterns to doRouteLoop (not used in script yet)
			v1.5.7  - AA groups can be stationary, 50/50 in war
			v1.5.8  - Using allSkins for plane/helo liveries
			v1.6.0  - Added tankers and bug fixes
			v1.6.1  - Re-adding crash crew
		--]]

		spawnOnDemand.version = {}
		spawnOnDemand.version.major = 1
		spawnOnDemand.version.minor = 6.1 -- including revision
		spawnOnDemand.toLog(string.format("v%i.%g locked and loaded.", spawnOnDemand.version.major, spawnOnDemand.version.minor))
	end

	-- start script
	spawnOnDemand.init()

end
