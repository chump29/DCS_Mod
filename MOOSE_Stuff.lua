--[[
-- MOOSE Stuff
-- by Chump
--]]

assert(BASE ~= nil, "Must include MOOSE framework for this script to work!")

MISSILETRAINER
	:New(200)
	:InitTrackingFrequency(-1)
	:InitMenusOnOff(false)

PSEUDOATC
	:New()
	:Start()

RESCUEHELO -- NOTE: global on purpose!
	:New(UNIT:FindByName("Carrier"), "CSAR")
	:Start()

RECOVERYTANKER
	:New(UNIT:FindByName("Carrier"), "Tanker")
	:SetAltitude(6000) -- in ft
	:SetRadio(243)
	:SetTACAN(79, "TEX")
	:Start()

RECOVERYTANKER
	:New(UNIT:FindByName("Carrier"), "AWACS")
	:SetAltitude(20000) -- in ft
	:SetAWACS()
	:SetRadio(255)
	:SetTACAN(55, "WAX")
	:SetTakeoffAir()
	:Start()