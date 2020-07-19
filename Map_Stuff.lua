--[[
-- Map Stuff
-- by Chump
--]]

CHUMP = CHUMP or {}

do

	local assert = _G.assert
	local string = _G.string

	local failMsg = " must be loaded prior to this script!"
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local ATC = PSEUDOATC
		:New()
		:Start()

--[[
	local Range = RANGE
		:New("XTC Range")
		:AddBombingTargetGroup(
			GROUP:FindByName("BombingTargets"),
			15.24, -- 50ft
			true
		)
		:AddStrafePitGroup(
			GROUP:FindByName("StrafeTargets"),
			457.2, -- 1500ft
			53.34, -- 175ft
			163,
			343,
			10,
			0
		)
		:SetMaxStrafeAlt(1524) -- 5000ft
		:SetRangeControl(123)
		:SetSoundfilesPath("Range/")
		:Start()
--]]

	function CHUMP.MapStuffEventHandler(event)
		if not event or not event.initiator or not event.initiator:getPlayerName() then return end

		local function say(msg)
			trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/static-short.ogg")
			trigger.action.outText(msg, 10)
			env.info(msg)
		end

		local unit = event.initiator
		local playerName = unit:getPlayerName()

		if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
			say(string.format("%s just took control of a %s!", playerName, unit:getDesc().typeName))

		elseif event.id == world.event.S_EVENT_PILOT_DEAD then
			say(string.format("%s is dead!", playerName))

		end
	end

	mist.addEventHandler(CHUMP.MapStuffEventHandler)

	env.info("Map Stuff loaded.")

end
