--[[
-- Honk Zone
-- by Chump
--]]

honkZone = {
	zones = {"Honk1", "Honk2"}, -- defined in mission
	sound = "honk.ogg" -- included in mission
}

do

	local assert = _G.assert
	local ipairs = _G.ipairs

	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	honkZone.whosInZone = {}
	function honkZone.CheckZone()
		for _, unit in ipairs(coalition.getPlayers(coalition.side.BLUE)) do
			if unit and unit:getLife() > 1 then
				local unitName = unit:getName()
				local pos = unit:getPosition().p
				local h = land.getHeight({x = pos.x, y = pos.z})
				local height = pos.y - h
				local u = UNIT:FindByName(unitName)
env.info(unitName.."@"..tostring(height))
				if u and height <= 6.096 then -- 20ft
					for _, zone in ipairs(honkZone.zones) do
						local z = ZONE:FindByName(zone)
						if z and u:IsInZone(z) then
env.info("in zone")
							if honkZone.whosInZone[unitName] ~= zone then
								honkZone.whosInZone[unitName] = zone
								local g = u:GetGroup()
								if g then
									trigger.action.outSoundForGroup(g:GetID(), "l10n/DEFAULT/" .. honkZone.sound)
								end
							end
						else
							if honkZone.whosInZone[unitName] == zone then
env.info("reset")
								honkZone.whosInZone[unitName] = nil
							end
						end
					end
				end
			end
		end
	end

	SCHEDULER:New(nil, honkZone.CheckZone, {}, 60, 1)

	env.info("HonkZone is running...")

end
