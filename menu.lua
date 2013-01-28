-- This will hold the main menu.
-- Player can choose between 1p and 2p, 
-- as well as which episode to play.
-- Choosing an episode will transition 
-- to that episode's menu.

Gamestate.menu = Gamestate.new()
local state = Gamestate.menu
local font = love.graphics.setNewFont(24)

function state:enter()
	love.graphics.setFont(font)
	-- Reinitialize the players when we enter menu
	player1.isplaying = false
	player2.isplaying = false
	player1:init()
	player2:init()
	player1:setPosition(Vector(100, dimScreen.y-(player1.height + 20)))
	player2:setPosition(Vector(dimScreen.x - (player1.width + 50), 
		dimScreen.y-(player1.height + 20)))

    gameOver = false

end


function state:leave()
end

function state:update(dt)
	dt = math.min(dt, 1/60)
	player1:update(dt)
	player2:update(dt)
end

function state:draw()
	love.graphics.draw(titleScene, 0,0)

	love.graphics.draw(titleImage, (dimScreen.x/2) - 320 , (dimScreen.y/2)-240)

	love.graphics.print("Main Menu", (dimScreen.x / 2) - 10, 10)
	-- Code to draw player when they join a game
	if player1.isplaying then 
		love.graphics.print("Player1",
			60,
			dimScreen.y - (player1.height + 80))
		player1:draw()
	else
		love.graphics.print("Press F to join",
			60,
			dimScreen.y - (player1.height + 80))
	end
	if player2.isplaying then
		love.graphics.print("Player2",
			dimScreen.x - (120 + player2.width),
			dimScreen.y - (player2.height + 80))
		player2:draw()
	else
		love.graphics.print("Press J to join",
			dimScreen.x - (120 + player2.width),
			dimScreen.y - (player2.height + 80))
	end
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		love.event.push("quit")
	elseif (player1.isplaying or player2.isplaying) 
		and (key == "return" or key==" ") then
		-- Start scene 1
		Gamestate.switch(Gamestate.epmenu)
	elseif key == player1.keyfire then
		player1.isplaying = not player1.isplaying
	elseif key == player2.keyfire then
		player2.isplaying = not player2.isplaying
	end	
end
