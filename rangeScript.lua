--[[
-- Range Script
-- by Chump
--]]

RangeScript = {
	TargetGroupNames = { -- groupName & flag
		{"TargetBRDM", 100},
		{"TargetBTR", 101},
		{"TargetInfantry", 102},
		{"TargetTank", 103}
	},
	RareTargetGroupNames = { -- groupName & flag
		{"TargetHelo", 200},
		{"TargetSAM", 201}
	},
	Sounds = { -- must be included in .miz via SOUND TO ALL trigger
		Spawn = "incoming.ogg",
		Clear = "completely_different.ogg",
		Win = "cheer2.ogg" -- must use MaxSpawnCount
	},
	MaxSpawnCount = 0, -- 0 = no limit
	WinFlag = 0, -- 0 for none
	JTAC = {
		GroupName = "JTAC", -- leave blank if not using JTAC
		LaserCode = 1788
	}
}

do

	local failMsg = " must be loaded prior to this script!"
	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(ctld ~= nil, "CTLD" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local ipairs = _G.ipairs
	local string = _G.string

	local function log(msg)
		env.info("RangeScript: " .. msg)
	end

	local function SpawnGroup(groupName)
		local g = SPAWN
			:NewWithAlias(groupName, "Target")
			:Spawn()

		local flag = 0
		local function SetFlag(arr, groupName)
			for _, obj in ipairs(arr) do
				if obj[1] == groupName then
					trigger.action.setUserFlag(obj[2], true)
					flag = obj[2]
					return
				end
			end
		end
		if RangeScript.isRare then
			SetFlag(RangeScript.RareTargetGroupNames, groupName)
		else
			SetFlag(RangeScript.TargetGroupNames, groupName)
		end
		if flag == 0 then
			log(string.format("Error setting flag for %s", groupName))
		end

		RangeScript.unitCount = RangeScript.unitCount + #g:GetUnits()
		RangeScript.spawnCount = RangeScript.spawnCount + 1
		trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/" .. RangeScript.Sounds.Spawn)
		local msg = string.format("%s(s) spotted!", g:GetDCSDesc().typeName)
		trigger.action.outText(msg, 10)
		log(msg)
	end

	local function PickGroup()
		if #RangeScript.TargetGroupNames == 0 then
			log("No targets to choose from!")
			return
		end

		local index = mist.random(#RangeScript.TargetGroupNames)
		local groupName = RangeScript.TargetGroupNames[index][1]
		RangeScript.isRare = false

		if #RangeScript.RareTargetGroupNames > 0 and mist.random(10) == 1 then -- 10%
			index = mist.random(#RangeScript.RareTargetGroupNames)
			groupName = RangeScript.RareTargetGroupNames[index][1]
			RangeScript.isRare = true
		end

		mist.scheduleFunction(SpawnGroup, {groupName}, timer.getTime() + 10)
		log(string.format("Spawning %s group...", groupName))
	end

	local function RefreshTargets()
		log("Refreshing targets...")
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
		if not unit or unit:getDesc().category > 3 then return end -- NOTE: Unit.getCategory is broken, only testing for 0=airplane, 1=helicopter, 2=ground_unit, 3=ship

		local unitName = ""
		if unit then
			unitName = unit:getName()
		end

		if event.id == world.event.S_EVENT_DEAD and string.len(unitName) > 0 and unitName:find("Target") then
			RangeScript.unitCount = RangeScript.unitCount - 1

			if RangeScript.unitCount == 0 then
				local msg = "All targets destroyed!"
				trigger.action.outText(msg, 10)
				log(msg)

				if RangeScript.MaxSpawnCount > 0 and RangeScript.spawnCount == RangeScript.MaxSpawnCount then
					trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/" .. RangeScript.Sounds.Win)
					trigger.action.outText("Outstanding job! Return to base!", 10)
					log("MaxSpawnCount reached! Stopping.")
					if RangeScript.WinFlag > 0 then
						trigger.action.setUserFlag(RangeScript.WinFlag, true)
					end
					mist.removeEventHandler(RangeScript.EventHandlerID)
					return
				else
					trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/" .. RangeScript.Sounds.Clear)
				end

				PickGroup()
			end

		elseif event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT and unit:getPlayerName() then
			GenerateMenu(unit:getGroup())

		end
	end

	RangeScript.unitCount = 0
	RangeScript.spawnCount = 0

	RangeScript.EventHandlerID = mist.addEventHandler(RangeScriptEventHandler)

	PickGroup()

	local jtacGroupName = RangeScript.JTAC.GroupName
	if jtacGroupName then
		ctld.JTACAutoLase(jtacGroupName, RangeScript.JTAC.LaserCode, false)
	end

	env.info("Range Script is providing targets...")

end
