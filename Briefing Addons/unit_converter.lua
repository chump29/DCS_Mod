--[[
-- Unit Converter
-- by Chump
--]]

module("unit_converter")

function mToFt(m)
	return m * 3.280839
end

function mpsToKts(mps)
	return mps * 1.943844
end

function mmHgToInHg(mmHg)
	return mmHg / 25.399999
end

function mmHgToHpa(mmHg)
	return mmHg * 1.333223
end
