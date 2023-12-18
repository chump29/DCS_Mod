--[[
-- Crash Crew
-- by Chump
--]]

do

	local config = CRASH_CREW_CONFIG or {
		maxCrews = 10,
		minTime = 60, -- in seconds
		maxTime = 120, -- in seconds
		useFlares = true,
		useSmoke = true,
		useIllumination = true,
		sound = "l10n/DEFAULT/siren.ogg",
		message = true,
		units = {
			land = {
				type = "HEMTT TFFT",
				livery = "Fire Truck 1"
			},
			water = {
				type  = "speedboat",
				livery = ""
			}
		},
		debug = false
	}

	assert(mist ~= nil, "MiST must be loaded prior to this script!")

	local CrashCrew = {	num = 0	}

	local function crashCrewEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit or Object.getCategory(unit) > 2 or not unit:isActive() then return end -- NOTE: only testing for 0=airplane, 1=helicopter, 2=ground_unit

		local playerName = unit:getPlayerName()
		if not playerName then return end

		if event.id == world.event.S_EVENT_CRASH then

			if CrashCrew.num == config.maxCrews then return end
			CrashCrew.num = CrashCrew.num + 1

			local function log(msg)
				env.info(string.format("CrashCrew: %s", msg))
			end

			local function destroyCrashCrew(group)
				group:destroy()
				CrashCrew.num = CrashCrew.num - 1
				if config.debug then log(string.format("%s destroyed.", group:getName())) end
			end

			local function addToHeading(heading, num)
				local newHeading = heading + num
				if newHeading >= 360 then
					newHeading = newHeading - 360
				end
				return newHeading * math.pi / 180
			end

			local function setOptions(group)
				local controller = group:getController()
				if not controller then return end
				controller:setCommand({
					id = "SetInvisible",
					params = {
						value = true
					}
				})
				controller:setCommand({
					id = "SetImmortal",
					params = {
						value = true
					}
				})
			end

			local groupData = {
				visible = false,
				lateActivation = false,
				tasks = {},
				uncontrollable = false,
				task = "Ground Nothing",
				hiddenOnMFD = true,
				taskSelected = true,
				route = {},
				hidden = true,
				units = {
					[1] = {
						type = config.units.land.type,
						transportable = {
							randomTransportable = false
						},
						livery_id = config.units.land.livery,
						skill = "Random",
						name = "CrashCrewUnit1-",
						playerCanDrive = false
					},
					[2] = {
						type = config.units.land.type,
						transportable = {
							randomTransportable = false
						},
						livery_id = config.units.land.livery,
						skill = "Random",
						name = "CrashCrewUnit2-",
						playerCanDrive = false
					},
					[3] = {
						type = config.units.land.type,
						transportable = {
							randomTransportable = false
						},
						livery_id = config.units.land.livery,
						skill = "Random",
						name = "CrashCrewUnit3-",
						playerCanDrive = false
					}
				},
				y = 0,
				x = 0,
				name = "CrashCrew",
				start_time = 0,
				hiddenOnPlanner = true
			}

			local groupCategory = Group.Category.GROUND
			local heading = mist.getHeading(unit) * 180 / math.pi
			local inM = mist.utils.feetToMeters(71) -- will end up ~100ft away (a²+b²=c²)
			local pos = unit:getPosition().p
			local surface = land.getSurfaceType({x = pos.x, y = pos.z})
			if surface == land.SurfaceType.SHALLOW_WATER or surface == land.SurfaceType.WATER then
				groupCategory = Group.Category.SHIP
				groupData.task = nil
				groupData.units[1].type = config.units.water.type
				groupData.units[1].livery_id = config.units.water.livery
				groupData.units[2].type = config.units.water.type
				groupData.units[2].livery_id = config.units.water.livery
				groupData.units[3].type = config.units.water.type
				groupData.units[3].livery_id = config.units.water.livery
			end

			groupData.name = groupData.name .. tostring(CrashCrew.num)

			groupData.units[1].y = pos.z + inM
			groupData.units[1].x = pos.x + inM
			groupData.units[1].heading = addToHeading(heading, -135)
			groupData.units[1].name = groupData.units[1].name .. tostring(CrashCrew.num)

			groupData.units[2].y = pos.z + inM
			groupData.units[2].x = pos.x - inM
			groupData.units[2].heading = addToHeading(heading, -45)
			groupData.units[2].name = groupData.units[2].name .. tostring(CrashCrew.num)

			groupData.units[3].y = pos.z - inM
			groupData.units[3].x = pos.x
			groupData.units[3].heading = addToHeading(heading, 90)
			groupData.units[3].name = groupData.units[3].name .. tostring(CrashCrew.num)

			local group = coalition.addGroup(
				country.id.SWITZERLAND,
				groupCategory,
				groupData
			)
			if not group then return end

			mist.scheduleFunction(setOptions, {group}, timer.getTime() + 1)

			mist.scheduleFunction(destroyCrashCrew, {group}, timer.getTime() + mist.random(config.minTime, config.maxTime))

			if config.useFlares then
				trigger.action.signalFlare(pos, trigger.flareColor.Green, 1)
				trigger.action.signalFlare(pos, trigger.flareColor.Red, 90)
				trigger.action.signalFlare(pos, trigger.flareColor.White, 180)
				trigger.action.signalFlare(pos, trigger.flareColor.Yellow, 270)
			end

			local coa = unit:getCoalition()

			if config.useSmoke then
				if coa == coalition.side.BLUE then
					trigger.action.smoke(pos, trigger.smokeColor.Blue)
				else
					trigger.action.smoke(pos, trigger.smokeColor.Red)
				end
			end

			if config.useIllumination then
				pos.y = pos.y + 1000
				trigger.action.illuminationBomb(pos, 1000000)
			end

			if config.sound then
				trigger.action.outSoundForCoalition(coa, config.sound)
			end

			if config.message then
				trigger.action.outTextForCoalition(coa, string.format("%s has crashed! Crash Crew dispatched.", playerName), 10)
			end

			if config.debug then log(string.format("%s spawned for %s.", group:getName(), playerName)) end

		end
	end

	mist.addEventHandler(crashCrewEventHandler)

	env.info("Crash Crew waiting to respond...")

end
