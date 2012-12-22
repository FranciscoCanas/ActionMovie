Gamestate.intro = Gamestate.new()
local state = Gamestate.intro

function state:enter()
end

function state:leave()
end

function state:update()
end

function state:draw()
	love.graphics.print("Intro Placeholder", 10, 10)
end 

function state:keyreleased(key)
	if key == "escape" then
		-- quits game
		love.event.push("quit")
	elseif key == " " or key=="return" then
		-- (space) skips to main menu
		Gamestate.switch(Gamestate.menu)
	end	
end
