Bullet = Class{
	function(self, shape, startpos, facing)
		self.radius = 10
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
			
		self.shape = love.physics.newCircleShape(3)
		
		self.fixture = love.physics.newFixture(
			self.body,
			self.shape,
			self.density)
			
		self.body:setLinearDamping(self.damping)
		self.body:setBullet(true)
		self.body:applyLinearImpulse(self.vel.x,self.vel.y)
		
	end
}

function Bullet:update(dt)
	self.position.x, self.position.y = self.body:getX(), self.body:getY()
end

function Bullet:Draw()
	love.graphics.setColor(255,0,0)
	love.graphics.circle(fill,
		self.position.x,
		self.position.y,
		self.radius,
		self.segments)
		
end