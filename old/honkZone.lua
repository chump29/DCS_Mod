--[[
-- Honk Zone
-- by Chump
--]]

HonkZone = {
	Sound = "honk.ogg",
	Zones = {
		"Honk1",
		"Honk2"
	}
}

do

	local assert = _G.assert
	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	local ipairs = _G.ipairs

	local function log(msg)
		env.info("HonkZone: " .. msg)
	end

	local function InZone(z, u)
		local unitName = u:GetPlayerName()
		if unitName then
			local zoneName = z:GetName()
			if not HonkZone.UnitsInZone.Zone[zoneName][unitName] then
				trigger.action.outSoundForGroup(u:GetGroup():GetID(), "l10n/DEFAULT/" .. HonkZone.Sound)
				HonkZone.UnitsInZone.Zone[zoneName][unitName] = true
				log(unitName .. " in zone " .. zoneName)
			end
		end
	end

	local function NotInZone(z, u)
		local unitName = u:GetPlayerName()
		if unitName then
			local zoneName = z:GetName()
			if HonkZone.UnitsInZone.Zone[zoneName][unitName] then
				HonkZone.UnitsInZone.Zone[zoneName][unitName] = nil
				log(unitName .. " out of zone " .. zoneName .. ". Resetting...")
			end
		end
	end

	local function CheckZone(z)
		local players = coalition.getPlayers(coalition.side.BLUE)
		if players and #players > 0 then
			for _, unit in ipairs(players) do
				local u = UNIT:Find(unit)
				if u and not u:InAir() then
					if u:IsInZone(z) then
						InZone(z, u)
					else
						NotInZone(z, u)
					end
				end
			end
		end
	end

	HonkZone.UnitsInZone = {
		Zone = {}
	}

	for _, zoneName in ipairs(HonkZone.Zones) do
		local z = ZONE:FindByName(zoneName)
		if not z then
			log("Zone (" .. zoneName .. ") not found!")
			return
		end

		SCHEDULER:New(nil, CheckZone, {z}, 60, 3)

		HonkZone.UnitsInZone.Zone[zoneName] = {}

		log(" Watching zone " .. zoneName .. "...")
	end

end
