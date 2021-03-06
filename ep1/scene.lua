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
Gamestate.scene = Gamestate.new()
local state = Gamestate.scene
local keypressed = "none"

-- some fonts
font12 = love.graphics.newFont(12) 
font16 = love.graphics.newFont(16)
font28 = love.graphics.newFont(28)

-- Stuffs local to scene
local MAXDEAD = 32
local TARGETDEAD = 20 -- end scene once we kill this many dudes


function state:init()	
	self.started = true
    self.ended = false
end

function state:enter()
	-- set up sound objects here
	bgMusicList = {"music/meanStreets.ogg"}
	TEsound.playLooping(bgMusicList, "stream")
	
	-- initialize world here
	-- world:setLinearAcceleration(0,9.8*love.physics.getMeter())
	-- Initialize players here
	if player1.isplaying then
		player1:setPosition(Vector(100,600))
	end
	if player2.isplaying then
		player2:setPosition(Vector(100,700)) 
	end

	-- set up state.camera ------------------------------------
	state.cam = Camera(player1.position.x, player1.position.y, 
		1, -- zoom level
		0 -- rotation angle
		)
		
	state.camfollows = true -- follows players around.
	state.camstatic = false -- does not.
	state.camMaxZoom = 1.1
	state.camMinZoom = 0.9
	state.camZoomRatio = 400
	--boundaries for the state.camera
	state.camLeft = 0
	state.camRight = 6500
	state.camTop = 0
	state.camBottom = 1000
	-- camera code ends here --
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
	
	-- set up bullets table --
	bullets = {}
	
	-- set up some baddies here --
	enemies = {}
--	enemiesPosition = {Vector(state.cam.x + 900, 600), Vector(state.cam.x + 600,700), Vector(state.cam.x + 700, 700)}
	deadCount = 0
--	state:insertEnemy(enemiesPosition, FOLLOWPLAYER)
	enemyTimer = Timer.new()
	enemyTimer:addPeriodic(2, function() 
                self:spawnEnemy() 
         end)
	
	eventTimer = Timer.new()
end

-- add an enemy at position x, y
function state:insertEnemy(positions, type) 
	for i, screenPos in ipairs(positions) do 
		table.insert(enemies, Enemy(false, screenPos, type))
	end
end

function state:leave()
	TEsound.stop("stream", false) -- stop bg music immediately
	enemies = {}
	bullets = {}
	enemyTimer:clear()
	eventTimer:clear()
end

function state:update(dt)
-- trying this frame limiter here
	frameLimiter(dt)
	dt = math.min(dt, 1/60)
	-- Sound updates
	TEsound.cleanup()
	-- Update scene-related systems.

	world:update(dt)
	background:update(dt)
	--Timer.update(math.min(dt, 1/60))
	enemyTimer:update(dt)
	eventTimer:update(dt)
	
	-- check for scene beaten conditions
    if not self.ended then
       
	    if (deadCount >= TARGETDEAD) then
            local alldead = true
		    enemyTimer:clear()
            for i,enemy in ipairs(enemies) do
                if enemy.isalive then 
                    alldead = false
                end
            end
            if alldead then
                self.ended = true
            	TEsound.stop("stream", false) -- stop bg music immediately
			    TEsound.play("music/actionHit.ogg")
           		eventTimer:add(3, function() Gamestate.switch(Gamestate.story2) end)
            end
	    end
	
	end
	-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying then
			player:update(dt)

		end
	end
	
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
	state:movecam(dt) -- Update camera. See movecam func below.

end

function state:draw()
	-- Anything drawn between camera attach and detach is drawn
	-- from camera perspective. 
	-- Game objects and anything in the scene's physical space
	-- will go here.
	state.cam:attach()	
	background:draw()

--	love.graphics.print("Attached to cam for reference", 30,30)

	-- need to determin drawing order which depends on y values of things
	for i,enemy in ipairs(enemies) do
		enemy:draw()
	end
	
	for i,bullet in ipairs(bullets) do
		bullet:draw()
	end
	
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
	
	
	state.cam:detach()

	love.graphics.setFont( font28 )
    love.graphics.print("Bad Guys Left \n         "..TARGETDEAD-deadCount, dimScreen.x/2-90, 10)
	-- Anything drawn out here is drawn according to screen
	-- perspective. 
	-- The HUD and any other overlays will go here.

	drawHud(font12)
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
    if (# enemies) >= TARGETDEAD then
        return
    end
	local totEnemy = #enemies
	local curDead = deadCount
    local spawnVector = {}
    local posx, posy = state.cam:worldCoords(state.cam.x, state.cam.y)
	while totEnemy - curDead < 3 do
        table.insert(spawnVector, Vector((posx + math.random(dimScreen.x+200,dimScreen.x+600)), 800 + math.random(100, dimScreen.y-100)))
		totEnemy = totEnemy+1
	end
	state:insertEnemy(spawnVector, FOLLOWPLAYER, true)
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
	
	-- Code to move the camera around.
	if state.camfollows then
		-- state.camera sticks to the midpoint between the two players if 
		-- both are playing, zooming out and in as necessary. 
		-- Otherwise it just follows the single player.
		if player1.isplaying and player2.isplaying then
			x = ((player1.position.x + player2.position.x) / 2) + (dimScreen.x/2 - 100)
			y = (player1.position.y + player2.position.y) / 2
			dist = (player1.position - player2.position):len()
			zoom = state.camZoomRatio / dist 
			if zoom > state.camMaxZoom then zoom = state.camMaxZoom end
			if zoom < state.camMinZoom then zoom = state.camMinZoom end
		elseif player1.isplaying and (not player2.isplaying) then
			x = player1.position.x + dimScreen.x/2 - 100
			y = player1.position.y
		elseif player2.isplaying and (not player1.isplaying) then
			x = player2.position.x + dimScreen.x/2 - 100
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

	y = math.max(y, state.camTop + (state.camWorldHeight / 2) - 50)
	y = math.min(y, state.camBottom - (state.camWorldWidth / 2))

	-- Move the cam to the coordinates calculated above.
	state.cam:lookAt(x, y)

	-- Zoom the cam to the appropriate level.
	state.cam:zoomTo(zoom)

	state.camWorldX = state.cam.x - (state.camWorldWidth / 2)
	state.camWorldY = state.cam.y - (state.camWorldHeight / 2)
	background.map:setDrawRange(state.camWorldX, state.camWorldY, state.camWorldWidth, state.camWorldHeight)

    if isGameOver then
        gameovercam(state.cam)
    end
end
