--[[
-- Zeus X
-- by Chump
--]]

zeusX = {
	debug = false
}

do

	local failMsg = " must be loaded prior to this script!"
	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(ctld ~= nil, "CTLD" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local ipairs = _G.ipairs
	local string = _G.string
	local table = _G.table

	local debug = zeusX.debug or false

	local count = 0

	function zeusX.getLaserCode()
		if not zeusX.laserCode then
			local code = 1000
			code = code + (mist.random(5, 7) * 100)
			code = code + (mist.random(8) * 10)
			code = code + mist.random(8)
			zeusX.laserCode = code
		end
		return zeusX.laserCode
	end

	function zeusX.getAlias(name)
		local alias = "Unknown"
		if name:find("a2a") then
			alias = "CAP Flight"
		elseif name:find("armor") then
			alias = "Armor Group"
		elseif name:find("helo") then
			alias = "Helo Flight"
		elseif name:find("inf") then
			alias = "Infantry Platoon"
		elseif name:find("jtac") then
			alias = "JTAC"
		elseif name:find("sam") then
			alias = "SAM Battery"
		elseif name:find("ship") then
			alias = "Battle Group"
		end
		return alias
	end

	function zeusX.handleCreate(text, pos)
		local function autoLase(name)
			ctld.JTACAutoLase(name, zeusX.getLaserCode(), false)
		end
		local obj = text:match(".+%s(.+)")
		if obj then
			local name = "ZEUSX_" .. obj
			local group = GROUP:FindByName(name)
			if group then
				if obj == "helos_red" or obj == "helos_blue" then
					pos.y = mist.utils.feetToMeters(500)
				elseif obj == "a2a_red" or obj == "a2a_blue" or obj == "jtac" then
					pos.y = mist.utils.feetToMeters(5000)
				else
					local surfaceType = land.getSurfaceType({x = pos.x, y = pos.z})
					if obj == "ship_red" or obj == "ship_blue" then
						if surfaceType ~= land.SurfaceType.SHALLOW_WATER and surfaceType ~= land.SurfaceType.WATER then
							if debug then env.warning("ZeusX: Cannot place naval units on land!") end
							return
						end
					elseif surfaceType == land.SurfaceType.SHALLOW_WATER or surfaceType == land.SurfaceType.WATER then
						if debug then env.warning("ZeusX: Cannot place land units on water!") end
						return
					end
				end
				count = count + 1
				local s = SPAWN
					:NewWithAlias(name, string.format("%s-%i", zeusX.getAlias(name), count))
					:SpawnFromVec3(pos)
				if obj == "jtac" then
					mist.scheduleFunction(autoLase, {s:GetName()}, timer.getTime() + 1)
					if not zeusX.jtacs then zeusX.jtacs = {} end
					table.insert(zeusX.jtacs, s)
				end
				if debug then env.info("ZeusX: Spawned " .. obj) end
			else
				if debug then env.warning("ZeusX: Unknown spawn template (" .. obj .. ")") end
			end
		end
	end

	function zeusX.handleDestroy(pos)
		local destroyObject = function(obj, val)
			if obj then
				local name = obj:getName()
				obj:destroy()
				if debug then env.info("ZeusX: Destroying " .. name .. "...") end
			end
			return true
		end
		local function inRange(unit, pos)
			local p = unit:getPosition()
			if p then
				return ((p.p.x - pos.x) ^ 2 + (p.p.z - pos.z) ^ 2) ^ 0.5 <= mist.utils.feetToMeters(1500)
			end
		end
		local destroyed = 0
		-- Air units
		local unitNames = mist.makeUnitTable({"[all][plane]", "[all][helicopter]"})
		if #unitNames > 0 then
			for _, unitName in ipairs(unitNames) do
				local unit = Unit.getByName(unitName)
				if unit and not unit:getPlayerName() and unit:isActive() and inRange(unit, pos) then
					if unitName:lower():find("jtac") then
						 ctld.JTACAutoLaseStop(unit:getGroup():getName())
					end
					destroyObject(unit)
				end
			end
		end
		-- Ground units
		local vol = {
			id = world.VolumeType.SPHERE,
			params = {
				point = pos,
				radius = mist.utils.feetToMeters(1500)
			}
		}
		destroyed = world.searchObjects(Object.Category.UNIT, vol, destroyObject)
		if debug then
			if destroyed > 0 then
				env.info(string.format("ZeusX: Destroyed %i objects.", destroyed))
			else
				env.warning("ZeusX: Nothing to destroy!")
			end
		end
	end

	function zeusX.eventHandler(event)
		local function trim(str)
			return str:gsub("^%s*(.-)%s*$", "%1")
		end
		if event.id == world.event.S_EVENT_MARK_REMOVED and event.text then
			local text = trim(event.text:lower())
			if text:find("-create") then
				zeusX.handleCreate(text, event.pos)
			elseif text == "-destroy" then
				zeusX.handleDestroy(event.pos)
			end
		end
	end

	mist.addEventHandler(zeusX.eventHandler)

	env.info("ZeusX is running...")

end
