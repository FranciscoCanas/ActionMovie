-- Introduction sequence.
-- Will include some fancy scrolling text, maybe
-- some sweet ass animations, and badass music.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(24)
love.graphics.setFont( font)

Gamestate.intro = Gamestate.new()
local state = Gamestate.intro
local currentString = ""

function state:enter()
-- title graphics 
	titleScene = love.graphics.newImage("art/titleScene.png")		
	titleImage = love.graphics.newImage("art/title.png")
	drawTitle = false

-- particle sys stuff go here now!
	explosionImage = love.graphics.newImage( "art/explosion.png" )
	self.explosion = love.graphics.newParticleSystem( explosionImage, 500 )
	self.explosion:setEmissionRate(60)
	self.explosion:setLifetime(1.0)
	self.explosion:setParticleLife(10)
	self.explosion:setSpread(360)
	self.explosion:setSizes(4, 6.5, 8.0)
	self.explosion:setRotation(60)
	self.explosion:setSpeed(350,550)
	self.explosion:setSpin(0,1,0.5)
	self.explosion:setPosition(dimScreen.x/2, dimScreen.y/2)
	self.explosion:stop()

-- set up props here (like sprites and such)
--	player1:setPosition(Vector(400, 500))
--	player2.setPosition(Vector(600, 600))
	mcGuffForce = Vector(0,0)
	crispyForce = Vector(0,0)
	mcGuffAnim = player2.standAnim
	crispyAnim = player1.standAnim

-- set up camera ------------------------------------
	cam = Camera(dimScreen.x/2, 400, 
		1, -- zoom level
		0 -- rotation angle
		)

	camdx = 0.5 -- camera x panning rate
	camdy = 0
	camdz = 1

-- set up sound objects here
	stringTimer = Timer.new()
	bgMusicList = {"music/actionMovie.ogg"}
	p = 0
					
	stringTimer:add(0, function() 
				currentString = "Crouching Guy Pictures Presents" 
			end)

	stringTimer:add(7, function() 
				currentString = "A Crouching Guy Productions Picture Production" 
			end)


	stringTimer:add(14, function() 
				currentString = "in Association with ..." 
			end)

	stringTimer:add(20, function() 
				currentString = "Based on a Youtube Sensation viewed by a guy from Crouching Guy Production Pictures" 
			end)

	-- around 26.5 or so
	stringTimer:add(24.5, function()
				camdx = 0
				state:titleExplosion()
				currentString = ""
			end)

	stringTimer:add(30, function()
				drawTitle = false
				currentString = "Starring Chun Chi Sham as Crispy"
				state:zoomCrispy()
			end)

	stringTimer:add(33, function()
				crispyAnim = player1.shootingAnim
				crispyForce = Vector(0,0)
			end)

	stringTimer:add(34, function()
				crispyAnim = player1.standAnim
				crispyForce = Vector(0,0)
			end)

	stringTimer:add(36, function()
				currentString = "Cisco as McGuff"
				state:zoomMcGuff()
			end)

	stringTimer:add(38, function()
				mcGuffAnim = player2.shootingAnim
					mcGuffForce = Vector(0,0)
			end)

	stringTimer:add(39, function()
				mcGuffAnim = player2.standAnim
					
			end)


	stringTimer:add(42, function()
				currentString = ""
				drawTitle = true
				state:zoomOldie()
				state:endAtTitle()
			end)


	stringTimer:add(43, function()
			crispyAnim = player1.standAnim
			mcGuffAnim = player2.standAnim	
			end)

	


	-- start music
	TEsound.playLooping(bgMusicList, "bgMusic")
end

function state:leave()
	TEsound.stop("bgMusic", false) -- stop bg music immediately
end

function state:update(dt)
	dt = math.min(dt, 1/60)
	world:update(dt)

	stringTimer:update(dt)

	player1:update(dt)
	player1.animation = crispyAnim
	player1.body:applyForce(crispyForce.x, crispyForce.y)
	player1.animation:update(dt)
	player2:update(dt)
	player2.animation = mcGuffAnim
	player2.body:applyForce(mcGuffForce.x, mcGuffForce.y)
	player2.animation:update(dt)
	
	cam:move(camdx,camdy)
	cam:zoom(camdz)
	state.explosion:update(dt)
end

function state:draw()


	cam:attach()	
	love.graphics.draw(titleScene, 0,0)
	-- draw stuff that's camera locked here
	player1:draw()
	player2:draw()
	
	cam:detach()	

	-- draw the credits and other non-camera locked stuff here
	love.graphics.draw(self.explosion)
	love.graphics.printf( currentString, (dimScreen.x/2) - 125, (dimScreen.y/2)-20, 250, "center" )

	if drawTitle then
		love.graphics.draw(titleImage, (dimScreen.x/2) - 320 , (dimScreen.y/2)-240)
	end
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		love.event.push("quit")
	elseif key == " " or key=="return" then
		-- (space) skips to main menu
		Gamestate.switch(Gamestate.menu)
	end	
end

function state:titleExplosion()
	self.explosion:start()
	drawTitle = true
end

function state:zoomCrispy()
	crispyForce = Vector(2000,0)
	camdx = 0.5
	camdz = 1.001
	cam:lookAt(player1.position.x+35, player1.position.y)
	cam:zoomTo(5)
	crispyAnim = player1.runAnim
end

function state:zoomMcGuff()
	mcGuffForce = Vector(2000,0)
	camdx = 0.5
	camdz = 1.001
	cam:lookAt(player2.position.x+35, player2.position.y)
	cam:zoomTo(5)
	mcGuffAnim = player2.runAnim
end

function state:zoomOldie()
	camdx = 0
	camdy = 0
	camdz = 1.001
	cam:lookAt(dimScreen.x/2, dimScreen.y/2)
	cam:zoomTo(1)
end

function state:endAtTitle()
	player1:setPosition(Vector(300,900))
	crispyAnim = player1.shootingAnim
	player2:setPosition(Vector(350,1000))
	mcGuffAnim = player2.shootingAnim
end
