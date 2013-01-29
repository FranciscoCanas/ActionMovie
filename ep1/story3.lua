-- Story cutscene/sequence.
require 'TESound.TEsound'
local Timer = require "hump.timer"
local Camera = require "hump.camera"
local font = love.graphics.setNewFont(28)


Gamestate.story3 = Gamestate.new()
local state = Gamestate.story3
local currentString = ""
local currentStringNum = 0
local diagInterval = 5
local dialogue = {	"Spill the beans on the bomb, you stupid, neon-gym-short wearing, president-bombing, tron-lookin' mo^$@%*&#ker!",
                    "You'll never make it on time, flatfoots!",
                    "Let's beat it out of him.",
                    "Whoah whoah, wait...i'll tell you where it is.",
                    "It's on the 18th floor of the president's mansion, but you only have 2 hours to get there!",
                    "2 hours? That's plenty of time.",
                    "Lunch?",
                    "If you're paying.",
                    "1 hour and 54 minutes later...",
                    "I can't believe I ate all those tacos.",
                    "And I can't believe you talked me into all-you-can-eat tacos.",
                    "Gadzooks! We need to get to that bomb, and fast."
			}
			
local currentShot = 0
local shotFuncs = {
		function() state:bothPlayers() end,
		function() state:closeUp(murderballer) end,
        function() state:closeUp(player1) end,
		function() state:closeUp(murderballer) end,
		function() state:closeUp(murderballer) end,
        function() state:closeUp(player2) end,
		function() state:closeUp(player1) end,
		function() state:closeUp(player2) end,
        function() state:startingShot()
                    TEsound.play("music/actionHit.ogg")  
                    backgroundScene = cityScene
                    murderballer.position = Vector(2000,2000)
            	player1:setPosition(Vector(400,5000))
            	player2:setPosition(Vector(470,5000))

                end,
        function() 
        	player1:setPosition(Vector(400,500))
        	player2:setPosition(Vector(470,500))

            backgroundScene = alleyScene
            state:closeUp(player2) end,
		function() state:closeUp(player1) end,
        function() state:closeUp(player2)
			TEsound.play("music/actionHit.ogg")  
           	TEsound.stop("bgMusic", false) -- stop bg music immediately
             end
	}

function state:enter()
love.graphics.setFont(font)
-- musics
	bgMusicList = {"music/movemberBlues.ogg"}
-- start music
	TEsound.play(bgMusicList, "bgMusic")

-- background
	alleyScene = love.graphics.newImage("art/titleScene.png")
    cityScene = love.graphics.newImage("art/cityscape.png")
    backgroundScene = alleyScene

-- players
	player1:setPosition(Vector(400,500))
	player2:setPosition(Vector(470,500))
	player2.facing = Vector(-1,0)
	player2.frameFlipH = true
	
	murderballer = Murderballer()
    murderballer.position = Vector(445, 518)

-- timer stuff
	stringTimer = Timer.new()

-- string stuff
    currentStringNum = 0
	

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
	
	love.graphics.printf( currentString, (dimScreen.x/2) - 400, (dimScreen.y)-150, 800, "center" )
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
		Gamestate.switch(Gamestate.scene3)
	elseif key == player1.keyfire or key == player2.keyfire then
		-- skip to next line in diag
		if currentStringNum >= table.getn(dialogue) then
				Gamestate.switch(Gamestate.scene3)
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

