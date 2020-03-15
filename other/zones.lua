--[[
	NOTE: MiST must be loaded via DO SCRIPT FILE trigger action before this script is loaded!
]]--

do

	-- declare unit names
	local hueys = {
		"helicargo1",
		"helicargo2",
		"helicargo3",
		"helicargo4",
		"helicargo5",
		"helicargo6"
	}

	-- declare landing zones
	local zones = { -- NOTE: put only one
		"Extract #008"
	}

	-- localize global objects
	local base = _G
	local assert = base.assert
	local ipairs = base.ipairs
	local pairs = base.pairs
	local string = base.string
	local table = base.table

	-- ensure that MiST is loaded
	assert(mist ~= nil, "MiST must be loaded before this script!")

	-- store who is on ground for how long
	local onGround = {}

	function showMsg(unit)

		-- returns huey index of name
		local function hueyIndex(name)
			for i = 1, #hueys do
				if hueys[i] == name then
					return i
				end
			end
		end

		-- make sure unit is still alive
		if not unit and unit:isExist() then return end

		-- show message
		local msg = string.format("Hey Captain %s, any chance you could drop us boys off at the strip club in Poti? My mate said he'd drop a green smoke canister when he hears us approaching to make it easy to find. What do ya say sir, come on, you'll be doing us a solid sir!", unit:getPlayerName())
		trigger.action.outTextForGroup(unit:getGroup():getID(), msg, 15) -- show for 15 seconds

	end

	function checkTime()

		-- removes unit from checks
		local function removeOnGround(name)
			onGround[name] = nil
		end

		-- loop through units on ground
		for name, data in pairs(onGround) do

			-- ensure they are alive
			if data.u and data.u:isExist() then

				--  ensure they are still on the ground
				if not data.u:inAir() then

					-- increment timer
					data.t = data.t + 1

					-- timer reached?
					if data.t == 45 then

						-- clear watched units
						hueys = {}
						onGround = {}

						-- show message
						showMsg(data.u)

					end

				else

					-- reset timer
					if data.t ~= 0 then
						data.t = 0
					end

				end

			else

				-- unit is dead, remove from checks
				removeOnGround(name)

			end
		end
	end

	function checkZones()

		-- have all hueys been shown message?
		if #hueys == 0 then
			mist.removeFunction(checkZoneScheduledFunctionID)
			checkZoneScheduledFunctionID = nil
			mist.removeFunction(checkTimeScheduledFunctionID)
			checkTimeScheduledFunctionID = nil
			return
		end

		-- find units in zones
		local units = mist.getUnitsInZones(hueys, zones)
		if #units > 0 then

			-- loop through units
			for _, unit in ipairs(units) do

				-- ensure they are alive and on the ground
				if unit and unit:isExist() and not unit:inAir() then

					-- get human player name
					local playerName = unit:getPlayerName()
					if playerName then

						-- store unit in table for timer
						if not onGround[playerName] then
							onGround[playerName] = {u = unit, t = 0}
						end

					end
				end
			end
		end
	end

	-- check zones each second
	checkZoneScheduledFunctionID = mist.scheduleFunction(checkZones, {}, timer.getTime() + 1, 1)

	-- check ground timer every second
	checkTimeScheduledFunctionID = mist.scheduleFunction(checkTime, {}, timer.getTime() + 1, 1)

end