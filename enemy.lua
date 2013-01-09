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
	
	-- Set up for Timers
	self.timer = Timer.new()
	
	-- love.physics code starts here
	self.facing = Vector(-1,0)
	self.acceleration = 500
	self.damping = 15
	self.density = 2
	
	self.body = love.physics.newBody(world, 
		(self.position.x + self.width) / 2,
		(self.position.y + self.height) / 2, 
		--self.position.x,
		--self.position.y,
		"dynamic"
		)
	self.body:setFixedRotation(true)

	self.shape = love.physics.newRectangleShape(
		self.width /3,
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
	self.inRange = 25 -- 
	self.maxTargetRange = 500 --/ background.map.tileWidth
	self.minTargetRange = 250 --/ background.map.tileHeight
	self.width = 64
	self.height = 64
	
	-- state machine info
	idle = 1
	moveToShoot = 2
	shoot = 4
	moveToCover = 8
	self.state = moveToShoot
	
	-- direction to move to during an update
	self.delta = Vector(0,0)
	
end

function Enemy:update(dt)
	-- delta holds direction of movement input
	self.delta = Vector(0,0)
	
   -- this is our finite state machine handling
   -- structure here
   if self.state == moveToShoot then
		self:moveToShoot()
		self.animation = self.runAnim
   elseif self.state == shoot then
		self:shoot()
   elseif self.state == idle then
		self:idle()
   elseif self.state == moveToCover then
		self:moveToCover()
   end
   
   if (self.delta.x < 0) then
		self.facing = Vector(-1,0)
		self.frameFlipH = true
	elseif (self.delta.x > 0) then
		self.facing = Vector(1,0)
		self.frameFlipH = false
	end
   
   self.body:applyForce(self.delta.x * self.acceleration, 
		self.delta.y * self.acceleration)
	
	self.position.x, self.position.y = 
		self.body:getX() - self.width / 2, 
		self.body:getY() - self.height / 2
		
	self:setTilePosition()
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

function Enemy:moveToShoot()
	-- Find nearest target if we don't have a target
	self:SetNearestTarget()

	
	if self.target ~= nil then
		self:MoveToShootingSpot()
	end
end

function Enemy:idle()
--
end

function Enemy:moveToCover()
--
end

function Enemy:shoot()
	if self.fired then
		return 
	end
		-- do the animation
		self.fired = true
		self.animation = self.shootAnim
		self.animation:gotoFrame(1)
		self.timer:add(0.5, function() self:stopShoot() end)
		-- figure out origin to fire from first
		local pos = Vector(0,0)
		pos.x, pos.y = self.body:getWorldCenter()
		pos = pos + self.facing * 25
		table.insert(bullets,Bullet(null, pos, self.facing))		
end

function Enemy:stopShoot()
	self.fired = false
	self.animation = self.standAnim
	self.state = moveToShoot
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
function Enemy:MoveToShootingSpot()
	local tx, ty = background:toTile(
			self.target.position.x,
			self.target.position.y)
	
	local dx = self.body:getX() - self.target.body:getX()
	
	local dy = self.body:getY() - self.target.body:getY()
	
	-- figure out where we need to go to shoot the target
	-- case 1: player is sufficiently far from enemy 
	-- on the x axis:
	if (dx < self.minTargetRange) then
		-- enemy too close to player. must back off.
		self.delta.x = dx		
	elseif (dx > self.maxTargetRange) then
		-- enemy too far from player. must go approach.
		self.delta.x = -dx
	end
	
	-- are we close enough to shoot?
	if (dy < self.inRange) then
		self.state = shoot
	end
	-- player is just right. so move to his y coord
	self.delta.y = -dy
	--self.delta:normalize_inplace()
		

	
end

-- Sends to the enemy the order to move
function Enemy:orderMove(path)
  self.path = path -- the path to follow
  self.isMoving = true -- whether or not the enemy should start moving
  self.cur = 1 -- indexes the current reached step on the path to follow
  self.there = true -- whether or not the enemy has reached a step
end

-- Moves the enemy by checking its current route and whether
-- it has reached the end of it.
function Enemy:move(dt)
  if self.isMoving then
    if not self.there then
      -- Walk to the assigned location
      self.moveToTile(self.path[self.cur].x,self.path[self.cur].y, dt)
    else
      -- Make the next step move
      if self.path[self.cur+1] then
        self.cur = self.cur + 1
        self.there = false
      else
        -- Reached the goal!
        self.isMoving = false
        self.path = nil
      end
    end
  end
end

-- sets the logical map tile position for this enemy
function Enemy:setTilePosition()
	self.tile_x, self.tile_y = 
		background:toTile(self.position.x, 
						self.position.y)
end

