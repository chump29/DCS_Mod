-- DCS Radio by Chump

dcsRadio = {
	debug = false,
	path = "C:\Users\Chump\Saved Games\DCS\Sounds\Custom\Radio",
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
		missionCommands.addCommandForCoalition(coalition.side.BLUE, "Re-Index", dcsRadio.menuPath, dcsRadio.init)
	end

	function dcsRadio.init()
		dcsRadio.files = {}
		for file in lfs.dir(dcsRadio.path) do
			if file ~= "." and file ~= ".." then
				if file:find(".ogg") ~= nil or file:find(".mp3") ~= nil then
					table.insert(dcsRadio.files, file)
					if dcsRadio.debug then
						env.info(string.format("dcsRadio: Added %s to file list", file)
					end
				end
			end
		end
	end

	function dcsRadio.createStation(controller, freq, amfm)
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
	            file = dcsRadio.path .. dcsRadio.files[math.random(#dcsRadio.files)]
	        }
		}
		controller:setCommand(freqCommand)
		controller:setCommand(msgCommand)
	end

	function dcsRadio.play()
		local unit = Unit.getByName(dcsRadio.unit)
		if unit then
			local controller = unit:getController()
			if controller then
				dcsRadio.createStation(controller, 2000000, radio.modulation.AM) -- LF
				dcsRadio.createStation(controller, 30000000, radio.modulation.FM) -- FM
				dcsRadio.createStation(controller, 132000000, radio.modulation.AM) -- VHF
				dcsRadio.createStation(controller, 232000000, radio.modulation.AM) -- UHF
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