-- This is the template for a scene.

-- Required libraries that are locally used
local Camera = require "hump.camera"
local anim8 = require 'anim8.anim8'

-- State declarations
Gamestate.scene = Gamestate.new()
local state = Gamestate.scene
local keypressed = "none"

-- Stuffs local to scene
enemies = {}
bullets = {}
map = ATL.Loader.load("maps/road.tmx") 

function state:init()	
end

function state:enter()
	-- Init collisions
	--Collider:setCallbacks(self:collide)
	-- Initialize players here
	if player1.isplaying then
		player1.position = Vector(100,100)
	end
	if player2.isplaying then
		player2.position = Vector(200,100)
	end
	
	-- set up cam
	cam = Camera(player1.position.x, player1.position.y, 
		1, -- zoom level
		0 -- rotation angle
		)
		
	-- The type of camera used.
	camfollows = true -- follows players around.
	camstatic = false -- does not.
	camMaxZoom = 1.5
	camMinZoom = 0.5
		
end

function state:leave()
end

function state:update(dt)
	-- Update scene-related systems.
	world:update(math.min(dt, 1/60))
	
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(dt)
			player.animation:update(dt)
		end
	end
	state:movecam() -- Update camera. See movecam func below.
end

function state:draw()
	-- Anything drawn between camera attach and detach is drawn
	-- from camera perspective. 
	-- Game objects and anything in the scene's physical space
	-- will go here.
	cam:attach()
	map:draw()
	love.graphics.print("Attached to cam for reference", 30,30)
	if (player1.isplaying and player2.isplaying) then
		if player1.position.y >= player2.position.y then
			player2:draw()
			player1:draw()
		else
			player1:draw()
			player2:draw()
		end
	else
		for i,player in ipairs(players) do
			if player.isplaying then
				player:draw()
				end
		end
	end
	cam:detach()
	
	-- Anything drawn out here is drawn according to screen
	-- perspective. 
	-- The HUD and any other overlays will go here.
	love.graphics.print("Scene Placeholder", 10, 10)
	-- love.graphics.print(player1.position.x, 200, 10)
	-- love.graphics.print(player1.position.y, 220, 10)
	love.graphics.print(player1.facing.x, 200, 30)
	love.graphics.print(player1.facing.y, 210, 30)
end 

function state:focus()
end

function state:keypressed(key)
	if player1.isplaying then
		player1:keyPressHandler(key)
	end
	
	if player2.isplaying then
		player2:keyPressHandler(key)
	end
	keypressed = key
end

function state:keyreleased(key) 
	if key == "escape" then
		-- quits to main menu
		Gamestate.switch(Gamestate.menu)
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

function state:movecam()
	local x, y = 0,0
	local dist
	local zoom = 1
	
	-- Code to move the camera around.
	if camfollows then
		-- Camera sticks to the midpoint between the two players if 
		-- both are playing, zooming out and in as necessary. 
		-- Otherwise it just follows the single player.
		if player1.isplaying and player2.isplaying then
			x = (player1.position.x + player2.position.x) / 2
			y = (player1.position.y + player2.position.y) / 2
			dist = (player1.position - player2.position):len()
			zoom = 600 / dist 
			if zoom > camMaxZoom then zoom = 1.5 end
			if zoom < camMinZoom then zoom = 0.5 end
		elseif player1.isplaying and (not player2.isplaying) then
			x = player1.position.x
			y = player1.position.y
		elseif player2.isplaying and (not player1.isplaying) then
			x = player2.position.x
			y = player2.position.y
		end
		
	end
	if camstatic then
		-- Nothing to do here just yet.
	end
	-- Move the cam to the coordinates calculated above.
	cam:lookAt(x, y)
	-- Zoom the cam to the appropriate level.
	cam:zoomTo(zoom)
end

-- Collision handling local to this particular scene. May instead choose to implement
-- on a game-wide basis so all scenes have the exact same detection and handling.
function collide(dt, shape_one, shape_two, dx, dy)

end

