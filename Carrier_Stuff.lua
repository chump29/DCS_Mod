--[[
-- Carrier Stuff
-- by Chump
--]]

do

	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	local string = _G.string

	local carrierUnitName = "Carrier"

	local unit = UNIT:FindByName(carrier_unit_name)
	if unit then

		RESCUEHELO = RESCUEHELO -- NOTE: global on purpose!
			:New(unit, "CSAR")
			:SetRescueOff()
			:SetTakeoffHot()
			:Start()

		local Tanker = RECOVERYTANKER
			:New(unit, "Tanker")
			:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
			:SetRadio(243)
			:SetSpeed(200)
			:SetTACAN(79, "TEX")
			:SetTakeoffAir()
			:Start()

		local AWACS = RECOVERYTANKER
			:New(UNIT:FindByName(unit), "AWACS")
			:SetAltitude(20000) -- in ft
			:SetAWACS()
			:SetCallsign(CALLSIGN.AWACS.Darkstar, 1)
			:SetRadio(255)
			:SetTACAN(55, "WAX")
			:SetTakeoffAir()
			:Start()

		env.info("Carrier Stuff loaded.")
	else
		env.info(string.format("CarrierStuff: Carrier unit (%s) not found!", carrierUnitName))
	end

end
