-- Introduction sequence.
-- Will include some fancy scrolling text, maybe
-- some sweet ass animations, and badass music.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(32)


Gamestate.intro = Gamestate.new()
local state = Gamestate.intro
local currentString = ""
local currentStringPos = Vector((dimScreen.x/2) - 200, (dimScreen.y/2)-100)

function state:enter()
-- set the font here
love.graphics.setFont( font)
-- title graphics 
	titleScene = love.graphics.newImage("art/titleScene.png")		
	titleImage = love.graphics.newImage("art/title.png")
	drawTitle = false

-- extra char graphics/anims here
	murderballer = {}

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
	
	e1 = Enemy(love.graphics.newImage('art/Enemy1Sprite.png'),Vector(2800,420),MOVETOSETSPOT,false)
	e2 = Enemy(love.graphics.newImage('art/Enemy1SpriteB.png'),Vector(2900,420),MOVETOSETSPOT, false)
	e3 = Enemy(love.graphics.newImage('art/Enemy1SpriteC.png'),Vector(3000,420),MOVETOSETSPOT, false)

	

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

-- set up state.camera ------------------------------------
	state.cam = Camera(dimScreen.x/2, 400, 
		1, -- zoom level
		0 -- rotation angle
		)

	state.camdx = 15 -- state.camera x panning rate per 30 frames
	state.camdy = 0
	state.camdz = 1

-- set up sound objects here
	stringTimer = Timer.new()
	bgMusicList = {"music/actionMovie.ogg"}
	p = 0
					
	stringTimer:add(0, function() 
				currentString = "Crouching Guy Pictures Presents" 
			end)

	stringTimer:add(6, function() 
				currentString = "A Crouching Guy Productions Picture Production" 
			end)


	stringTimer:add(12, function() 
				currentString = "in Association with Crazy Cup Entertainment Studios" 
			end)

	stringTimer:add(18, function() 
				currentString = "Based on a youtube sensation viewed by the guy from Crouching Guy Production Pictures" 
			end)

	stringTimer:add(24, function() 
				currentString = "and adapted from some movie" 
			end)

	stringTimer:add(30, function() 
				currentString = "it's" 
			end)


	-- around 32.75 or so
	stringTimer:add(33, function()
				state.camdx = 0
				state:titleExplosion()
				currentString = ""
			end)

	stringTimer:add(37, function()
				drawTitle = false
				
				state:zoomCrispy()
			end)

	stringTimer:add(39, function()
				crispyAnim = player1.shootingAnim
				crispyForce = Vector(0,0)
				state.camdz = 1
				state.camdx = 0
				state.cam:lookAt(player1.position.x+50, player1.position.y)
				state.cam:zoomTo(10)
			end)

	stringTimer:add(40, function()
				currentString = "Starring Chi as Detective Crispy"
				crispyAnim = player1.standAnim
				state:closeUp(player1)
				crispyForce = Vector(0,0)
			end)

	stringTimer:add(43, function()
				currentString = ""
				state:zoomMcGuff()
			end)

	stringTimer:add(45, function()
				mcGuffAnim = player2.shootingAnim
					mcGuffForce = Vector(0,0)
				state.camdz = 1
				state.camdx = 0
				state.cam:lookAt(player2.position.x+50, player2.position.y)
				state.cam:zoomTo(10)

			end)

	stringTimer:add(46, function()
				mcGuffAnim = player2.standAnim					
				currentString = "Cisco as McGuff: P.I."
				state:closeUp(player2)
			end)



	-- 42
	stringTimer:add(49, function()
				currentString = ""
				state.cam:lookAt(murderBallerPos.x, murderBallerPos.y-50)
				state.cam:zoomTo(4)
				state.camdx = 15
				state.camdy = 0
				state.camdz = 1
				drawMurderBaller = true		
			end)

	


	stringTimer:add(51, function()
			currentString = "Murderballer #2 as Lloyd the Rat"
			murderBaller = murderBallerStandAnim
--			murderballer.position = Vector(murderBallerPos.x, murderBallerPos.y)
--			state:closeUp(murderballer)
			state.cam:zoomTo(6)
			state.camdx = 0
			state.camdz = 1
			state.camdy = 0
		end)
		
	stringTimer:add(55, function()
				currentString = "with Griff Peterson as \"Burgertime\""
				state:bodyShot(e1)
				e1.animation = e1.shootAnim
				drawMurderBaller = false
			      --state:endAtTitle()
			end)
			
	stringTimer:add(56, function()
		e1.animation = e1.standAnim
	end)

	stringTimer:add(59, function()
		currentString = "P. Tear Griffon as \"Limpy\""
		state:bodyShot(e2)
		e2.animation = e2.shootAnim
	
		  --state:endAtTitle()
	end)
	
	stringTimer:add(60, function()
		e2.animation = e2.standAnim
	end)
	
	stringTimer:add(64, function()
		currentString = "Professor Griffy McPeterly as \"Disco Lex\""
		state:bodyShot(e3)
		e3.animation = e3.shootAnim
	end)

	stringTimer:add(65, function()
		e3.animation = e3.runAnim
	end)

	stringTimer:add(67, function()
		e3.frameFlipH = true
	end)

	stringTimer:add(68.5, function()
		e3.frameFlipH = false
	end)


	stringTimer:add(70, function()
		currentString = ""
		state:startingShot()
		state.camdz = 1.001
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
-- trying this frame limiter here
	frameLimiter(dt)
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
	--e1:update(dt)
	e1.animation:update(dt)
	--e1:update(dt)
	e2.animation:update(dt)
	--e1:update(dt)
	e3.animation:update(dt)
	
	if drawMurderBaller then
		murderBaller:update(dt)
	end

	state.cam:move((state.camdx * (dt)), state.camdy * (dt))
	state.cam:zoom(state.camdz)
	state.explosion:update(dt)
end

function state:draw()


	state.cam:attach()	
	love.graphics.draw(titleScene, 0,0)
	-- draw stuff that's state.camera locked here
	player1:draw()
	player2:draw()
	e1:draw()
	e2:draw()
	e3:draw()
	state.cam:detach()	

		if drawMurderBaller then
		murderBaller:drawf(murderBallerImage, 
			murderBallerPos.x,
			murderBallerPos.y,
			0, -- angle
			4, -- x scale
			4, -- y scale
			0, -- x offset
			0, -- y offset
			false, -- H flip
			false -- V flip
			)
		end
	


	-- draw the credits and other non-state.camera locked stuff here
	love.graphics.draw(self.explosion)
	love.graphics.printf( currentString, currentStringPos.x, currentStringPos.y, 400, "center" )

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
	state.camdx = 15
	state.camdz = 1.001
	state.cam:lookAt(player1.position.x+35, player1.position.y)
	state.cam:zoomTo(5)
	crispyAnim = player1.runAnim
end

function state:zoomMcGuff()
	mcGuffForce = Vector(2000,0)
	state.camdx = 15
	state.camdz = 1.001
	state.cam:lookAt(player2.position.x+35, player2.position.y)
	state.cam:zoomTo(5)
	mcGuffAnim = player2.runAnim
end

function state:zoomToTitle()
	state.camdx = 0
	state.camdy = 0
	state.camdz = 1.001
	state.cam:lookAt(dimScreen.x/2, dimScreen.y/2)
	state.cam:zoomTo(1)
end

function state:endAtTitle()
	state.cam:zoomTo(1)
	state.camdz = 1
	drawTitle = true
	player1:setPosition(Vector(300,900))
	crispyAnim = player1.shootingAnim
	player2:setPosition(Vector(350,1000))
	mcGuffAnim = player2.shootingAnim
end
function state:startingShot()
	state.cam:lookAt(600,400)
	state.cam:zoomTo(1)
end

function state:closeUp(p)
	currentStringPos = Vector((dimScreen.x/2) - 200, 200)
	state.cam:lookAt(p.position.x + 25, p.position.y + 15)
	state.cam:zoomTo(16)
end

function state:bodyShot(p)
	state.cam:lookAt(p.position.x+50, p.position.y + 25)
	state.cam:zoomTo(8)
	state.camdz = 1.001
end

function state:shot2()
	state.cam:lookAt(player2.position.x + 30, player2.position.y+30)
	state.cam:zoomTo(12)
end

function state:bothPlayers()
	state.cam:lookAt(player1.position.x + 60, player1.position.y+30)
	state.cam:zoomTo(8)	
end
