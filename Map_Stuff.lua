--[[
-- Map Stuff
-- by Chump
--]]

do

	local failMsg = " must be loaded prior to this script!"
	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local string = _G.string
	local ipairs = _G.ipairs
	local math = _G.math

	local require = _G.require
	local dllWeather = require("Weather")

	local config = {
		announcements = false,
		atc = true,
		markers = true,
		sound = "l10n/DEFAULT/static-short.ogg",
		startingId = 10000
	}

	if config.atc then
		PSEUDOATC
			:New()
			:Start()
	end

	local function MapStuffEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		local unitCategory = unit:getDesc().category
		if not unit or unitCategory > 3 or not unit:isActive() then return end -- NOTE: Unit.getCategory is broken, only testing for 0=airplane, 1=helicopter, 2=ground_unit, 3=ship

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
			local unitTypeName = unit:getGroup():getName()
			if unitCategory <= 1 then -- airplane/helicopter only
				unitTypeName = UNIT:Find(unit):GetNatoReportingName()
			end
			say(string.format("%s just took control of: %s %s", playerName, string.upper(unit:getTypeName()), string.upper(unitTypeName)))

		elseif event.id == world.event.S_EVENT_PILOT_DEAD then
			say(string.format("%s is dead!", playerName))

		elseif event.id == world.event.S_EVENT_CRASH then
			local category = unit:getGroup():getCategory()
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

	local function getTemp(c)
 		return string.format("%d°F / %d°C", math.floor((c or 0) * 9 / 5 + 32), c or 0)
	end

	local function getQNH(qnh)
	  	return string.format("%0.2finHg / %dhPa", (qnh or 0) / 25.4, qnh or 0)
	end

	local function getClouds(m)
	  	return string.format("%dft / %dm", math.floor((m or 0) * 3.281), m or 0)
	end

	-- TODO: refactor wind
	local function revertWind(a_value)
		a_value = a_value + 180
		if a_value > 360 then
			a_value = a_value - 360
		end
		return a_value
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
		local wind = "CALM"
		if weather.atmosphere_type == 0 then
			if weather.wind.atGround.speed > 0 then
				wind = string.format("From %d° @ %dmph / %dkts", revertWind(weather.wind.atGround.dir), math.floor(weather.wind.atGround.speed * 2.23694), math.floor(mist.utils.mpsToKnots(weather.wind.atGround.speed)))
			end
		else
			dllWeather.initAtmospere(weather)
			local res = dllWeather.getGroundWindAtPoint({position = pos or {x = 0, y = 0, z = 0}})
			wind = string.format("From %d° @ %dmph / %dkts", toPositiveDegrees(res.a + math.pi), math.floor(res.v * 2.23694), math.floor(mist.utils.mpsToKnots(res.v)))
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
