--[[
-- Radio Tower
-- by Chump
--]]

do

	local config = RADIO_TOWER_CONFIG or {
		towers = {
			{
				name = "Music", -- zone
				stations = {
					{
						name = "Radio X",
						sound = "Radio X.ogg", -- mp3/ogg
						frequency = 40, -- in MHz
						modulation = 1, -- 0=AM, 1=FM
						power = 1000, -- in W
						loop = true
					},
					{
						name = "V-Rock",
						sound = "VROCK.ogg",
						frequency = 41,
						modulation = 1,
						power = 1000,
						loop = true
					}
				}
			}
		},
		enableMarks = true, -- show on F10 map
		messages = false -- show status messages
	}

	local function log(msg)
		env.info(string.format("RadioTower: %s", msg))
	end
	local function say(msg)
		trigger.action.outText(msg, 10)
	end

	local function getFrequency(frequency)
		if frequency < 1 then return tonumber(string.format("%f", frequency * 1000)) end
		return frequency
	end
	local function getHertz(frequency)
		if frequency < 1 then return "kHz" end
		return "MHz"
	end
	local function getModulation(modulation)
		if modulation == 1 then return "FM" end
		return "AM"
	end

	for _, tower in ipairs(config.towers) do
		local zone = trigger.misc.getZone(tower.name)
		if zone then
			local obj = coalition.addStaticObject(country.id.SWITZERLAND, {
    			category = "Fortifications",
				shape_name = "tele_bash",
				type = "TV tower",
				rate = 0,
				y = zone.point.z,
				x = zone.point.x,
				name = tower.name,
				heading = math.random(360),
				--hidden = true
			})
			if obj then
				for i, station in ipairs(tower.stations) do
					local name = string.format("%s-%d", tower.name, i)
					local power = math.floor(math.abs(station.power))
					trigger.action.radioTransmission(
						string.format("l10n/DEFAULT/%s", station.sound),
						zone.point,
						radio.modulation[getModulation(station.modulation)],
						station.loop,
						tonumber(string.format("%.9d", station.frequency * 1000000)),
						power,
						name
					)
					local str = string.format("%s started transmitting %s (%s) on %.3f %s %s [%dw]", tower.name, station.name, station.sound, getFrequency(station.frequency), getHertz(station.frequency), getModulation(station.modulation), power)
					log(str)
					if config.messages then	say(str) end
					local handler = {}
					function handler:onEvent(event)
						if event.id == world.event.S_EVENT_DEAD and event.initiator and event.initiator:getName() == tower.name then
							trigger.action.stopRadioTransmission(name)
							local str = string.format("%s stopped transmitting %s (%s) on %.3f %s %s [%dw]", tower.name, station.name, station.sound, getFrequency(station.frequency), getHertz(station.frequency), getModulation(station.modulation), power)
							log(str)
							if config.messages then say(str) end
							if config.enableMarks then
								trigger.action.removeMark(tower.id)
							end
						end
					end
					world.addEventHandler(handler)
				end
			else
				log(string.format("Unable to spawn static object for %s", tower.name))
			end
			if config.enableMarks then
				local stations = ""
				for i, station in ipairs(tower.stations) do
					if i > 1 then stations = string.format("%s\n", stations) end
					stations = string.format("%s%s - %.3f %s %s [%dw]", stations, station.name, getFrequency(station.frequency), getHertz(station.frequency), getModulation(station.modulation), math.floor(math.abs(station.power)))
				end
				if string.len(stations) > 0 then
					tower.id = math.random(100000, 1000000)
					trigger.action.markToAll(tower.id, string.format("%s stations:\n%s", tower.name, stations), zone.point, true)
				end
			end
		else
			log(string.format("Zone %s not found", tower.name))
		end
	end

end
