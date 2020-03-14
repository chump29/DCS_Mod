do

	local heloIDs = {}
	local planeIDs = {}

	local function add(tbl, id)
		if not tbl[id] then
			tbl[id] = 1
		end
	end

	for _, unit in ipairs(coalition.getPlayers(coalition.side.BLUE)) do
		local group = unit:getGroup()
		local category = group:getCategory()
		local groupID = group:getID()

		if category == Group.Category.HELICOPTER then
			add(heloIDs, groupID)
		elseif category == Group.Category.AIRPLANE then
			add(planeIDs, groupID)
		end
	end

	local function playSound(tbl, snd)
		for id, _ in pairs(tbl) do
			trigger.action.outSoundForGroup(id, snd)
		end
	end

	playSound(heloIDs, "l10n/DEFAULT/heloBreifing.ogg")
	playSound(planeIDs, "l10n/DEFAULT/planeBreifing.ogg")

end