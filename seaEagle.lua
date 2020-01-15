--[[
-- Sea Eagle
-- by Chump
--]]

seaEagle = {
	debug = false,
	markId = -1,
	task = {
		id = "ComboTask",
		params = {
			tasks = {
				[1] = {
					id = "EngageTargets",
					params = {
						targetTypes = {
							[1] = "Ships"
						}
					}
				},
				[2] = {
					id = "AttackGroup",
					params = {
						groupId = -1,
						attackQty = 1,
						directionEnabled = false,
						altitudeEnabled = false
					}
				}
			}
		}
	}
}

do

	assert(mist ~= nil, "MiST must be loaded prior to this script!")

	function seaEagle.eventHandler(event)
		if not event.id or not event.initiator or not event.pos then return end

		if not event.text or string.len(event.text) == 0 or not string.find(string.lower(event.text), "seaeagle") then return end

		local group = event.initiator:getGroup()
		if not group then
			seaEagle.log("Group not found for unit")
			return
		end

		local groupId = group:getID()
		if not groupId then
			seaEagle.log("GroupID not found for group")
			return
		end

		if event.id == world.event.S_EVENT_MARK_ADDED or event.id == world.event.S_EVENT_MARK_CHANGE then

			local unitNames = mist.makeUnitTable({"[all][ship]"})
			if #unitNames == 0 then
				seaEagle.log("No ships found in mission")
				return
			end

			local units = {}
			for index = 1, #unitNames do
				local unit = Unit.getByName(unitNames[index])
				if unit and unit:isActive() then
					table.insert(units, unit)
				else
					seaEagle.log("Unit not found for ship")
				end
			end
			if #units == 0 then
				seaEagle.log("No units found for ships")
				return
			end

			local unitsInRange = {}
			for index = 1, #units do
				local pos = units[index]:getPosition()
				if pos then
					if ((pos.p.x - event.pos.x) ^ 2 + (pos.p.z - event.pos.z) ^ 2) ^ 0.5 <= mist.utils.NMToMeters(1) then
						table.insert(unitsInRange, units[index])
					end
				else
					seaEagle.log("Position not found for ship")
				end
			end

			if #unitsInRange == 0 then
				seaEagle.say(groupId, "No ships detected within range!")
				trigger.action.removeMark(event.idx)
				return
			end

			local targetGroup = unitsInRange[mist.random(#unitsInRange)]:getGroup()
			if not targetGroup then
				seaEagle.log("Group not found for target")
				return
			end

			local targetGroupId = targetGroup:getID()
			if not targetGroupId then
				seaEagle.log("GroupID not found for target")
				return
			end

			local targetGroupName = targetGroup:getName()
			if not targetGroupName then
				seaEagle.log("GroupName not found for target")
				return
			end

			local controller = group:getController()
			if not controller then
				seaEagle.log("Controller not found for group")
				return
			end

			if seaEagle.task.params.tasks[2].params.groupId == -1 then
				seaEagle.say(groupId, "Sea Eagle target identified as: " .. targetGroupName)
			else
				seaEagle.say(groupId, "New tasking! Sea Eagle target now identified as: " .. targetGroupName)
				seaEagle.newTask = true
				trigger.action.removeMark(seaEagle.markId)
			end

			seaEagle.markId = event.idx
			seaEagle.task.params.tasks[2].params.groupId = targetGroupId

			controller:setTask(seaEagle.task)

			seaEagle.say(groupId, "Fire when ready!")

			seaEagle.log("Target found: " .. targetGroupName)

		elseif event.id == 27 then -- S_EVENT_MARK_REMOVE or S_EVENT_MARK_REMOVED? Neither seem to work...

			if seaEagle.markId == event.idx then

				seaEagle.task.params.tasks[2].params.groupId = -1

				if not seaEagle.newTask then
					seaEagle.say(groupId, "Sea Eagle target cleared!")
				end
				seaEagle.newTask = nil

				seaEagle.log("Target cleared")
			end
		end
	end

	function seaEagle.log(msg)
		if seaEagle.debug then
			env.info("seaEagle: " .. msg)
		end
	end

	function seaEagle.say(groupId, msg)
		trigger.action.outTextForGroup(groupId, msg, 5)
	end

	function seaEagle.showVersion()

		--[[ Changelog
			1.0 - Initial release
		--]]

		seaEagle.version = {}
		seaEagle.version.major = 1
		seaEagle.version.minor = 0 -- including revision

		env.info(string.format("v%i.%g is waiting for a target.", seaEagle.version.major, seaEagle.version.minor))

	end

	mist.addEventHandler(seaEagle.eventHandler)

	seaEagle.showVersion()
end