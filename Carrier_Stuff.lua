--[[
-- Carrier Stuff
-- by Chump
--]]

do

	local config = CARRIER_STUFF_CONFIG or {
		carrierUnitName = "Carrier",
		tanker = {
			radio = 243, -- in MHz
			speed = 200, -- in kts
			tacan = {
				channel = 79, -- Y
				id = "TEX"
			}
		},
		awacs = {
			altitude = 20000, -- in ft
			radio = 255, -- in MHz
			tacan = {
				channel = 55, -- Y
				id = "WAX"
			}
		}
	}

	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	local unit = UNIT:FindByName(config.carrierUnitName)
	if unit then

		RESCUEHELO = RESCUEHELO -- NOTE: global on purpose!
			:New(unit, "CSAR")
			:SetRescueOff()
			:SetTakeoffHot()
			:Start()

		local Tanker = RECOVERYTANKER
			:New(unit, "Tanker")
			:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
			:SetRadio(config.tanker.radio)
			:SetSpeed(config.tanker.speed)
			:SetTACAN(config.tanker.tacan.channel, config.tanker.tacan.id)
			:SetTakeoffAir()
			:Start()

		local AWACS = RECOVERYTANKER
			:New(UNIT:FindByName(unit), "AWACS")
			:SetAltitude(config.awacs.altitude)
			:SetAWACS()
			:SetCallsign(CALLSIGN.AWACS.Overlord, 1)
			:SetRadio(config.awacs.radio)
			:SetTACAN(config.awacs.tacan.channel, config.awacs.tacan.id)
			:SetTakeoffAir()
			:Start()

		env.info("Carrier Stuff loaded.")
	else
		env.info(string.format("CarrierStuff: Carrier unit (%s) not found!", config.carrierUnitName))
	end

end
