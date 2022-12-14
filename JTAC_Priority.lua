--[[
-- JTAC_Priority
-- by Chump
--]]

do

	local config = JTAC_PRIORITY_CONFIG or {
		maxDistance = 8046.72, -- in m (5mi)
		debug = false
	}

	local function log(msg)
		env.info(string.format("JTAC Priority: %s", msg))
	end

	local foundOverride = false
	local isCTLD = false
	if ctld and ctld.findNearestVisibleEnemy and ctld.alreadyTarget and ctld.isVehicle and ctld.isInfantry and ctld.getDistance then
		if config.debug then log("Replacing ctld.findNearestVisibleEnemy...") end
		isCTLD = true
		foundOverride = true
		ctld.findNearestVisibleEnemy = function (j, t, d)
			findNearestVisibleEnemy(j, t, d)
		end
	elseif findNearestVisibleEnemy and alreadyTarget and isVehicle and isInfantry and getDistance then
		if config.debug then log("Replacing findNearestVisibleEnemy...") end
		foundOverride = true
	else
		if config.debug then log("findNearestVisibleEnemy not found") end
	end

	if foundOverride then
		findNearestVisibleEnemy = function (jtac, target, distance)
			if not jtac or not jtac:isActive() or jtac:getLife() < 1 then
				log("JTAC unit not found")
				return nil
			end
			local function isTargeted(unit)
				if isCTLD then
					return ctld.alreadyTarget(jtac, unit)
				end
				return alreadyTarget(jtac, unit)
			end
			local function isTargetAllowed(unit)
				if target == "vehicle" then
					if isCTLD then
						return ctld.isVehicle(unit)
					end
					return isVehicle(unit)
				elseif target == "troop" then
					if isCTLD then
						return ctld.isInfantry(unit)
					end
					return isInfantry(unit)
				end
				return true
			end
			local function getDistanceBetweenPoints(point1, point2)
				if isCTLD then
					return ctld.getDistance(point1, point2)
				end
				return getDistance(point1, point2)
			end
			local jtacPoint = jtac:getPoint()
			distance = distance or config.maxDistance
			local function isLOS(unit)
				local unitPoint = unit:getPoint()
				if land.isVisible({ x = jtacPoint.x, y = jtacPoint.y + 2, z = jtacPoint.z }, { x = unitPoint.x, y = unitPoint.y + 2, z = unitPoint.z }) then
					return true
				end
				return false
			end
			local jtacName = jtac:getName()
			local function getUnits()
				local volume = {
					id = world.VolumeType.SPHERE,
					params = {
						point = jtacPoint,
						radius = distance
					}
				}
				local foundUnits = {}
				local search = function (unit)
					if unit
						and unit:getCoalition() == coalition.side.RED
						and unit:getDesc().category == Unit.Category.GROUND_UNIT
						and unit:isActive()
						and unit:getLife() >= 1
						and not unit:inAir()
						and not isTargeted(unit)
						and isTargetAllowed(unit)
						and isLOS(unit) then
						table.insert(foundUnits, { unit = unit, dist = getDistanceBetweenPoints(jtacPoint, unit:getPoint()) })
					end
					return true
				end
				world.searchObjects(Object.Category.UNIT, volume, search)
				if config.debug then
					local function mToMi(m)
						return m / 1609.344
					end
					if #foundUnits > 0 then
						log(string.format("Found %i unit(s) within %0.2fmi of JTAC %s:", #foundUnits, mToMi(distance), jtacName))
						for _, unit in ipairs(foundUnits) do
							log(string.format("  %s @ %0.2fmi", unit.unit:getName(), mToMi(unit.dist)))
						end
					else
						log(string.format("No units found within %0.2fmi of JTAC %s", mToMi(distance), jtacName))
					end
				end
				return foundUnits
			end
			local units = {}
			local samUnits = {}
			local foundSAM = false
			local aaaUnits = {}
			local foundAAA = false
			local tankUnits = {}
			local foundTank = false
			local armedUnits = {}
			local foundArmed = false
			for _, obj in ipairs(getUnits()) do
				-- https://github.com/mrSkortch/DCS-miscScripts/tree/master/ObjectDB
				-- https://wiki.hoggitworld.com/view/DCS_enum_attributes
				local unit = obj.unit
				if unit:hasAttribute("SAM") then
					if not foundSAM then foundSAM = true end
					table.insert(samUnits, obj)
				elseif not foundSAM and unit:hasAttribute("AAA") then
					if not foundAAA then foundAAA = true end
					table.insert(aaaUnits, obj)
				elseif not foundSAM and not foundAAA and unit:hasAttribute("Tanks") then
					if not foundTank then foundTank = true end
					table.insert(tankUnits, obj)
				elseif not foundSAM and not foundAAA and not foundTank and unit:hasAttribute("Armed ground units") then
					if not foundArmed then foundArmed = true end
					table.insert(armedUnits, obj)
				elseif not foundSAM and not foundAAA and not foundTank and not foundArmed then
					table.insert(units, obj)
				end
			end
			if foundSAM then
				units = samUnits
			elseif foundAAA then
				units = aaaUnits
			elseif foundTank then
				units = tankUnits
			elseif foundArmed then
				units = armedUnits
			end
			if #units > 0 then
				table.sort(units, function (o1, o2) return o1.dist < o2.dist end)
				local nearestUnit = units[1].unit
				if config.debug then log(string.format("Nearest unit to JTAC %s is %s (%s) @ %0.2fm", jtacName, nearestUnit:getName(), nearestUnit:getTypeName(), units[1].dist)) end
				return nearestUnit
			end
			return nil
		end
		env.info("JTAC Priority is prioritizing targets.")
	else
		env.info("Exiting JTAC Priority.")
	end

end
