-- This will hold the main menu.
-- Player can choose between 1p and 2p, 
-- as well as which episode to play.
-- Choosing an episode will transition 
-- to that episode's menu.

Gamestate.menu = Gamestate.new()
local state = Gamestate.menu

function state:enter()
	-- Reinitialize the players when we enter menu
	player1.isplaying = false
	player2.isplaying = false
	player1:init()
	player2:init()
end

function state:leave()
end

function state:update()
end

function state:draw()
	love.graphics.print("Main Menu", (dimScreen.x / 2) - 10, 10)
	
	-- Code to draw player when they join a game
	if player1.isplaying then 
		love.graphics.print("Player1",
			60,
			dimScreen.y - (player1.height + 50))
		player1:draw()
	else
		love.graphics.print("Press F to join",
			60,
			dimScreen.y - (player1.height + 50))
	end
	if player2.isplaying then
		love.graphics.print("Player2",
			dimScreen.x - (40 + player2.width),
			dimScreen.y - (player2.height + 50))
		player2:draw()
	else
		love.graphics.print("Press J to join",
			dimScreen.x - (40 + player2.width),
			dimScreen.y - (player2.height + 50))
	end
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		love.event.push("quit")
	elseif (player1.isplaying or player2.isplaying) 
		and (key == "return" or key==" ") then
		-- Start scene 1
		Gamestate.switch(Gamestate.epmenu)
	elseif key == player1.keyfire then
		player1.isplaying = not player1.isplaying
	elseif key == player2.keyfire then
		player2.isplaying = not player2.isplaying
	end	
end