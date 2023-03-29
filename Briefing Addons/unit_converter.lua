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

	local function mToNm(m) -- to nautical miles
		return (m or 0) / 1852
	end

	local function mToSm(m) -- to statute miles
		return (m or 0) / 1609.344
	end

	local function cToF(c)
		return (c or 0) * 9 / 5 + 32
	end

	local function qfeToQnh(q, a) -- in hPa
		return q + a / 27.3
	end

	local function hPaToInHg(h)
		return h * 0.029530
	end

	local function hPaToMmHg(h)
		return h * 0.750062
	end

	return {
		mToFt = mToFt,
		mpsToKts = mpsToKts,
		mmHgToInHg = mmHgToInHg,
		mmHgToHpa = mmHgToHpa,
		mToNm = mToNm,
		mToSm = mToSm,
		cToF = cToF,
		qfeToQnh = qfeToQnh,
		hPaToInHg = hPaToInHg,
		hPaToMmHg = hPaToMmHg
	}

end
