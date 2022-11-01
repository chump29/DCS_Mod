--[[
-- METAR
-- by Chump
-- Many thanks to HILOK for the ideas and testing!
--]]

local base = _G

module("metar")

local math = base.math
local string = base.string
local TheatreOfWarData = base.require("Mission.TheatreOfWarData")

--[[
METAR resources used:
* https://mediawiki.ivao.aero/index.php?title=METAR_explanation
* https://metar-taf.com/explanation
* https://www.dwd.de/EN/specialusers/aviation/download/products/metar_taf/metar_taf_download.pdf?__blob=publicationFile&v=3
* https://meteocentre.com/doc/metar.html
--]]

local function normalizeData(data)
	-- checking DCS.getPlayerBriefing(), then env.mission
	return {
		date = data.mission_date or data.date,
		time = data.mission_start_time or data.start_time,
		atmosphere = data.weather.atmosphere_type,
		wind = data.weather.wind.atGround,
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
	if not c or string.len(c) == 0 then
		local theatreCallsigns = {
			["Caucasus"] = "UGGG",
			["Falklands"] = "SAVF",
			["MarianaIslands"] = "KZAK",
			["Nevada"] = "KZLA",
			["Normandy"] = nil,
			["PersianGulf"] = "OMAE",
			["Syria"] = "LCCC",
			["TheChannel"] = nil
		}
		local theatre = TheatreOfWarData.getName() or env.mission.theatre
		return theatreCallsigns[theatre] or "ZZZZ"
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

local function getWindDirectionAndSpeed(w, t)
	-- NOTE: max settings in ME are s=97 & t=197
	local d = reverseWind(math.floor(w.dir / 10 + 0.5) * 10)
	local s = math.floor(w.speed * 1.943844 + 0.5)
	if s < 1 then
		if t < 36 then -- s: 0, t: 0-35
			return "00000KT"
		else -- s: 0, t: 36-197
			return "/////KT"
		end
	elseif s < 8 and t >= 36 and t < 126 then -- s: 2-7, t: 36-125
		return string.format("VRB%0.2dKT", math.floor(t * 0.48 / 10 + 0.5)) -- min: 2, max: 6
	elseif s < 8 and t >= 126 then -- s: 2-7, t: 126-197
		return "/////KT"
	elseif s < 46 and t >= 36 then -- s: 8-45, t: 36-197
	 	local g = math.floor(s * (t * 0.0025 + 1.3) + 0.5)
	 	if g < 17 then
	 		v = 17
	 	elseif g > 68 then
	 		g = 68
	 	end
		return string.format("%0.3d%0.2dG%0.2dKT", d, s, g) -- g = min: 17, max: 68
	elseif s >= 46 and t >= 36 then -- s: 46-97, t: 36-197
		local g = math.floor(s * (t * 0.0025 + 1.3) - s / 3 + 0.5)
		if t >= 126 then
			g = math.floor(s * (t * 0.0025 + 1.3) - s / 2 + 0.5)
		end
		return string.format("%0.3d%0.2dG%0.2dKT", d, s, g) -- g = (3) - min: 6, max: 26    (2) - min: 9, max: 38
	end
	return string.format("%0.3d%0.2dKT", d, s) -- s: 2-97, t: 0-35
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
	-- cloud base min: 984ft/300m, max: 16404ft/5000m
	local r = 50
	local i = 100
	local m = 1
	local ft = c.base * 3.28084
	if ft > 10000 then
		r = 500
		i = 1000
		m = 10
	end
	return string.format("%s%0.3d", str, math.floor((ft + r) / i) * m)
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
	if data.date.Year < 1968 then
		return "N/A"
	end
	local metar = string.format("%s %0.2d%0.2d%0.2dL", getCallsign(code), data.date.Day, math.floor(data.time / 60 / 60), data.time / 60 % 60)
	if data.atmosphere > 0 then
		return string.format("%s NIL", metar)
	end
	metar = string.format("%s AUTO", metar)
	local wind = getWindDirectionAndSpeed(data.wind, data.turbulence * 3.28084)
	metar = string.format("%s %s", metar, wind)
	local vis = getVisibility(data)
	metar = string.format("%s %0.4d", metar, vis)
	metar = string.format("%s%s", metar, getWeather(data.precipitation, data.fog, data.fog_visibility, data.dust))
	metar = string.format("%s %s", metar, getClouds(data.clouds))
	metar = string.format("%s %s/%s", metar, getTemp(data.temp), getDewPoint(data.temp, data.clouds.base * 3.28084))
	metar = string.format("%s A%0.4d", metar, math.floor(data.qnh / 25.4 * 100))
	if wind == "/////KT" then
		metar = string.format("%s RMK WS", metar)
	end
	metar = string.format("%s %s", metar, getColor(vis / 1000, data.clouds.base * 3.28084))
	return metar
end
