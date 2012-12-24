-- library requires
Gamestate = require "hump.gamestate"
Class = require "hump.class"
-- Entities requires
require "player"

-- gamestate requires
require "intro"
require "menu"
require "ep1/epmenu"

-- Globals

player1 = Player(1)
player2 = Player(2)


-- call this last so gamestate events get registered.
function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(Gamestate.intro)
end
