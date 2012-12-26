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
	self.grid = Anim8.newGrid(64, 64, 
			self.image:getWidth(),
			self.image:getHeight())
	self.animation = Anim8.newAnimation('loop', 
			self.grid:getFrames(1,1),
			0.1)
			
	self.isplaying = false
	self.velocity = Vector(0,0)
	self.acceleration = 10000
	self.max_velocity = 500
	self.drag = 0.96
	
	-- Collision detection init
	self.collisionShape = Collider:addRectangle(self.position.x,
		self.position.y,
		self.image:getWidth(),
		self.image:getHeight())
	
	-- self.body = love.physics.newBody(world, 
		-- ((self.position.x + self.image:getWidth()) / 2),
		-- ((self.position.y + self.image:getHeight()) / 2), 
		-- "dynamic"
		-- )
		
	-- self.shape = love.physics.newRectangleShape(
		-- self.position.x,
		-- self.position.y,
		-- self.image:getWidth(), 
		-- self.image:getHeight(),
		-- 0)
		
	-- self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	-- self.body:setLinearDamping( 0.001 )
	-- self.fixture:setUserData("player")
	-- self.body:setMassData(
		-- (self.position.x + self.image:getWidth()) / 2,
		-- (self.position.y + self.image:getHeight()) / 2,
		-- 64,
		-- 10)
	
end
}

function Player:init()
	if self.pnum == 2 then
		self.position = Vector(dimScreen.x - (50+self.image:getWidth()),dimScreen.y - 80)
	elseif self.pnum == 1 then
		self.position = Vector(50,dimScreen.y - 80)
	end
	
end

function Player:update(dt)
	-- delta holds direction of movement input
	local delta = Vector(0,0)
	
    if love.keyboard.isDown(self.keyleft) then
        delta.x = -1
		--self.body:applyForce(-400,0)
    elseif love.keyboard.isDown(self.keyright) then
        delta.x =  1
		--self.body:applyForce(0,400)
    end
    if love.keyboard.isDown(self.keyup) then
        delta.y = -1
		--self.body:applyForce(0,-400)
    elseif love.keyboard.isDown(self.keydown) then
        delta.y =  1
		--self.body:applyForce(0,400)
    end
	
	-- Want length 1 vector with correct x, y elements
    delta:normalize_inplace()

	--compute velocity based on normalized delta and acceleration
    self.velocity = self.velocity + delta 
		* self.acceleration * dt
	
	-- add drag so player stops when keys released
	-- with inertia
	self.velocity = self.velocity * self.drag

	-- clamp upper velocity bound
    if self.velocity:len() > self.max_velocity then
        self.velocity = self.velocity:normalized() * self.max_velocity
    end
	
	-- clamp lower velocity bound
	if self.velocity:len() < 1 then
		self.velocity = Vector(0,0)
	end

    self.position = self.position + self.velocity * dt
	self.collisionShape:moveTo(self.position.x + self.image:getWidth()/2,
		self.position.y + self.image:getHeight()/2)
	--self.body:setPosition(self.position.x, self.position.y)
	--self.position.x, self.position.y = self.body:getX(), self.body:getY()
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


