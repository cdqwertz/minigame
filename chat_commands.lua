local minigame_formspec = "size[8,9]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			default.gui_slots ..
			"label[0,0;respawn]" .. 
			"dropdown[4,0;4,1;can_respawn;yes,no;0]" ..
			"label[0,1;goal]" .. 
			"dropdown[4,1;4,1;goal;default,custom;0]" ..
			"label[0,2;player count]" .. 
			"dropdown[4,2;4,1;min_players;1,2,3,4,5,6,7,8,10,16,20;0]" ..
			"label[0,3;break blocks]" .. 
			"dropdown[4,3;4,1;break_blocks;yes,no;0]" ..
			"label[0,4;clear inventory]" .. 
			"dropdown[4,4;4,1;clear_inventory;yes,no;0]" ..
			"label[0,5;speed]" .. 
			"dropdown[4,5;4,1;speed;0,1,2,3,4,5;0]" ..
			"label[0,6;gravity]" .. 
			"dropdown[4,6;4,1;gravity;0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1.5,2;0]" ..
			"button[2,8;4,1;btn_submit;Ok]"

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
			elseif cmd == "set" then
				-- TODO
				minetest.show_formspec(name, "minigame:minigame", minigame_formspec)
			end
		else
			return false, "minigame <command>"
		end
		
		return true, "Done"
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()

	if formname == "minigame:minigame" then
		if fields.btn_submit and minetest.get_player_privs(name).server then
			minigame.game.stop()
		
			local break_blocks = false
			local respawn = false
			local clear_inventory = false
			
			if fields.can_respawn == "yes" then
				respawn = true
			end
			
			if fields.break_blocks == "yes" then
				break_blocks = true
			end
			
			if fields.clear_inventory == "yes" then
				clear_inventory = true
			end
			
			local goal_type = fields.goal or "default"
			local min_players = tonumber(fields.min_players) or 2
			
			local speed = tonumber(fields.speed) or 1
			local gravity = tonumber(fields.gravity) or 1
		
			minigame.set_game({
				respawn = respawn,
				goal = {
					type = goal_type
				},
				min_players = min_players,
				break_blocks = break_blocks,
				clear_inventory = clear_inventory,
				physics = {
					speed = speed,
					gravity = gravity
				}
			})
			
			minetest.chat_send_player(name, "[game] updated")
			
			for i, p in ipairs(minetest.get_connected_players()) do
				table.insert(minigame.game.players, p:get_player_name())
			end
		end
	end
end)

--

minetest.register_chatcommand("go", {
	params = "",
	description = "Starts the minigame",
	privs = {},
	func = function(name, text)
		if #minigame.game.players > minigame.game.min_players -1 then
			if not(minigame.game.is_running) then
				minigame.game.start()
				return true, "Done"
			end
		end
		
		return false, "Error"
	end,
})
