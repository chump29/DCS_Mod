--[[
-- Briefing Addons
-- Modified by Chump
-- Originally by BManx2000 @ https://www.digitalcombatsimulator.com/en/files/2080541/
--]]

local base = _G

module('briefing_addons')

local require           = base.require
local math              = base.math
local string            = base.string
local dllWeather        = require('Weather')
local UC                = require('utils_common')
local convert = require("unit_converter")

-- for < DCS 2.8
local function handleRequire(m)
	local s, o = base.pcall(require, m)
	if s then return o end
	return nil
end
local magvar			= handleRequire("magvar")
local terrain			= require("terrain")

local mpsToKts = convert.mpsToKts
local round = UC.round
local roundToNearest = UC.roundToNearest

function getMV(d, g)
	if not magvar or not g or not g.position then
		return "N/A"
	end
	magvar.init(d.Month, d.Year)
	local lat, lon = terrain.convertMetersToLatLon(g.position.x, g.position.z)
	local magVar = UC.toDegrees(magvar.get_mag_decl(lat, lon), true)
	local dir = "East"
	if magVar < 0 then
		dir = "West"
	end
	return string.format("%0.1f° %s (%+0.1f)", math.abs(magVar), dir, magVar * -1)
end

function getTemp(c)
	return string.format("%d°C (%d°F)", round(c), round(c * 9 / 5 + 32))
end

local function toQNH(q, a)
	return q + a / 27.3 -- in hPa
end

function getQNH(a, q, g)
	if a == 0 then
		return string.format("%0.2finHg / %dmmHg / %0.2dhPa", math.floor(convert.mmHgToInHg(q) * 100) / 100, math.floor(q), math.floor(convert.mmHgToHpa(q)))
	elseif g and g.position and g.position.y then -- in m
		local _, pressure = dllWeather.getTemperatureAndPressureAtPoint({position = g.position}) -- QFE in Pa
		local qnh = toQNH(pressure / 100, g.position.y)
		return string.format("%0.2finHg / %dmmHg / %0.2dhPa", math.floor(qnh * 0.029530), math.floor(qnh * 0.750062), math.floor(qnh))
	end
	return "N/A"
end

function getClouds(a, c)
	if a > 0 then
		return "N/A"
	end
	if not c.preset and c.density == 0 then
		return "NIL"
	end
	local ft = roundToNearest(convert.mToFt(c.base), 100)
	local m = roundToNearest(c.base, 30)
	return string.format("%dft / %dm", ft, m)
end

local function cduWindToStr(d, s, t)
	return string.format("%0.3d/%0.2d  %+0.2d", UC.revertWind(d), s, t)
end

function cduWindString(a_weather, a_humanPosition, temperature)
	local wind = {}
	if a_weather.atmosphere_type == 0 then
			local w = a_weather.wind

			local atGroundSpeed = round(mpsToKts(w.atGround.speed))
			local at2000Speed = round(mpsToKts(w.at2000.speed))
			local at8000Speed = round(mpsToKts(w.at8000.speed))

			wind[1] = '00  ' .. cduWindToStr(w.atGround.dir, atGroundSpeed, temperature)

			--if w.atGround.speed + w.at2000.speed + w.at8000.speed == 0 then return wind end

			local interpolatedWind = {speed = atGroundSpeed*2, dir = w.atGround.dir}
			wind[2] = '02  ' .. cduWindToStr(interpolatedWind.dir, interpolatedWind.speed, temperature-4)
			wind[3] = '07  ' .. cduWindToStr(w.at2000.dir, at2000Speed, temperature-14)
			wind[4] = '26  ' .. cduWindToStr(w.at8000.dir, at8000Speed, temperature-52)
	else
			local position = a_humanPosition or {x=0, y=0, z=0}

			local param = {cyclones = a_weather.cyclones, position = position}
			local res = dllWeather.getGroundWindAtPoint(param)
		--  param.agl = 1000
		--  local res = dllWeather.getWindAtPoint(param)

			res.v = round(mpsToKts(res.v))

			if res.v == 0 then
				return { "NIL" }
			end

			wind[1] = '00  ' .. cduWindToStr(UC.toPositiveDegrees(res.a+math.pi), res.v, temperature)
	end
	return wind
end

function getTheatreData()
	return {
		["Caucasus"] = {
			["icao"] = "UGTB",
			["utc"] = 4,
			["position"] = { x = -314926.25, y = 479.69479370117, z = 895724 }
		},
		["Falklands"] = {
			["icao"] = "EGYP",
			["utc"] = -3,
			["position"] = { x = 73598.5625, y = 74.136428833008, z = 46176.4140625 }
		},
		["MarianaIslands"] = {
			["icao"] = "PGUA",
			["utc"] = 10,
			["position"] = { x = 9961.662109375, y = 166.12214660645, z = 13072.155273438 }
		},
		["Nevada"] = {
			["icao"] = "KLSV",
			["utc"] = -8,
			["position"] = { x = -399275.84375, y = 561.30914306641, z = -18183.12109375 }
		},
		-- Normandy
		["PersianGulf"] = {
			["icao"] = "OMAA",
			["utc"] = 4,
			["position"] = { x = -187211.25, y = 28.000028610229, z = -163535.515625 }
		},
		["Syria"] = {
			["icao"] = "LCLK",
			["utc"] = 3,
			["position"] = { x = -8466.0517578125, y = 5.0000047683716, z = -209773.46875 }
		}
		-- TheChannel
	}
end

function getZuluTime(s, t)
	local theatreData = getTheatreData()
	local td = theatreData[t]
	if td then
		return s + td.utc * 60 * 60
	end
	return s
end
