function minigame.set_game(def)
	def.players = def.players or {}
	def.players_playing = {}
	def.spawns = def.spawns or {{x = 0, y = 0, z = 0}}
	def.lobby = def.lobby or {x = 0, y = 50, z = 0}
	def.respawn = def.respawn or false
	def.physics = def.physics or {}
	def.min_players = 2
	def.goal = def.goal or {
		type = "default"
	}
	
	def.is_running = false
	
	def.load = def.load or (function()
	end)
	
	def.start = def.start or (function()
		minigame.game.load() -- load map, fill chests...
	
		for i, name in ipairs(minigame.game.players) do
			local player = minetest.get_player_by_name(name)
			player:setpos(minigame.game.spawns[math.random(#minigame.game.spawns)])
			
			table.insert(minigame.game.players_playing, name)
			player:set_physics_override(minigame.game.physics)
		end
	end)
	
	def.stop = def.stop or (function(player)
		minigame.game.players_playing = {}
		
		for i, name in ipairs(minigame.game.players) do
			local player = minetest.get_player_by_name(name)
			player:setpos(minigame.game.lobby)
			player:set_physics_override({
				speed = 1.0,
				jump = 1.0,
				gravity = 1.0,
				sneak = true
			})
		end
	end)
	
	def.on_die = def.on_die or (function(player)
	end)
	
	def.on_win = def.on_win or (function(player)
		minetest.chat_send_all("[game] " .. minigame.game.players_playing[1] .. " won!")
		minigame.game.stop()
	end)
	
	def.on_respawn = def.on_respawn or (function(player)
		if minigame.game.respawn then
			player:setpos(minigame.game.spawns[math.random(#minigame.game.spawns)])
		else
			for i, name in ipairs(minigame.game.players_playing) do
				if name == player:get_player_name() then
					table.remove(minigame.game.players_playing, i)
				end
			end
			
			minetest.chat_send_all("[game] " .. player:get_player_name() .. " died!")
			
			player:setpos(minigame.game.lobby)
			player:set_physics_override({
				speed = 1.0,
				jump = 1.0,
				gravity = 1.0,
				sneak = true
			})
			
			minetest.after(1, function(p)
				if p then
					player:setpos(minigame.game.lobby)
				end
			end, player)
			
			if minigame.game.goal.type == "default" then
				if minigame.game.is_running and #minigame.game.players_playing < 2 then
					minigame.game.on_win()
				end
			end
		end
	end)

	minigame.game = def
	-- minigame.game.start()
end

minetest.register_on_joinplayer(function(player)
	table.insert(minigame.game.players, player:get_player_name())
	
	player:setpos(minigame.game.lobby)
	player:set_physics_override({
		speed = 1.0,
		jump = 1.0,
		gravity = 1.0,
		sneak = true
	})
	
	minetest.chat_send_all("[game] players : " .. tostring(#minigame.game.players) .. "/" .. tostring(minigame.game.min_players))
	
	if #minigame.game.players > minigame.game.min_players -1 then
		if not(minigame.game.is_running) then
			minigame.game.start()
			minigame.game.is_running = true
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	for i, name in ipairs(minigame.game.players_playing) do
		if name == player:get_player_name() then
			table.remove(minigame.game.players_playing, i)
		end
	end
	
	for i, name in ipairs(minigame.game.players) do
		if name == player:get_player_name() then
			table.remove(minigame.game.players, i)
		end
	end
end)

minetest.register_on_dieplayer(function(player)
	minigame.game.on_die(player)
end)

minetest.register_on_respawnplayer(function(player)
	minigame.game.on_respawn(player)
end)
