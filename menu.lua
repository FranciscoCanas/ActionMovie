-- This will hold the main menu.
-- Player can choose between 1p and 2p, 
-- as well as which episode to play.
-- Choosing an episode will transition 
-- to that episode's menu.

Gamestate.menu = Gamestate.new()
local state = Gamestate.menu
local font = love.graphics.setNewFont(24)
local selectFont = love.graphics.setNewFont(20)

function state:enter()
    titleScene = love.graphics.newImage("art/cityscape.png")
	titleImage = love.graphics.newImage("art/title.png")
	love.graphics.setFont(font)
	
    -- Reinitialize the players when we enter menu
	player1.isplaying = false
	player2.isplaying = false
	player1:init()
	player2:init()
	player1:setPosition(Vector(dimScreen.x / 16, (dimScreen.y / 8) - (player1.height + 20)))
	player2:setPosition(Vector((dimScreen.x / 4) - (player1.width + 50), 
		dimScreen.y / 2 -(player1.height + 20)))

    isGameOver = false
    epselect = 1


end


function state:leave()
end

function state:update(dt)
	dt = math.min(dt, 1/60)
    globalMenuBGx = globalMenuBGx + dt * globalMenuBGdx
    if (globalMenuBGx < -1 * titleScene:getWidth()) then
        globalMenuBGx = 0
    end
	player1:update(dt)
	player2:update(dt)
end

function state:draw()
	MENU_Y_SCALE = 3.5
	MENU_X_SCALE = 4.0
	love.graphics.draw(titleScene, globalMenuBGx, 0)
	love.graphics.draw(titleImage, (dimScreen.x / 7), dimScreen.y / 24)
    love.graphics.setColor( 255,0,0,255 )
    love.graphics.setFont(font)
	love.graphics.print("Main Menu", (dimScreen.x / MENU_X_SCALE) - 40, dimScreen.y / MENU_Y_SCALE)
	-- Code to draw player when they join a game

	if epselect==0 then
		arrowCoord = 50
	elseif epselect==1 then
		arrowCoord = 75
	else
		arrowCoord = 100
	end

    love.graphics.setFont(selectFont)
	love.graphics.print("->", (dimScreen.x / MENU_X_SCALE) - 60, (dimScreen.y / MENU_Y_SCALE) + arrowCoord)
	love.graphics.print("Intro", (dimScreen.x / MENU_X_SCALE) - 40, (dimScreen.y / MENU_Y_SCALE) +50)
	love.graphics.print("Episode One", (dimScreen.x / MENU_X_SCALE) - 40, (dimScreen.y / MENU_Y_SCALE) + 75)
	love.graphics.print("Credits", (dimScreen.x / MENU_X_SCALE) - 40, (dimScreen.y / MENU_Y_SCALE) + 100)
--    love.graphics.setColor( 255,255,255,255 )

	if player1.isplaying then 

		love.graphics.print("Crispy: P.I.",
			60,
			(dimScreen.y / 2) - (player1.height + 80))
		love.graphics.setColor( 255,255,255,255 )
		player1:setPosition(Vector(60, (dimScreen.y / 2) - (player1.height + 80)))
		player1:draw()
    	love.graphics.setColor( 255,0,0,255 )
	else
		love.graphics.print("Press F to join",
			60,
			(dimScreen.y / 2) - (player1.height + 80))
	end
	if player2.isplaying then
		love.graphics.print("Detective McGuff",
			dimScreen.x / 2 - (120 + player2.width),
			dimScreen.y / 2 - (player2.height + 80))
        love.graphics.setColor(255,255,255,255)
		player2:draw()
       love.graphics.setColor( 255,0,0,255 )
	else
		love.graphics.print("Press J to join",
			dimScreen.x / 2 - (120 + player2.width),
			dimScreen.y / 2 - (player2.height + 80))
	end
       love.graphics.setColor( 255,255,255,255 )
end 

function state:keyreleased(key)
	if key == "escape" or key == "i" then
		-- quits game
		love.event.push("quit")
	elseif (key == "return" or key==" " or key=="z" or key=="a") then
		-- Start scene 1
        if (epselect == 1 and (player1.isplaying or player2.isplaying)) then
    		Gamestate.switch(Gamestate.epmenu)
        elseif epselect == 0 then
            player1:init()
            player2:init()
            Gamestate.switch(Gamestate.intro)
        elseif epselect == 2 then
            Gamestate.switch(Gamestate.credits)
        end
	elseif key == player1.keyfire then
		player1.isplaying = not player1.isplaying
	elseif key == player2.keyfire then
		player2.isplaying = not player2.isplaying
	elseif key == "up" or key == "r" then
		epselect = (epselect - 1) % 3
	elseif key == "down" or key == "f" then
		epselect = (epselect + 1) % 3 
	end	
end
