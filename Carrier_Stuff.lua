--[[
-- Carrier Stuff
-- by Chump
--]]

do

	local assert = _G.assert

	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	RESCUEHELO -- NOTE: global on purpose!
		:New(UNIT:FindByName("Carrier"), "CSAR")
		:Start()

	local Tanker = RECOVERYTANKER
		:New(UNIT:FindByName("Carrier"), "Tanker")
		:SetAltitude(6000) -- in ft
		:SetRadio(243)
		:SetTACAN(79, "TEX")
		:Start()

	local AWACS = RECOVERYTANKER
		:New(UNIT:FindByName("Carrier"), "AWACS")
		:SetAltitude(20000) -- in ft
		:SetAWACS()
		:SetRadio(255)
		:SetTACAN(55, "WAX")
		:SetTakeoffAir()
		:Start()

	env.info("Carrier Stuff loaded.")

end
