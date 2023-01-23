--[[
-- Logger
-- by Chump
--]]

do

	local fileName = "logger.lua"
	local useDesktopPath = true

	local function log(v, n)
		if io and os and require then
			local d = ""
			if useDesktopPath then
				d = os.getenv("USERPROFILE") or ""
				if string.len(d) > 0 then
					d = d .. "\\Desktop\\"
				end
			end
			local f = assert(io.open(d .. fileName, "a"))
			if f then
				local Serializer = require("Serializer")
				local s = Serializer.new(f)
				f:write(os.date("-- %x @ %X"), "\n\n")
				s:serialize_sorted(n or "", v)
				f:write("\n")
				f:flush()
				f:close()
			end
		else
			env.info("Environment sanitized!")
		end
	end

	return { log = log }

end
