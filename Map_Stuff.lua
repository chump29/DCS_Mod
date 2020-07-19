--[[
-- Map Stuff
-- by Chump
--]]

do

	local assert = _G.assert
	local string = _G.string

	local failMsg = " must be loaded prior to this script!"
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local ATC = PSEUDOATC
		:New()
		:Start()

--[[
	local Fox = FOX
		:New()
		:Start()
--]]

	local function MapStuffEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit or not unit:getCategory() == Object.Category.UNIT then return end

		local playerName = unit:getPlayerName()
		if not playerName then return end

		local function say(msg)
			trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/static-short.ogg")
			trigger.action.outText(msg, 10)
			env.info(msg)
		end

		if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
			say(string.format("%s just took control of an %s!", playerName, unit:getDesc().typeName))

		elseif event.id == world.event.S_EVENT_PILOT_DEAD then
			say(string.format("%s is dead!", playerName))

		elseif event.id == world.event.S_EVENT_CRASH then
			local category = unit:getGroup():getCategory()
			local cat
			if category == Group.Category.HELICOPTER then
				cat = "helicopter"
			elseif category == Group.Category.AIRPLANE then
				cat = "plane"
			elseif category == Group.Category.GROUND then
				cat = "vehicle"
			elseif category == Group.Category.SHIP then
				cat = "ship"
			else
				return
			end
			say(string.format("%s's %s has crashed!", playerName, category))

		end
	end

	mist.addEventHandler(MapStuffEventHandler)

	env.info("Map Stuff loaded.")

end
