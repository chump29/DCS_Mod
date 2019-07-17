-- DCS Radio by Chump

dcsRadio = {
	debug = true,
	freqs = {
		{"LF", 2000000, radio.modulation.AM},
		{"FM", 32000000, radio.modulation.FM},
		{"VHF", 132000000, radio.modulation.AM},
		{"UHF", 232000000, radio.modulation.AM}
	},
	path = "C:\\Users\\Chump\\Saved Games\\DCS\\Sounds\\Custom\\Radio\\",
	unit = "Radio"
}

do

	assert(require ~= nil, "require is sanitized")
	local lfs = require "lfs"
	assert(lfs ~= nil, "lfs is sanitized")

	function dcsRadio.buildControls()
		if dcsRadio.menuPath then
			missionCommands.removeItemForCoalition(coalition.side.BLUE, dcsRadio.menuPath)
		end
		dcsRadio.menuPath = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "DCS Radio")

		missionCommands.addCommandForCoalition(coalition.side.BLUE, "New song", dcsRadio.menuPath, dcsRadio.play)
		missionCommands.addCommandForCoalition(coalition.side.BLUE, "Re-index songs", dcsRadio.menuPath, dcsRadio.init)
	end

	function dcsRadio.init()
		dcsRadio.files = {}
		for file in lfs.dir(dcsRadio.path) do
			if file ~= "." and file ~= ".." then

				if file:find(".ogg") ~= nil or file:find(".mp3") ~= nil then
					table.insert(dcsRadio.files, file)

					if dcsRadio.debug then
						env.info(string.format("dcsRadio: Added %s to song list", file)
					end
				end
			end
		end
	end

	function dcsRadio.createStation(controller, name, freq, amfm)
		local freqCommand = {
			id = "SetFrequency",
			params = {
				frequency = freq,
				modulation = amfm
			}
		}
		local msgCommand = {
			id = "TransmitMessage",
	        params = {
	            loop = true,
	            file = dcsRadio.song
	        }
		}
		controller:setCommand(freqCommand)
		controller:setCommand(msgCommand)

		if dcsRadio.debug then
			env.info(string.format("dcsRadio: Created station (%s)", name))
		end
	end

	function dcsRadio.play()
		if dcsRadio.files then
			dcsRadio.song = dcsRadio.path .. dcsRadio.files[math.random(#dcsRadio.files)]

			if dcsRadio.debug then
				env.info(string.format("dcsRadio: Song is %s", dcsRadio.song))
			end
		else
			if dcsRadio.debug then
				env.info("dcsRadio: songs not found")
			end

			return
		end

		local unit = Unit.getByName(dcsRadio.unit)
		if unit then
			local controller = unit:getController()
			if controller then

				for freq in dcsRadio.freqs do
					dcsRadio.createStation(controller, freq[0], freq[1], freq[2])
				end

			else
				if dcsRadio.debug then
					env.info("dcsRadio: controller not found")
				end
			end
		else
			if dcsRadio.debug then
				env.info("dcsRadio: unit not found")
		end
	end

	dcsRadio.init()
	dcsRadio.play()

	if dcsRadio.debug then
		dcsRadio.buildControls()
	end

	env.info("dcsRadio: tuned in.")

end