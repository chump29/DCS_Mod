--[[
-- Map Stuff
-- by Chump
--]]

do

	local base = _G

	local assert = base.assert
	local string = base.string
	local ipairs = base.pairs
	local math = base.math

	local dllWeather = require("Weather")

	local failMsg = " must be loaded prior to this script!"
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	PSEUDOATC
		:New()
		:Start()

	local function MapStuffEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit or unit:getDesc().category > 3 or not unit:isActive() then return end -- NOTE: Unit.getCategory is broken, only testing for 0=airplane, 1=helicopter, 2=ground_unit, 3=ship

		local playerName = unit:getPlayerName()
		if not playerName then return end

		local function say(msg)
			trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/static-short.ogg")
			trigger.action.outTextForCoalition(coalition.side.BLUE, msg, 10)
			env.info(msg)
		end

		if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
			say(string.format("%s just took control of: %s %s", playerName, string.upper(unit:getTypeName()), string.upper(unit:getGroup():getName())))

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

	-- TODO: refactor
	local function revertWind(a_value)
		a_value = a_value + 180
		if a_value > 360 then
			a_value = a_value - 360
		end
		return a_value
	end
	function toDegrees(radians, raw)
		local degrees = radians * 180 / math.pi
		if not raw then
			degrees = math.floor(degrees + 0.5)
		end
		return degrees
	end
	function toPositiveDegrees(radians, raw)
		local degrees = toDegrees(radians, raw)
		if degrees < 0 then
			degrees = degrees + 360
		end
		return degrees
	end
	local function getGroundWind(weather, pos)
		local wind = "N/A"
		if weather.atmosphere_type == 0 then
			wind = string.format("From %d° @ %dmph / %dkts", revertWind(weather.wind.atGround.dir), math.floor(weather.wind.atGround.speed * 2.23694), math.floor(mist.utils.mpsToKnots(weather.wind.atGround.speed)))
		else
			dllWeather.initAtmospere(weather)
			local res = dllWeather.getGroundWindAtPoint({position = pos or {x = 0, y = 0, z = 0}})
			wind = string.format("From %d° @ %dmph / %dkts", toPositiveDegrees(res.a + math.pi), math.floor(res.v * 2.23694), math.floor(mist.utils.mpsToKnots(res.v)))
		end
		return wind
	end

	local function drawMarkers()
		for i, base in ipairs(coalition.getAirbases(coalition.side.BLUE)) do
			if base:getDesc().category == Airbase.Category.AIRDROME then
				local point = base:getPoint()
				--point.z = point.z + 10
				local baseName = base:getDesc().displayName
				if baseName then
					baseName = baseName .. " / "
				end
				local baseCallsign = base:getCallsign()
				local weather = env.mission.weather
				local data = {
					id = i,
					pos = point,
					text = string.format("%s%s\nWind: %s\nQNH: %s\nTemp: %s\nCloud Base: %s", baseName, baseCallsign, getGroundWind(weather, point), getQNH(weather.qnh), getTemp(weather.season.temperature), getClouds(weather.clouds.base)),
					markForCoa = coalition.side.BLUE
				}
				mist.marker.add(data)
			end
		end
	end

	local eventHandler = { f = MapStuffEventHandler }
	function eventHandler:onEvent(e)
		self.f(e)
	end
	world.addEventHandler(eventHandler)

	drawMarkers()

	env.info("Map Stuff loaded.")

end
