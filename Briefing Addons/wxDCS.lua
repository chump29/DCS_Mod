--[[
-- wxDCS
-- by Chump
-- Many thanks to HILOK for the ideas and testing!
--]]

do

	local autobriefingutils = require("autobriefingutils")
	local convert = require("unit_converter")
	local utils = require("utils_common")
	local theatreData = require("theatre_data")

	local mToFt = convert.mToFt
	local mpsToKts = convert.mpsToKts
	local round = utils.round
	local composeDateString = autobriefingutils.composeDateString

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

	local function getOffset(m)
		local td = theatreData[m]
		if td then
			return td.utc
		end
		return 0
	end

	local function getTime(t)
		local x = t / 60
		return math.floor(x / 60), math.floor(x % 60) -- h, m
	end

	local function getDate(d, t, m)
		if not d then return "?" end
		local dd = d
		local h, mm = getTime(t)
		h = h - getOffset(m)
		if mm > 50 then
			mm = 50
		elseif mm > 20 then
			mm = 20
		else
			mm = 50
			h = h - 1
		end
		if h >= 24 then
			h = h - 24
			dd = dd + 1
		elseif h < 0 then
			h = h + 24
			dd = dd - 1
		end
		return string.format("%0.2d%0.2d%0.2d", dd, h, mm)
	end

	local function getWindDirectionAndSpeed(w, t)
		if not w then return "?" end
		-- NOTE: max settings in ME are s=97 & ft=197
		local ft = round(mToFt(t))
		local d = utils.revertWind(round(w.dir / 10) * 10)
		local s = round(mpsToKts(w.speed))
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

	local function getPreset(p)
		if dofile then
			local CloudPresets = dofile("Config\\Effects\\getCloudsPresets.lua")
			if p and CloudPresets then
				return CloudPresets[p]
			end
		else
			env.info("wxDCS: dofile not available")
		end
		return nil
	end

	local function getVisibility(d)
		if not d.visibility then return -1 end
		local vis = d.visibility
		local preset = getPreset(d.clouds.preset)
		if preset and preset.precipitationPower > 0 then
			vis = 8000
			d.tempo = true
		elseif d.clouds.iprecptns and (d.clouds.iprecptns == 2 or d.clouds.iprecptns == 4) then
			vis = 3050
		end
		if d.fog and d.fog_visibility and d.fog_visibility < vis then
			vis = d.fog_visibility
		end
		if d.dust and d.dust_visibility < vis then
			vis = d.dust_visibility
		end
		if d.tempo and vis <= 2400 then
			d.tempo = nil
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

	local function getWeather(c, p, f, fv, ft, du, d, t, h, v)
		local str = ""
		local preset = getPreset(c)
		if preset and preset.precipitationPower > 0 then
			if t and t < 3 then
				str = "SN"
			else
				str = "RA"
				if t < 0 then
					str = "FZ" .. str
				end
			end
		elseif not preset then
			if p and p > 0 then
				if p < 3 and t and t < 3 then
					str = "RASN"
				elseif p < 3 and t and t < 0 then
					str = "SN"
				elseif p == 1 then
					if d and d < 7 then
						str = "SHRA"
					else
						str = "RA"
						if t < 0 then
							str = "FZ" .. str
						end
					end
				elseif p == 2 then
					str = "TSRA"
				elseif p == 3 then
					if d and d < 7 then
						str = "SHSN"
					else
						str = "SN"
					end
				else
					str = "+SN"
				end
			end
		end
		if h and h ~= "off" and v <= 5000 and t <= 0 then
			if string.len(str) > 0 then
				str = str .. " IC"
			else
				str = "IC"
			end
		end
		if f and fv and ft then
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
				height = td.position.y
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
			for _, l in ipairs(p.layers) do
				if l.coverage > 0 then
					local c, i = getCoverage(l.coverage)
					if i >= z then
						z = i
						n = n + 1
						local a = d.agl
						if n == 1 then
							d.clouds.density = math.floor(l.density * 10)
						elseif n > 1 then
							a = toAGL(l.altitudeMin, d.msl, d.theatre, d.useDefault)
						end
						local ft = mToFt(a)
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
		d.msl = nil
		if d.position then
			d.msl = d.position.y
		end
		d.agl = toAGL(c.base, d.msl, d.theatre, d.useDefault)
		local str = getPresetClouds(d)
		if str then
			return str
		end
		local ft = mToFt(d.agl)
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
		if not t then return "?" end
		local str = string.format("%0.2d", math.abs(round(t)))
		if t < 0 then
			str = "M" .. str
		end
		return str
	end

	local function getQNH(q)
		return math.floor(convert.mmHgToInHg(q) * 100)
	end

	local function getDewPoint(a, f, d, t, q, v)
		if not t then return "?" end
		local dp = -15
		local ft = mToFt(a)
		if not f then
			if d and d > 0 then
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
		if not w then return "?" end
		local s = round(mpsToKts(w))
		local ft = round(mToFt(t))
		local str = ""
		if s < 3 and ft >= 36 and ft < 126 then -- s: 0-2, ft: 36-125
			str = " TURB"
		elseif s < 8 and ft >= 126 then -- s: 0-7, ft: 126-197
			str = " MOD TURB"
		end
		return str
	end

	local function getColor(v, d, a)
		local vis = v / 1000
		local ft = 99999
		if d and d > 0 then
			ft = mToFt(a)
		end
		if vis < 0.8 then
			return "RED", 1
		elseif vis < 1.6 then
			if ft < 200 then
				return "RED", 1
			else
				return "AMB", 2
			end
		elseif vis < 3.7 then
			if ft < 200 then
				return "RED", 1
			elseif ft < 300 then
				return "AMB", 2
			else
				return "YLO", 3
			end
		elseif vis < 5 then
			if ft < 200 then
				return "RED", 1
			elseif ft < 300 then
				return "AMB", 2
			elseif ft < 700 then
				return "YLO", 3
			else
				return "GRN", 4
			end
		elseif vis < 8 then
			if ft < 200 then
				return "RED", 1
			elseif ft < 300 then
				return "AMB", 2
			elseif ft < 700 then
				return "YLO", 3
			elseif ft < 1500 then
				return "GRN", 4
			else
				return "WHT", 5
			end
		else
			if ft < 200 then
				return "RED", 1
			elseif ft < 300 then
				return "AMB", 2
			elseif ft < 700 then
				return "YLO", 3
			elseif ft < 1500 then
				return "GRN", 4
			elseif ft < 2500 then
				return "WHT", 5
			elseif ft < 20000 then
				return "BLU", 6
			else
				return "BLU+", 7 -- DCS only allows 16,404ft set in ME
			end
		end
	end

	local NA = "N/A"

	local function getSunriseAndSunset(d)
		local err = {
			z = { sunrise = NA, sunset = NA },
			l = { sunrise = NA, sunset = NA }
		}
		local p = d.position
		if not p then
			local td = theatreData[d.theatre]
			if td then
				p = td.position
			end
			if not p then return err end
		end
		local lat, long = coord.LOtoLL(p)
		if not lat or not lon then return err end

		-- NOTE: Borrowed (and modified) from MOOSE [https://github.com/FlightControl-Master/MOOSE/blob/fea1839c06a7608182a465a1852800a07e3b43bb/Moose%20Development/Moose/Utilities/Utils.lua#L1612]
		local MOOSE={}function MOOSE.GetDayOfYear(b,c,d)local e=math.floor;local f=e(275*c/9)local g=e((c+9)/12)local h=1+e((b-4*e(b/4)+2)/3)return f-g*h+d-30 end;function MOOSE.GetSunRiseAndSet(i,j,k,l,m)local n=90.83;local o=j;local p=k;local q=l;local r=i;m=m or 0;local s=math.rad;local t=math.deg;local e=math.floor;local u=function(r)return r-e(r)end;local v=function(w)return math.cos(s(w))end;local x=function(w)return t(math.acos(w))end;local y=function(w)return math.sin(s(w))end;local z=function(w)return t(math.asin(w))end;local A=function(w)return math.tan(s(w))end;local B=function(w)return t(math.atan(w))end;local function C(D,E,F)local G=F-E;local H;if D<E then H=e((E-D)/G)+1;return D+H*G elseif D>=F then H=e((D-F)/G)+1;return D-H*G else return D end end;local I=p/15;local J;if q then J=r+(6-I)/24 else J=r+(18-I)/24 end;local K=0.9856*J-3.289;local L=C(K+1.916*y(K)+0.020*y(2*K)+282.634,0,360)local M=C(B(0.91764*A(L)),0,360)local N=e(L/90)*90;local O=e(M/90)*90;M=M+N-O;M=M/15;local P=0.39782*y(L)local Q=v(z(P))local R=(v(n)-P*y(o))/(Q*v(o))if q and R>1 then return"N/R"elseif R<-1 then return"N/S"end;local S;if q then S=360-x(R)else S=x(R)end;S=S/15;local T=S+M-0.06571*J-6.622;local U=C(T-I+m,0,24)return e(U)*60*60+u(U)*60*60 end;function MOOSE.GetSunrise(d,c,b,j,k,m)local i=MOOSE.GetDayOfYear(b,c,d)return MOOSE.GetSunRiseAndSet(i,j,k,true,m)end;function MOOSE.GetSunset(d,c,b,j,k,m)local i=MOOSE.GetDayOfYear(b,c,d)return MOOSE.GetSunRiseAndSet(i,j,k,false,m)end

		local srZ = MOOSE.GetSunrise(d.date.Day, d.date.Month, d.date.Year, lat, lon)
		local ssZ = MOOSE.GetSunset(d.date.Day, d.date.Month, d.date.Year, lat, lon)
		if srZ == "N/R" or ssZ == "N/S" then return err end

		local offset = getOffset(d.theatre)
		local srL = MOOSE.GetSunrise(d.date.Day, d.date.Month, d.date.Year, lat, lon, offset)
		local ssL = MOOSE.GetSunset(d.date.Day, d.date.Month, d.date.Year, lat, lon, offset)
		if srL == "N/R" or ssL == "N/S" then return err end
		return {
			z = { sunrise = composeDateString(srZ), sunset = composeDateString(ssZ), sr = srZ, ss = ssZ },
			l = { sunrise = composeDateString(srL), sunset = composeDateString(ssL), sr = srL, ss = ssL }
		}
	end

	local function getCase(d)
		if d.atmosphere > 0 then return NA end
		if not d.sun.l.sr or not d.sun.l.ss then return NA end
		local ft = 99999
		if d.clouds.density and d.clouds.density > 0 then
			local p = d.position
			local useDefault = false
			if not p then
				local td = theatreData[d.theatre]
				if td then
					p = td.position
					useDefault = true
				end
			end
			if not p then return NA end
			ft = mToFt(toAGL(d.clouds.base, p.y, d.theatre, useDefault))
		end
		local v = getVisibility(d) / 1852
		local time = d.current_time or d.start_time
		local case = "I"
		if time < d.sun.l.sr or time > d.sun.l.ss or ft < 1000 or v < 5 then
			case = "III"
		elseif ft < 3000 then
			case = "II"
		end
		return string.format("Case %s", case)
	end

	local function getMETAR(d)
		if d.date and d.date.Year < 1968 then return NA end
		local icao = getICAO(d)
		local metar = string.format("%s %sZ", icao, getDate(d.date.Day, d.start_time, d.theatre))
		if d.atmosphere > 0 then
			return string.format("%s NIL", metar)
		end
		metar = string.format("%s AUTO", metar)
		local wind = getWindDirectionAndSpeed(d.wind, d.turbulence)
		metar = string.format("%s %s", metar, wind)
		local vis = getVisibility(d)
		metar = string.format("%s %0.4d", metar, vis)
		metar = string.format("%s%s", metar, getWeather(d.clouds.preset, d.clouds.iprecptns, d.fog, d.fog_visibility, d.fog_thickness, d.dust, d.clouds.density, d.temp, d.halo, vis))
		metar = string.format("%s %s", metar, getClouds(d))
		local qnh = getQNH(d.qnh)
		metar = string.format("%s %s/%s", metar, getTemp(d.temp), getDewPoint(d.agl, d.fog, d.clouds.density, d.temp, qnh, vis))
		metar = string.format("%s A%0.4d", metar, qnh)
		local color, num = getColor(vis, d.clouds.density, d.agl)
		metar = string.format("%s %s", metar, color)
		metar = string.format("%s RMK AO2", metar)
		if wind == "/////KT" then
			metar = string.format("%s%s", metar, getTurbulence(d.wind.speed, d.turbulence))
		end
		if d.tempo then
			metar = string.format("%s TEMPO 2400", metar)
			if num > 3 then
				metar = string.format("%s YLO", metar)
			end
		end
		return string.format("%s=", metar)
	end

	return {
		getSunriseAndSunset = getSunriseAndSunset,
		getCase = getCase,
		getMETAR = getMETAR
	}

end
