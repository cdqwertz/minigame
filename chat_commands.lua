minetest.register_chatcommand("minigame", {
	params = "spawn/lobby/start/stop",
	description = "",
	privs = {server = true},
	func = function(name, text)
		local params = text:split(" ")
		local player = minetest.get_player_by_name(name)
		local pos = player:getpos()
		
		if #params > 0 then
			local cmd = params[1]
			
			if cmd == "spawn" then
				if #params > 1 then
					if params[2] == "add" then
						table.insert(minigame.game.spawns, pos)
						return true, "Added " .. minetest.pos_to_string(pos) .. "."
					elseif params[2] == "clear" then
						minigame.game.spawns = {}
						
						table.insert(minigame.game.spawns, pos)
						return true, "Done!"
					end
				else
					table.insert(minigame.game.spawns, pos)
					return true, "Added " .. minetest.pos_to_string(pos) .. "."
				end
			elseif cmd == "lobby" then
				minigame.game.lobby = pos
				return true, "Set lobby position : " .. minetest.pos_to_string(pos) .. "."
			elseif cmd == "go" or cmd == "start" then
				if not(minigame.game.is_running) then
					minigame.game.start()
				end
			elseif cmd == "stop" then
				minigame.game.stop()
			end
		else
			return false, "minigame <command>"
		end
		
		return true, "Done"
	end,
})
