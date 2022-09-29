--[[
-- Radio Tower
-- by Chump
--]]

do

	local config = {
		stations = {
			{
				name = "Music", -- zone
				music = "Radio X.ogg", -- mp3/ogg
				frequency = 40, -- in MHz
				modulation = 1, -- 0=AM, 1=FM
				power = 1000, -- in W
				loop = true
			}
		},
		debug = false
	}

	local function log(msg)
		env.info(string.format("RadioTower: %s", msg))
	end

	for _, station in ipairs(config.stations) do
		local zone = trigger.misc.getZone(station.name)
		if zone then
			local obj = coalition.addStaticObject(country.id.SWITZERLAND, {
				category = "Fortifications",
				shape_name = "tele_bash",
				type = "TV tower",
				rate = 0,
				y = zone.point.z,
				x = zone.point.x,
				name = station.name
			})
			if obj then
				local function getFrequency()
					if station.frequency < 1 then
						return tonumber(string.format("%f", station.frequency * 1000))
					end
					return station.frequency
				end
				local function getHertz()
					if station.frequency < 1 then
						return "kHz"
					end
					return "MHz"
				end
				local function getModulation()
					if station.modulation == 1 then return "FM" end
					return "AM"
				end
				trigger.action.radioTransmission(
					string.format("l10n/DEFAULT/%s", station.music),
					zone.point,
					radio.modulation[getModulation()],
					station.loop,
					tonumber(string.format("%.9d", station.frequency * 1000000)),
					station.power,
					station.name
				)
				local handler = {}
				function handler:onEvent(event)
					if event.id == world.event.S_EVENT_DEAD and event.initiator and event.initiator:getName() == station.name then
						trigger.action.stopRadioTransmission(station.name)
						local str = string.format("%s stopped transmitting on %.3f %s %s", station.name, getFrequency(), getHertz(), getModulation())
						log(str)
						if config.debug then trigger.action.outText(str, 10) end
					end
				end
				world.addEventHandler(handler)
				local str = string.format("%s is transmitting on %.3f %s %s", station.name, getFrequency(), getHertz(), getModulation())
				log(str)
				if config.debug then trigger.action.outText(str, 10) end
			else
				log(string.format("Unable to spawn static object for %s", station.name))
			end
		else
			log(string.format("Zone %s not found", station.name))
		end
	end

end
