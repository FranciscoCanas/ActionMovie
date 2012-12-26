-- This is the menu for episode one.
-- Players will be able to select a scene to start from.
require "ep1/scene"
Gamestate.epmenu = Gamestate.new()
local state = Gamestate.epmenu

function state:enter()
	--player1:init()
	--player2:init()
end

function state:leave()
end

function state:update()
end

function state:draw()
	love.graphics.print("Episode One", (dimScreen.x / 2) - 10, 10)
	-- Code to draw player when they join a game
	if player1.isplaying then 
		love.graphics.print("Player1",
			60,
			dimScreen.y - (player1.image:getHeight() + 50))
		player1:draw()
	end
	if player2.isplaying then
		love.graphics.print("Player2",
			dimScreen.x - (40 + player2.image:getWidth()),
			dimScreen.y - (player2.image:getHeight() + 50))
		player2:draw()
	end
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		Gamestate.switch(Gamestate.menu)
	elseif key == "return" then
		-- Start scene 1
		Gamestate.switch(Gamestate.scene)
	end	
	
end