-- library requires
Gamestate = require "hump.gamestate"
Class = require "hump.class"
Vector = require "hump.vector"
Anim8 = require "anim8.anim8"

-- Entities requires
require "player"
require "enemy"
require "bullet"

-- gamestate requires
require "intro"
require "menu"
require "ep1/epmenu"


-- Globals
-- TODO: organize these into groups
-- note: Initialization order matters.
dimScreen = Vector(1024, 768)
love.physics.setMeter(32) --the height of a meter our worlds will be 32px
world = love.physics.newWorld(
	0, -- x grav
	0, -- y grav
	true)
player1 = Player(1)
player2 = Player(2)
players = {player1, player2}

function love.update()
end

-- call this last so gamestate events get registered.
function love.load()
	-- Gamestate inits:
	Gamestate.registerEvents()
	Gamestate.switch(Gamestate.intro)
	
	-- Graphic options:
	love.graphics.setMode(
		dimScreen.x, 
		dimScreen.y, 
		false, -- fullscreen
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

	if (a:is_a(Bullet) and (b:is_a(Player) or b:is_a(Enemy))) then
		b:isShot(a, coll)
	elseif (b:is_a(Bullet) and (a:is_a(Player) or a:is_a(Enemy))) then
		a:isShot(b, coll)
	end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end