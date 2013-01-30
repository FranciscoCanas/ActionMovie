-- Story cutscene/sequence.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(28)
local font36 = love.graphics.setNewFont(36)


Gamestate.story4 = Gamestate.new()
local state = Gamestate.story4
local currentString = ""
local currentStringNum = 0
local diagInterval = 5
local dialogue = {	
            "Oh no, the bomb is about to go--",
            "Will Crispy and McGuff escape the explosion in time to save the president?!",
            "Tune in next week, and find out!"
			}
    
			
local currentShot = 0
local shotFuncs = {
        function() player2.animation=player2.standAnim
            state:closeUp(player2)
        end,
		function() state:bothPlayers()
            state.camdz=1.0001
            state:explode()
        player1.animation = player1.hurtAnim
        player2.animation = player1.hurtAnim
			TEsound.play("music/actionHit.ogg")  
        end,
        function() 
            drawContinue = true
        end
	}

function state:enter()
love.graphics.setFont(font)
-- musics
	bgMusicList = {"music/movemberBlues.ogg"}
-- start music
--	TEsound.play(bgMusicList, "bgMusic")

-- background
	alleyScene = love.graphics.newImage("art/titleScene.png")
    cityScene = love.graphics.newImage("art/cityscape.png")
    backgroundScene = alleyScene

-- players
	player1:setPosition(Vector(400,500))
	player2:setPosition(Vector(470,500))
	player2.facing = Vector(-1,0)
	player2.frameFlipH = true

	
--	murderballer = Murderballer()
--    murderballer.position = Vector(445, 518)

-- timer stuff
	stringTimer = Timer.new()

-- string stuff
    currentStringNum = 0
    currentShot = 0
	drawContinue = false

-- state.camera setup
-- set up state.camera ------------------------------------
	state.cam = Camera(
		player1.position.x + 50, 
		player1.position.y,  
		10, -- zoom level
		0 -- rotation angle
		)

	state.camdx = 0 -- state.camera x panning rate
	state.camdy = 0
	state.camdz = 1


	
	
	-- init state.camera and diag here
	state:nextLine()
	state:nextShot()
	
	-- extra char graphics/anims here

-- particle sys stuff go here now!
	explosionImage = love.graphics.newImage( "art/explosion.png" )
	state.explosion = love.graphics.newParticleSystem( explosionImage, 500 )
	state.explosion:setEmissionRate(60)
	state.explosion:setLifetime(10.0)
	state.explosion:setParticleLife(10)
	state.explosion:setSpread(360)
	state.explosion:setSizes(4, 6.5, 8.0)
	state.explosion:setRotation(60)
	state.explosion:setSpeed(350,550)
	state.explosion:setSpin(0,1,0.5)
	state.explosion:setPosition(400, 400)
	state.explosion:stop()
end

function state:nextLine()
		stringTimer:clear()

			currentStringNum = currentStringNum + 1			
			currentString = dialogue[currentStringNum]

		stringTimer:add(diagInterval, function()
			if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.scene3)
			else
			state:nextLine()
			state:nextShot()
			end
		end)
end

function state:nextShot()
	currentShot = currentShot + 1
	if currentShot <= table.getn(shotFuncs) then
		shot = shotFuncs[currentShot]	
		shot()
	end
end

function state:update(dt)
-- trying this frame limiter here
	frameLimiter(dt)

	dt = math.min(dt, 1/60)
	stringTimer:update(dt)
--	player1:update(dt)
--	player2:update(dt)
	state.cam:move(state.camdx*dt,state.camdy*dt)
	state.cam:zoom(state.camdz)
	state.explosion:update(dt)
--	murderballer:update(dt)
end


function state:draw()

	state.cam:attach()	
	love.graphics.draw(backgroundScene, 0,0)
	love.graphics.draw(state.explosion)
	-- draw stuff that's state.camera locked here
	player1:draw()
	player2:draw()
--	murderballer:draw()
	state.cam:detach()	
	
	-- cinematic letterboxing here
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill", 0, 0, dimScreen.x, 150)
	love.graphics.rectangle("fill", 0, dimScreen.y - 150, dimScreen.x, 150)
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.printf( currentString, (dimScreen.x/2) - 400, (dimScreen.y)-150, 800, "center" )
    if drawContinue then
        love.graphics.setColor(255,0,0,255)
        love.graphics.setFont(font36)
        love.graphics.printf( "To Be Continued", dimScreen.x/2 - 200, dimScreen.y/2 - 50, 400, "center")
        love.graphics.setFont(font)
        love.graphics.setColor(255,255,255,255)
    end
end

function state:leave()
	stringTimer:clear()
	TEsound.stop("bgMusic", false) -- stop bg music immediately
end

function state:keyreleased(key)
	if key == "escape" then
		-- quits to menu
		Gamestate.switch(Gamestate.menu)
	elseif key == " " or key=="return" then
		-- (space) skips to main scene1
		Gamestate.switch(Gamestate.credits)
	elseif key == player1.keyfire or key == player2.keyfire then
		-- skip to next line in diag
		if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.credits)
		else
			state:nextLine()
			state:nextShot()
		end
	end	
end

function state:startingShot()
	state.cam:lookAt(600,400)
	state.cam:zoomTo(1)
end


function state:closeUp(p)
	state.cam:lookAt(p.position.x + 25, p.position.y + 15)
	state.cam:zoomTo(16)
end

function state:shot2()
	state.cam:lookAt(player2.position.x + 30, player2.position.y+30)
	state.cam:zoomTo(12)
end

function state:bothPlayers()
	state.cam:lookAt(player1.position.x + 70, player1.position.y+30)
	state.cam:zoomTo(8)	
end

function state:explode()
	state.explosion:start()
end

