-- Introduction sequence.
-- Will include some fancy scrolling text, maybe
-- some sweet ass animations, and badass music.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(32)
love.graphics.setFont( font)

Gamestate.intro = Gamestate.new()
local state = Gamestate.intro
local currentString = ""

function state:enter()
-- title graphics 
	titleScene = love.graphics.newImage("art/titleScene.png")		
	titleImage = love.graphics.newImage("art/title.png")
	drawTitle = false

-- extra char graphics/anims here
	drawMurderBaller = false
	murderBallerPos = Vector(400,500)
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

	stringTimer:add(5, function() 
				currentString = "A Crouching Guy Productions Picture Production" 
			end)


	stringTimer:add(10, function() 
				currentString = "in Association with Crazy Cup Entertainment Studios" 
			end)

	stringTimer:add(15, function() 
				currentString = "Based on a Youtube Sensation viewed by the guy from Crouching Guy Production Pictures" 
			end)

	stringTimer:add(20, function() 
				currentString = "...which was in turn adapted from some Turkish movie..." 
			end)

	stringTimer:add(23, function() 
				currentString = "...it's..." 
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
				camdz = 1
				camdx = 0
				cam:lookAt(player1.position.x+50, player1.position.y)
				cam:zoomTo(10)
			end)

	stringTimer:add(34, function()
				crispyAnim = player1.standAnim
				crispyForce = Vector(0,0)
			end)

	stringTimer:add(36, function()
				currentString = "Cisco as McGuff"
				state:zoomMcGuff()
			end)

	stringTimer:add(39, function()
				mcGuffAnim = player2.shootingAnim
					mcGuffForce = Vector(0,0)
				camdz = 1
				camdx = 0
				cam:lookAt(player2.position.x+50, player2.position.y)
				cam:zoomTo(10)

			end)

	stringTimer:add(40, function()
				mcGuffAnim = player2.standAnim
					
			end)



	-- 42
	stringTimer:add(42, function()
				currentString = "Murderballer #2 as Lloyd the Rat"
				cam:lookAt(murderBallerPos.x, murderBallerPos.y-50)
				cam:zoomTo(4)
				camdx = 0.5
				camdy = 0
				camdz = 1
				drawMurderBaller = true		
			end)

	stringTimer:add(45, function()
				currentString = "with guest appearances by"
				state:zoomToTitle()
			      --state:endAtTitle()
			end)


	stringTimer:add(46, function()
			murderBaller = murderBallerStandAnim
			camdx = 0
		end)


	stringTimer:add(49, function()
				state:zoomToTitle()
				currentString = "Wendell Pierce as Detective Bunk"
				drawMurderBaller = false
			end)

	stringTimer:add(54, function()
				currentString = "Drex Gillicudy as Pato"
			end)

	stringTimer:add(59, function()
				currentString = "Mr. T as Skinny Pete"
			end)
	

	stringTimer:add(64, function()
				currentString = "And a special guest appearance by..."
			end)


	stringTimer:add(66, function()
				currentString = "Barack Obama as himself"
			end)


	stringTimer:add(71, function()
			currentString = ""
			state:endAtTitle()
			end)
	
	stringTimer:add(73, function()
			crispyAnim = player1.standAnim
			mcGuffAnim = player2.standAnim	
			end)

	stringTimer:add(76, function()
				currentString = ""
			end)


	stringTimer:add(100, function()
			Gamestate.switch(Gamestate.menu)
		end)


	-- start music
	TEsound.play(bgMusicList, "bgMusic")
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
	
	if drawMurderBaller then
		murderBaller:update(dt)
	end

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

		if drawMurderBaller then
		murderBaller:drawf(murderBallerImage, 
			murderBallerPos.x,
			murderBallerPos.y,
			0, -- angle
			4, -- x scale
			4, -- y scale
			0, -- x offset
			0, -- y offset
			self.frameFlipH,
			self.frameFlipV
			)
		end
	


	-- draw the credits and other non-camera locked stuff here
	love.graphics.draw(self.explosion)
	love.graphics.printf( currentString, (dimScreen.x/2) - 200, (dimScreen.y/2)-100, 400, "center" )

	if drawTitle then
		love.graphics.draw(titleImage, (dimScreen.x/2) - 320 , (dimScreen.y/2)-220)
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

function state:zoomToTitle()
	camdx = 0
	camdy = 0
	camdz = 1.001
	cam:lookAt(dimScreen.x/2, dimScreen.y/2)
	cam:zoomTo(1)
end

function state:endAtTitle()
	cam:zoomTo(1)
	camdz = 1
	drawTitle = true
	player1:setPosition(Vector(300,900))
	crispyAnim = player1.shootingAnim
	player2:setPosition(Vector(350,1000))
	mcGuffAnim = player2.shootingAnim
end
