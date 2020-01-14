do
	local myGroupName = "MyGroup"
	local targetGroupName = "MyTargetGroup"

	local target = Group.getByName(targetGroupName)
	local targetID = 0
	if target then
		targetID = target:getID()
	else
		env.info("Group not found for " .. targetGroupName)
	end
	if targetID == 0 then
		env.info("GroupID not found for " .. targetGroupName)
	end

	local group = Group.getByName(myGroupName)
	if not group then
		env.info("Group not found for " .. myGroupName)
	end
	local controller = group:getController()
	if not controller then
		env.info("Controller not found for " .. myGroupName)
	end

	local task = {
		id = "ComboTask",
		params = {
			tasks = {
				[1] = {
					id = "EngageTargets",
					params = {
						targetTypes = {
							[1] = "Ships"
						}
					}
				},
				[2] = {
					id = "AttackGroup",
					params = {
						groupId = targetID,
						attackQty = 1,
						directionEnabled = false,
						altitudeEnabled = false
					}
				}
			}
		}
	}

	controller:setTask(task)

	local groupID = group:groupID()
	if not groupID then
		env.info("GroupID not found for " .. myGroupName)
	end
	trigger.action.outTextForGroup(groupID, "Fire your Sea Eagle towards the target when ready!")

end