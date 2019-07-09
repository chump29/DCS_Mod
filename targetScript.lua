-- TargetScript by Chump

targetScript = {
	groupNames = {"Targets1", "Targets2", "Targets3", "Targets4", "Targets5"},
	jtac = {"JTAC", 1688}
}

do

	for k, v in ipairs({[mist] = "MiST", [ctld] = "CTLD"}) do assert(k ~= nil, v .. " must be loaded prior to this script!") end

	function targetScript.handleGroup(group)
		if group:isExist() then
			mist.respawnGroup(group:getName())
			trigger.action.activateGroup(group)
			targetScript.say(string.format("%ss spotted!", group:getUnits()[1]:getDesc().typeName))
			targetScript.activeGroup = group:getName()
		end
	end

	function targetScript.activateGroup()
		local groupName = targetScript.groupNames[mist.random(#targetScript.groupNames)]
		local group = Group.getByName(groupName)
		if group then
			mist.scheduleFunction(targetScript.handleGroup, {group}, timer.getTime() + mist.random(30))
		else
			env.error(string.format("TargetScript [activateGroup]: Group (%s) not found!", groupName))
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
			if not silent then
				local msg = "TargetScript started."
				targetScript.say(msg)
				env.info(msg)
			end
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
			local msg = "TargetScript stopped."
			targetScript.say(msg)
			env.info(msg)
			targetScript.generateMenu()
		else
			targetScript.say("TargetScript is not running!")
			targetScript.generateMenu()
		end
	end

	function targetScript.jtac(obj)
		local status = obj.status
		if status == nil then status = true end
		if status and not targetScript.jtacOn then
			ctld.JTACAutoLase(targetScript.jtac[1], targetScript.jtac[2], false, "all")
			targetScript.jtacOn = true
			targetScript.say("JTAC enabled.")
			targetScript.generateMenu()
		elseif not status and targetScript.jtacOn then
			ctld.JTACAutoLaseStop(targetScript.jtacName)
			targetScript.jtacOn = false
			targetScript.say("JTAC disabled.")
			targetScript.generateMenu()
		else
			env.error("TargetScript: JTAC error!")
		end
	end

	function targetScript.generateMenu()
		if targetScript.menuPath then
			missionCommands.removeItemForCoalition(coalition.side.BLUE, targetScript.menuPath)
		end
		targetScript.menuPath = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "TargetScript")
		if not targetScript.eventId then
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "Start", targetScript.menuPath, targetScript.start)
		else
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "Stop", targetScript.menuPath, targetScript.stop)
		end
		if not targetScript.jtacOn then
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "JTAC On", targetScript.menuPath, targetScript.jtac)
		else
			missionCommands.addCommandForCoalition(coalition.side.BLUE, "JTAC Off", targetScript.menuPath, targetScript.jtac, {status = false})
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

	local function countUnitsInGroup(group)
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
				env.error("TargetScript [countUnitsInGroup]: No units found!")
			end
		else
			env.error("TargetScript [countUnitsInGroup]: Cannot find group!")
		end
		return count
	end

	local function contains(val, tbl)
		for _, v in ipairs(tbl) do
			if v == val then return true end
		end
		return false
	end

	function targetScript.events(e)
		local i = e.initiator
		local t = e.target
		local w = e.weapon

		if e.id == world.event.S_EVENT_DEAD then -- dead
			if i and  i:getCategory() == Object.Category.UNIT and not i:getPlayerName() and i:getGroup() and not w and contains(i:getGroup():getName(), targetScript.groupNames) then
				local msg
				local unitsAlive = countUnitsInGroup(i:getGroup())
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

	env.info("TargetScript: targets loaded.")

end