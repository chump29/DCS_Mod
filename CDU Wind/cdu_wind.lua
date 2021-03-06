-- modified by Chump
local base = _G

module('cdu_wind')

local type          = base.type
local require       = base.require
local print         = base.print
local assert        = base.assert
local tostring      = base.tostring
local pairs         = base.pairs
local ipairs        = base.ipairs
local tonumber      = base.tonumber
local table         = base.table
local math          = base.math
local string        = base.string
local clock         = base.os.clock

local gettext       = require('i_18n')
local dllWeather  = require('Weather')
local minizip       = require('minizip')

local TheatreOfWarData = require('Mission.TheatreOfWarData')

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
  -- Caucasus +6 (East), year ~ 2011
  -- NTTR +12 (East), year ~ 2011
  -- Normandy -10 (West), year ~ 1944
  -- Persian Gulf +2 (East), year ~ 2011
  -- Syria +5 (East), year ~ 2020

  local theatre
  if TheatreOfWarData then
    theatre = TheatreOfWarData.getName()
  elseif env then
    theatre = env.mission.theatre
  end

  local dec
  if theatre == "Caucasus" then
    dec = 6
  elseif theatre == "Nevada" then
    dec = 12
  elseif theatre == "Normandy" then
    dec = -10
  elseif theatre == "PersianGulf" then
    dec = 2
  elseif theatre == "Syria" then
    dec = 5
  else
    return dec
  end

  if toStr then
    local dir = "East"
    if dec < 0 then dir = "West" end
    dec = string.format("%i° %s (%+i)", dec, dir, dec * -1)
  end

  return dec
end

function getTempString(c)
  return string.format("%+d°C / %+d°F", c, c * 9 / 5 + 32)
end

function getClouds(m)
  return string.format("%dm / %dft", m, math.floor(m * 3.281))
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