Player = Class{
function(self, num)
	
	if num == 1 then
		self.pnum = 1
		self.keyup = "w"
		self.keyright = "d"
		self.keyleft = "a"
		self.keydown = "s"
		self.keyfire = "f"
		self.keyroll = "g" 
		self.image = love.graphics.newImage('art/woman.gif')
		
	elseif num == 2 then
		self.pnum = 2
		self.keyup = "o"
		self.keyright = ";"
		self.keyleft = "k"
		self.keydown = "l"
		self.keyfire = "j"
		self.keyroll = "h" 
		self.image = love.graphics.newImage('art/man.gif')
		
	end
	self:init()
	
	-- Set up anim8 for spritebatch animations:
	self.grid = Anim8.newGrid(64, 64, 
			self.image:getWidth(),
			self.image:getHeight())
	
	self.animation = Anim8.newAnimation('loop', 
			self.grid:getFrames(1,1),
			0.1)

	-- This stuff used for non-love.physics based motion
	-- self.velocity = Vector(0,0)
	-- self.acceleration = 10000
	-- self.max_velocity = 500
	-- self.drag = 0.96
	-- end of stuff used for non-physics based motion
	
	-- Collision detection init using hardon collider
	-- self.collisionShape = Collider:addRectangle(self.position.x,
		-- self.position.y,
		-- self.image:getWidth(),
		-- self.image:getHeight())
	
	-- love.physics code starts here
	self.facing = Vector(1,0) -- normalized direction vector
	self.acceleration = 4000
	self.damping = 15
	self.density = 2
	
	self.body = love.physics.newBody(world, 
		((self.position.x + self.image:getWidth()) / 4),
		((self.position.y + self.image:getHeight()) / 6), 
		"dynamic"
		)

	self.shape = love.physics.newRectangleShape(
		self.image:getWidth() / 3,
		self.image:getHeight() / 2
		)
		
	self.fixture = love.physics.newFixture(
		self.body, 
		self.shape, 
		self.density)
		
	self.body:setLinearDamping( self.damping )
	
	-- self.body:setMassData(
		-- (self.position.x + self.image:getWidth()) / 2,
		-- (self.position.y + self.image:getHeight()) / 2,
		-- 64, -- mass (kg)
		-- 10) -- inertia
	-- love.physics ends here
end
}

function Player:init()
	self.isplaying = false
	if self.pnum == 2 then
		self.position = Vector(
			dimScreen.x - (50+self.image:getWidth()),
			dimScreen.y - 80)
	elseif self.pnum == 1 then
		self.position = Vector(50,dimScreen.y - 80)
	end
	
end

function Player:update(dt)
	-- delta holds direction of movement input
	local delta = Vector(0,0)
	local moved = false
	
    if love.keyboard.isDown(self.keyleft) then
        delta.x = -1
		self.body:applyForce(-self.acceleration,0)
		moved = true
    elseif love.keyboard.isDown(self.keyright) then
        delta.x =  1
		self.body:applyForce(self.acceleration,0)
		moved = true
    end	
    if love.keyboard.isDown(self.keyup) then
        delta.y = -1
		self.body:applyForce(0,-self.acceleration)
		moved = true
    elseif love.keyboard.isDown(self.keydown) then
        delta.y =  1
		self.body:applyForce(0,self.acceleration)
		moved = true
    end
	
	-- Want length 1 vector with correct x, y elements
    delta:normalize_inplace()
	if moved then 
		self.facing = delta
	end

	--compute velocity based on normalized delta and acceleration
    -- self.velocity = self.velocity + delta 
		-- * self.acceleration * dt
	
	-- add drag so player stops when keys released
	-- with inertia
	-- self.velocity = self.velocity * self.drag

	-- clamp upper velocity bound
    -- if self.velocity:len() > self.max_velocity then
        -- self.velocity = self.velocity:normalized() * self.max_velocity
    -- end
	
	-- clamp lower velocity bound
	-- if self.velocity:len() < 1 then
		-- self.velocity = Vector(0,0)
	-- end

	-- This code used for none love.physics movement:
		--self.position = self.position + self.velocity * dt
		-- self.collisionShape:moveTo(self.position.x + self.image:getWidth()/2,
			-- self.position.y + self.image:getHeight()/2)
		--self.body:setPosition(self.position.x, self.position.y)
	
	self.position.x, self.position.y = self.body:getX(), self.body:getY()
end

function Player:draw()
    self.animation:draw(self.image, 
				self.position.x,
				self.position.y,
				0, -- angle
				1, -- x scale
				1, -- y scale
				0, -- x offset
				0 -- y offset
				)
end

function Player:keyPressHandler(key)
	-- if key == self.keyup then
		-- self.body:applyForce(0,-40000)
	-- elseif key == self.keydown then	
		-- self.body:applyForce(0,40000)
	-- elseif key == self.keyleft then
		-- self.body:applyForce(-40000,0)
	-- elseif key == self.keyright then
		-- self.body:applyForce(40000,0)
	-- end
end

function Player:keyReleaseHandler(key)
	if key == self.keyfire then
		love.graphics.print("fire", 300, 300)
	elseif key == self.keyroll then
		love.graphics.print("roll", 300, 300)
	end
end


