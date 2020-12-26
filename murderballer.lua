Murderballer = Class { 
function(self)
	-- extra char graphics/anims here
	self.isAlive = false
	self.position = Vector(1000,500)
	self.image = love.graphics.newImage('art/murderballer.png')
	self.grid = Anim8.newGrid(52, 52, 
			self.image:getWidth(),
			self.image:getHeight())

	self.runAnim = Anim8.newAnimation(
		self.grid('1-4', 1),
		0.2) 

	self.standAnim = Anim8.newAnimation(
		self.grid('1-4', 2),
		0.2) 

    self.scale = 1
	self.animation = self.standAnim
	self.delta = Vector(0,0)
end
}

function Murderballer:update(dt)
	self.position = self.position + (self.delta * dt)
	self.animation:update(dt)
end

function Murderballer:draw()
	self.animation:draw(
			self.image, 
			self.position.x,
			self.position.y,
			0, -- angle
			self.scale, -- x scale
			self.scale, -- y scale
			0, -- x offset
			0 -- y offset
			--1, -- H flip
			--1 -- V flip
			)
end
