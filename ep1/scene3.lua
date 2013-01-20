-- This is the template for a scene.

require "../level"

-- Required libraries that are locally used
local Camera = require "hump.camera"
local anim8 = require 'anim8.anim8'
Jumper = require 'Jumper.jumper'
local jumperDebug = require 'Jumper.debug_utils'
local Timer = require "hump.timer"
require 'TESound.TEsound'


-- State declarations
Gamestate.scene3 = Gamestate.new()
local state = Gamestate.scene3
local keypressed = "none"

-- some fonts
font12 = love.graphics.newFont(12) 

-- Stuffs local to scene
local MAXDEAD = 4


function state:init()	
	self.started = false
end

function state:enter()
	-- set up sound objects here
	bgMusicList = {"music/meanStreets.ogg"}
--	TEsound.playLooping(bgMusicList, "bgMusic")
	
	-- initialize world here
	-- world:setGravity(0,9.8*love.physics.getMeter())
	-- Initialize players here
	if player1.isplaying then
		player1.body:setPosition(100, 600)
		--player1:setPosition(Vector(100,600))
	end
	if player2.isplaying then
		player2.body:setPosition(100,700)
		--player2:setPosition(Vector(100,700)) 
	end

	-- set up camera ------------------------------------
	cam = Camera(player1.position.x, player1.position.y, 
		2, -- zoom level
		0 -- rotation angle
		)
		
	camfollows = false -- follows players around.
	camstatic = true -- does not.
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
	
	

	-- make objects in map solid
	background = Level("ep1s3", false)
	background:createObjects()

	-- Initializing Jumper
	searchMode = 'ORTHOGONAL' -- whether or not diagonal moves are allowed
	heuristics = {'MANHATTAN','EUCLIDIAN','DIAGONAL','CARDINTCARD'} -- valid distance heuristics names
	current_heuristic = 2 -- indexes the chosen heuristics within 'heuristics' table
	filling = false -- whether or not returned paths will be smoothed
	postProcess = false -- whether or not the grid should be postProcessed
	pather = Jumper(background.collisionMap) -- Inits Jumper
	pather:setMode(searchMode)
	pather:setHeuristic(heuristics[current_heuristic])
	pather:setAutoFill(filling)
	
	-- set up bullets table --
	bullets = {}
	
	-- set up some baddies here --
	enemies = {}
	deadCount = 0

	-- tiled coordinates
	--(cover.x, cover.y, shoot.x, shoot.y)
	movementPositions = {{20, 17, 20, 19}, {24, 12, 24, 14}} --, {20, 16, 20, 15}}
--	insertEnemy(enemiesPosition)
	enemyTimer = Timer.new()
	enemyTimer:add(5, s3spawnEnemy)
end

-- add an enemy at position x, y
function insertMEnemy(positions) 
	for i, screenPos in ipairs(positions) do 
		print("position")
		table.insert(enemies, Enemy(love.graphics.newImage('art/gunman.png'), screenPos, MOVETOSETSPOT))
	end
end

function state:leave()
	TEsound.stop("bgMusic", false) -- stop bg music immediately
end

function state:update(dt)
	-- Sound updates
	TEsound.cleanup()
	-- Update scene-related systems.
	world:update(math.min(dt, 1/60))
	--Timer.update(math.min(dt, 1/60))
	enemyTimer:update(math.min(dt, 1/60))
	
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(math.min(dt, 1/60))

		end
	end
	
	for i,enemy in ipairs(enemies) do
		if ((not enemy.isalive) and (not enemy.counted)) then
			deadCount = deadCount + 1
			enemy.counted = true
		else
			enemy:update(math.min(dt,1/60))
		end
		enemy.animation:update(math.min(dt,1/60))
	end
	
	for i,bullet in ipairs(bullets) do
		if bullet.impacted then 
			table.remove(bullets, i)
		else 
			bullet:update(math.min(dt,1/60))
		end
	end

	if deadCount >= MAXDEAD then 
		s3removeDead()
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

	--love.graphics.print("Attached to cam for reference", 30,30)

	-- need to determin drawing order which depends on y values of things

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
	-- love.graphics.print("Scene Placeholder", 10, 10)
	-- love.graphics.print(player1.position.x, 200, 10)
	-- love.graphics.print(player1.position.y, 220, 10)
	love.graphics.print(background.map.viewX..", "..background.map.viewY, 200, 10)
	jumperDebug.drawPath(font12, path, true)
	jumperDebug.drawPath(font12, _path, true)
end 

function s3removeDead() 
	for i, enemy in ipairs(enemies) do
		if ((not enemy.isalive) and enemy.counted) then
			table.remove(enemies, i)
			deadCount = deadCount - 1
			if deadCount <= MAXDEAD/2 then break end
		end
	end
end

function s3spawnEnemy()
	-- local totEnemy = #enemies
	-- local curDead = deadCount
	-- while totEnemy - curDead < 3 do
		insertEnemy({Vector(1900, 650)}, MOVETOSETSPOT)
		-- totEnemy = totEnemy+1
	-- end
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

	-- Restrict zoom level to camera boundaries --NEEDS WORK--
	-- if (y - ((dimScreen.y/2)*zoom)) < camTop then
	-- 	zoom = (2/dimScreen.y)*(camTop+y)
	-- end

	-- Zoom the cam to the appropriate level.
	cam:zoomTo(zoom)

	camWorldX = cam.x - (camWorldWidth / 2)
	camWorldY = cam.y - (camWorldHeight / 2)
	background.map:setDrawRange(camWorldX, camWorldY, camWorldWidth, camWorldHeight)
end

function state:mousepressed(x,y,button)
	if button == 'l' then
		--x,y = cam:worldCoords(x_, y_)
		tileX, tileY = background:toTile(x, y)
		x_, y_ = player1:getCenter()
		playerX, playerY = background:toTile(x_, y_)
		-- getPath doesn't work when zooming is involved atm
		path, length =pather:getPath(playerX, playerY, tileX, tileY)
	end
end
