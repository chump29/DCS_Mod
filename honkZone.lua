--[[
-- Honk Zone
-- by Chump
--]]

local base = _G
local assert = base.assert
local ipairs = base.ipairs

assert(BASE ~= nil, "MOOSE must be included before this script!")

honkZone = {
	zones = {"Honk1", "Honk2"}, -- defined in mission
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
				if u and u:GetHeight() <= 3.048 then -- in m
					for _, zone in ipairs(honkZone.zones) do
						local z = ZONE:FindByName(zone)
						if z and u:IsInZone(z) then
							if honkZone.whosInZone[unitName] ~= zone then
								honkZone.whosInZone[unitName] = zone
								local g = u:GetGroup()
								if g then
									trigger.action.outSoundForGroup(g:GetID(), "l10n/DEFAULT/" .. honkZone.sound)
								end
							end
						else
							if honkZone.whosInZone[unitName] == zone then
								honkZone.whosInZone[unitName] = nil
							end
						end
					end
				end
			end
		end
	end

	SCHEDULER:New(nil, honkZone.CheckZone, {}, 10, 0.5)

	env.info("HonkZone is running...")

end
