--[[
-- Range Script
-- by Chump
--]]

RangeScript = {
	TargetGroupNames = {
		"TargetBTR",
		"TargetInfantry",
		"TargetTank"
	},
	RareTargetGroupNames = {
		"TargetHelo"
	}
}

do

	local assert = _G.assert
	local ipairs = _G.ipairs
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
		if #RangeScript.TargetGroupNames == 0 then
			env.info("RangeScript: No Targets to choose from!")
			return
		end

		local index = mist.random(#RangeScript.TargetGroupNames)
		local groupName = RangeScript.TargetGroupNames[index]

		if #RangeScript.RareTargetGroupNames > 0 and mist.random(10) == 1 then -- 10%
			index = mist.random(#RangeScript.RareTargetGroupNames)
			groupName = RangeScript.RareTargetGroupNames[index]
		end

		mist.scheduleFunction(SpawnGroup, {groupName}, timer.getTime() + 10)
		env.info(string.format("Spawning %s...", groupName))
	end

	local function RefreshTargets()
		local function DestroyGroup(group)
			if group then group:destroy() end
		end
		for _, group in ipairs(coalition.getGroups(coalition.side.BLUE)) do
			if group:getName():find("Target") then
				DestroyGroup(group)
			end
		end
		PickGroup()
	end

	local function GenerateMenu(group)
		if group then
			local groupID = group:getID()
			local menu = "Range"
			missionCommands.removeItem(menu)
			local main = missionCommands.addSubMenuForGroup(groupID, menu)
			missionCommands.addCommandForGroup(groupID, "Refresh Targets", main, RefreshTargets)
		end
	end

	local function RangeScriptEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit or not unit:getCategory() == Object.Category.UNIT then return end

		if event.id == world.event.S_EVENT_DEAD and unit:getName():find("Target") then
			RangeScript.count = RangeScript.count - 1

			if RangeScript.count == 0 then
				trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/cheer2.ogg")
				local msg = "All targets destroyed!"
				trigger.action.outText(msg, 10)
				env.info(msg)

				PickGroup()
			end

		elseif event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT and unit:getPlayerName() then
			GenerateMenu(unit:getGroup())

		end
	end

	RangeScript.count = 0

	mist.addEventHandler(RangeScriptEventHandler)

	PickGroup()

	env.info("Range Script is providing targets...")

end

