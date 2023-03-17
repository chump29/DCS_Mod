--[[
-- Fire Support
-- by Chump
--]]

do

	local config = FIRE_SUPPORT_CONFIG or {
		diameter = 75, -- in meters
		power = 68,
		preWaitArty = 10, -- in seconds
		preWaitSmoke = 5,
		postWaitArty = 30,
		postWaitSmoke = 10,
		rounds = 6, -- number of shots
		smokeColor = "Random" -- "Green", "Red", "White", "Orange", "Blue", "Random"
	}

	world.addEventHandler({
		onEvent = function(self, event)
			local text = string.lower(event.text or "")
			if event.id == world.event.S_EVENT_MARK_CHANGE and string.len(text) > 0 and (text == "arty" or text == "smoke") then
				local function say(txt)
					trigger.action.outTextForCoalition(coalition.side.BLUE, txt, 10)
					trigger.action.removeMark(event.idx)
				end
				if text == "arty" then
					if config.artyTime and timer.getTime() < config.artyTime then
						say(string.format("Arty is cooling down. Try again in %d seconds...", config.artyTime - timer.getTime()))
						return
					end
					local function getRandomPosition(pos)
						local ang = math.random() * 2 * math.pi
						local hyp = math.sqrt(math.random()) * config.diameter / 2
						local adj = math.cos(ang) * hyp
						local opp = math.sin(ang) * hyp
						return {x = pos.x + adj, y = 0, z = pos.z + opp}
					end
					local function explosion(pos)
						trigger.action.explosion(pos, config.power)
					end
					local maxTime = 0
					for i = 1, config.rounds do
						local time = timer.getTime() + config.preWaitArty + i + math.random(i)
						if time > maxTime then
							maxTime = time
						end
						timer.scheduleFunction(explosion, getRandomPosition(event.pos), time)
					end
					if config.postWaitArty > 0 then
						config.artyTime = maxTime + config.postWaitArty
					end
					if config.preWaitArty > 0 then
						say(string.format("Firing for effect in %d seconds!", config.preWaitArty))
					else
						say("Firing for effect!")
					end
				elseif text == "smoke" then
					if config.smokeTime and timer.getTime() < config.smokeTime then
						say(string.format("Reloading. Try again in %d seconds...", config.smokeTime - timer.getTime()))
						return
					end
					local color = config.smokeColor
					if color == "Random" then
						local colors = {"Green", "Red", "White", "Orange", "Blue"}
						color = colors[math.random(#colors)]
					end
					local function smoke(pos)
						trigger.action.smoke(pos, trigger.smokeColor[color])
					end
					timer.scheduleFunction(smoke, event.pos, timer.getTime() + config.preWaitSmoke)
					if config.postWaitSmoke > 0 then
						config.smokeTime = timer.getTime() + config.postWaitSmoke
					end
					if config.preWaitSmoke > 0 then
						say(string.format("%s smoke out in %d seconds!", color, config.preWaitSmoke))
					else
						say(string.format("%s smoke out!", color))
					end
				end
			end
		end
	})

	env.info("Fire Support available.")

end
