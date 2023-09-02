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
local theatreData = require("theatre_data")
local magvar			= require("magvar")
local terrain			= require("terrain")

local mpsToKts = convert.mpsToKts
local round = UC.round
local roundToNearest = UC.roundToNearest

function getMV(d, g)
	if not magvar or not g or not g.position or not d then
		return "N/A"
	end
	magvar.init(d.Month, d.Year)
	local lat, lon = terrain.convertMetersToLatLon(g.position.x, g.position.z)
	local mv = UC.toDegrees(magvar.get_mag_decl(lat, lon), true)
	local dir = "East"
	if mv < 0 then
		dir = "West"
	end
	return string.format("%0.1f° %s (%+0.1f)", math.abs(mv), dir, -mv), -mv
end

function getTemp(c)
	return string.format("%d°C (%d°F)", round(c), round(convert.cToF(c)))
end

function getQNH(a, q, g)
	if a == 0 then
		return string.format("%0.2finHg / %dmmHg / %0.2dhPa", math.floor(convert.mmHgToInHg(q) * 100) / 100, math.floor(q), math.floor(convert.mmHgToHpa(q)))
	elseif g and g.position and g.position.y then -- in m
		local _, pressure = dllWeather.getTemperatureAndPressureAtPoint({position = g.position}) -- QFE in Pa
		local qnh = convert.qfeToQnh(pressure / 100, g.position.y) -- QNH in hPa
		return string.format("%0.2finHg / %dmmHg / %0.2dhPa", math.floor(convert.hPaToInHg(qnh)), math.floor(convert.hPaToMmHg(qnh)), math.floor(qnh))
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

function cduWindString(a_weather, a_humanPosition, temperature, mv)
	mv = mv or 0
	local wind = {}
	if a_weather.atmosphere_type == 0 then
			local w = a_weather.wind

			local atGroundSpeed = round(mpsToKts(w.atGround.speed))
			local at2000Speed = round(mpsToKts(w.at2000.speed))
			local at8000Speed = round(mpsToKts(w.at8000.speed))

			local atGroundDir = w.atGround.dir + mv
			local at2000Dir = w.at2000.dir + mv
			local at8000Dir = w.at8000.dir + mv

			wind[1] = '00  ' .. cduWindToStr(atGroundDir, atGroundSpeed, temperature)

			--if w.atGround.speed + w.at2000.speed + w.at8000.speed == 0 then return wind end

			local interpolatedWind = {speed = atGroundSpeed*2, dir = atGroundDir}
			wind[2] = '02  ' .. cduWindToStr(interpolatedWind.dir, interpolatedWind.speed, temperature-4)
			wind[3] = '07  ' .. cduWindToStr(at2000Dir, at2000Speed, temperature-14)
			wind[4] = '26  ' .. cduWindToStr(at8000Dir, at8000Speed, temperature-52)
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

			wind[1] = '00  ' .. cduWindToStr(UC.toPositiveDegrees(res.a+math.pi) + mv, res.v, temperature)
	end
	return wind
end

function getZuluTime(s, t)
	local td = theatreData[t]
	if td then
		return s + td.utc * 60 * 60
	end
	return s
end
