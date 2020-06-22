--[[
-- Honk Zone
-- by Chump
--]]

local base = _G
local assert = base.assert
local ipairs = base.ipairs

assert(BASE ~= nil, "MOOSE must be included before this script!")

honkZone = {
	zone = "Honk", -- defined in mission
	sound = "horn.ogg" -- included in mission
}

do

	honkZone.whosInZone = {}
	function honkZone.CheckZone()
		local players = coalition.getPlayers(coalition.side.BLUE)
		for _, unit in ipairs(players) do
			if unit and unit:getLife() > 1 then
				local unitName = unit:getName()
				local u = UNIT:FindByName(unitName)
				if u and u:IsInZone(ZONE:FindByName(honkZone.zone)) then
					if not honkZone.whosInZone[unitName] then
						honkZone.whosInZone[unitName] = true
						local group = unit:getGroup()
						if group then
							trigger.action.outSoundForGroup(group:getID(), "l10n/DEFAULT/" .. honkZone.sound)
						end
					end
				else
					if honkZone.whosInZone[unitName] then
						honkZone.whosInZone[unitName] = nil
					end
				end
			end
		end
	end

	SCHEDULER:New(nil, honkZone.CheckZone, {}, 10, 0.5)

	env.info("HonkZone is running...")

end
