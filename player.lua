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
		self.image = love.graphics.newImage('art/WomenRun.png')
		
	elseif num == 2 then
		self.pnum = 2
		self.keyup = "o"
		self.keyright = ";"
		self.keyleft = "k"
		self.keydown = "l"
		self.keyfire = "j"
		self.keyroll = "h" 
		self.image = love.graphics.newImage('art/ManRun.png')
		
	end
	self:init()
	
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
		
	self.animation = self.standAnim

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
		((self.position.x + self.width) / 4),
		((self.position.y + self.height) / 6), 
		"dynamic"
		)

	self.shape = love.physics.newRectangleShape(
		self.width / 3,
		self.height / 2
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
	self.scale = 0.5
	self.width = 64 -- size we will draw each frame at
	self.height = 64 -- size we will draw each frame at
	self.facing = Vector(1,0)
	if self.pnum == 2 then
		self.position = Vector(
			dimScreen.x - (50 + self.width),
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
		self.frameFlipH = true
    elseif love.keyboard.isDown(self.keyright) then
        delta.x =  1
		self.body:applyForce(self.acceleration,0)
		moved = true
		self.frameFlipH = false
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
		self.animation = self.runAnim
		
	else
		self.animation = self.standAnim
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
    self.animation:drawf(self.image, 
				self.position.x,
				self.position.y,
				0, -- angle
				self.scale, -- x scale
				self.scale, -- y scale
				0, -- x offset
				0, -- y offset
				self.frameFlipH,
				self.frameFlipV
				)
end

function Player:keyPressHandler(key)
end

function Player:fire(self)
		-- some weird stuff happening here.
		-- self.facing is being passed in as null
		-- and this event is being called when any key
		-- is pressed, not just keyfire.
		Bullet(null, self.position, self.facing)
end

function Player:keyReleaseHandler(key)
	if key == self.keyfire then
		--self:fire(self)
	elseif key == self.keyroll then
		-- animate roll here
	end
end




