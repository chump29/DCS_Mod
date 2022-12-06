--[[
-- METAR
-- by Chump
-- Many thanks to HILOK for the ideas and testing!
--]]

local base = _G

module("METAR")

local math = base.math
local string = base.string

local theatreData = {
	["Caucasus"] = {
		["icao"] = "UGTB",
		["elevation"] = 1574, -- in ft
		["utc"] = 4
	},
	["Falklands"] = {
		["icao"] = "EGYP",
		["elevation"] = 243,
		["utc"] = -3
	},
	["MarianaIslands"] = {
		["icao"] = "PGUA",
		["elevation"] = 618,
		["utc"] = 10
	},
	["Nevada"] = {
		["icao"] = "KLSV",
		["elevation"] = 1869,
		["utc"] = -8
	},
	["PersianGulf"] = {
		["icao"] = "OMAA",
		["elevation"] = 92,
		["utc"] = 4
	},
	["Syria"] = {
		["icao"] = "LCLK",
		["elevation"] = 16,
		["utc"] = 3
	}
}

local function toFt(m) -- in m
	return m * 3.280839
end

local function toKts(m) -- in mps
	return m * 1.943844
end

local function toM(f) -- in ft
	return f / 3.280839
end

local function reverseWind(d)
	local dir = d + 180
	if dir > 360 then
		return dir - 360
	end
	return dir
end

local function round(n)
	return math.floor(n + 0.5)
end

local function getICAO(d)
	if not d.icao or string.len(d.icao) == 0 then
		local td = theatreData[d.theatre]
		if td then
			d.useDefault = true
			return td.icao
		end
		return "ZZZZ"
	end
	return d.icao
end

local function getDate(d, t, m)
	local dd = d
	local h = math.floor(t / 60 / 60)
	local td = theatreData[m]
	if td then
		h = h - td.utc
	end
	if h >= 24 then
		h = h - 24
		dd = dd + 1
	elseif h < 0 then
		h = h + 24
		dd = dd - 1
	end
	return string.format("%0.2d%0.2d%0.2d", dd, h, t / 60 % 60)
end

local function getWindDirectionAndSpeed(w, t)
	-- NOTE: max settings in ME are s=97 & ft=197
	local ft = round(toFt(t))
	local d = reverseWind(round(w.dir / 10) * 10)
	local s = round(toKts(w.speed))
	if s < 3 then
		if ft < 36 then -- s: 0-2, ft: 0-35
			return "00000KT"
		else -- s: 0-2, ft: 36-197
			return "/////KT"
		end
	elseif s < 8 and ft >= 36 and ft < 126 then -- s: 3-7, ft: 36-125
		return string.format("VRB%0.2dKT", round(ft * 0.048)) -- min: 2, max: 6
	elseif s < 8 and ft >= 126 then -- s: 3-7, ft: 126-197
		return "/////KT"
	elseif s < 46 and ft >= 36 then -- s: 8-45, ft: 36-197
	 	local g = round(s * (ft * 0.0025 + 1.3))
	 	if ft < 126 and g < s + 6 then
	 		g = s + 6
	 	elseif ft >= 126 and g < s + 9 then
	 		g = s + 9
	 	end
		return string.format("%0.3d%0.2dG%0.2dKT", d, s, g) -- g = min: 17, max: 68
	elseif s >= 46 and ft >= 36 then -- s: 46-97, ft: 36-197
		local g
		local gg = s * (ft * 0.0025 + 1.3)
		if ft < 126 then
			g = round(s + (gg - s) / 3) -- g = min: 52, max: 123
		else
			g = round(s + (gg - s) / 2) -- g = min: 55, max: 135
		end
		return string.format("%0.3d%0.2dG%0.2dKT", d, s, g)
	end
	return string.format("%0.3d%0.2dKT", d, s) -- s: 3-97, ft: 0-35
end

local function getVisibility(v, f, fv, d, dv)
	local vis = v
	if f and fv < vis then
		vis = fv
	end
	if d and dv < vis then
		vis = dv
	end
	local visibility = 9999
	local m
	if vis < 50 then
		visibility = 0
	elseif vis < 800 then
		m = 50
	elseif vis < 5000 then
		m = 100
	elseif vis < 10000 then
		m = 1000
	end
	if m then
		return round(vis / m) * m
	end
	return visibility
end

local function getPreset(p)
	local CloudPresets = base.dofile("Config\\Effects\\getCloudsPresets.lua")
	if p and CloudPresets then
		return CloudPresets[p]
	end
	return nil
end

local function getWeather(c, p, f, fv, ft, du, d)
	local str = ""
	local preset = getPreset(c)
	if preset and preset.precipitationPower > 0 then
		str = "RA"
	elseif not preset then
		if p > 0 then
			if p == 1 then
				if d < 7 then
					str = "SHRA"
				else
					str = "RA"
				end
			elseif p == 2 then
				str = "TSRA"
			elseif p == 3 then
				if d < 7 then
					str = "SHSN"
				else
					str = "SN"
				end
			else
				str = "+SN"
			end
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
	if du then
		if string.len(str) > 0 then
			str = str .. " DU"
		else
			str = "DU"
		end
	end
	if string.len(str) > 0 then
		str = " " .. str
	end
	return str
end

local function toAGL(c, h, t, d)
	local height = h
	if not height or d then
		local td = theatreData[t]
		if td then
			height = toM(td.elevation)
		else
			height = 0
		end
	end
	local cb = c - height
	if cb < 0 then
		cb = 0
	end
	return cb
end

local function getCoverage(c)
	-- instead of using octals, split into ten parts for cloud density slider in ME
	if c < .3 then -- 1-2
		return "FEW", 1
	elseif c > .2 and c < .6 then -- 3-5
		return "SCT", 2
	elseif c > .5 and c < .9 then -- 6-8
		return "BKN", 3
	end
	return "OVC", 4 -- 9-10
end

local function roundClouds(f)
	-- cloud base min: 984ft/300m, max: 16404ft/5000m
	local r = 50
	local i = 100
	local m = 1
	if f > 10000 then
		r = 500
		i = 1000
		m = 10
	end
	return string.format("%0.3d", math.floor((f + r) / i) * m)
end

local function getCB(a, p, d)
	if a <= 10000 then -- not marking clouds above FL100
		if (p == 1 and d > 6) or p == 2 or p == 4 then
			return "CB"
		end
	end
	return ""
end

local function getPresetClouds(d)
	local p = getPreset(d.clouds.preset)
	if p then
		local str = ""
		local z, n = 0, 0
		for _, l in base.ipairs(p.layers) do
			if l.coverage > 0 then
				local c, i = getCoverage(l.coverage)
				if i >= z then
					z = i
					n = n + 1
					local a = d.agl
					if n > 1 then
						a = toAGL(l.altitudeMin, d.msl, d.theatre, d.useDefault)
					end
					local ft = toFt(a)
					if ft <= 24000 then -- skipping clouds above FL240
						if string.len(str) > 0 then
							str = str .. " "
						end
						str = string.format("%s%s%s%s", str, c, roundClouds(ft), getCB(ft, p.precipitationPower, d.clouds.density))
					end
				end
			end
		end
		if string.len(str) > 0 then
			return str
		end
	end
	return nil
end

local function getClouds(d)
	local c = d.clouds
	d.agl = toAGL(c.base, d.msl, d.theatre, d.useDefault)
	local str = getPresetClouds(d)
	if str then
		return str
	end
	local ft = toFt(d.agl)
	if ft > 24000 then -- skipping clouds above FL240
		return "NSC"
	end
	if c.iprecptns == 0 then
		if c.density == 0 then
			if d.fog then
				return "NSC"
			end
			return "CLR"
		elseif d.fog and c.density > 0 and ft > 5000 then
			return "NSC"
		elseif c.density > 0 and ft > 12000 then
			return "CLR"
		elseif c.density > 0 and ft > 5000 then
			return "NSC"
		end
	end
	str, _ = getCoverage(c.density / 10)
	return string.format("%s%s%s", str, roundClouds(ft), getCB(ft, c.iprecptns, c.density))
end

local function getTemp(t)
	if t < 0 then
		return "M" .. string.format("%0.2d", math.abs(math.ceil(t - 0.5)))
	end
	return string.format("%0.2d", math.abs(round(t)))
end

local function getQNH(q)
	return math.floor(q / 25.4 * 100)
end

local function getDewPoint(a, f, d, t, q, v)
	local dp = -15
	local ft = toFt(a)
	if not f then
		if d > 0 then
			dp = t - ft / 400
		end
		if q < 2992 and t - dp > 7 then
			dp = t - 7
		elseif t - dp > 11 then
			dp = t - 11
		end
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

local function getTurbulence(w, t)
	local s = round(toKts(w))
	local ft = round(toFt(t))
	local str = ""
	if s < 3 and ft >= 36 and ft < 126 then -- s: 0-2, ft: 36-125
		str = " RMK TURB"
	elseif s < 8 and ft >= 126 then -- s: 0-7, ft: 126-197
		str = " RMK MOD TURB"
	end
	return str
end

local function getColor(v, d, a)
	local vis = v / 1000
	local ft = 99999 -- arbitrary
	if d > 0 then
		ft = toFt(a)
	end
	if vis < 0.8 then
		return "RED"
	elseif vis < 1.6 then
		if ft < 200 then
			return "RED"
		else
			return "AMB"
		end
	elseif vis < 3.7 then
		if ft < 200 then
			return "RED"
		elseif ft < 300 then
			return "AMB"
		else
			return "YLO"
		end
	elseif vis < 5 then
		if ft < 200 then
			return "RED"
		elseif ft < 300 then
			return "AMB"
		elseif ft < 700 then
			return "YLO"
		else
			return "GRN"
		end
	elseif vis < 8 then
		if ft < 200 then
			return "RED"
		elseif ft < 300 then
			return "AMB"
		elseif ft < 700 then
			return "YLO"
		elseif ft < 1500 then
			return "GRN"
		else
			return "WHT"
		end
	else
		if ft < 200 then
			return "RED"
		elseif ft < 300 then
			return "AMB"
		elseif ft < 700 then
			return "YLO"
		elseif ft < 1500 then
			return "GRN"
		elseif ft < 2500 then
			return "WHT"
		elseif ft < 20000 then
			return "BLU"
		else
			return "BLU+" -- DCS only allows 16,404ft set in ME
		end
	end
end

--[[
local function debug(n, v)
	if base.io and base.os and base.require then
		local d = base.os.getenv("USERPROFILE") or ""
		if string.len(d) > 0 then
			d = d .. "\\Desktop\\"
		end
		local f = base.assert(base.io.open(d .. "log.txt", "a"))
		if f then
			local Serializer = base.require("Serializer")
			local s = Serializer.new(f)
			f:write(base.os.date("-- %x @ %X"), "\n\n")
			s:serialize_sorted(n, v)
			f:write("\n")
			f:flush()
			f:close()
		end
	end
end
--]]

function getMETAR(d)
	--debug("d", d)
	if d.date.Year < 1968 then
		return "N/A"
	end
	local icao = getICAO(d)
	local metar = string.format("%s %sZ", icao, getDate(d.date.Day, d.time, d.theatre))
	if d.atmosphere > 0 then
		return string.format("%s NIL", metar)
	end
	metar = string.format("%s AUTO", metar)
	local wind = getWindDirectionAndSpeed(d.wind, d.turbulence)
	metar = string.format("%s %s", metar, wind)
	local vis = getVisibility(d.visibility, d.fog, d.fog_visibility, d.dust, d.dust_visibility)
	metar = string.format("%s %0.4d", metar, vis)
	metar = string.format("%s%s", metar, getWeather(d.clouds.preset, d.clouds.iprecptns, d.fog, d.fog_visibility, d.fog_thickness, d.dust, d.clouds.density))
	metar = string.format("%s %s", metar, getClouds(d))
	local qnh = getQNH(d.qnh)
	metar = string.format("%s %s/%s", metar, getTemp(d.temp), getDewPoint(d.agl, d.fog, d.clouds.density, d.temp, qnh, vis))
	metar = string.format("%s A%0.4d", metar, qnh)
	if wind == "/////KT" then
		metar = string.format("%s%s", metar, getTurbulence(d.wind.speed, d.turbulence))
	end
	return string.format("%s %s", metar, getColor(vis, d.clouds.density, d.agl))
end
