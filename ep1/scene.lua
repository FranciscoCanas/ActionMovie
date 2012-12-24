-- This is the template for a scene.

-- Required libraries that are locally used
local Camera = require "hump.camera"
local anim8 = require 'anim8.anim8'

-- State declarations
Gamestate.scene = Gamestate.new()
local state = Gamestate.scene

function state:init()
end

function state:enter()
-- Initialize players here
	if player1.isplaying then
		player1.x = 200
		player1.y = 640
	end
	if player2.isplaying then
		player1.x = 300
		player1.y = 640
	end
	
	cam = Camera(50,50)
end

function state:leave()
end

function state:update(dt)
	-- Camera that follows player
	local dx,dy = player1.x - cam.x, player1.y - cam.y
	cam:move(dx/2,dy/2)
end

function state:draw()
	love.graphics.print("Scene Placeholder", 10, 10)
end 

function state:focus()
end

function state:keypressed()
	if player1.isplaying then
		player1:keyPressHandler(key)
	end
	
	if player2.isplaying then
		player2:keyPressHandler(key)
	end
end

function state:keyreleased(key)
	if key == "escape" then
		-- quits to main menu
		Gamestate.switch(Gamestate.epmenu)
	else
		if player1.isplaying then
			player1.keyReleaseHandler(key)
		end
		if player2.isplaying then
			player2.keyReleaseHandler(key)
		end
	end	
end



function state:quit()
end

