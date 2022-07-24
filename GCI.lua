--[[
-- GCI
-- by Chump
--]]

do

	assert(mist ~= nil, "MiST must be loaded prior to this script!")

	local config = {
		offsetUp = 800,
		offsetRight = 400,
		greenHeight = 1000, -- in ft
		yellowHeight = 2500, -- in ft
		maxHistory = 3, -- 30s
		fontColor = {0, 0, 1, 1}, -- RGBA
		fontSize = 10,
		backgroundColor = {0, 0, 0, 0.1}, -- RGBA
		debug = false
	}

	local positions = {}
	local cachedGroups = {}
	local startingId = 100

	local function log(msg)
		env.info(string.format("GCI: %s", msg))
	end

	local function getGroups()
		local groups = {}

		for _, group in ipairs(coalition.getGroups(coalition.side.BLUE, Group.Category.AIRPLANE)) do
			table.insert(groups, group)
		end
		if config.debug then log(string.format("Plane groups found: %i", #groups)) end

		local helos = 0
		for _, group in ipairs(coalition.getGroups(coalition.side.BLUE, Group.Category.HELICOPTER)) do
			helos = helos + 1
			table.insert(groups, group)
		end
		if config.debug then log(string.format("Helicopter groups found: %i", helos)) end

		cachedGroups = groups
		return groups
	end

	local function isValidGroup(group)
		return group ~= nil and group:isExist() and #group:getUnits() > 0
	end

	local function isValidUnit(unit)
		return unit ~= nil and unit:isExist() and unit:isActive() and unit:getLife() > 1 and unit:inAir()
	end

	local function getId()
		startingId = startingId + 1
		return startingId
	end

	local function getColor(height)
		local color = {1, 0, 0, 1}
		if height <= config.greenHeight then
			color = {0, 1, 0, 1}
		elseif height <= config.yellowHeight then
			color = {1, 1, 0, 1}
		end
		return color
	end

	local function moveOver(pos)
		return {x = pos.x + config.offsetUp, y = pos.y, z = pos.z + config.offsetRight}
	end

	local function drawInfo()
		for _, group in ipairs(cachedGroups) do
			if isValidGroup(group) then
				local foundLeader = false
				for _, unit in ipairs(group:getUnits()) do
					if not foundLeader and isValidUnit(unit) then
						foundLeader = true

						local groupId = group:getID()
						local groupName = group:getName()

						if not positions[groupId] then
							positions[groupId] = {}
						end

						local pos = unit:getPoint()
						local txt = string.format(" %s \n %i ft \n %i kts \n %i° ",
							groupName,
							mist.utils.metersToFeet(pos.y),
							mist.utils.mpsToKnots(mist.vec.mag(unit:getVelocity())),
							mist.getHeading(unit, true) * 180 / math.pi
						)

						local id = positions[groupId].id
						if id then
							trigger.action.setMarkupPositionStart(id, moveOver(pos))
							trigger.action.setMarkupText(id, txt)
							if config.debug then log(string.format("Info updated for %s.", groupName)) end
						else
							id = getId()
							positions[groupId].id = id
							trigger.action.textToAll(
								coalition.side.BLUE,
								id,
								moveOver(pos),
								config.fontColor,
								config.backgroundColor,
								config.fontSize,
								true,
								txt
							)
							if config.debug then log(string.format("Info added for %s.", groupName)) end
						end

					end
				end
			end
		end
	end

	local function drawLine()
		for _, group in ipairs(getGroups()) do
			if isValidGroup(group) then
				for _, unit in ipairs(group:getUnits()) do
					if isValidUnit(unit) then

						local unitId = unit:getID()
						local pos = unit:getPoint()
						if not positions[unitId] then
							positions[unitId] = {
								lastPosition = pos,
								currentPosition = pos,
								history = {}
							}
						else
							positions[unitId].lastPosition = positions[unitId].currentPosition
							positions[unitId].currentPosition = pos
						end

						local lastPos = positions[unitId].lastPosition
						local curPos = positions[unitId].currentPosition
						if lastPos ~= curPos then
							local id = getId()
							table.insert(positions[unitId].history, 1, id)
							if #positions[unitId].history > config.maxHistory then
								trigger.action.removeMark(table.remove(positions[unitId].history))
							end
							trigger.action.lineToAll(
								coalition.side.BLUE,
								id,
								lastPos,
								curPos,
								getColor(mist.utils.metersToFeet(curPos.y)),
								3,
								true
							)
							if config.debug then log(string.format("Line added for %s.", unit:getName())) end
						end

					end
				end
			end
		end
	end

	mist.scheduleFunction(drawLine, {}, timer.getTime() + 1, 10)
	mist.scheduleFunction(drawInfo, {}, timer.getTime() + 1, 0.33)

	env.info("GCI is observing.")

end
