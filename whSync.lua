do
	function click(dev, cmd, arg)
		GetDevice(dev):performClickableAction(cmd, arg)
	end

	click(39, 3002, 0) -- flaps up
	click(1, 3017, 0) -- l eng start off
	click(1, 3018, 0) -- r eng start off
end