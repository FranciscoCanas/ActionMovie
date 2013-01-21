-- This is the template for a scene.

require "../level"

-- Required libraries that are locally used
local Camera = require "hump.camera"
local anim8 = require 'anim8.anim8'
local Jumper = require 'Jumper.jumper'
local jumperDebug = require 'Jumper.debug_utils'
local Timer = require "hump.timer"
require 'TESound.TEsound'

-- State declarations
Gamestate.scene2 = Gamestate.new()
local state = Gamestate.scene2
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
	TEsound.playLooping(bgMusicList, "bgMusic")
	
	-- initialize world here
	-- world:setGravity(0,9.8*love.physics.getMeter())
	-- Initialize players here
	if player1.isplaying then
		player1:setPosition(Vector(100,600))
	end
	if player2.isplaying then
		player2:setPosition(Vector(100,700)) 
	end

	loseString = "Lloyd the Rat got away!"
	drawLoseString = false

	-- set up camera ------------------------------------
	cam = Camera(
		dimScreen.x/2,
		dimScreen.y/2,
		--player1.body:getX(),
		--player1.body:getY(), 
		1, -- zoom level
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
	-- camera movement params --
	camdx = 15
	camdy = 0
	camdz = 1

	-- camera code ends here --
	self.started = true

	

	-- make objects in map solid
	background = Level("ep1", false)
	background:createObjects()

	-- Initializing Jumper
	searchMode = 'DIAGONAL' -- whether or not diagonal moves are allowed
	heuristics = {'MANHATTAN','EUCLIDIAN','DIAGONAL','CARDINTCARD'} -- valid distance heuristics names
	current_heuristic = 2 -- indexes the chosen heuristics within 'heuristics' table
	filling = false -- whether or not returned paths will be smoothed
	postProcess = false -- whether or not the grid should be postProcessed
	pather = Jumper(background.collisionMap) -- Inits Jumper
	pather:setMode(searchMode)
	pather:setHeuristic(heuristics[current_heuristic])
	pather:setAutoFill(filling)

	-- set up an event timer
	eventTimer = Timer.new()
	
	-- set up bullets table --
	bullets = {}
	
	-- set up some innocent bystanders here --
	bystanders = {}
--	table.insert(bystanders, Bystander(love.graphics.newImage('art/femaleBystander.png'), Vector(1000,800)))
--	bystanderPositions = {Vector(dimScreen.x,400), Vector(dimScreen.x,500), Vector(dimScreen.x,600)}
	bystanderTimer = Timer.new()
	bystanderTimer:addPeriodic(math.random(1,3), function()
		state:spawnBystanders()
		end)
	
	-- enemies here --
	enemies = {}
	enemiesPosition = {Vector(900, 600), Vector(600,700), Vector(700, 700)}
	deadCount = 0
--	insertEnemy(bystandersPosition, FOLLOWPLAYER)
	enemyTimer = Timer.new()
--	enemyTimer:addPeriodic(10, spawnEnemy)

	-- set up murderballer
	drawMurderBaller = true
	murderBallerPos = Vector(dimScreen.x - 152,600)
	murderBallerImage = love.graphics.newImage('art/murderballer.png')
	murderBallerGrid = Anim8.newGrid(52, 52, 
			murderBallerImage:getWidth(),
			murderBallerImage:getHeight())

	murderBallerRunAnim = Anim8.newAnimation('loop',
		murderBallerGrid('1-4, 1'),
		0.2) 

	murderBallerStandAnim = Anim8.newAnimation('loop',
		murderBallerGrid('1-4, 2'),
		0.2) 

	murderBaller = murderBallerRunAnim
	murderBallerDX = 0
end

function state:spawnBystanders()
	local posx, posy
	for i = 1,math.random(1,5),1 do 
		if math.random(1,2) == 1 then
			img = 'art/femaleBystander.png'
		else
			img = 'art/maleBystander.png'
		end

		posx = cam.x + dimScreen.x + math.random(400,800)
		posy = math.random(dimScreen.y, dimScreen.y+600)

		table.insert(bystanders, Bystander(love.graphics.newImage(img), Vector(posx, posy)))
	end
end

function state:removeBystanders()
	for i, bystander in ipairs(bystanders) do
		if outOfBounds(bystander) then
			table.remove(bystanders, i)
		end
	end
end

-- add an enemy at position x, y
function state:insertEnemy(positions, type) 
	for i, screenPos in ipairs(enemiesPosition) do 
		table.insert(enemies, Enemy(love.graphics.newImage('art/Enemy1Sprite.png'), screenPos, type))
	end
end

function state:leave()
	TEsound.stop("bgMusic", false) -- stop bg music immediately
	enemies = {}
	bullets = {}
	bystanders = {}
	bystanderTimer:clear()
	enemyTimer:clear()
end

function state:update(dt)
	-- Sound updates
	TEsound.cleanup()
	-- Update scene-related systems.
	world:update(math.min(dt, 1/60))
	--Timer.update(math.min(dt, 1/60))
	enemyTimer:update(math.min(dt, 1/60))
	bystanderTimer:update(math.min(dt, 1/60))
	
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(math.min(dt, 1/60))

		end
	end

	-- update the murderballer
	murderBallerPos.x = murderBallerPos.x + murderBallerDX
	murderBaller:update(math.min(dt, 1/60))
	
	for i,enemy in ipairs(enemies) do
		--print ("alive "..enemy.isalive.. " counted " .. enemy.counted)
		if ((not enemy.isalive) and (not enemy.counted)) then
			deadCount = deadCount + 1
			enemy.counted = true
		elseif (enemy.isalive) then
			enemy:update(math.min(dt,1/60))
		end
		enemy.animation:update(math.min(dt,1/60))
	end

	for i,bystander in ipairs(bystanders) do
		if bystander.isalive then
			bystander:update(math.min(dt,1/60))
			bystander.animation:update(math.min(dt,1/60))
		end	
	end
	
	for i,bullet in ipairs(bullets) do
		if bullet.impacted then 
			table.remove(bullets, i)
		else 
			bullet:update(math.min(dt,1/60))
		end
	end

	if deadCount >= MAXDEAD then 
		state:removeDead()
	end
	state:movecam() -- Update camera. See movecam func below.

	-- check for player loseage here
	if outOfBounds(player1) and outOfBounds(player2) then
		state:playersLose()
	end

end

function outOfBounds(p)
	return (p.position.x < (cam.x - dimScreen.x/2 - 200))
end

function state:draw()
	-- Anything drawn between camera attach and detach is drawn
	-- from camera perspective. 
	-- Game objects and anything in the scene's physical space
	-- will go here.
	cam:attach()	
	background:draw()

--	love.graphics.print("Attached to cam for reference", 30,30)

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
	
	

	for i,bystander in ipairs(bystanders) do
		bystander:draw()
	end
	cam:detach()

--	if drawMurderBaller then
		murderBaller:drawf(murderBallerImage, 
			murderBallerPos.x,
			murderBallerPos.y,
			0, -- angle
			1, -- x scale
			1, -- y scale
			0, -- x offset
			0, -- y offset
			false, -- h flip
			false -- v flip
			)
--		end
	-- lose string here
	if drawLoseString then
		love.graphics.printf( loseString, (dimScreen.x/2) - 200, (dimScreen.y/2)-100, 400, "center" )
	end
	-- Anything drawn out here is drawn according to screen
	-- perspective. 
	-- The HUD and any other overlays will go here.
	--love.graphics.print("Scene Placeholder", 10, 10)
	-- love.graphics.print(player1.position.x, 200, 10)
	-- love.graphics.print(player1.position.y, 220, 10)
	--love.graphics.print(player1.facing.x, 200, 30)
	--love.graphics.print(player1.facing.y, 210, 30)
	--love.graphics.print(player1.health, 50, 50)
	--love.graphics.print("clicked", 10, 70)
	--love.graphics.print(tileX or 0, 60, 70)
	--love.graphics.print(tileY or 0, 80, 70)
	--love.graphics.print("player1", 10, 90)
	--love.graphics.print(playerX or 0, 60, 90)
	--love.graphics.print(playerY or 0, 80, 90)
	--jumperDebug.drawPath(font12, path, true)
	love.graphics.print(cam.x, 5,5)
	love.graphics.print(cam.y, 50,5)

end 

function state:removeDead() 
	for i, enemy in ipairs(enemies) do
		if ((not enemy.isalive) and enemy.counted) then
			table.remove(enemies, i)
			deadCount = deadCount - 1
			if deadCount <= MAXDEAD/2 then break end
		end
	end
end

function state:spawnEnemy()
	local totEnemy = #enemies
	local curDead = deadCount
	while totEnemy - curDead < 3 do
		insertEnemy({Vector(800, 800)}, FOLLOWPLAYER)
		totEnemy = totEnemy+1
	end
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
	camWorldWidth = love.graphics.getWidth() / zoom
	camWorldHeight = love.graphics.getHeight() / zoom

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
		
	
	

	
	x = math.max(x, camLeft + (camWorldWidth / 2))
	x = math.min(x, camRight - (camWorldWidth / 2))

	y = math.max(y, camTop + (camWorldHeight / 2))
	y = math.min(y, camBottom - (camWorldWidth / 2))

	-- Move the cam to the coordinates calculated above.
	cam:lookAt(x, y)
	
	
	
	end

	if camstatic then
		cam:move(camdx / framesPerSecond,camdy / framesPerSecond)
		cam:zoom(camdz)
		-- Nothing to do here just yet.
	end
	-- Restrict zoom level to camera boundaries --NEEDS WORK--
	-- if (y - ((dimScreen.y/2)*zoom)) < camTop then
	-- 	zoom = (2/dimScreen.y)*(camTop+y)
	-- end

	-- Zoom the cam to the appropriate level.
	--cam:zoomTo(zoom)
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

function state:playersLose()
	-- do stuff here when players go out of cam bounds
	drawLoseString = true
	camdx = 0
	murderBallerPosDX = 1.5

	eventTimer:add(5, function()
			Gamestate.switch(Gamestate.menu)
		end)
end
