--[[
-- Sky Spy
-- by Chump
--]]

skySpy = {
	debug = false,
	sounds = { -- NOTE: must be included in the .miz file (empty for no sound)!
		incoming = "incoming.ogg",
		radio = "static-short.ogg"
	}
}

do

	assert(mist ~= nil, "MiST must be loaded prior to this script!")

	function skySpy.eventHandler(event)
		local debug = skySpy.debug

		local unit = event.initiator
		local unitName
		if unit then
			unitName = string.upper(unit:getDesc().typeName)
		end

		local target = event.target

		local weapon = event.weapon
		local weaponName
		if weapon then
			weaponName = string.upper(weapon:getDesc().displayName)
		end

		local groupId
		if unit then
			local category = unit:getCategory()
			if category ~= Object.Category.SCENERY and category ~= Object.Category.BASE then
				groupId = unit:getGroup():getID()
			end
		end

		local playerName
		if unit and groupId then
			playerName = unit:getPlayerName()
		end

		if event.id == world.event.S_EVENT_BIRTH and playerName then -- for MP clients/host

			skySpy.updatePlayer(playerName, unit)

			if unitName == "A-10C" then -- for Warthog throttle sync

				local function click(dev, cmd, arg)
					GetDevice(dev):performClickableAction(cmd, arg)
				end

				click(39, 3002, 0) -- flaps up
				click(1, 3017, 0) -- l eng start off
				click(1, 3018, 0) -- r eng start off

				local msg = "Warthog controls are now in sync!"
				skySpy.say(groupId, msg, 5, false)

				if debug then skySpy.log(msg) end
			end

		elseif event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_CRASH then -- NOTE: spawned AI can die and not trigger dead events

			if playerName and groupId then
				skySpy.say(groupId, "*** R. I. P. ***")

				if debug then skySpy.log(string.format("%s is dead", playerName)) end

			elseif unit and unit:getCategory() == Object.Category.UNIT then

				if string.find(unit:getGroup():getName(), "^RAT_") ~= nil then return end -- do not handle RAT planes
				if string.find(unit:getGroup():getName(), "^TS_") ~= nil then return end -- do not handle TargetScript targets

				local name = ""
				if playerName then
					name = " (" .. playerName .. ")"
				end
				skySpy.say(nil, string.format("[Co-Pilot] %s%s is dead.", unitName, name))

			end

		elseif event.id == world.event.S_EVENT_HIT then

			local weaponCategory
			if weapon then
				weaponCategory = weapon:getCategory()
			end

			if target and target:getCategory() == Object.Category.UNIT and weaponCategory == Object.Category.WEAPON and playerName then
				skySpy.say(groupId, string.format("[Co-Pilot] HIT %s with %s!", string.upper(target:getDesc().typeName), weaponName))

			elseif target and target:getCategory() == Object.Category.UNIT and target:getGroup() and weaponCategory == Object.Category.WEAPON and not playerName and target:getPlayerName() then
				if unitName then
					skySpy.say(target:getGroup():getID(), string.format("[Co-Pilot] HIT by %s from %s!", weaponName, unitName))
				else
					skySpy.say(target:getGroup():getID(), string.format("[Co-Pilot] HIT by %s!", weaponName))
				end

			end

		elseif event.id == world.event.S_EVENT_SHOT and unit and weapon and weapon:getTarget() and weapon:isExist() then

			local t = weapon:getTarget()
			local targetName
			if t then -- it could have been blown up...
				targetName = t:getPlayerName()
			else
				return
			end

			local player = skySpy.players[targetName]
			if not player then return end -- should never happen

			if player.unit:isExist() and not player.isTracking then
				player.isTracking = true
				mist.scheduleFunction(skySpy.incoming, {weapon, player.unit, player.isTracking}, timer.getTime() + 0.5) -- 1/2 second reaction time
			end

		end

	end

	-- NOTE: Co-Pilot can only keep track of one incoming missle at a time!
	function skySpy.incoming(weapon, unit, tracking, num)
		num = num or 0

		if tracking and weapon and weapon:isExist() then -- catches when object dies during scheduled wait time
			local groupId = unit:getGroup():getID()

			-- check if player is still on the ground
			if not unit:inAir() then
				-- NOTE: bullets have no target, invincibility does not work for players, so only destroy missiles
				weapon:destroy()
				skySpy.say(groupId, "[Co-Pilot] Incoming missile DESTROYED!")
				return
			end

			-- get positions
	        local position = Weapon.getPosition(weapon).p
	        local playerPosition = unit:getPosition().p
	        local relativePosition = mist.vec.sub(position, playerPosition)

			-- get distance
			local dist = mist.utils.get2DDist(playerPosition, position)
	        if dist <= mist.utils.NMToMeters(10) then -- max detection range

	        	-- get angle
	            local playerHeading = mist.getHeading(unit)
	            local headingVector = {x = math.cos(playerHeading), y = 0, z = math.sin(playerHeading)}
	            local headingVectorPerpendicular = {x = math.cos(playerHeading + math.pi / 2), y = 0, z = math.sin(playerHeading + math.pi / 2)}
	            local forwardDistance = mist.vec.dp(relativePosition, headingVector)
	            local rightDistance = mist.vec.dp(relativePosition, headingVectorPerpendicular)
	            local angle = math.atan2(rightDistance, forwardDistance) * 180 / math.pi
	            if angle < 0 then angle = 360 + angle end
	            angle = math.floor(angle * 12 / 360 + 0.5)
	            if angle == 0 then angle = 12 end

				-- make sure that it hasn't passed us
				if num > 0 and dist >= num then

					-- notify player
					skySpy.say(groupId, "[Co-Pilot] MISS!")

					-- reset tracking
					tracking = nil

				else

					-- set max
					num = dist

					-- determine scale
					if dist >= mist.utils.NMToMeters(1) then
						dist = mist.utils.metersToNM(dist)
						dist = tostring(mist.utils.round(dist)) .. "nm"
					else
						dist = mist.utils.metersToFeet(dist)
						dist = mist.utils.round(dist)
						local s = dist
						while true do
							s, n = string.gsub(s, "^(-?%d+)(%d%d%d)", '%1,%2') -- adds comma
							if (n == 0) then break end
						end
						dist = s .. "ft"
					end

					-- notify player
					local name = weapon:getDesc().displayName
					local str = ""
					local category = weapon:getDesc().missileCategory
					if not category then
						category = ""
					else
						if category == Weapon.MissileCategory.AAM then
							category = "AAM"
						elseif category == Weapon.MissileCategory.SAM then
							category = "SAM"
						else -- BM/ANTI_SHIP/CRUISE/OTHER
							category = "NA"
						end
					end
					local guidance = weapon:getDesc().guidance
					if not guidance then
						guidance = ""
					else
						if guidance == Weapon.GuidanceType.IR then
							guidance = "IR"
						elseif guidance == Weapon.GuidanceType.RADAR_ACTIVE then
							guidance = "RADAR-A"
						elseif guidance == Weapon.GuidanceType.RADAR_SEMI_ACTIVE then
							guidance = "RADAR-SA"
						elseif guidance == Weapon.GuidanceType.RADAR_PASSIVE then
							guidance = "RADAR-P"
						else -- INS/TV/LASER/TELE
							guidance = "NA"
						end
					end
					if string.len(category) > 0 or string.len(guidance) > 0 then
						str = string.format(" (%s / %s)", category, guidance)
					end
					local incomingSound = skySpy.sounds.incoming
					if incomingSound and string.len(incomingSound) > 0 then
						trigger.action.outSoundForGroup(groupId, "l10n/DEFAULT/" .. incomingSound)
					end
					local text = string.format("[Co-Pilot] INCOMING %s%s at %i o'clock for %s!", name, str, angle, dist)
		            skySpy.say(groupId, text, 3, false)

			        -- schedule next timer
			        mist.scheduleFunction(skySpy.incoming, {weapon, unit, tracking, num}, timer.getTime() + 1) -- next warning will occur in 1 second

				end
	        end

		else

			-- notify player
			--skySpy.say(groupId, "[Co-Pilot] MISS!")

			-- reset tracking
			tracking = nil

		end

	end

	function skySpy.checkPlayers()

		if not skySpy.players then
			skySpy.players = {}
		end

		-- for SP host
		for _, unit in pairs(coalition.getPlayers(coalition.side.BLUE)) do
			skySpy.updatePlayer(unit:getPlayerName(), unit)
		end
		for _, unit in pairs(coalition.getPlayers(coalition.side.RED)) do
			skySpy.updatePlayer(unit:getPlayerName(), unit)
		end

	end

	function skySpy.updatePlayer(playerName, unit)
		local found = false
		if skySpy.players[playerName] then found = true end

		skySpy.players[playerName] = {
			unit = unit
		}

		if not found then skySpy.players[playerName].isConnecting = true end

		skySpy.welcomePlayer(playerName)
	end

	function skySpy.welcomePlayer(playerName)
		local player = skySpy.players[playerName]
		if not player then return end

		local groupId = player.unit:getGroup():getID()

		local unitName = string.upper(player.unit:getDesc().typeName)

		if player.isConnecting then

			player.isConnecting = nil
			skySpy.say(groupId, string.format("Welcome, %s!", playerName), 5)

		else

			skySpy.say(groupId, string.format("Welcome back to the fight, %s!", playerName), 5)
		end

		if skySpy.debug then skySpy.log(string.format("%s entered %s", playerName, unitName)) end
	end

	function skySpy.say(groupId, msg, delay, useSound)
		if msg and string.len(msg) > 0 then

			delay = delay or 10
			if useSound == nil then useSound = true end

			local sound
			local radioSound = skySpy.sounds.radio
			if radioSound and string.len(radioSound) > 0 then
				sound = "l10n/DEFAULT/" .. radioSound
			else
				useSound = false
			end

			if not groupId then

				if useSound then
					trigger.action.outSound(sound)
				end
				trigger.action.outText(msg, delay)

			else

				if useSound then
					trigger.action.outSoundForGroup(groupId, sound)
				end
				trigger.action.outTextForGroup(groupId, msg, delay)

			end

		end
	end

	function skySpy.log(msg)
		if msg and string.len(msg) > 0 then
			env.info(string.format("SkySpy: %s", msg))
		end
	end

	function skySpy.init()

		skySpy.checkPlayers()

		if not skySpy.eventHandlerId then
			skySpy.eventHandlerId = mist.addEventHandler(skySpy.eventHandler)
		end

		skySpy.showVersion()

	end

	function skySpy.showVersion()

		--[[ Changelog
			1.0 - Initial release
			1.1 - Added WH sync
			1.2 - Various things
			1.2.1 - Refactored some things
			1.2.2 - Added TMWH message
		--]]

		skySpy.version = {}
		skySpy.version.major = 1
		skySpy.version.minor = 2.2 -- including revision

		skySpy.log(string.format("v%i.%g is watching.", skySpy.version.major, skySpy.version.minor))

	end

	skySpy.init()

end