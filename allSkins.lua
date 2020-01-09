allSkins = {
	debug = false,
	paths = { -- NOTE: path MUST end in slash
		lfs.currentdir() .. "Bazar\\Liveries\\",
		lfs.writedir() .. "Mods\\aircraft\\Civil Aircraft Mod\\Liveries\\",
		"D:\\DCS.Liveries\\",
		 -- because some people have to be different:
		 -- TODO: refactor to auto scan dir
		lfs.currentdir() .. "CoreMods\\aircraft\\AJS37\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\AV8BNA\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\C-101\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\ChinaAssetPack\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\Christen Eagle II\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\F-5E\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\F14\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\F-16C\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\F-86\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\FA-18C\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\Hawk\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\I-16\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\L-39\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\M-2000C\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\MiG-15bis\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\MiG-19P\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\MiG-21BIS\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\SA342\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\Su-34\\Liveries\\",
		lfs.currentdir() .. "CoreMods\\aircraft\\Yak-52\\Liveries\\"
	}
}

do

	local lfs = require("lfs")

	function allSkins.getLiveries(path)
		local debug = allSkins.debug

		if debug then env.info("allSkins: Scanning " .. path) end

		if not allSkins.liveries then allSkins.liveries = {} end

		local function invalid(obj) return obj == nil or obj == "." or obj == ".." end

		for airframe in lfs.dir(path) do
			if not invalid(airframe) and lfs.attributes(path .. airframe, "mode") == "directory" then

				for livery in lfs.dir(path .. airframe) do
					if not invalid(livery) and lfs.attributes(path .. airframe .. "\\" .. livery, "mode") == "directory" then

						if not allSkins.liveries[airframe] then allSkins.liveries[airframe] = {} end

						table.insert(allSkins.liveries[airframe], livery)

						if debug then env.info("allSkins: Inserted " .. livery .. " for " .. airframe) end
					end
				end
			end
		end
	end

	for _, path in ipairs(allSkins.paths) do
		allSkins.getLiveries(path)
	end

	env.info("allSkins: scanned.")
end