-- This is the menu for episode one.
-- Players will be able to select a scene to start from.
---------------------------------------------------------
require "ep1/story1"
require "ep1/scene"
require "ep1/story2"
require "ep1/scene2"
require "ep1/story3"
require "ep1/scene3"
require "ep1/story4"
require "ep1/story4a"

Gamestate.epmenu = Gamestate.new()
local state = Gamestate.epmenu
local epi = 0 

function state:enter()
	titleScene = love.graphics.newImage("art/cityscape.png")
	local font = love.graphics.setNewFont(20)
	love.graphics.setFont( font)
end

function state:leave()
end

function state:update(dt)
    globalMenuBGx = globalMenuBGx + dt * globalMenuBGdx
    if ( globalMenuBGx < -1*titleScene:getWidth()) then
        globalMenuBGx = 0
    end
end

function state:draw()
	love.graphics.draw(titleScene, globalMenuBGx,0)
    love.graphics.draw(titleScene, globalMenuBGx + titleScene:getWidth(), 0)
	love.graphics.draw(titleImage, (dimScreen.x/2) - 320 , 25)
    love.graphics.setColor( 255,0,0,255 )


	if epi==0 then
		arrowCoord = 50
	elseif epi==1 then
		arrowCoord = 75
	else
		arrowCoord = 100
	end

   	love.graphics.print("Episode One", (dimScreen.x / 2) - 40, dimScreen.y/1.75 )
	love.graphics.print("->", (dimScreen.x / 2) - 60, (dimScreen.y/1.75) + arrowCoord)
	love.graphics.print("Scene One", (dimScreen.x / 2) - 40, (dimScreen.y / 1.75) +50)
	love.graphics.print("Scene Two", (dimScreen.x / 2) - 40, (dimScreen.y / 1.75) + 75)
	love.graphics.print("Scene Three", (dimScreen.x / 2) - 40, (dimScreen.y / 1.75) + 100)
    love.graphics.setColor( 255,255,255,255 )

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
			Gamestate.switch(Gamestate.story1)
		elseif (epi == 1) then
			Gamestate.switch(Gamestate.story2)
		elseif (epi == 2) then
			Gamestate.switch(Gamestate.story3)
		end
	elseif key == "up" then
		epi = (epi - 1) % 3
	elseif key == "down" then
		epi = (epi + 1) % 3 
	end	
	
end
