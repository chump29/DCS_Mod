--[[
-- Carrier Stuff
-- by Chump
--]]

do

	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	local carrier_unit_name = "Carrier"

	RESCUEHELO = RESCUEHELO -- NOTE: global on purpose!
		:New(UNIT:FindByName(carrier_unit_name), "CSAR")
		:SetRescueOff()
		:SetTakeoffHot()
		:Start()

	local Tanker = RECOVERYTANKER
		:New(UNIT:FindByName(carrier_unit_name), "Tanker")
		:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
		:SetRadio(243)
		:SetSpeed(200)
		:SetTACAN(79, "TEX")
		:SetTakeoffAir()
		:Start()

	local AWACS = RECOVERYTANKER
		:New(UNIT:FindByName(carrier_unit_name), "AWACS")
		:SetAltitude(20000) -- in ft
		:SetAWACS()
		:SetCallsign(CALLSIGN.AWACS.Darkstar, 1)
		:SetRadio(255)
		:SetTACAN(55, "WAX")
		:SetTakeoffAir()
		:Start()

	env.info("Carrier Stuff loaded.")

end
