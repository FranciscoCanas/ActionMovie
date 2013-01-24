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

	-- set up state.camera --
	state.cam = Camera(
		dimScreen.x/2,
		dimScreen.y/2,
		--player1.body:getX(),
		--player1.body:getY(), 
		1, -- zoom level
		0 -- rotation angle
		)
		
	state.camfollows = false -- follows players around.
	state.camstatic = false -- does not.
	state.camOnMurderballer = true
	state.camMaxZoom = 2.0
	state.camMinZoom = 0.5
	state.camZoomRatio = 500
	--boundaries for the state.camera
	state.camLeft = 0
	state.camRight = 2000
	state.camTop = 0
	state.camBottom = 1000
	-- state.camera movement params --
	state.camdx = 0
	state.camdy = 0
	state.camdz = 1

	-- state.camera code ends here --
	self.started = true

	

	-- make objects in map solid
	background = Level("ep1", false, state.cam)
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

	--set up murderballer
	murderballer = Murderballer()
	murderballer.position = Vector(dimScreen.x - 152, 600)
	murderballer.animation = murderballer.runAnim
	murderballer.delta = Vector(50,0)
end

function state:spawnBystanders()
	local posx, posy
	for i = 1,math.random(1,5),1 do 
		if math.random(1,2) == 1 then
			img = 'art/femaleBystander.png'
		else
			img = 'art/maleBystander.png'
		end

		posx = state.cam.x + dimScreen.x + math.random(400,800)
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
-- trying this frame limiter here
	frameLimiter(dt)

	dt = math.min(dt,1/60)
	-- Sound updates
	TEsound.cleanup()
	-- Update scene-related systems.
	world:update(dt)
	--Timer.update(math.min(dt, 1/60))
	enemyTimer:update(dt)
	bystanderTimer:update(dt)
	
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(dt)
		end
	end

	-- update the murderballer
	murderballer:update(dt)
	
	for i,enemy in ipairs(enemies) do
		--print ("alive "..enemy.isalive.. " counted " .. enemy.counted)
		if ((not enemy.isalive) and (not enemy.counted)) then
			deadCount = deadCount + 1
			enemy.counted = true
		elseif (enemy.isalive) then
			enemy:update(dt)
		end
		enemy.animation:update(dt)
	end

	for i,bystander in ipairs(bystanders) do
		if bystander.isalive then
			bystander:update(dt)
			bystander.animation:update(dt)
		end	
	end
	
	for i,bullet in ipairs(bullets) do
		if bullet.impacted then 
			table.remove(bullets, i)
		else 
			bullet:update(dt)
		end
	end

	if deadCount >= MAXDEAD then 
		state:removeDead()
	end
	state:movecam(dt) -- Update state.camera. See movestate.cam func below.

	-- check for player loseage here
	if state:outOfBounds(player1) and outOfBounds(player2) then
		state:playersLose()
	end

end

function state:outOfBounds(p)
	return (p.position.x < (state.cam.x - dimScreen.x/2 - 200))
end

function state:draw()
	-- Anything drawn between state.camera attach and detach is drawn
	-- from state.camera perspective. 
	-- Game objects and anything in the scene's physical space
	-- will go here.
	state.cam:attach()	
	background:draw()

--	love.graphics.print("Attached to state.cam for reference", 30,30)

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
	state.cam:detach()

--	if drawMurderBaller then
		murderballer:draw()
--		end
	-- lose string here
	if drawLoseString then
		love.graphics.printf( loseString, (dimScreen.x/2) - 200, (dimScreen.y/2)-100, 400, "center" )
	end
	-- Anything drawn out here is drawn according to screen
	-- perspective. 
	-- The HUD and any other overlays will go here.
	love.graphics.print(state.cam.x, 5,5)
	love.graphics.print(state.cam.y, 50,50)
	love.graphics.print(murderballer.position.x - state.cam.x, 600,5)
	love.graphics.print(murderballer.position.y, 600,50)

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

function state:movecam(dt)
	local x, y = 0,0
	local dist
	local zoom = 1
	state.camWorldWidth = love.graphics.getWidth() / zoom
	state.camWorldHeight = love.graphics.getHeight() / zoom

	-- Code to move the state.camera around.
	if state.camfollows then
		-- Camera sticks to the midpoint between the two players if 
		-- both are playing, zooming out and in as necessary. 
		-- Otherwise it just follows the single player.
		if player1.isplaying and player2.isplaying then
			x = (player1.position.x + player2.position.x) / 2
			y = (player1.position.y + player2.position.y) / 2
			dist = (player1.position - player2.position):len()
			zoom = state.camZoomRatio / dist 
			if zoom > state.camMaxZoom then zoom = state.camMaxZoom end
			if zoom < state.camMinZoom then zoom = state.camMinZoom end
		elseif player1.isplaying and (not player2.isplaying) then
			x = player1.position.x
			y = player1.position.y
		elseif player2.isplaying and (not player1.isplaying) then
			x = player2.position.x
			y = player2.position.y
		end
		
	
	

	
		x = math.max(x, state.camLeft + (state.camWorldWidth / 2))
		x = math.min(x, state.camRight - (state.camWorldWidth / 2))

		y = math.max(y, state.camTop + (state.camWorldHeight / 2))
		y = math.min(y, state.camBottom - (state.camWorldWidth / 2))

		-- Move the state.cam to the coordinates calculated above.
		state.cam:lookAt(x, y)
	
	
	
	end

--	if state.camstatic then
--		state.cam:move(state.camdx * dt,state.camdy * dt)
--		state.cam:zoom(state.camdz)
		-- Nothing to do here just yet.
--	end
	
	if state.camOnMurderballer then
		state.cam:lookAt(murderballer.position.x - (dimScreen.x/2) - 100, dimScreen.y/2)
		state.cam:zoomTo(1)
	end
	-- Restrict zoom level to state.camera boundaries --NEEDS WORK--
	-- if (y - ((dimScreen.y/2)*zoom)) < state.camTop then
	-- 	zoom = (2/dimScreen.y)*(state.camTop+y)
	-- end

	-- Zoom the state.cam to the appropriate level.
	--state.cam:zoomTo(zoom)
	state.camWorldX = state.cam.x - (state.camWorldWidth / 2)
	state.camWorldY = state.cam.y - (state.camWorldHeight / 2)
	background.map:setDrawRange(state.camWorldX, state.camWorldY, state.camWorldWidth, state.camWorldHeight)
end

function state:mousepressed(x,y,button)
	if button == 'l' then
		--x,y = state.cam:worldCoords(x_, y_)
		tileX, tileY = background:toTile(x, y)
		x_, y_ = player1:getCenter()
		playerX, playerY = background:toTile(x_, y_)
		-- getPath doesn't work when zooming is involved atm
		path, length =pather:getPath(playerX, playerY, tileX, tileY)
	end
end

function state:playersLose()
	-- do stuff here when players go out of state.cam bounds
	drawLoseString = true
	state.camdx = 0
	murderBallerPosDX = 1.5

	eventTimer:add(3, function()
			Gamestate.switch(Gamestate.menu)
		end)
end
