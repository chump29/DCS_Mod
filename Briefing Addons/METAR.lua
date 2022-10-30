--[[
-- METAR
-- by Chump
-- Many thanks to HILOK for the ideas and testing!
--]]

local base = _G

module("metar")

local math = base.math
local string = base.string

--[[
METAR resources used:
* https://mediawiki.ivao.aero/index.php?title=METAR_explanation
* https://metar-taf.com/explanation
* https://www.dwd.de/EN/specialusers/aviation/download/products/metar_taf/metar_taf_download.pdf?__blob=publicationFile&v=3
* https://met.nps.edu/~bcreasey/mr3222/files/helpful/DecodeMETAR-TAF.html
* https://meteocentre.com/doc/metar.html
--]]

local function normalizeData(data)
	-- checking DCS.getPlayerBriefing(), then env.mission
	return {
		date = data.mission_date or data.date,
		time = data.mission_start_time or data.start_time,
		atmosphere = data.weather.atmosphere_type,
		wind = data.weather.wind,
		turbulence = data.weather.groundTurbulence,
		visibility = data.weather.visibility.distance, -- doesn't seem to change, always 80000
		precipitation = data.weather.clouds.iprecptns,
		fog = data.weather.enable_fog,
		fog_visibility = data.weather.fog.visibility,
		dust = data.weather.enable_dust,
		dust_visibility = data.weather.dust_density,
		clouds = data.weather.clouds,
		temp = data.weather.season.temperature,
		qnh = data.weather.qnh
	}
end

local function getCallsign(c)
	if not c then
		return "ZZZZ"
	end
	return c
end

local function reverseWind(d)
	local d = d + 180
	if d > 360 then
		return d - 360
	end
	return d
end

local function getWindDirection(d, s)
	if s < 1 then
		return 0
	end
	local d = math.floor(d / 10 + 0.5) * 10
	return reverseWind(d)
end

local function getWindSpeed(s, t)
	local s = math.floor(s + 0.5)
	if s >= 100 then
		return "ABV99"
	elseif s > 0 and t > 25 then
		if t <= 197 then
			return string.format("%0.2dG%0.2d", s, s * 1.5) -- TODO: need equation for multiplier
		end
		return "/////"
	elseif s == 0 and t > 25 then
		if t <= 125 then
			return string.format("VRB%0.2d", math.floor(0.48 * t / 10 + 0.5))
		end
		return "/////"
	end
	return string.format("%0.2d", s)
end

local function getVisibility(data)
	local v = data.visibility
	if data.fog and data.fog_visibility < v then
		v = data.fog_visibility
	end
	if data.dust and data.dust_visibility < v then
		v = data.dust_visibility
	end
	local visibility = 9999
	local m
	if v < 50 then
		visibility = 0
	elseif v < 800 then
		m = 50
	elseif v < 5000 then
		m = 100
	elseif v < 10000 then
		m = 1000
	end
	if m then
		return math.floor(v / m + 0.5) * m
	end
	return visibility
end

local function getWeather(p, f, fv, d)
	local str = ""
	if p == 1 or p == 3 then
		str = "SH"
	elseif p == 2 or p == 4 then
		str = "TS"
	end
	if p > 0 and p < 3 then
		str = str .. "RA"
	elseif p >= 3 then
		str = str .. "SN"
	end
	if f and fv < 1000 then
		if string.len(str) > 0 then
			str = str .. " FG"
		else
			str = "FG"
		end
	end
	if d then
		if string.len(str) > 0 then
			str = str .. " DU"
		else
			str = "DU"
		end
	end
	if string.len(str) > 0 then
		return " " .. str
	end
	return str
end

local function getClouds(c)
	local str
	-- instead of using octals, split into ten parts
	if c.density == 0 then
		return "CLR"
	elseif c.density > 0 and c.density < 3 then -- 1-2
		str = "FEW"
	elseif c.density > 2 and c.density < 6 then -- 3-5
		str = "SCT"
	elseif c.density > 5 and c.density < 9 then -- 6-8
		str = "BKN"
	elseif c.density > 8 then -- 9-10
		str = "OVC"
	end
	local m = 1000
	if c.base < 3048 then
		m = 100
	end
	return string.format("%s%0.3d", str, math.floor(c.base * 3.28084 / m + 0.5) * m)
end

local function getTemp(t)
	if t < 0 then
		return "M" .. string.format("%0.2d", math.abs(math.ceil(t - 0.5)))
	end
	return string.format("%0.2d", math.abs(math.floor(t + 0.5)))
end

local function getDewPoint(t, c)
	local dp = t - c / 400
	if dp < -15 then
		dp = -15
	end
	return getTemp(dp)
end

local function getColor(v, c)
	if v < 0.8 then
		return "RED"
	elseif v < 1.6 then
		if c < 200 then
			return "RED"
		else
			return "AMB"
		end
	elseif v < 3.7 then
		if c < 200 then
			return "RED"
		elseif c < 300 then
			return "AMB"
		else
			return "YLO"
		end
	elseif v < 5 then
		if c < 200 then
			return "RED"
		elseif c < 300 then
			return "AMB"
		elseif c < 700 then
			return "YLO"
		else
			return "GRN"
		end
	elseif v < 8 then
		if c < 200 then
			return "RED"
		elseif c < 300 then
			return "AMB"
		elseif c < 700 then
			return "YLO"
		elseif c < 1500 then
			return "GRN"
		else
			return "WHT"
		end
	else
		if c < 200 then
			return "RED"
		elseif c < 300 then
			return "AMB"
		elseif c < 700 then
			return "YLO"
		elseif c < 1500 then
			return "GRN"
		elseif c < 2500 then
			return "WHT"
		elseif c < 20000 then
			return "BLU"
		else
			return "BLU+" -- DCS only allows 16,404ft set in ME
		end
	end
end

function getMETAR(data, code)
	local data = normalizeData(data)
	local metar = getCallsign(code)
	metar = string.format("%s %0.2d%0.2d%0.2dL", metar, data.date.Day, math.floor(data.time / 60 / 60), data.time / 60 % 60)
	if data.atmosphere > 0 then
		return string.format("%s NIL", metar)
	end
	metar = string.format("%s AUTO", metar)
	metar = string.format("%s %0.3d%sKT", metar, getWindDirection(data.wind.atGround.dir, data.wind.atGround.speed * 1.943844), getWindSpeed(data.wind.atGround.speed * 1.943844, data.turbulence * 1.943844))
	local vis = getVisibility(data)
	metar = string.format("%s %0.4d", metar, vis)
	metar = string.format("%s%s", metar, getWeather(data.precipitation, data.fog, data.fog_visibility, data.dust))
	metar = string.format("%s %s", metar, getClouds(data.clouds))
	metar = string.format("%s %s/%s", metar, getTemp(data.temp), getDewPoint(data.temp, data.clouds.base * 3.28084))
	metar = string.format("%s A%0.4d", metar, math.floor(data.qnh / 25.4 * 100))
	metar = string.format("%s %s", metar, getColor(vis / 1000, data.clouds.base * 3.28084))
	return metar
end
