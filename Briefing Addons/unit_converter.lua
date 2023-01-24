--[[
-- Unit Converter
-- by Chump
--]]

do

	local function mToFt(m)
		return m * 3.280839
	end

	local function mpsToKts(mps)
		return mps * 1.943844
	end

	local function mmHgToInHg(mmHg)
		return mmHg / 25.399999
	end

	local function mmHgToHpa(mmHg)
		return mmHg * 1.333223
	end

	return {
		mToFt = mToFt,
		mpsToKts = mpsToKts,
		mmHgToInHg = mmHgToInHg,
		mmHgToHpa = mmHgToHpa
	}

end
