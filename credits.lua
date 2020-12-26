-- Story cutscene/sequence.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(28)


Gamestate.credits = Gamestate.new()
local state = Gamestate.credits
local currentString = ""
local currentStringNum = 0
local diagInterval = 5
local dialogue = {	
        "Action Movie: The Series (The Video Game)",
        "Conceived and Conceptualized by Christy and Francisco",
		"Writing and Acting by Christy and Francisco",
        "Digital Manipulations by Christy and Francisco",
        "Visuals and Art Direction by Christy",
        "Funky Jams Performed by Francisco",
        "Cinematography by Francisco",
		"Costume Design by Christy",
		"THE END"
}
			
local currentShot = 0
local shotFuncs = {
          function() state:startingShot() end,
		  function() state:startingShot() end,
          function() state:startingShot() end,      
          function() state:startingShot() end,      
          function() state:startingShot() end,      
          function() state:startingShot() end,      
          function() state:startingShot() end,      
		  function() state:startingShot() end,      
          function() state:startingShot() 
			stringTimer.clear()
			end,      		
	}

function state:enter()
    love.graphics.setFont(font)
-- musics
	bgMusicList = {"music/actionCredits.ogg"}
-- start music
	TEsound.play(bgMusicList, "stream")

-- background
	backgroundScene = love.graphics.newImage("art/cityscape.png")

-- players
	player1:setPosition(Vector(400,500))
	player2:setPosition(Vector(470,500))
	player2.facing = Vector(-1,0)
	player2.frameFlipH = -1
	
	murderballer = Murderballer()
    murderballer.position = Vector(445, 518)

-- timer stuff
	stringTimer = Timer.new()


	

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

    -- string stuff
    currentStringNum = 0
	
	-- init state.camera and diag here
	state:nextLine()
end

function state:nextLine()
		stringTimer:clear()

			currentStringNum = currentStringNum + 1			
			currentString = dialogue[currentStringNum]

		stringTimer:add(diagInterval, function()
			if currentStringNum >= table.getn(dialogue) then
			--	Gamestate.switch(Gamestate.menu)
			else
			state:nextLine()
			state:nextShot() -- no shot changes here
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
    globalMenuBGx = globalMenuBGx + dt * globalMenuBGdx
    if ( globalMenuBGx < -1*titleScene:getWidth()) then
        globalMenuBGx = 0
    end
	dt = math.min(dt, 1/60)
	stringTimer:update(dt)
--	player1:update(dt)
--	player2:update(dt)
--	state.cam:move(state.camdx*dt,state.camdy*dt)
--	state.cam:zoom(state.camdz)
--	murderballer:update(dt)
end


function state:draw()
--	state.cam:attach()	
    love.graphics.draw(titleScene, globalMenuBGx,0)
    love.graphics.draw(titleScene, globalMenuBGx + titleScene:getWidth(), 0)
	-- draw stuff that's state.camera locked here
--	player1:draw()
--	player2:draw()
--	murderballer:draw()
--	state.cam:detach()	
	
	-- cinematic letterboxing here
	love.graphics.setColor(255,0,0,255)
--	love.graphics.rectangle("fill", 0, 0, dimScreen.x, 150)
--	love.graphics.rectangle("fill", 0, dimScreen.y - 150, dimScreen.x, 150)
	love.graphics.printf( currentString, (dimScreen.x/2) - 400, (dimScreen.y/2)-150, 800, "center" )
	love.graphics.setColor(255,255,255,255)
	

end

function state:leave()
	stringTimer:clear()
	TEsound.stop("stream", false) -- stop bg music immediately
end

function state:keyreleased(key)
	if key == "escape" then
		-- quits to menu
		Gamestate.switch(Gamestate.menu)
	elseif key == " " or key=="return" then
		-- (space) skips to main scene1
		Gamestate.switch(Gamestate.menu)
	elseif key == player1.keyfire or key == player2.keyfire then
		-- skip to next line in diag
		if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.menu)
		else
			state:nextLine()
--			state:nextShot()
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
	state.cam:lookAt(player1.position.x + 60, player1.position.y+30)
	state.cam:zoomTo(8)	
end

