Class = require "hump.class"

Player = Class{
function(self, num)
	if num == 1 then
		self.keyup = "w"
		self.keyright = "d"
		self.keyup = "w"
		self.keydown = "s"
		self.keyfire = "f"
		self.keyroll = "g" 
	elseif num == 2 then
		self.keyup = "o"
		self.keyright = ";"
		self.keyup = "k"
		self.keydown = "l"
		self.keyfire = "j"
		self.keyroll = "h" 
	end
	self.isplaying = false
end
}

function Player:update(dt)
   
end

function Player:draw()
    --love.graphics.draw(self.img, self.pos.x, self.pos.y)
end

function Player:keyPressHandler(key)
	if key == self.keyup then
		love.graphics.print("up", 300, 300)
	elseif key == self.keydown then	
		love.graphics.print("down", 300, 300)
	elseif key == self.keyleft then
		love.graphics.print("left", 300, 300)
	elseif key == self.keyright then
		love.graphics.print("right", 300, 300)
	end
end

function Player:keyReleaseHandler(key)
	if key == self.keyfire then
		love.graphics.print("fire", 300, 300)
	elseif key == self.keyroll then
		love.graphics.print("roll", 300, 300)
	end
end


