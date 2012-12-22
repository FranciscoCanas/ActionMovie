-- This will hold the main menu.
-- Player can choose between 1p and 2p, 
-- as well as which episode to play.
-- Choosing an episode will transition 
-- to that episode's menu.

Gamestate.menu = Gamestate.new()
local state = Gamestate.menu

function state:enter()
end

function state:leave()
end

function state:update()
end

function state:draw()
	love.graphics.print("Menu Placeholder", 10, 10)
	
	if player1.isplaying then 
		love.graphics.print("Player1",10,200)
	end
	if player2.isplaying then
		love.graphics.print("Player2",400,200)
	end
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		love.event.push("quit")
	elseif key == "return" or key==" " then
		-- Start scene 1
		Gamestate.switch(Gamestate.epmenu)
	elseif key == player1.keyfire then
		player1.isplaying = not player1.isplaying
	elseif key == player2.keyfire then
		player2.isplaying = not player2.isplaying
	end	
	
end