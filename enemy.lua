Enemy = Class{
function(self, image, position)
	--self.image = love.graphics.newImage(image)
	self:init()
	self.position = position
	
	self.image = love.graphics.newImage('art/gunman.png')
	-- Set up anim8 for spritebatch animations:
	self.frameDelay = 0.2
	self.frameFlipH = false
	self.frameFlipV = false
	self.grid = Anim8.newGrid(80, 94, 
			self.image:getWidth(),
			self.image:getHeight())
	
	self.standAnim = Anim8.newAnimation('loop', 
			self.grid:getFrames('1-8, 1'),
			self.frameDelay)
			
	self.runAnim = Anim8.newAnimation('loop',
		self.grid('1-3, 2'),
		self.frameDelay)
		
	self.shootAnim = Anim8.newAnimation('loop',
		self.grid('1-2, 3'),
		self.frameDelay)
		
	self.diesAnim = Anim8.newAnimation('loop',
		self.grid('4-8, 3'),
		self.frameDelay)
		
	self.animation = self.standAnim
	
	-- love.physics code starts here
	self.facing = Vector(-1,0)
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
		self.width / 3,
		self.height
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
	self.isalive = true
	self.health = 3
	self.fired = false
	self.target = nil
	self.destination = nil
	self.maxTargetRange = 500
	self.shootRange = 250
	self.width = 64
	self.height = 64
end

function Enemy:update(dt)
	-- delta holds direction of movement input
	local delta = Vector(0,0)
	
   
	-- Handle the animation switching here as needed:
	if not self.fired then
		-- decide where/if to move here
		if not self.target then
			self:SetNearestTarget()
		end
		
		if self.target then 
			self:DirToTarget(delta)
		end
		
		if (delta.x ~= 0) and (delta.y ~= 0) then
			moved = true
			delta = delta * self.acceleration
			self.body:applyForce(delta.x, delta.y)
		end
		
		if moved then 
			self.facing = delta
			self.animation = self.runAnim
		else
			self.animation = self.standAnim
		end
	end
	
	self.position.x, self.position.y = 
		self.body:getX() - self.width / 2, 
		self.body:getY() - self.height / 2
end


function Enemy:draw()
love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
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

function Enemy:fire()
		-- do the animation
		self.fired = true
		self.animation = self.shootingAnim
		self.animation:gotoFrame(1)
		self.timer:add(0.5, function() self:stopFire() end)
		-- figure out origin to fire from first
		local pos = Vector(0,0)
		pos.x, pos.y = self.body:getWorldCenter()
		pos = pos + self.facing * 25
		table.insert(bullets,Bullet(null, pos, self.facing))
end

function Enemy:stopFire()
	self.fired = false
	self.animation = self.standAnim
end

-- Resolve being shot here.
-- called by world collision callback in main.lua
function Enemy:isShot(bullet, collision)
	self.health = self.health - 1
end

-- Some simple AI decision making functions

-- Checks distance to each playing player and selects
-- the closest one to target, provided said player
-- is within range.
function Enemy:SetNearestTarget()
self.target = nil
local leastdist = self.maxTargetRange
-- Update the players.
	for i,player in ipairs(players) do
		if player.isplaying and player.isalive then
			thisdist = (player.position - self.position):len()
			if thisdist < leastdist then
				leastdist = thisdist
				self.target = player
			end
		end
	end
end

-- Will move the bad guy towards a shooting channel
-- within range so they can fire at player.
function Enemy:DirToTarget(delta)
	-- vector towards target
	delta = (self.position 
		- self.target.position):normalize_inplace()
		
	if math.abs(self.position.x 
		- self.position.y) < self.shootRange then
			delta.x = 0
		end
end


