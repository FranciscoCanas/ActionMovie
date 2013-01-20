-- This is the menu for episode one.
-- Players will be able to select a scene to start from.
require "ep1/scene"
require "ep1/scene2"
require "ep1/scene3"
Gamestate.epmenu = Gamestate.new()
local state = Gamestate.epmenu
local epi = 0 

function state:enter()
	--player1:init()
	--player2:init()
end

function state:leave()
end

function state:update(dt)
	
end

function state:draw()
	love.graphics.draw(titleScene, 0,0)

	love.graphics.draw(titleImage, (dimScreen.x/2) - 320 , (dimScreen.y/2)-240)


	love.graphics.print("Episode One", (dimScreen.x / 2) - 10, 10)

	if (epi == 0) then
		love.graphics.print("Scene One", (dimScreen.x / 2) - 10, (dimScreen.y / 2) )
	elseif (epi == 1) then
		love.graphics.print("Scene Two", (dimScreen.x / 2) - 10, (dimScreen.y / 2))
	elseif (epi == 2) then
		love.graphics.print("Scene Three", (dimScreen.x / 2) - 10, (dimScreen.y / 2))
	end
	-- Code to draw player when they join a game
	if player1.isplaying then 
		--love.graphics.print("Player1",
		--	60,
		--	dimScreen.y - (player1.height + 50))
		player1:draw()
	end
	if player2.isplaying then
		--love.graphics.print("Player2",
		--	dimScreen.x - (40 + player2.width),
		--	dimScreen.y - (player2.height + 50))
		player2:draw()
	end
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		Gamestate.switch(Gamestate.menu)
	elseif key == "return" then
		-- Start scene 1
		if (epi == 0) then
			Gamestate.switch(Gamestate.scene)
		elseif (epi == 1) then
			Gamestate.switch(Gamestate.scene2)
		elseif (epi == 2) then
			Gamestate.switch(Gamestate.scene3)
		end
	elseif key == "up" then
		epi = (epi - 1) % 3
	elseif key == "down" then
		epi = (epi + 1) % 3 
	end	
	
end
