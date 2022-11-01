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

-- for < DCS 2.8
local function handleRequire(m)
	local s, o = base.pcall(require, m)
	if s then return o end
	return nil
end
local magvar			= handleRequire("magvar")
local MapWindow
if magvar then
	MapWindow			= require("me_map_window")
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

function getMV(d, p)
	if not magvar or not p then
		return "N/A"
	end
	magvar.init(d.Month, d.Year)
	local lat, long = MapWindow.convertMetersToLatLon(p.x, p.z)
	local magVar = UC.toDegrees(magvar.get_mag_decl(lat, long), true)
	local dir = "East"
	if magVar < 0 then
		dir = "West"
	end
	return string.format("%0.1f° %s (%+0.1d)", math.abs(magVar), dir, math.floor(magVar * -1 + 0.5))
end

local function round(n)
	if n < 0 then
		return math.ceil(n - 0.5)
	end
	return math.floor(n + 0.5)
end

function getTemp(c)
	if not c then return 0 end
	return string.format("%d°C (%d°F)", round(c), round(c * 9 / 5 + 32))
end

function getQNH(qnh)
	if not qnh then return 0 end
	return string.format("%0.2finHg / %dmmHg / %0.2dhPa", math.floor(qnh / 25.4 * 100) / 100, qnh, math.floor(qnh * 1.33322))
end

function getClouds(c)
	if not c then return 0 end
	-- cloud base min: 984ft/300m, max: 16404ft/5000m
	local r = 50
	local i = 100
	local ft = c * 3.28084
	if ft > 10000 then
		r = 500
		i = 1000
	end
	local inFt = math.floor((ft + r) / i) * i
	local inM = math.floor(inFt / 3.28084 + 0.5)
	return string.format("%dft / %dm", inFt, inM)
end

local function reverseWind(dir)
	local dir = dir + 180
	if dir > 360 then
		return dir - 360
	end
	return dir
end

local function toKts(mps)
	return math.floor(mps * 1.943844 + 0.5)
end

function cduWindToStr(wind, temperature)
	return string.format("%0.3d/%0.2d  %+0.2d", reverseWind(wind.dir), wind.speed, temperature)
end

function cduWindString(a_weather, a_humanPosition, temperature)
	local wind = {}
	if a_weather.atmosphere_type == 0 then
			local w = a_weather.wind

			w.atGround.speed = toKts(w.atGround.speed)
			w.at2000.speed = toKts(w.at2000.speed)
			w.at8000.speed = toKts(w.at8000.speed)

			if w.atGround.speed == 0 and w.at2000.speed == 0 and w.at8000.speed == 0 then
				return { "NIL" }
			end

			wind[1] = '00  ' .. cduWindToStr(w.atGround, temperature)

			--if w.atGround.speed + w.at2000.speed + w.at8000.speed == 0 then return wind end

			local interpolatedWind = {speed = w.atGround.speed*2, dir = w.atGround.dir}
			wind[2] = '02  ' .. cduWindToStr(interpolatedWind, temperature-4)
			wind[3] = '07  ' .. cduWindToStr(w.at2000, temperature-14)
			wind[4] = '26  ' .. cduWindToStr(w.at8000, temperature-52)
	else
			local position = a_humanPosition or {x=0, y=0, z=0}

			local param = {cyclones = a_weather.cyclones, position = position}
			local res = dllWeather.getGroundWindAtPoint(param)
		--  param.agl = 1000
		--  local res = dllWeather.getWindAtPoint(param)

			res.v = toKts(res.v)

			if res.v == 0 then
				return { "NIL" }
			end

			wind[1] = '00  ' .. cduWindToStr({speed=res.v, dir = toPositiveDegrees(res.a+math.pi)}, temperature)
	end
	return wind
end
