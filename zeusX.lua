--[[
-- Zeus X
-- by Chump
--]]

local base = _G
local assert = base.assert
local ipairs = base.ipairs
local string = base.string
local table = base.table

local str = " must be included before this script!"
assert(BASE ~= nil, "MOOSE" .. str)
assert(mist ~= nil, "MiST" .. str)
assert(ctld ~= nil, "CTLD" .. str)

zeusX = {
	debug = false
}

do

	local debug = zeusX.debug

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
				end
				local s = SPAWN
					:New(name)
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

	function zeusX.handleDestroy(text, pos)
		local destroyObject = function(obj, val)
			if obj then
				local name = obj:getName()
				obj:destroy()
				if debug then env.info("ZeusX: Destroying " .. name .. "...") end
			end
			return true
		end
		local destroyed = 0
		local obj = text:match(".+%s(.+)")
		if obj and obj == "jtacs" then
			for _, g in ipairs(zeusX.jtacs) do
				destroyObject(Group.getByName(g:GetName()))
				destroyed = destroyed + 1
			end
			zeusX.jtacs = {}
		else
			local vol = {
				id = world.VolumeType.SPHERE,
				params = {
					point = pos,
					radius = mist.utils.feetToMeters(1500)
				}
			}
			destroyed = world.searchObjects(Object.Category.UNIT, vol, destroyObject)
		end
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
			elseif text:find("-destroy") then
				zeusX.handleDestroy(text, event.pos)
			end
		end
	end

	mist.addEventHandler(zeusX.eventHandler)

	env.info("ZeusX is running...")

end
