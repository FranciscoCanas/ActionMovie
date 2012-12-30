Enemy = Class{
function(self, image, position)
	self.image = love.graphics.newImage(image)
	self.position = position
	self.isalive = true
	self.health = 3
	
	-- Set up anim8 for spritebatch animations:
	self.frameDelay = 0.2
	self.frameFlipH = false
	self.frameFlipV = false
	self.grid = Anim8.newGrid(128, 128, 
			self.image:getWidth(),
			self.image:getHeight())
	
	self.standAnim = Anim8.newAnimation('loop', 
			self.grid:getFrames(1,1),
			self.frameDelay)
			
	self.runAnim = Anim8.newAnimation('loop',
		self.grid('2-3, 1'),
		self.frameDelay)
		
	-- self.shootAnim = Anim8.newAnimation('loop',
		-- self.grid('1-1, 2'),
		-- self.frameDelay)
		
	self.animation = self.standAnim
	
	-- love.physics code starts here
	self.acceleration = 4000
	self.damping = 15
	self.density = 2
	
	self.body = love.physics.newBody(world, 
		((self.position.x + self.width) / 2 ),
		((self.position.y + self.height) / 2 ), 
		--self.position.x,
		--self.position.y,
		"dynamic"
		)
	self.body:setFixedRotation(true)

	self.shape = love.physics.newRectangleShape(
		self.image:getWidth() / 3,
		self.image:getHeight() / 3
		)
		
	self.fixture = love.physics.newFixture(
		self.body, 
		self.shape, 
		self.density) -- density
	
	-- awkward but absolutely needed to pull out the
	-- object that owns the fixture during collision
	-- detection:
	self.fixture:setUserData(self)	
		
		
	self.body:setLinearDamping( self.damping )
end
}

function Enemy:init()
end

function Enemy:update(dt)
	-- delta holds direction of movement input
	local delta = Vector(0,0)
	
    if love.keyboard.isDown(self.keyleft) then
        --delta.x = -1
		self.body:applyForce(-self.acceleration,0)
    elseif love.keyboard.isDown(self.keyright) then
        --delta.x =  1
		self.body:applyForce(self.acceleration,0)
    end
	
    if love.keyboard.isDown(self.keyup) then
        --delta.y = -1
		self.body:applyForce(0,-self.acceleration)
    elseif love.keyboard.isDown(self.keydown) then
        --delta.y =  1
		self.body:applyForce(0,self.acceleration)
    end
	
	self.position.x, self.position.y = self.body:getX(), self.body:getY()
end

function Enemy:update(dt)
end

function Enemy:draw()
    self.animation:drawf(self.image, 
				self.position.x,
				self.position.y,
				0, -- angle
				1, -- x scale
				1, -- y scale
				0, -- x offset
				0, -- y offset
				self.frameFlipH,
				self.frameFlipV
				)
end


-- Resolve being shot here.
-- called by world collision callback in main.lua
function Enemy:isShot(bullet, collision)

end


