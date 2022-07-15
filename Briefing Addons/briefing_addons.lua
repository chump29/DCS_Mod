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
local TheatreOfWarData  = require('Mission.TheatreOfWarData')
local MissionDate       = base.MissionDate
local UC                = require('utils_common')

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

function getMagneticDeclination(toStr)
  local theatre
  if TheatreOfWarData then
    theatre = TheatreOfWarData.getName()
  elseif env then
    theatre = env.mission.theatre
  end

  local year = MissionDate.Year

  -- NOTE: East=positive, West=negative
  local dec = 0
  if theatre == "Caucasus" then
    if year >= 2015 then
      dec = 6
    elseif year >= 2006 then
      dec = 5
    elseif year >= 1981 then
      dec = 4
    elseif year >= 1954 then
      dec = 3
    else
      dec = 2
    end
  elseif theatre == "Nevada" then
    if year >= 2015 then
      dec = 10
    elseif year >= 2006 then
      dec = 11
    elseif year >= 1997 then
      dec = 12
    else
      dec = 13
    end
  elseif theatre == "Normandy" then
    if year >= 2010 then
      dec = -1
    elseif year >= 2005 then
      dec = -2
    elseif year >= 1995 then
      dec = -3
    elseif year >= 1990 then
      dec = -4
    elseif year >= 1980 then
      dec = -5
    elseif year >= 1975 then
      dec = -6
    elseif year >= 1970 then
      dec = -7
    elseif year >= 1965 then
      dec = -8
    elseif year >= 1960 then
      dec = -9
    elseif year >= 1950 then
      dec = -10
    else
      dec = -11
    end
  elseif theatre == "PersianGulf" then -- NOTE: using Iran magvar
    if year >= 2010 then
      dec = 1
    else
      dec = 0
    end
  elseif theatre == "Syria" then
    if year >= 2016 then
      dec = 4
    elseif year >= 2010 then
      dec = 3
    elseif year >= 1985 then
      dec = 2
    elseif year >= 1960 then
      dec = 1
    else
      dec = 0
    end
  elseif theatre == "MarianaIslands" then
    if year >= 2013 then
      dec = -1
    else
      dec = 0
    end
  elseif theatre == "TheChannel" then
    if year >= 2006 then
      dec = 0
    elseif year >= 2000 then
      dec = -1
    elseif year >= 1992 then
      dec = -2
    elseif year >= 1987 then
      dec = -3
    elseif year >= 1978 then
      dec = -4
    elseif year >= 1974 then
      dec = -5
    elseif year >= 1970 then
      dec = -6
    elseif year >= 1960 then
      dec = -7
    elseif year >= 1953 then
      dec = -8
    elseif year >= 1949 then
      dec = -9
    else
      dec = -10
    end
  elseif theatre == "Falklands" then
    if toStr then
      return "* See Kneeboard" -- NOTE: too much variant
    end
  end

  if toStr then
    local dir = "East"
    if dec < 0 then dir = "West" end
    dec = string.format("%i° %s (%+i)", dec, dir, dec * -1)
  end

  return dec
end

function getTemp(c)
  return string.format("%d°F / %d°C", math.floor((c or 0) * 9 / 5 + 32), c or 0)
end

function getQNH(qnh)
  return string.format("%0.2finHg / %dhPa", (qnh or 0) / 25.4, qnh or 0)
end

function getClouds(m)
  return string.format("%dft / %dm", math.floor((m or 0) * 3.281), m or 0)
end

function cduWindToStr(wind, temperature)
  local speed = math.floor(wind.speed*1.94384 + 0.5)

  local angle = wind.dir - getMagneticDeclination()

  if angle >= 360 then
    angle = angle - 360
  end

  if angle < 0 then angle = angle + 360 end

    local str = string.format("%.3d/%.2d  %+.2d", angle, speed, temperature)
    return str
end

function cduWindString(a_weather, a_humanPosition, temperature)
    local wind = {}
    if a_weather.atmosphere_type == 0 then
        local w = a_weather.wind
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

        wind[1] = '00  ' .. cduWindToStr({speed=res.v, dir = toPositiveDegrees(res.a+math.pi)}, temperature)
    end
    return wind
end