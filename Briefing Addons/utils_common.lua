local base = _G

module('utils_common')

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

local gettext       	= require('i_18n')
local dllWeather 		= require('Weather')
local minizip       	= require('minizip')
local lfs       		= require('lfs')
local mod_dictionary	= require('dictionary')
local datum_converter 	= base.safe_require("DatumConverter")

local mdcVersion = 1

local function _(text) 
	return gettext.translate(text) 
end

local cdata =
{
    speed_unit = _('m/s'),
    wind_at_ground = _('GRND'),
    wind_at_2000 = _('6600ft / 2000m'),
    wind_at_8000 = _('26000ft / 8000m'),
	Meteo		 = _('Meteo'),
	speed_unit_kts = _("kts"),
	NA = _("N/A"),
	NIL = _("NIL")
}

local missionTheatreCache
local missionTheatreCacheChanged = false
local missionTheatreCacheFilename = 'MissionEditor/MissionTheatreCache.lua'

local missionDataCache
local missionDataCacheChanged = false
local missionDataCacheFilename = 'MissionEditor/MissionDataCache.lua'

function LL_datum_convert(datum_src,datum_dest,lat,lon)
    if datum_converter then
       local  clat,clon = datum_converter.convert(datum_src,datum_dest,lat,lon)
       return clat,clon
    end
    return lat,lon
end

function sleep(n)  -- mseconds только для небольших интервалов
  local t0 = clock()*1000
  while clock()*1000 - t0 <= n do end
end

function toDegrees(radians, raw)
  local degrees = radians * 180 / math.pi
  
  if not raw then
    degrees = math.floor(degrees + 0.5)
  end
  
  return degrees
end

function toRadians(degrees, raw)
  local radians = degrees * math.pi / 180  
  
  if not raw then
    radians = math.floor(radians + 0.5)
  end
  
  return radians
end

function toPositiveDegrees(radians, raw)
  local degrees = toDegrees(radians, raw)
  
  if degrees < 0 then
    degrees = degrees + 360
  end
  
  return degrees
end


local function revertWind(a_value)
	local a_value = a_value + 180
	if a_value > 360 then
		return a_value - 360
	end
	return a_value
end

local function toKts(mps)
	return math.floor(mps * 1.943844 + 0.5)
end

local function roundTo10(n)
	return math.floor(n / 10 + 0.5) * 10
end

-------------------------------------------------------------------------------
-- convert wind structure to wind string
function windToStr(d, s)
    return string.format("%.3d° @ %.1d%s", revertWind(roundTo10(d)), s, cdata.speed_unit_kts) -- direction wind blows FROM, in kts
end

-------------------------------------------------------------------------------
-- формирование массива строк с данными о турбулентности
function composeTurbulenceString(a_weather)
	if not a_weather then 
		return {cdata.NA}
	end
    if  a_weather.turbulence then
        local t = a_weather.turbulence
        local turbulence = {}
        if t == 0 then
        	turbulence[1] = cdata.NIL
        else
        	turbulence[1] = string.format("%0.1f%s (%0.1f%s)", math.floor(t.atGround * 1.943844 + 0.5) / 10, cdata.speed_unit_kts, math.floor(t.atGround + 0.5) / 10, cdata.speed_unit)
        end
        return turbulence
    else
        local turbulence = {}
        if a_weather.groundTurbulence == 0 then
        	turbulence[1] = cdata.NIL
        else
        	turbulence[1] = string.format("%0.1f%s (%0.1f%s)", math.floor(a_weather.groundTurbulence * 1.943844 + 0.5) / 10, cdata.speed_unit_kts, math.floor(a_weather.groundTurbulence + 0.5) / 10, cdata.speed_unit)
        end
        return turbulence
    end    
end

-------------------------------------------------------------------------------
-- формирование массива строк с данными о ветре
function composeWindString(a_weather, a_humanPosition)
    if not a_weather then 
		return {'0','0','0'}
	end
	
	local wind = {}
	dllWeather.initAtmospere(a_weather)
 
    if a_weather.atmosphere_type == 0 then
        local w = a_weather.wind

		local atGroundSpeed = toKts(w.atGround.speed)
		local at2000Speed = toKts(w.at2000.speed)
		local at8000Speed = toKts(w.at8000.speed)

		if atGroundSpeed == 0 and at2000Speed == 0 and at8000Speed == 0 then
			return { cdata.NIL }
		end

        wind[1] = cdata.wind_at_ground .. ' ' .. windToStr(w.atGround.dir, atGroundSpeed)
        wind[2] = cdata.wind_at_2000 .. ' ' .. windToStr(w.at2000.dir, at2000Speed)
        wind[3] = cdata.wind_at_8000 .. ' ' .. windToStr(w.at8000.dir, at8000Speed)
    else
		local res = dllWeather.getGroundWindAtPoint({position = a_humanPosition or {x=0, y=0, z=0}})

		res.v = toKts(res.v)

		if res.v == 0 then
			return { cdata.NIL }
		end

        wind[1] = cdata.wind_at_ground .. ' ' ..windToStr(toPositiveDegrees(res.a+math.pi), res.v)
    end
    return wind
end

function loadMissionTheatreCache()
	if not missionTheatreCache then
		local f, err = base.loadfile(lfs.writedir() .. missionTheatreCacheFilename)

		if f then
			missionTheatreCache = f()
		else
			missionTheatreCache = {}
		end		
	end
	
	if not missionDataCache then
		local f, err = base.loadfile(lfs.writedir() .. missionDataCacheFilename)

		if f then
			missionDataCache = f()
			if missionDataCache == nil or missionDataCache.version == nil or missionDataCache.version < mdcVersion then
				missionDataCache = {}
			end
		else
			missionDataCache = {}
		end		
	end
end

function saveMissionTheatreCache()
	if missionTheatreCacheChanged then
		local Serializer = require('Serializer')
		local file, err = base.io.open(lfs.writedir() .. missionTheatreCacheFilename, 'w')
		
		if file then
			local serializer = Serializer.new(file)
			
			file:write('local ')
			serializer:serialize_sorted('missionTheatreCache', missionTheatreCache)
			file:write('return missionTheatreCache\n')
			
			file:close()
		else
			print(err)
		end
	end
	
	if missionDataCacheChanged then
		local Serializer = require('Serializer')
		local file, err = base.io.open(lfs.writedir() .. missionDataCacheFilename, 'w')
		missionDataCache.version = mdcVersion
		
		if file then
			local serializer = Serializer.new(file)
			
			file:write('local ')
			serializer:serialize_sorted('missionDataCache', missionDataCache)
			file:write('return missionDataCache\n')
			
			file:close()
		else
			print(err)
		end
	end
end

local function addToMissionTheatreCache(filename, theatre, modification)
	missionTheatreCache[filename] = {theatre = theatre, modification = modification}
	missionTheatreCacheChanged		= true
end

local function addToMissionDataCache(filename, data, modification, a_locale)
	missionDataCache[filename] = missionDataCache[filename] or {}
	missionDataCache[filename][a_locale] = {data = data, modification = modification}
	missionDataCacheChanged		= true
end


-------------------------------------------------------------------------------
-- получение театра из миссии
function getNameTheatre(a_fileName)
--print("---getNameTheatre--",a_fileName)	
	local data			= missionTheatreCache[a_fileName]
	local attributes	= lfs.attributes(a_fileName)
	
	if data then	
		if data.modification == attributes.modification then
			return data.theatre
		end		
	end
    
    local zipFile = minizip.unzOpen(a_fileName, 'rb')
	
    if not zipFile then
        return ''
    end
	
    local misStr
	
    if zipFile:unzLocateFile('theatre') then
        misStr = zipFile:unzReadAllCurrentFile(true) -- true- чтобы не вызывало падения при битом файле
		
		if misStr then
			zipFile:unzClose()
			
			addToMissionTheatreCache(a_fileName, misStr, attributes.modification)
			 
			return misStr
		end
    end	

    if zipFile:unzLocateFile('mission') then
        misStr = zipFile:unzReadAllCurrentFile(true) -- true- чтобы не вызывало падения при битом файле
		
		if misStr == nil then
			print("--ERROR getNameTheatre, zipFile:unzReadAllCurrentFile:", a_fileName)
			return ''
		end
    end

    local funD = base.loadstring(misStr or "")
    local envD = { }
    if funD then
        base.setfenv(funD, envD)
    else
        print("--ERROR getNameTheatre, funD==nil",a_fileName)
        return " "
    end
    
    status, err = base.pcall(funD)
	
    if not status then 
        print("--ERROR getNameTheatre, err=",status, err)
        return " "
    end

    local mission = envD.mission
    local theatre
    
    if mission then
        theatre = mission.theatre
    end    
    
    zipFile:unzClose()
	
	addToMissionTheatreCache(a_fileName, theatre or 'Caucasus', attributes.modification)
	
    return theatre or 'Caucasus'
end

-------------------------------------------------------------------------------
-- получение данных из миссии
function getMissionData(a_fileName, a_locale)
	local missionData	= missionDataCache[a_fileName] and missionDataCache[a_fileName][a_locale]
	local attributes	= lfs.attributes(a_fileName)
	
	if attributes == nil then
		return nil
	end
	
	if missionData then	
		if missionData.modification == attributes.modification then
			return missionData.data
		end	
	else
		missionData = {}
	end
    
	local desc, requiredModules, task, theatreName, unitType, sortie = mod_dictionary.getMissionDescription(a_fileName, a_locale, false, true)
	missionData.data = {desc = desc, requiredModules = requiredModules, task = task, theatreName = theatreName, unitType = unitType, sortie = sortie}

	addToMissionDataCache(a_fileName, missionData.data, attributes.modification, a_locale)

    return missionData.data
end

function getExtension(a_fileName)
    local ext = nil
    local dotIdx = string.find(string.reverse(a_fileName), '%.')
    if dotIdx then
        ext = string.sub(a_fileName, -dotIdx+1)
    end
    return ext
end

function getNumDayInMounts()
	local NumDayInMounts =
	{
		31, --Январь
		28, --Февраль
		31,	--Март
		30,	--Апрель
		31,	--Май
		30,	--Июнь
		31,	--Июль
		31,	--Август
		30,	--Сентябрь
		31,	--Октябрь
		30,	--Ноябрь
		31	--Декабрь
	}
	return NumDayInMounts
end

function parseColorString(colorString)
	local r
	local g
	local b
	local a

	local i = tonumber(colorString)

	if i then
		local f

		i, f = math.modf(i / 256)
		a = f * 256

		i, f = math.modf(i / 256)
		b = f * 256

		r, f = math.modf(i / 256)

		g = f * 256
	end

	return r, g, b, a
end

function colorFromString(colorString)
	local r, g, b, a = parseColorString(colorString)

	return { r / 255, g / 255, b / 255, a / 255}
end