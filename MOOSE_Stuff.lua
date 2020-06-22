local base = _G
local assert = base.assert

assert(BASE ~= nil, "Must include MOOSE framework for this script to work!")

local missileTrainer = MISSILETRAINER
	:New(200)
	:InitTrackingFrequency(-2)
	:InitMenusOnOff(false)

local pseudoAtc = PSEUDOATC
	:New()
	:Start()

rescueHelo = RESCUEHELO -- NOTE: global on purpose!
	:New(UNIT:FindByName("Carrier"), "RescueHelo")
	:Start()