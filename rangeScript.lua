--[[
-- Range Script
-- by Chump
--]]

-- TODO: JTAC

RangeScript = {
	TargetGroupNames = {
		"TargetBTR",
		"TargetBRDM",
		"TargetInfantry",
		"TargetHelo",
		"TargetSAM",
		"TargetTank"
	}
}

do

	local assert = _G.assert
	local string = _G.string

	local failMsg = " must be loaded prior to this script!"
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local function SpawnGroup(groupName)
		local g = SPAWN
			:NewWithAlias(groupName, "Target")
			:Spawn()
		RangeScript.count = RangeScript.count + #g:GetUnits()
		trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/incoming.ogg")
		local msg = string.format("%s(s) spotted!", g:GetDCSDesc().typeName)
		trigger.action.outText(msg, 10)
		env.info(msg)
	end

	local function PickGroup()
		local index = mist.random(#RangeScript.TargetGroupNames)
		local groupName = RangeScript.TargetGroupNames[index]
		mist.scheduleFunction(SpawnGroup, {groupName}, timer.getTime() + 10)
		env.info(string.format("Spawning %s...", groupName))
	end

	local function RangeScriptEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit then return end

		if event.id == world.event.S_EVENT_DEAD and unit:getName():find("Target") then
			RangeScript.count = RangeScript.count - 1

			if RangeScript.count == 0 then
				trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/cheer2.ogg")
				local msg = "All targets destroyed!"
				trigger.action.outText(msg, 10)
				env.info(msg)

				PickGroup()
			end
		end
	end

	RangeScript.count = 0

	mist.addEventHandler(RangeScriptEventHandler)

	PickGroup()

	env.info("Range Script is providing targets...")

end
