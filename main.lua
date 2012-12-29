-- library requires
Gamestate = require "hump.gamestate"
Class = require "hump.class"
Vector = require "hump.vector"
Anim8 = require "anim8.anim8"

-- Entities requires
require "player"
require "enemy"

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
end
