do
	local assert = _G.assert
	assert(mist ~= nil, "MiST must be loaded prior to this script!")

	local ipairs = _G.ipairs
	local math = _G.math
	local string = _G.string
	local table = _G.table
	local tonumber = _G.tonumber

	local debug = true
	local positions = {}
	local count = 1000

	function drawInfo()
		local function log(msg)	env.info(string.format("GCI: %s", msg))	end

		local groups = {}
		for _, group in ipairs(coalition.getGroups(coalition.side.BLUE, Group.Category.AIRPLANE)) do
			table.insert(groups, group)
		end
		if debug then log(string.format("Plane groups found: %i", #groups)) end

		local helos = 0
		for _, group in ipairs(coalition.getGroups(coalition.side.BLUE, Group.Category.HELICOPTER)) do
			helos = helos + 1
			table.insert(groups, group)
		end
		if debug then log(string.format("Helicopter groups found: %i", helos)) end

		for _, group in ipairs(groups) do
			if group and group:isExist() and #group:getUnits() > 0 then
				local groupName = group:getName()
				local unit = group:getUnits()[1]
				if unit and unit:isExist() and unit:isActive() and unit:getLife() > 1 then
					if unit:inAir() then
						local function getId()
							count = count + 1
							return count
						end

						local pos = unit:getPoint()
						if not positions[groupName] then
							positions[groupName] = {
								id = getId(),
								lastPosition = pos,
								currentPosition = pos
							}
						else
							positions[groupName].lastPosition = positions[groupName].currentPosition
							positions[groupName].currentPosition = pos
						end

						local lastPos = positions[groupName].lastPosition
						local curPos = positions[groupName].currentPosition

						if lastPos ~= curPos then
							local id = getId()
							trigger.action.lineToAll(coalition.side.BLUE, id, lastPos, curPos, {0, 0, 0, 1}, 3, true)
							if debug then log(string.format("Line #%i added for %s.", id, groupName)) end

							id = positions[groupName].id
							trigger.action.removeMark(id)
							if debug then log(string.format("Mark #%i removed for %s.", id, groupName)) end
							positions[groupName].id = getId()
						end
						id = positions[groupName].id
						trigger.action.markToCoalition(
							id,
							string.format("%s / %s\n%i ft\n%i kts\n%i°", unit:getTypeName(), groupName, mist.utils.metersToFeet(curPos.y), mist.utils.mpsToKnots(mist.vec.mag(unit:getVelocity())), mist.getHeading(unit)),
							curPos,
							coalition.side.BLUE,
							true
						)
						if debug then log(string.format("Mark #%i added for %s.", id, groupName)) end
					else
						if debug then log(string.format("Unit (%s) not in air. Skipping.", unit:getName())) end
					end
				else
					if debug then log(string.format("Unit (%s) not found.", unit:getName())) end
				end
			else
				if debug then log(string.format("Group (%s) not found.", groupName)) end
			end
		end
	end

	mist.scheduleFunction(drawInfo, {}, timer.getTime() + 1, 10)

	env.info("GCI is observing.")
end