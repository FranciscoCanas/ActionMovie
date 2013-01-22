Bullet = Class{
	function(self, shape, startpos, facing)
		self.impacted = false
		self.radius = 3
		self.segments = 5
		self.position = startpos
		self.direction = facing
		self.force = 10000
		self.vel = self.direction * self.force
		self.damping = 0
		self.density = 0.1
		
		self.body = love.physics.newBody(world,
			self.position.x,
			self.position.y,
			"dynamic")
			
		self.shape = love.physics.newCircleShape(self.radius)
		
		self.fixture = love.physics.newFixture(
			self.body,
			self.shape,
			self.density)
		
		-- awkward but absolutely needed to pull out the
		-- object that owns the fixture during collision
		-- detection:
		self.fixture:setUserData(self)
		self.fixture:setCategory(BULLET)
			
		self.body:setLinearDamping(self.damping)
		self.body:setBullet(true)
		self.body:applyLinearImpulse(self.vel.x,self.vel.y)
		
	end
}

function Bullet:update(dt)
	self.position.x, self.position.y = self.body:getX(), self.body:getY()
end

function Bullet:draw()
	--love.graphics.setColor(255,0,0)
	-- love.graphics.circle('fill',
		-- self.position.x,
		-- self.position.y,
		-- self.radius,
		-- self.segments)
	--love.graphics.clear()	
end

function Bullet:impact()
	-- we'll put some particle effects bitnez here
	self.impacted = true
	self.body:destroy()
end