-- Introduction sequence.
-- Will include some fancy scrolling text, maybe
-- some sweet ass animations, and badass music.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"

Gamestate.intro = Gamestate.new()
local state = Gamestate.intro
local currentString = ""

function state:enter()
-- title graphics 
	titleImage = love.graphics.newImage("art/title.png")
	drawTitle = false

-- particle sys stuff go here now!
	explosionImage = love.graphics.newImage( "art/explosion.png" )
	self.explosion = love.graphics.newParticleSystem( explosionImage, 500 )
	self.explosion:setEmissionRate(500)
	self.explosion:setLifetime(0.01)
	self.explosion:setParticleLife(5)
	self.explosion:setSpread(360)
	self.explosion:setSizes(1, 2.5, 5.0)
	self.explosion:setRotation(60)
	self.explosion:setSpeed(75,125)
	self.explosion:setSpin(0,1,0.5)
	self.explosion:setPosition(dimScreen.x/2, dimScreen.y/2)
	self.explosion:stop()

-- set up props here (like sprites and such)
	player1.position = Vector(5000, 5000)
	player2.position = Vector(10000, 10000)

-- set up camera ------------------------------------
	cam = Camera(0, 0, 
		1, -- zoom level
		0 -- rotation angle
		)

-- set up sound objects here
	stringTimer = Timer.new()
	bgMusicList = {"music/actionMovie.ogg"}
	TEsound.playLooping(bgMusicList, "bgMusic")
	p = 0
					
	stringTimer:add(0, function() 
				currentString = "Crouching Guy Pictures Presents" 
			end)

	stringTimer:add(6, function() 
				currentString = "A Crouching Guy Productions Picture Production" 
			end)


	stringTimer:add(12, function() 
				currentString = "in Association with ..." 
			end)

	stringTimer:add(18, function() 
				currentString = "Based on a Youtube Sensation viewed by a guy from Crouching Guy Production Pictures" 
			end)

	-- around 26 or so
	stringTimer:add(28, function()
				state:titleExplosion()
				currentString = ""
			end)

	stringTimer:add(35, function()
				currentString = "Starring Chun Chi Sham as Crispy"
				state:zoomCrispy()
			end)

	stringTimer:add(41, function()
				currentString = "Cisco as McGuff"
				state:zoomMcGuff()
			end)


	stringTimer:add(47, function()
				currentString = "Bugsie as Oldie Olderson Jr"
				state:zoomOldie()
			end)

	




end

function state:leave()
	TEsound.stop("bgMusic", false) -- stop bg music immediately
end

function state:update(dt)
	dt = math.min(dt, 1/60)
	stringTimer:update(dt)

	player1:update(dt)
	player2:update(dt)

	state.explosion:update(dt)
end

function state:draw()

	cam:attach()	
	-- draw stuff that's camera locked here
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
	cam:lookAt(player1.position:unpack())
	cam:zoomTo(10)
end

function state:zoomMcGuff()
	cam:lookAt(player2.position:unpack())
	cam:zoomTo(10)
end

function state:zoomOldie()

end
