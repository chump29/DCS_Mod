--[[
-- Zeus X
-- by Chump
--]]

local base = _G
local assert = base.assert
local string = base.string

local str = " must be included before this script!"
assert(BASE ~= nil, "MOOSE" .. str)
assert(mist ~= nil, "MiST" .. str)

zeusX = {}

do

	function zeusX.handleCreate(text, pos)
		local obj = text:match(".+%s(.+)")
		if obj then
			local name = "ZEUSX_" .. obj
			local group = GROUP:FindByName(name)
			if group then
				SPAWN
					:New(name)
					:SpawnFromVec3(pos)
				env.info("ZeusX: Spawned " .. obj)
			end
		end
	end

	function zeusX.handleDestroy(pos)
		local destroyUnit = function(unit)
			unit:destroy()
			return true
		end
		local vol = {
			id = world.VolumeType.SPHERE,
			params = {
				point = pos,
				radius = 500
			}
		}
		world.searchObjects(Object.Category.UNIT, vol, destroyUnit)
	end

	function zeusX.eventHandler(event)
		if event.id == world.event.S_EVENT_MARK_REMOVED and event.text then
			local text = event.text:lower()
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
