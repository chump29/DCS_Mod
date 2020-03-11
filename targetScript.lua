--[[
-- Target Script
-- by Chump
--]]

local base = _G
local assert = base.assert
local ipairs = base.ipairs
local string = base.string

targetScript = {
	jtac = {"TS_JTAC", 1688},
	groupNames = {"TS_BRDM", "TS_BTR", "TS_Infantry", "TS_MTLB", "TS_AAA"},
	rareGroupNames = {"TS_A2A"} -- blank if none
}

do
	local failMsg = " must be loaded prior to this script!"
	assert(mist ~= nil, "MiST" .. failMsg)
	assert(ctld ~= nil, "CTLD" .. failMsg)

	function targetScript.handleGroup(group)
		if group:isExist() then
			local groupName = group:getName()
			mist.respawnGroup(groupName)
			trigger.action.activateGroup(group)
			local typeName = group:getUnits()[1]:getDesc().typeName
			local msg = " spotted!"
			if targetScript.countUnitsInGroup(group) > 1 then
				msg = "s" .. msg
			end
			targetScript.say(typeName .. msg)
			targetScript.activeGroup = groupName
		end
	end

	function targetScript.activateGroup()
		local groupName = targetScript.groupNames[mist.random(#targetScript.groupNames)]

		if #targetScript.rareGroupNames > 0 then
			if mist.random(4) == 1 then -- 25%
				if mist.random(3) == 1 then -- 33%
					if mist.random(2) == 1 then -- 50%
						groupName = targetScript.rareGroupNames[mist.random(#targetScript.rareGroupNames)]
					end
				end
			end
		end

		local group = Group.getByName(groupName)
		if group then
			mist.scheduleFunction(targetScript.handleGroup, {group}, timer.getTime() + mist.random(30))
		else
			targetScript.log(string.format("[activateGroup]: Group (%s) not found!", groupName), true)
		end
	end

	function targetScript.deactivateGroups()
		for _, groupName in ipairs(targetScript.groupNames) do
			local group = Group.getByName(groupName)
			if group then
				trigger.action.deactivateGroup(group)
				targetScript.activeGroup = nil
			end
		end
	end

	function targetScript.start(silent)
		silent = silent or false
		if not targetScript.eventId then
			targetScript.init()

			local msg = "started."
			if not silent then
				targetScript.say("TargetScript " .. msg)
			end
			targetScript.log(msg)
		else
			targetScript.say("TargetScript already running!")
			targetScript.generateMenu()
		end
	end

	function targetScript.stop()
		if targetScript.eventId then
			mist.removeEventHandler(targetScript.eventId)
			targetScript.eventId = nil
			targetScript.deactivateGroups()
			local msg = "stopped."
			targetScript.say("TargetScript " .. msg)
			targetScript.log(msg)
			targetScript.generateMenu()
		else
			targetScript.say("TargetScript is not running!")
			targetScript.generateMenu()
		end
	end

	function targetScript.doJTAC(obj)
		if not obj then obj = { status = true } end
		local status = obj.status
		if status and not targetScript.jtacOn then
			ctld.JTACAutoLase(targetScript.jtac[1], targetScript.jtac[2], false)
			targetScript.jtacOn = true
			targetScript.say("JTAC enabled.")
			targetScript.generateMenu()
		elseif not status and targetScript.jtacOn then
			ctld.JTACAutoLaseStop(targetScript.jtac[1])
			targetScript.jtacOn = false
			targetScript.say("JTAC disabled.")
			targetScript.generateMenu()
		else
			targetScript.log("JTAC error!", true)
		end
	end

	function targetScript.newTargets()
		targetScript.deactivateGroups()
		targetScript.activateGroup()
	end

	function targetScript.generateMenu()
		if targetScript.menuPath then
			missionCommands.removeItemForCoalition(coalition.side.BLUE, targetScript.menuPath)
		end
		targetScript.menuPath = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "TargetScript")
		missionCommands.addCommandForCoalition(coalition.side.BLUE, "New Targets", targetScript.menuPath, targetScript.newTargets)
		if not targetScript.eventId then
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "Start", targetScript.menuPath, targetScript.start)
		else
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "Stop", targetScript.menuPath, targetScript.stop)
		end
		if not targetScript.jtacOn then
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "JTAC On", targetScript.menuPath, targetScript.doJTAC)
		else
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "JTAC Off", targetScript.menuPath, targetScript.doJTAC, {status = false})
		end
	end

	function targetScript.init()
		targetScript.activateGroup()
		targetScript.eventId = mist.addEventHandler(targetScript.events)
		targetScript.jtacOn = false
		targetScript.generateMenu()
	end

	function targetScript.say(msg)
		if msg and string.len(msg) > 0 then
			trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/static-short.ogg")
			trigger.action.outTextForCoalition(coalition.side.BLUE, msg, 10)
		end
	end

	function targetScript.log(msg, isError)
		isError = isError or false
		local str = "TargetScript: "
		if msg and string.len(msg) > 0 then
			msg = str .. msg
			if isError then
				env.error(msg)
			else
				env.info(msg)
			end
		end
	end

	function targetScript.countUnitsInGroup(group)
		local count = 0
		if group then
			local units = group:getUnits()
			if units then
				for _, unit in ipairs(units) do
					if unit:isExist() and unit:isActive() and unit:getLife() > 1 then -- doing this because getUnits() seems to return dead ones
						count = count + 1
					end
				end
			else
				targetScript.log("[countUnitsInGroup]: No units found!", true)
			end
		else
			targetScript.log("[countUnitsInGroup]: Cannot find group!", true)
		end
		return count
	end

	function targetScript.contains(val, tbl)
		for _, v in ipairs(tbl) do
			if v == val then return true end
		end
		return false
	end

	function targetScript.events(e)
		local i = e.initiator
		local t = e.target
		local w = e.weapon

		if e.id == world.event.S_EVENT_DEAD then
			if i and  i:getCategory() == Object.Category.UNIT and not i:getPlayerName() and i:getGroup() and not w and targetScript.contains(i:getGroup():getName(), targetScript.groupNames) then
				local msg
				local unitsAlive = targetScript.countUnitsInGroup(i:getGroup())
				if unitsAlive > 0 then
					msg = string.format("%i targets left.", unitsAlive)
				elseif unitsAlive == 0 and targetScript.activeGroup then
					msg = "All targets have been destroyed!"
					targetScript.activeGroup = nil
					targetScript.activateGroup()
				end
				if msg then
					targetScript.say(msg)
				end
			end
		end
	end

	targetScript.start(true)
end