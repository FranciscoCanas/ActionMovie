-- library requires
Gamestate = require "hump.gamestate"

-- gamestate requires
require "intro"
require "menu"
require "ep1/epmenu"

-- Globals
player1 = {}
player2 = {}

player1.keyup = "w"
player1.keyright = "d"
player1.keyup = "w"
player1.keydown = "s"
player1.keyfire = "f"
player1.keyroll = "g" 

player2.keyup = "o"
player2.keyright = ";"
player2.keyup = "k"
player2.keydown = "l"
player2.keyfire = "j"
player2.keyroll = "h" 

player1.isplaying = false
player2.isplaying = false

-- call this last so gamestate events get registered.
function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(Gamestate.intro)
end
