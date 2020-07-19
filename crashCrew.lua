--[[
-- Crash Crew
-- by Chump
--]]

CrashCrew = {
	num = 1
}

do

	local assert = _G.assert
	local string = _G.string

 	local failMsg = " must be loaded prior to this script!"
	assert(BASE ~= nil, "MOOSE" .. failMsg)
	assert(mist ~= nil, "MiST" .. failMsg)

	local function CrashCrewEventHandler(event)
		if not event or not event.initiator then return end

		local unit = event.initiator
		if not unit then return end

		local playerName = unit:getPlayerName()
		if not playerName then return end

		if event.id == world.event.S_EVENT_CRASH then

			local function DestroyCrashCrew(g)
				local group = g:GetDCSObject()
				if group then
					group:destroy()
				end
			end

			local function AddToHeading(heading, num)
				local newHeading = heading + num
				if newHeading >= 360 then
    				newHeading = newHeading - 360
  				end
				return newHeading
			end

			local pos = unit:getPosition().p

			for index = 1, 3 do
				local unitPos = {
					heading = UNIT
						:FindByName(unit:getName())
						:GetHeading()
				}

				local inM = mist.utils.feetToMeters(71) -- will end up ~100ft away (a²+b²=c²), facing wreck
				if index == 1 then -- 45°
					unitPos.y = pos.z + inM
					unitPos.x = pos.x + inM
					unitPos.heading = AddToHeading(unitPos.heading, 45)
				elseif index == 2 then -- 135°
					unitPos.y = pos.z + inM
					unitPos.x = pos.x - inM
					unitPos.heading = AddToHeading(unitPos.heading, 135)
				else -- 270°
					unitPos.y = pos.z - mist.utils.feetToMeters(100)
					unitPos.x = pos.x
					unitPos.heading = AddToHeading(unitPos.heading, 270)
				end

				local g = SPAWN
					:NewWithAlias("CrashCrew", string.format("Crash Crew %i-%i", CrashCrew.num, index))
					:InitCoalition(coalition.side.BLUE)
					:InitCountry(country.id.USA)
					:InitHeading(unitPos.heading)
					:SpawnFromVec2({x = unitPos.x, y = unitPos.y})

				mist.scheduleFunction(DestroyCrashCrew, {g}, timer.getTime() + 120)
			end

			CrashCrew.num = CrashCrew.num + 1
			if CrashCrew.num > 10 then
				CrashCrew.num = 1
			end

			local msg = string.format("Crash Crew dispatched to %s!", playerName)
			--trigger.action.outSoundForCoalition(coalition.side.BLUE, "l10n/DEFAULT/static-short.ogg")
			--trigger.action.outText(msg, 10)
			env.info(msg)
		end
	end

	mist.addEventHandler(CrashCrewEventHandler)

	env.info("Crash Crew waiting to respond...")

end
