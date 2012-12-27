Bullet = Class{
	function(self, shape, startpos, facing)
		self.position = startpos
		self.direction = facing
		self.foce = 10000
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
		self.body:setLinearVelocity(self.vel.x, self.vel.y)
		
	end
}

function Bullet:Draw()
	
end