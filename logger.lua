--[[
-- Logger
-- by Chump
--]]

local base = _G

module("logger")

local fileName = "logger.lua"

function log(v, n)
	if base.io and base.os and base.require then
		local d = base.os.getenv("USERPROFILE") or ""
		if base.string.len(d) > 0 then
			d = d .. "\\Desktop\\"
		end
		local f = base.assert(base.io.open(d .. fileName, "a"))
		if f then
			local Serializer = base.require("Serializer")
			local s = Serializer.new(f)
			f:write(base.os.date("-- %x @ %X"), "\n\n")
			s:serialize_sorted(n or "", v)
			f:write("\n")
			f:flush()
			f:close()
		end
	end
end
