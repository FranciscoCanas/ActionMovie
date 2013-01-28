-- Story cutscene/sequence.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(28)


Gamestate.story1 = Gamestate.new()
local state = Gamestate.story1
local currentString = ""
local currentStringNum = 0
local diagInterval = 5
local dialogue = {	"Last week in Action Movie...",
			"Crispy, you're a loose canon!",
			"That ice cream truck was illegally parked. He deserved what he got!",
	"And who's gonna pay for the damages to that orphanage!?",
		"If we don't find that bomb, they're gonna blow up the president!",
			"Big Boss is sending his goons over, we gotta split.",
			"We'll shoot our way out!",
			}
local currentShot = 0
local shotFuncs = {
		function() state:startingShot() end, -- last week...
		function() state:closeUp(player2) end, --
		function() state:closeUp(player1) end, --
		function() state:closeUp(player2) end, --
		function() 
                    player1:setPosition(Vector(1200,370))
                    player2:setPosition(Vector(1250,370))
                    state:closeUp(player1) 
                    end, -- If we don't...
		function() 
                    player1:setPosition(Vector(1800,400))
                    player2:setPosition(Vector(1850,400))
                    state:closeUp(player2) 
                    end, -- Big Boss...
		function() state:bothPlayers() end,
	}

function state:enter()
love.graphics.setFont(font)
-- background
	backgroundScene = love.graphics.newImage("art/titleScene.png")

-- players
	player1:setPosition(Vector(1800,500))
	player2:setPosition(Vector(1850,500))
	player2.facing = Vector(-1,0)
	player2.frameFlipH = true

-- timer stuff
	stringTimer = Timer.new()

-- musics
	bgMusicList = {"music/movemberBlues.ogg"}

	

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


	-- start music
	TEsound.play(bgMusicList, "bgMusic")

	
	-- init state.camera and diag here
	state:nextLine()
	state:nextShot()

end

function state:nextLine()
		stringTimer:clear()

			currentStringNum = currentStringNum + 1			
			currentString = dialogue[currentStringNum]

		stringTimer:add(diagInterval, function()
			if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.scene)
			else
			state:nextLine()
			state:nextShot()
			end
		end)
end

function state:nextShot()
	currentShot = currentShot + 1
	shot = shotFuncs[currentShot]	
	shot()
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
end


function state:draw()
	state.cam:attach()	
	love.graphics.draw(backgroundScene, 0,0)
	-- draw stuff that's state.camera locked here
	player1:draw()
	player2:draw()
	state.cam:detach()	
	
	-- cinematic letterboxing here
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill", 0, 0, dimScreen.x, 150)
	love.graphics.rectangle("fill", 0, dimScreen.y - 150, dimScreen.x, 150)
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.printf( currentString, (dimScreen.x/2) - 300, (dimScreen.y)-150, 600, "center" )
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
		Gamestate.switch(Gamestate.scene)
	elseif key == player1.keyfire or key == player2.keyfire then
		-- skip to next line in diag
		if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.scene)
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
	state.cam:lookAt(player1.position.x + 60, player1.position.y+30)
	state.cam:zoomTo(8)	
end
