--[[
-- Carrier Stuff
-- by Chump
--]]

do

	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	RESCUEHELO = RESCUEHELO -- NOTE: global on purpose!
		:New(UNIT:FindByName("Carrier"), "CSAR")
		:SetRescueOff()
		:SetTakeoffHot()
		:Start()

	local Tanker = RECOVERYTANKER
		:New(UNIT:FindByName("Carrier"), "Tanker")
		:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
		:SetRadio(243)
		:SetSpeed(200)
		:SetTACAN(79, "TEX")
		:SetTakeoffAir()
		:Start()

	local AWACS = RECOVERYTANKER
		:New(UNIT:FindByName("Carrier"), "AWACS")
		:SetAltitude(20000) -- in ft
		:SetAWACS()
		:SetCallsign(CALLSIGN.AWACS.Darkstar, 1)
		:SetRadio(255)
		:SetTACAN(55, "WAX")
		:SetTakeoffAir()
		:Start()

	env.info("Carrier Stuff loaded.")

end
