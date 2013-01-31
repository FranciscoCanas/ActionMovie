-- library requires
Gamestate = require "hump.gamestate"
Class = require "hump.class"
Vector = require "hump.vector"
Anim8 = require "anim8.anim8"
Timer = require "hump.timer"
--require "TESound.TEsound"
require 'TESound.TEsound'

-- Entities requires
require "player"
require "enemy"
require "bullet"
require "bystander"
require 'murderballer'



-- Globals
-- TODO: organize these into groups
-- note: Initialization order matters.
hudFont = love.graphics.setNewFont(24)
gameOverFont = love.graphics.setNewFont(48)
dimScreen = Vector(1024, 768)
framesPerSecond = 56
love.physics.setMeter(32) --the height of a meter our worlds will be 32px
world = love.physics.newWorld(
	0, -- x grav
	0, -- y grav
	true)


OBSTACLE = 1 
PLAYER = 2
ENEMY = 3
BULLET = 4
BARRICADE = 5
BOMB = 6

player1 = Player(1)
player2 = Player(2)
players = {player1, player2}

isGameOver = false
gameOverTimer = Timer.new()
deadPlayer = nil

globalMenuBGdx=-20
globalMenuBGx=0



-- gamestate requires
require "intro"
require "menu"
require "credits"
require "ep1/epmenu"


function love.update(dt)
		
end

-- call this last so gamestate events get registered.
function love.load()
	-- Gamestate inits:
	Gamestate.registerEvents()
	Gamestate.switch(Gamestate.intro)
    love.mouse.setVisible(false)
	
	-- Graphic options:
	love.graphics.setMode(
		dimScreen.x, 
		dimScreen.y, 
		true, -- fullscreen
		true, --vsync
		0 -- antialiasing
		)
		
	-- universal world callbacks here:
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end


-- love.physics collision callbacks get defined here since they
-- will be universal to all scenes/episodes
-- a is the first fixture involved in the collision
-- b is the second
-- coll is the collision object created
function beginContact(a, b, coll)
	local a, b = a:getUserData(), b:getUserData()
	
	
	
	-- if we've got a bullet and a person...
	if (a:is_a(Bullet) and (b:is_a(Player) or b:is_a(Enemy))) then
		b:isShot(a, coll)
	elseif (b:is_a(Bullet) and (a:is_a(Player) or a:is_a(Enemy))) then
		a:isShot(b, coll)
	elseif (a:is_a(Obstacle) and (b:is_a(Bullet))) then
		a:impactEffect(coll)
	elseif (b:is_a(Obstacle) and (a:is_a(Bullet))) then
		b:impactEffect(coll)
	elseif (a:is_a(Bomb) and (b:is_a(Bullet))) then
		a:infuse()
		a:impactEffect(coll)
	elseif (b:is_a(Bomb) and (a:is_a(Bullet))) then
		b:infuse()
		b:impactEffect(coll)
	end
	
	if (a:is_a(Bullet)) then a:impact() end
	if (b:is_a(Bullet)) then b:impact() end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end

function frameLimiter(dt)
 if dt < 1/30 then
      love.timer.sleep(1/framesPerSecond - dt)
   end
end

function drawHud(oldFont)
	love.graphics.setFont(hudFont)
	heart = love.graphics.newImage('art/heart.png')
	if player1.isplaying then
		for i=1,player1.health do
			--love.graphics.print( "@", 5 + (i*20), 5)
			love.graphics.draw( heart, 5 + (i*30), 5)
		end
	end
	
	if player2.isplaying then
		for i=1,player2.health do
			--love.graphics.print( "@", dimScreen.x - 20 - (i*20), 5)
			love.graphics.draw(heart, dimScreen.x - 20 - (i*30), 5)
		end

	end


    if isGameOver then
        love.graphics.setFont(gameOverFont)
        love.graphics.print("FIN", dimScreen.x/2 + 100, dimScreen.y/2 - 50)
    end
	love.graphics.setFont(oldFont)
end


function StartGameOver(player)
        	TEsound.stop("bgMusic", false) -- stop bg music immediately
			TEsound.play("music/actionHit.ogg")             
            isGameOver = true
            deadPlayer = player
            player.timer:add(5.0, function()
                Gamestate.switch(Gamestate.menu)
            end)
           
end

function gameovercam(cam)
	cam:lookAt(deadPlayer.position.x + 35, deadPlayer.position.y + 20)
	cam:zoomTo(12)
end

