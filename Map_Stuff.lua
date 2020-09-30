--[[
-- Map Stuff
-- by Chump
--]]

do

	local debug = false

	local assert = _G.assert
	local string = _G.string

	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	PSEUDOATC
		:New()
		:Start()

	local fox = FOX
		:New()
		:Start()

	local function MapStuffEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit or not unit:getCategory() == Object.Category.UNIT or not unit:isActive() then return end

		local playerName = unit:getPlayerName()
		if not playerName then return end

		local function say(msg)
			trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/static-short.ogg")
			trigger.action.outTextForCoalition(coalition.side.BLUE, msg, 10)
			env.info(msg)
		end

		if event.id == world.event.S_EVENT_BIRTH then
			local g = UNIT:Find(unit):GetGroup()
			fox:AddProtectedGroup(g)
			local gID = g:GetID()
			trigger.action.outSoundForGroup(gID, "l10n/DEFAULT/static-short.ogg")
			trigger.action.outTextForGroup(gID, "Protected by FOX!", 5)
			env.info(string.format("%s is protected by FOX!", playerName))

		elseif event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
			say(string.format("%s just took control of an %s!", playerName, string.upper(unit:getDesc().typeName)))

		elseif event.id == world.event.S_EVENT_PILOT_DEAD then
			say(string.format("%s is dead!", playerName))

		elseif event.id == world.event.S_EVENT_CRASH then
			local category = unit:getGroup():getCategory()
			local cat = "unknown"
			if category == Group.Category.HELICOPTER then
				cat = "helicopter"
			elseif category == Group.Category.AIRPLANE then
				cat = "plane"
			elseif category == Group.Category.GROUND then
				cat = "vehicle"
			elseif category == Group.Category.SHIP then
				cat = "ship"
			end
			say(string.format("%s's %s has crashed!", playerName, cat))

		end
	end

	SCHEDULER:New(nil, MapStuffEventHandler, nil, 0)

	env.info("Map Stuff loaded.")

end
