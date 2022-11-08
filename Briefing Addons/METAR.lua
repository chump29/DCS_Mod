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
		fog_thickness = data.weather.fog.thickness,
		dust = data.weather.enable_dust,
		dust_visibility = data.weather.dust_density,
		clouds = data.weather.clouds,
		temp = data.weather.season.temperature,
		qnh = data.weather.qnh
	}
end

local function getCallsign(g)
	local c
	if g and #g > 0 then
		c = g[1].code
	end
	if not c or string.len(c) == 0 then
		local theatreCallsigns = {
			["Caucasus"] = "UGGG",
			["Falklands"] = "SAVF",
			["MarianaIslands"] = "KZAK",
			["Nevada"] = "KZLA",
			["PersianGulf"] = "OMAE",
			["Syria"] = "LCCC"
		}
		local theatre = TheatreOfWarData.getName() or env.mission.theatre
		if theatre then
			local cs = theatreCallsigns[theatre]
			if cs then
				return cs
			end
		end
		return "ZZZZ"
	end
	return c
end

local function toFt(m)
	return m * 3.28084
end

local function toKts(mps)
	 return mps * 1.943844
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
	local s = math.floor(toKts(w.speed) + 0.5)
	if s < 3 then
		if t < 36 then -- s: 0-2, t: 0-35
			return "00000KT"
		else -- s: 0-2, t: 36-197
			return "/////KT"
		end
	elseif s < 8 and t >= 36 and t < 126 then -- s: 3-7, t: 36-125
		return string.format("VRB%0.2dKT", math.floor(t * 0.048 + 0.5)) -- min: 2, max: 6
	elseif s < 8 and t >= 126 then -- s: 3-7, t: 126-197
		return "/////KT"
	elseif s < 46 and t >= 36 then -- s: 8-45, t: 36-197
	 	local g = math.floor(s * (t * 0.0025 + 1.3) + 0.5)
	 	if t < 126 and g < s + 6 then
	 		g = s + 6
	 	elseif t >= 126 and g < s + 9 then
	 		g = s + 9
	 	end
		return string.format("%0.3d%0.2dG%0.2dKT", d, s, g) -- g = min: 17, max: 68
	elseif s >= 46 and t >= 36 then -- s: 46-97, t: 36-197
		local g
		local gg = s * (t * 0.0025 + 1.3)
		if t < 126 then
			g = math.floor(s + (gg - s) / 3 + 0.5) -- g = min: 52, max: 123
		else
			g = math.floor(s + (gg - s) / 2 + 0.5) -- g = min: 55, max: 135
		end
		return string.format("%0.3d%0.2dG%0.2dKT", d, s, g)
	end
	return string.format("%0.3d%0.2dKT", d, s) -- s: 3-97, t: 0-35
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

local function getWeather(p, f, fv, ft, d)
	local str = ""
	if p > 0 then
		if p == 1 then
			str = "SHRA"
		elseif p == 2 then
			str = "TSRA"
		elseif p == 3 then
			str = "SHSN"
		else
			str = "+SN"
		end
	end
	if f then
		local fs
		if fv < 1000 then
			fs = "FG"
			if ft < 2 then
				fs = "MI" .. fs
			end
		elseif fv < 3000 then
			fs = "BCFG"
		elseif fv <= 5000 then
			fs = "BR"
		end
		if fs then
			if string.len(str) > 0 then
				str = str .. " " .. fs
			else
				str = fs
			end
		end
	end
	if d then
		if string.len(str) > 0 then
			str = str .. " DU"
		else
			str = "DU"
		end
	end
	return str
end

local function getClouds(c, f, p)
	local ft = toFt(c.base)
	local str = ""
	-- instead of using octals, split into ten parts
	if p == 0 then
		if c.density == 0 then
			if f then
				return "NSC"
			end
			return "CLR"
		elseif f and c.density > 0 and ft > 5000 then
			return "NSC"
		elseif c.density > 0 and ft > 12000 then
			return "CLR"
		elseif c.density > 0 and ft > 5000 then
			return "NSC"
		elseif c.density > 0 and c.density < 3 then -- 1-2
			str = "FEW"
		elseif c.density > 2 and c.density < 6 then -- 3-5
			str = "SCT"
		elseif c.density > 5 and c.density < 9 then -- 6-8
			str = "BKN"
		else -- 9-10
			str = "OVC"
		end
	end
	-- cloud base min: 984ft/300m, max: 16404ft/5000m
	local r = 50
	local i = 100
	local m = 1
	if ft > 10000 then
		r = 500
		i = 1000
		m = 10
	end
	local cb = "CB"
	if p == 3 then
		cb = ""
	end
	return string.format("%s%0.3d%s", str, math.floor((ft + r) / i) * m, cb)
end

local function getTemp(t)
	if t < 0 then
		return "M" .. string.format("%0.2d", math.abs(math.ceil(t - 0.5)))
	end
	return string.format("%0.2d", math.abs(math.floor(t + 0.5)))
end

local function getDewPoint(c, f, t, v)
	local dp
	local ft = toFt(c.base)
	if not f then
		dp = t - ft / 400
		if dp < -15 then
			dp = -15
		end
	else
		dp = t - 2
		if v < 1000 then
			dp = t
		elseif v < 3000 then
			dp = t - 1
		end
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

function getMETAR(data, groups)
	local data = normalizeData(data)
	if data.date.Year < 1968 then
		return "N/A"
	end
	local metar = string.format("%s %0.2d%0.2d%0.2dL", getCallsign(groups), data.date.Day, math.floor(data.time / 60 / 60), data.time / 60 % 60)
	if data.atmosphere > 0 then
		return string.format("%s NIL", metar)
	end
	metar = string.format("%s AUTO", metar)
	local wind = getWindDirectionAndSpeed(data.wind, toFt(data.turbulence))
	metar = string.format("%s %s", metar, wind)
	local vis = getVisibility(data)
	metar = string.format("%s %0.4d", metar, vis)
	local clouds = getClouds(data.clouds, data.fog, data.precipitation)
	if clouds ~= "NSC" then
		metar = string.format("%s %s", metar, getWeather(data.precipitation, data.fog, data.fog_visibility, data.fog_thickness, data.dust))
	end
	metar = string.format("%s %s", metar, clouds)
	metar = string.format("%s %s/%s", metar, getTemp(data.temp), getDewPoint(data.clouds, data.fog, data.temp, vis))
	metar = string.format("%s A%0.4d", metar, math.floor(data.qnh / 25.4 * 100))
	if wind == "/////KT" then
		metar = string.format("%s RMK WS", metar)
	end
	metar = string.format("%s %s", metar, getColor(vis / 1000, toFt(data.clouds.base)))
	return metar
end
