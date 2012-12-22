-- This is the menu for episode one.

require "ep1/scene"
Gamestate.epmenu = Gamestate.new()
local state = Gamestate.epmenu

function state:enter()
end

function state:leave()
end

function state:update()
end

function state:draw()
	love.graphics.print("Episode One Menu", 10, 10)
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