-- This is the template for a scene.

require "../level"

-- Required libraries that are locally used
local Camera = require "hump.camera"
local anim8 = require 'anim8.anim8'
local background = Level("ep1")

-- State declarations
Gamestate.scene = Gamestate.new()
local state = Gamestate.scene
local keypressed = "none"

-- Stuffs local to scene
enemies = {}
bullets = {}


function state:init()	
	self.started = false
end

function state:enter()
	-- initialize world here
	-- world:setGravity(0,9.8*love.physics.getMeter())
	-- Initialize players here
	if player1.isplaying then
		player1.position = Vector(100,100)
	end
	if player2.isplaying then
		player2.position = Vector(200,100)
	end

	-- make objects in map solid
	background:createObjects()

	-- set up camera ------------------------------------
	cam = Camera(player1.position.x, player1.position.y, 
		1, -- zoom level
		0 -- rotation angle
		)
		
	camfollows = true -- follows players around.
	camstatic = false -- does not.
	camMaxZoom = 2.0
	camMinZoom = 0.5
	camZoomRatio = 500
	--boundaries for the camera
	camLeft = 0
	camRight = 2000
	camTop = 0
	camBottom = 1000
	-- camera code ends here --
	self.started = true
	
	-- set up some baddies here --
	-- table.insert(enemies, 
		-- Enemy(love.graphics.newImage('art/gunman.png'),
		-- Vector(400,800)))
end

function state:leave()
end

function state:update(dt)
	-- Update scene-related systems.
	world:update(math.min(dt, 1/60))
	--Timer.update(math.min(dt, 1/60))
	
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(math.min(dt, 1/60))
			player.animation:update(math.min(dt, 1/60))
		end
	end
	
	for i,enemy in ipairs(enemies) do
		if enemy.isalive then
			enemy:update(math.min(dt,1/60))
			enemy.animation:update(math.min(dt,1/60))
		end
	end
	
	for i,bullet in ipairs(bullets) do
		if bullet.impacted then 
			table.remove(bullets, i)
		else 
			bullet:update(math.min(dt,1/60))
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
	background:draw()

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
	
	for i,enemy in ipairs(enemies) do
		enemy:draw()
	end
	
	for i,bullet in ipairs(bullets) do
		bullet:draw()
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
	love.graphics.print(player1.health, 50, 50)
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
			player1:keyReleaseHandler(key)
		end
		
		if player2.isplaying then
			player2:keyReleaseHandler(key)
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
			zoom = camZoomRatio / dist 
			if zoom > camMaxZoom then zoom = camMaxZoom end
			if zoom < camMinZoom then zoom = camMinZoom end
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

	camWorldWidth = love.graphics.getWidth() / zoom
	camWorldHeight = love.graphics.getHeight() / zoom
	
	x = math.max(x, camLeft + (camWorldWidth / 2))
	x = math.min(x, camRight - (camWorldWidth / 2))

	y = math.max(y, camTop + (camWorldHeight / 2))
	y = math.min(y, camBottom - (camWorldWidth / 2))

	-- Move the cam to the coordinates calculated above.
	cam:lookAt(x, y)
	-- Zoom the cam to the appropriate level.
	cam:zoomTo(zoom)



	camWorldX = cam.x - (camWorldWidth / 2)
	camWorldY = cam.y - (camWorldHeight / 2)
	background:setDrawRange(camWorldX, camWorldY, camWorldWidth, camWorldHeight)
end


