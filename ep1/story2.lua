-- Story cutscene/sequence.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(28)


Gamestate.story2 = Gamestate.new()
local state = Gamestate.story2
local currentString = ""
local currentStringNum = 0
local diagInterval = 5
local dialogue = {	"Who's a baaaaaaaad mutha--.",
			"Shut your mouth! We gotta start thinking about finding that bomb!",
		"Look, it's that rat Lloyd! He probably knows the score...",
		"It's the fuzz! Aww sheeeeeeee--",
			"Let's shake it outta him!",
			"T'ain't gonna catch me!",
			"Dang, he's making a break for it into that crowd!",
			"Why is it always mardi gras around here?!"
			}
			
local currentShot = 0
local shotFuncs = {
		function() state:closeUp(player2) end,
		function() state:closeUp(player1) end,
		function() state:closeUp(player2) end,
		function() state:closeUp(murderballer) end,
		function() state:closeUp(player1) end,
		function() 
			murderballer.delta = Vector(25,0)
			state.camdx = murderballer.delta.x
			murderballer.animation = murderballer.runAnim
			state:closeUp(murderballer) end,
		function() 
			state.camdx = 0
			state:closeUp(player2) end,
		function() state:closeUp(player1) end
	}

function state:enter()
love.graphics.setFont(font)
-- musics
	bgMusicList = {"music/movemberBlues.ogg"}
-- start music
	TEsound.play(bgMusicList, "bgMusic")

-- background
	backgroundScene = love.graphics.newImage("art/titleScene.png")

-- players
	player1:setPosition(Vector(400,500))
	player2:setPosition(Vector(450,500))
	player2.facing = Vector(-1,0)
	player2.frameFlipH = true
	
	murderballer = Murderballer()

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


	
	
	-- init state.camera and diag here
	state:nextLine()
	state:nextShot()
	
	-- extra char graphics/anims here
	
	-- murderBaller = {}
	-- drawMurderBaller = false
	-- murderBaller.position = Vector(1000,500)
	-- murderBaller.image = love.graphics.newImage('art/murderballer.png')
	-- murderBaller.grid = Anim8.newGrid(52, 52, 
			-- murderBaller.image:getWidth(),
			-- murderBaller.image:getHeight())

	-- murderBaller.runAnim = Anim8.newAnimation('loop',
		-- murderBaller.grid('1-4, 1'),
		-- 0.2) 

	-- murderBaller.standAnim = Anim8.newAnimation('loop',
		-- murderBaller.grid('1-4, 2'),
		-- 0.2) 

	-- murderBaller.animation = murderBaller.standAnim
	-- murderBaller.delta = Vector(0,0)
	-- murderBaller.draw = function()
		-- murderBaller.animation:drawf(
			-- murderBaller.image, 
			-- murderBaller.position.x,
			-- murderBaller.position.y,
			-- 0, -- angle
			-- 0.75, -- x scale
			-- 0.75, -- y scale
			-- 0, -- x offset
			-- 0, -- y offset
			-- false, -- H flip
			-- false -- V flip
			-- )
	-- end
	

end

function state:nextLine()
		stringTimer:clear()

			currentStringNum = currentStringNum + 1			
			currentString = dialogue[currentStringNum]

		stringTimer:add(diagInterval, function()
			if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.scene2)
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
	murderballer:update(dt)
	
end


function state:draw()
	state.cam:attach()	
	love.graphics.draw(backgroundScene, 0,0)
	-- draw stuff that's state.camera locked here
	player1:draw()
	player2:draw()
	murderballer:draw()
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
		Gamestate.switch(Gamestate.scene2)
	elseif key == player1.keyfire or key == player2.keyfire then
		-- skip to next line in diag
		if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.scene2)
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

