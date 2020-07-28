--[[
-- Honk Zone
-- by Chump
--]]

HonkZone = {
	Sound = "honk.ogg",
	Units = {
		"Hawg1",
		"Hawg2"
	},
	Zone = "Honk"
}

do

	local assert = _G.assert
	local ipairs = _G.ipairs

	assert(BASE ~= nil, "MOOSE must be loaded prior to this script!")

	local function log(msg)
		env.info("HonkZone: " .. msg)
	end

	local function InZone(z, u)
		local unitName = u:GetPlayerName()
		if unitName then
			if not HonkZone.UnitsInZone[unitName] then
				trigger.action.outSoundForGroup(u:GetGroup():GetID(), "l10n/DEFAULT/" .. HonkZone.Sound)
				HonkZone.UnitsInZone[unitName] = true
				log(unitName .. " in zone " .. z:GetName())
			end
		end
	end

	local function NotInZone(z, u)
		local unitName = u:GetPlayerName()
		if unitName then
			if HonkZone.UnitsInZone[unitName] then
				HonkZone.UnitsInZone[unitName] = nil
				log(unitName .. " out of zone " .. z:GetName() .. ". Resetting...")
			end
		end
	end

	local function CheckZone(z)
		local players = coalition.getPlayers(coalition.side.BLUE)
		if players and #players > 0 then
			for _, unit in ipairs(players) do
				local u = UNIT:Find(unit)
				if u then
					if u:IsInZone(z) then
						InZone(z, u)
					else
						NotInZone(z, u)
					end
				end
			end
		end
	end

	HonkZone.UnitsInZone = {}

	local z = ZONE:FindByName(HonkZone.Zone)
	if not z then
		log("Zone (" .. HonkZone.Zone .. ") not found!")
		return
	end

	SCHEDULER:New(nil, CheckZone, {z}, 10, 2)

	log(" Watching zone " .. z:GetName() .. "...")

end
