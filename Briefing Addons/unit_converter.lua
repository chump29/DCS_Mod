--[[
-- Unit Converter
-- by Chump
--]]

do

	local function mToFt(m)
		return (m or 0) * 3.280839
	end

	local function mpsToKts(mps)
		return (mps or 0) * 1.943844
	end

	local function mmHgToInHg(mmHg)
		return (mmHg or 0) / 25.399999
	end

	local function mmHgToHpa(mmHg)
		return (mmHg or 0) * 1.333223
	end

	return {
		mToFt = mToFt,
		mpsToKts = mpsToKts,
		mmHgToInHg = mmHgToInHg,
		mmHgToHpa = mmHgToHpa
	}

end
