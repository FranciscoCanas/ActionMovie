-- This is the template for a scene --
require "../level"
require "../bomb"

-- Required libraries that are locally used
local Camera = require "hump.camera"
local anim8 = require 'anim8.anim8'
local Jumper = require 'Jumper.jumper'
jumperDebug = require 'Jumper.debug_utils'
local Timer = require "hump.timer"
require 'TESound.TEsound'


-- State declarations
Gamestate.scene3 = Gamestate.new()
local state = Gamestate.scene3
local keypressed = "none"

-- some fonts
font12 = love.graphics.newFont(12) 
font28 = love.graphics.newFont(28)

-- Stuffs local to scene
local MAXDEAD = 12
local MAXALIVE = 10

--bomb explodes after 5 minutes
Timers = {}
local minutes = 4
local seconds = 15

function state:init()	
	self.started = false
end

function state:enter()
	-- set up sound objects here
	bgMusicList = {"music/meanStreets.ogg"}
	TEsound.playLooping(bgMusicList, "stream")
	
	-- initialize world here
	-- world:setLinearAcceleration(0,9.8*love.physics.getMeter())
	-- Initialize players here
	if player1.isplaying then
		player1.body:setPosition(100, 600)
		player1.health = 10
		--player1:setPosition(Vector(100,600))
	end
	if player2.isplaying then
		player2.body:setPosition(100,700)
		player2.health = 10
		--player2:setPosition(Vector(100,700)) 
	end

	-- set up state.camera ------------------------------------
	state.cam = Camera(player1.position.x, player1.position.y, 
		2, -- zoom level
		0 -- rotation angle
		)
		
	state.camfollows = false -- follows players around.
	state.camstatic = true -- does not.
	state.camMaxZoom = 2.0
	state.camMinZoom = 0.5
	state.camZoomRatio = 500
	--boundaries for the state.camera
	state.camLeft = 0
	state.camRight = 2000
	state.camTop = 0
	state.camBottom = 1000
	-- state.camera code ends here --
	self.started = true
	
	

	-- make objects in map solid
	background = Level("ep1s3", false, state.cam)
	background:createObjects()

	-- Initializing Jumper
	searchMode = 'DIAGONAL' --'ORTHOGONAL' -- whether or not diagonal moves are allowed
	heuristics = {'MANHATTAN','EUCLIDIAN','DIAGONAL','CARDINTCARD'} -- valid distance heuristics names
	current_heuristic = 1 -- indexes the chosen heuristics within 'heuristics' table
	filling = false -- whether or not returned paths will be smoothed
	postProcess = false -- whether or not the grid should be postProcessed
	pather = Jumper(background.collisionMap) -- Inits Jumper
	pather:setMode(searchMode)
	pather:setHeuristic(heuristics[current_heuristic])
	pather:setAutoFill(filling)
	
	-- set up bullets table --
	bullets = {}

	-- set up the bomb
	bomb = {}
	bomb = Bomb(Vector(0, 368))
	
	-- get ready for some baddies here --
	enemies = {}
	deadCount = 0

	-- **** TO-DO (when have time): GET LEVEL.LUA TO GENERATE From Map Layers****
	-- tiled coordinates
	--(cover.x, cover.y, shoot.x, shoot.y, covered)
	movementPositions =  {
		--back column of possible cover
		{{31, 2, 31, 4, false}, {28, 8, 28, 6, false}, {30, 15, 30, 17, false}, {29, 21, 29, 19, false}},
		--second column of possible cover
		{{23, 2, 23, 4, false}, {22, 8, 22, 10, false}, {24, 15, 24, 13, false}, {21, 21, 21, 19, false}}, 
		--thrid column of possible cover before reaching player
		{{15, 2, 15, 4, false}, {16, 8, 16, 6, false}, {18, 15, 18, 13, false}, {13, 21, 13, 19, false}}
		} 

	-- Timer stuff
	Timers.countdown = Timer.new()	
	Timers.enemyTimer = Timer.new()
	Timers.enemyTimer:addPeriodic(5, s3spawnEnemy)
	Timers.countdown:addPeriodic(1, timed, 301)

	-- winning condition
	playersWin = false
end

-- function dispatchEnemies()
-- 	s3spawnEnemy()
-- end

function timed()
	if (seconds == 0 and minutes == 0) then
		state:playersWin(Gamestate.story4)
	elseif (seconds == 0) then
		seconds = 59
		minutes = minutes - 1
	else
		seconds = seconds - 1 
	end
end

-- add an enemy at position x, y
function state:insertEnemy(positions) 
	for i, screenPos in ipairs(positions) do 
		table.insert(enemies, Enemy(false, screenPos, MOVETOSETSPOT, true))
	end
end

function state:leave()
	TEsound.stop("stream", false) -- stop bg music immediately
	for i, enemy in ipairs(enemies) do
		if enemy.isalive then
			enemy.fixture:destroy()
		end
	end
	Timers.enemyTimer:clear()
	Timers.countdown:clear()
	bomb:reset()
end

function state:update(dt)
-- trying this frame limiter here
	frameLimiter(dt)

	-- Sound updates
	TEsound.cleanup()
	-- Update scene-related systems.
	world:update(math.min(dt, 1/60))
	background:update(math.min(dt,1/60))
	--Timer.update(math.min(dt, 1/60))
	Timers.enemyTimer:update(math.min(dt, 1/60))
	Timers.countdown:update(math.min(dt, 1/60))
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(math.min(dt, 1/60))
			defusing = isDefusing(player)
			if defusing then bomb:defuse(dt) 
				--else bomb:infuse(dt)
			end

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

	if not playersWin then
		if (bomb.health < 1 ) then 
			state:playersWin(Gamestate.story4a)
		end
	end
	state:movecam(dt) -- Update state.camera. See movestate.cam func below.
end

function state:draw()
	-- Anything drawn between state.camera attach and detach is drawn
	-- from state.camera perspective. 
	-- Game objects and anything in the scene's physical space
	-- will go here.
	state.cam:attach()	
	background:draw()

	--love.graphics.print("Attached to state.cam for reference", 30,30)

	bomb:draw()
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
	state.cam:detach()
	
	-- Anything drawn out here is drawn according to screen
	-- perspective. 
	-- The HUD and any other overlays will go here.
	-- love.graphics.print("Scene Placeholder", 10, 10)
	-- love.graphics.print(player1.position.x, 200, 10)
	-- love.graphics.print(player1.position.y, 220, 10)
	if (seconds < 10) then
		secondstr = "0"..seconds
	else
		secondstr = seconds
	end
	love.graphics.setFont( font28 )
	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Time Left\n    "..minutes..":"..secondstr, dimScreen.x/2-50, 10)
	love.graphics.setColor(255, 255, 255, 255)
	-- if defusing then
	-- 	love.graphics.print("defusing bomb \n "..bomb.health, bomb.position.x, bomb.position.y - 50)
	-- end

	drawHud(font12)
	jumperDebug.drawPath(font12, path, true)
	-- jumperDebug.drawPath(font12, _path, true)
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
	--spawn whenever there is more than one empty space in the first tier
		spawn = true
		local count = 0
		for i, position in ipairs(movementPositions[1]) do
			spawn = (spawn and position[5])
			if not position[5] then
				count = count + 1
			end
		end
		if not spawn and (#enemies - deadCount + count -2 <= MAXALIVE) then
			-- print(dimScreen.x..", "..dimScreen.y)
			-- table.insert(enemies, Enemy(false, Vector(state.cam.x + dimScreen.x + 500, math.random(450,1050)), MOVETOSETSPOT, true))
			-- table.insert(enemies, Enemy(false, Vector(state.cam.x + dimScreen.x + 500, math.random(450,1050)), MOVETOSETSPOT, true))
			-- table.insert(enemies, Enemy(false, Vector(state.cam.x + dimScreen.x + 500, math.random(450,1050)), MOVETOSETSPOT, true))
		--*******
			for i = 2, count, 1 do
				state:insertEnemy({Vector(state.cam.x + dimScreen.x + 500, math.random(450,1050))})
			end
		--******
		-- else
		-- 	break
		end
	-- end
end

function isDefusing(player)
	return ((player.animation == player.standAnim) and (math.abs(player.position.x - bomb.position.x) < 30) 
		and (math.abs(player.position.y - bomb.position.y) < 30))
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
		
	end
	if state.camstatic then
		-- Nothing to do here just yet.
	end

	
	state.camWorldWidth = love.graphics.getWidth() / zoom
	state.camWorldHeight = love.graphics.getHeight() / zoom
	
	x = math.max(x, state.camLeft + (state.camWorldWidth / 2))
	x = math.min(x, state.camRight - (state.camWorldWidth / 2))

	y = math.max(y, state.camTop + (state.camWorldHeight / 2))
	y = math.min(y, state.camBottom - (state.camWorldWidth / 2))

	-- Move the state.cam to the coordinates calculated above.
	state.cam:lookAt(x, y)

	-- Restrict zoom level to state.camera boundaries --NEEDS WORK--
	-- if (y - ((dimScreen.y/2)*zoom)) < state.camTop then
	-- 	zoom = (2/dimScreen.y)*(state.camTop+y)
	-- end

	-- Zoom the state.cam to the appropriate level.
	state.cam:zoomTo(zoom)

	state.camWorldX = state.cam.x - (state.camWorldWidth / 2)
	state.camWorldY = state.cam.y - (state.camWorldHeight / 2)
	background.map:setDrawRange(state.camWorldX, state.camWorldY, state.camWorldWidth, state.camWorldHeight)
	
	if isGameOver then
        gameovercam(state.cam)
    end
end

function state:playersWin(story)
    playersWin = true
	TEsound.stop("stream", false) -- stop bg music immediately
	TEsound.play("music/actionHit.ogg")     
    Gamestate.switch(story) 
end