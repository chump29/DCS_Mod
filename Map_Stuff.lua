--[[
-- Map Stuff
-- by Chump
--]]

do

	local config = MAP_STUFF_CONIFG or {
		announcements = false,
		atc = true,
		markers = true,
		sound = "l10n/DEFAULT/static-short.ogg",
		startingId = 10000
	}

	if config.atc then
		assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

		PSEUDOATC
			:New()
			:Start()
	end

	local function MapStuffEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		local unitCategory = Object.getCategory(unit)
		if not unit or unitCategory > 3 or not unit:isActive() then return end -- NOTE: only testing for 0=airplane, 1=helicopter, 2=ground_unit, 3=ship

		local playerName = unit:getPlayerName()
		if not playerName then return end

		local function say(msg)
			if config.sound then
				trigger.action.outSoundForCoalition(coalition.side.BLUE, config.sound)
			end
			trigger.action.outTextForCoalition(coalition.side.BLUE, msg, 10)
			env.info(msg)
		end

		if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
			local group = unit:getGroup()
			if group then
				local unitTypeName = group:getName()
				if unitCategory <= 1 then -- airplane/helicopter only
					unitTypeName = UNIT:Find(unit):GetNatoReportingName()
				end
				say(string.format("%s just took control of: %s %s", playerName, string.upper(unit:getTypeName()), string.upper(unitTypeName)))
			end

		elseif event.id == world.event.S_EVENT_PILOT_DEAD then
			say(string.format("%s is dead!", playerName))

		elseif event.id == world.event.S_EVENT_CRASH then
			local group = unit:getGroup()
			if group then
				local category = Object.getCategory(group)
				local cat = "unknown"
				if category == Group.Category.HELICOPTER then
					cat = "helicopter"
				elseif category == Group.Category.AIRPLANE then
					cat = "plane"
				elseif category == Group.Category.GROUND then
					cat = "vehicle"
				elseif category == Group.Category.SHIP then
					cat = "ship"
				end
				say(string.format("%s's %s has crashed!", playerName, cat))
			end

		end
	end

	local function getTemp(c)
 		return string.format("%d°F / %d°C", math.floor((c or 0) * 9 / 5 + 32), c or 0)
	end

	local function getQNH(qnh)
	  	return string.format("%0.2finHg / %0.2fmmHg/ %dhPa", (qnh or 0) / 25.399999, qnh or 0, (qnh or 0) * 1.333223)
	end

	local function getClouds(m)
	  	return string.format("%dft / %dm", math.floor((m or 0) * 3.280839), m or 0)
	end

	-- TODO: refactor wind
	local function reverseWind(d)
		local dir = d + 180
		if dir > 360 then
			return dir - 360
		end
		return dir
	end
	local function toDegrees(radians, raw)
		local degrees = radians * 180 / math.pi
		if not raw then
			degrees = math.floor(degrees + 0.5)
		end
		return degrees
	end
	local function toPositiveDegrees(radians, raw)
		local degrees = toDegrees(radians, raw)
		if degrees < 0 then
			degrees = degrees + 360
		end
		return degrees
	end
	local function getGroundWind(weather, pos)
		local function mpsToKts(mps)
			return mps * 1.943844
		end

		if weather.atmosphere_type > 0 then
			return "N/A"
		end

		local wind = "CALM"
		if weather.wind.atGround.speed > 0 then
			wind = string.format("%d° @ %dkts", reverseWind(weather.wind.atGround.dir), math.floor(mpsToKts(weather.wind.atGround.speed)))
		end
		return wind
	end

	local function getATIS(name)
		if ATISFREQS and ATISFREQS[name] then
			return string.format(" ATIS: %.2f MHz \n", ATISFREQS[name])
		end
		return ""
	end

	local function drawMarkers()
		for i, base in ipairs(coalition.getAirbases(coalition.side.BLUE)) do
			if base:getDesc().category == Airbase.Category.AIRDROME then
				local point = base:getPoint()
				local weather = env.mission.weather
				trigger.action.textToAll(
					coalition.side.BLUE,
					config.startingId + i,
					{x = point.x + 500, y = point.y, z = point.z + 500},
					{1, 1, 1, 1},
					{0, 0, 0, 0.33},
					10,
					true,
					string.format("%s Wind: %s \n QNH: %s \n Temp: %s \n Cloud Base: %s ", getATIS(base:getCallsign()), getGroundWind(weather, point), getQNH(weather.qnh), getTemp(weather.season.temperature), getClouds(weather.clouds.base))
				)
			end
		end
	end

	if config.announcements then
		local eventHandler = { f = MapStuffEventHandler }
		function eventHandler:onEvent(e)
			self.f(e)
		end
		world.addEventHandler(eventHandler)
	end

	if config.markers then
		drawMarkers()
	end

	env.info("Map Stuff loaded.")

end
