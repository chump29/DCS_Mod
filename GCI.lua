do
	local assert = _G.assert
	assert(mist ~= nil, "MiST must be loaded prior to this script!")

	local ipairs = _G.ipairs
	local math = _G.math
	local string = _G.string
	local table = _G.table

	local debug = false

	local positions = {}
	local count = 100

	local offsetUp = 800
	local offsetRight = 600
	local offsetLine = 600
	local greenSpeed = 131 -- 150mph
	local yellowSpeed = 174 -- 200mph

	function log(msg)
		env.info(string.format("GCI: %s", msg))
	end

	function getGroups()
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

		return groups
	end

	function isValidGroup(group)
		return group ~= nil and group:isExist() and #group:getUnits() > 0
	end

	function isValidUnit(unit)
		return unit ~= nil and unit:isExist() and unit:isActive() and unit:getLife() > 1 and unit:inAir()
	end

	function getId()
		count = count + 1
		return count
	end

	function getColor(speed)
		local color = {1, 0, 0, 1}
		if speed < greenSpeed then
			color = {0, 1, 0, 1}
		elseif speed < yellowSpeed then
			color = {1, 1, 0, 1}
		end
		return color
	end

	function moveOver(pos)
		return {x = pos.x + offsetUp, y = pos.y, z = pos.z + offsetRight}
	end

	function moveOut1(pos)
		return {x = pos.x + offsetLine, y = pos.y, z = pos.z}
	end

	function moveOut2(pos, speed)
		local function getLength(speed)
			local length = 1000
			if speed < greenSpeed then
				length = 500
			elseif speed < yellowSpeed then
				length = 750
			end
			return length
		end
		return {x = pos.x + getLength(speed) + offsetLine, y = pos.y, z = pos.z}
	end

	function drawInfo()
		for _, group in ipairs(getGroups()) do
			if isValidGroup(group) then
				local groupName = group:getName()
				local unit = group:getUnits()[1]
				if isValidUnit(unit) then

					if positions[groupName] then
						local pos = unit:getPoint()
						local speed = mist.utils.mpsToKnots(mist.vec.mag(unit:getVelocity()))
						local heading = mist.getHeading(unit)
						local txt = string.format(" %s / %s \n %i ft\n %i kts\n%i°", unit:getTypeName(), groupName, mist.utils.metersToFeet(pos.y), speed, heading)

						local id = positions[groupName].infoId
						if id then
							trigger.action.setMarkupPositionStart(id, moveOver(pos))
							trigger.action.setMarkupText(id, txt)

							id = positions[groupName].vecId
							trigger.action.setMarkupPositionStart(id, moveOut1(pos))
							trigger.action.setMarkupPositionEnd(id, moveOut2(pos, speed))
							trigger.action.setMarkupColor(id, getColor(speed))
							if debug then log(string.format("Info updated for %s.", groupName)) end
						else
							id = getId()
							positions[groupName].infoId = id
							trigger.action.textToAll(
								coalition.side.BLUE,
								id,
								moveOver(pos),
								{0, 0, 1, 1},
								{0, 0, 0, 0.1},
								10,
								true,
								txt
							)

							id = getId()
							positions[groupName].vecId = id
							trigger.action.lineToAll(
								coalition.side.BLUE,
								id,
								moveOut1(pos),
								moveOut2(pos, speed),
								getColor(speed),
								1,
								true
							)
							if debug then log(string.format("Info added for %s.", groupName)) end
						end
					end

				end
			end
		end
	end

	function drawLine()
		for _, group in ipairs(getGroups()) do
			if isValidGroup(group) then
				local groupName = group:getName()
				local unit = group:getUnits()[1]
				if isValidUnit(unit) then

					local pos = unit:getPoint()
					if not positions[groupName] then
						positions[groupName] = {
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
						trigger.action.lineToAll(
							coalition.side.BLUE,
							getId(),
							lastPos,
							curPos,
							{0, 0, 0, 1},
							3,
							true
						)
						if debug then log(string.format("Line added for %s.", groupName)) end
					end

				end
			end
		end
	end

	mist.scheduleFunction(drawLine, {}, timer.getTime() + 0.5, 10)
	mist.scheduleFunction(drawInfo, {}, timer.getTime() + 1, 0.33)

	env.info("GCI is observing.")
end