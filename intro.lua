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
	p = 1

	stringTimer:add(p+2, function() 
				currentString = "Crouching Guy Pictures Presents" 
			end)

	stringTimer:add(p+8, function() 
				currentString = "A Crouching Guy Productions Picture Production" 
			end)


	stringTimer:add(p+14, function() 
				currentString = "Based on a Youtube Sensation viewed by a guy from Crouching Guy Production Pictures" 
			end)

	stringTimer:add(p+20, function() 
				currentString = "starring" 
			end)
	stringTimer:add(p+26, function() 
				currentString = "Chun Chi Sham as Crispy" 
			end)
	stringTimer:add(p+32, function() 
				currentString = "Cisco as McGuff" 
			end)

	stringTimer:add(p+38, function() 
				currentString = "Oldie McOlderson Jr \n\tas\n\tHimself" 
			end)

	stringTimer:add(p+44, function() 
				currentString = "in" 
			end)

	stringTimer:add(p+50, function() 
				currentString = "" 
			end)

	-- 1:05 is exactly where we need an explosions
end

function state:leave()
	TEsound.stop("bgMusic", false) -- stop bg music immediately
end

function state:update(dt)
	dt = math.min(dt, 1/60)
	stringTimer:update(dt)
end

function state:draw()

	cam:attach()	
	-- draw stuff that's camera locked here
	cam:detach()	

	-- draw the credits and other non-camera locked stuff here
	love.graphics.printf( currentString, (dimScreen.x/2) - 125, (dimScreen.y/2)-20, 250, "center" )
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
