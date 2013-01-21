-- Story cutscene/sequence.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(24)
love.graphics.setFont( font)

Gamestate.story1 = Gamestate.new()
local state = Gamestate.story1
local currentString = ""
local currentStringNum = 0
local diagInterval = 5
local dialogue = {	"Last week, on ActionMovie...",
			"Crispy, you're a lose canon!!!",
			"That ice cream truck was illegally parked! He deserved what he got!",
	"Who's gonna pay for the damages to that orphanage!?",
		"If we don't find that bomb, they're gonna blow up the president!",
			"Big Boss is sending his goons over.",
			"Quick, out the back! We'll escape through the alleyway!",
			}
local currentShot = 0
local shotFuncs = {
		function() state:startingShot() end,
		function() state:closeUp(player2) end,
		function() state:closeUp(player1) end,
		function() state:closeUp(player2) end,
		function() state:closeUp(player1) end,
		function() state:closeUp(player2) end,
		function() state:bothPlayers() end,
	}

function state:enter()
-- background
	backgroundScene = love.graphics.newImage("art/titleScene.png")

-- players
	player1:setPosition(Vector(800,500))
	player2:setPosition(Vector(850,500))
	player2.facing = Vector(-1,0)
	player2.frameFlipH = true

-- timer stuff
	stringTimer = Timer.new()

-- musics
	bgMusicList = {"music/movemberBlues.ogg"}

	

-- camera setup
-- set up camera ------------------------------------
	cam = Camera(
		player1.position.x + 50, 
		player1.position.y,  
		10, -- zoom level
		0 -- rotation angle
		)

	camdx = 0 -- camera x panning rate
	camdy = 0
	camdz = 1


	-- start music
	TEsound.play(bgMusicList, "bgMusic")

	
	-- init camera and diag here
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

	dt = math.min(dt, 1/60)
	stringTimer:update(dt)
--	player1:update(dt)
--	player2:update(dt)
	cam:move(camdx,camdy)
	cam:zoom(camdz)
end


function state:draw()
	cam:attach()	
	love.graphics.draw(backgroundScene, 0,0)
	-- draw stuff that's camera locked here
	player1:draw()
	player2:draw()
	cam:detach()	
	
	-- cinematic letterboxing here
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill", 0, 0, dimScreen.x, 150)
	love.graphics.rectangle("fill", 0, dimScreen.y - 150, dimScreen.x, 150)
	love.graphics.setColor(255,255,255,255)
	
	love.graphics.printf( currentString, (dimScreen.x/2) - 200, (dimScreen.y)-150, 400, "center" )
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
	cam:lookAt(600,400)
	cam:zoomTo(1)
end


function state:closeUp(p)
	cam:lookAt(p.position.x + 25, p.position.y + 15)
	cam:zoomTo(16)
end

function state:shot2()
	cam:lookAt(player2.position.x + 30, player2.position.y+30)
	cam:zoomTo(12)
end

function state:bothPlayers()
	cam:lookAt(player1.position.x + 60, player1.position.y+30)
	cam:zoomTo(8)	
end
