--different types of enemies
FOLLOWPLAYER = 1
MOVETOSETSPOT = 2
movementPositions = {}

Bystander = Class{
function(self, image, position)
	
	self:init()
--	wx, wy = cam:worldCoords(position.x, position.y)
	self.position = position
--	self.behaviour = type

	images = {'art/bystander1.png','art/bystander1a.png','art/bystander1b.png',
				'art/bystander2.png','art/bystander2a.png'}
	if not image then
		self.type = math.random(1,# images)
		randImage = images[self.type]
		
		self.image = love.graphics.newImage(randImage)
	else
		self.image = image --love.graphics.newImage(image)
	end

	--self.image = love.graphics.newImage('art/gunman.png')
	-- Set up anim8 for spritebatch animations:
	self.frameDelay = 0.5
	self.frameFlipH = 1
	self.frameFlipV = 1
	self.grid = Anim8.newGrid(128, 128, 
			self.image:getWidth(),
			self.image:getHeight())
	
	self.standAnim = Anim8.newAnimation( 
			self.grid:getFrames(1, 1),
			self.frameDelay, 'pauseAtEnd')
			
	self.runAnim = Anim8.newAnimation(
		self.grid('2-3', 1),
		self.frameDelay, 'pauseAtEnd')
		
	self.danceAnim = Anim8.newAnimation(
		self.grid('1-2',1),
		self.frameDelay, 'pauseAtEnd')
		
	self.animation = self.runAnim
	
	-- Set up for Timers
	self.timer = Timer.new()
	self.width = 128 * self.scalex
	self.height = 128 * self.scaley
	-- love.physics code starts here
	self.facing = Vector(-1,0)
	self.acceleration = 8000
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
	--self.fixture:setCategory(Bystander)	
		
	self.body:setLinearDamping( self.damping )

-- particle sys stuff go here now!
	gunParticleImage = love.graphics.newImage( "art/gunParticle.png" )
	self.gunEmitter = love.graphics.newParticleSystem( gunParticleImage, 100 )
	self.gunEmitter:setEmissionRate(500)
	self.gunEmitter:setEmitterLifetime(0.01)
	self.gunEmitter:setParticleLifetime(0.25)
	self.gunEmitter:setSpread(3.14/3)
	self.gunEmitter:setSizes(0.05, 0.5)
	self.gunEmitter:setLinearAcceleration(0,0)
	self.gunEmitter:setSpeed(140,260)
end
}

function Bystander:init()
	self.isalive = true
	self.health = 3
	self.fired = false
	self.target = nil
	self.destination = nil
	self.scalex = 0.6
	self.scaley = 0.6

	self.inRange = 32  -- y axis shooting boundary
	self.maxTargetRange = 400 --/ max distance from player to shoot
	self.minTargetRange = 250 --/ min distance from player to shoot
	self.observePlayerRange = 600 -- distance to interact with player
	
	self.width = 40
	self.height = 80

	self.counted = false
	
	-- state machine info
	dying = 0
	idle = 1
	moveToShoot = 2
	shoot = 4
	moveToCover = 8
	moveLeft = 16
	moveRight = 32
	self.state = idle
	
	-- direction to move to during an update
	self.delta = Vector(0,0)
	
	-- sound stuff
	gunsoundlist = { "sfx/gunshot1.ogg", "sfx/gunshot2.ogg"}
	screamsoundlist = { "sfx/scream1.ogg", "sfx/scream2.ogg", 
		"sfx/scream3.ogg"}
	
end


function Bystander:setPosition(v)
	self.body:setX(v.x)
	self.body:setY(v.y)
	self.position.x = v.x
	self.position.y = v.y
end

function Bystander:update(dt)
	-- update particles
	self.gunEmitter:update(dt)
	-- update the timer
	self.timer:update(dt)
	-- delta holds direction of movement input
	self.delta = Vector(0,0)
	
   -- this is our finite state machine handling
   -- structure here
   if self.state == idle then
	self:idle()
   elseif self.state == moveLeft then
	self.delta.x = -1
   elseif self.state == moveRight then
	self.delta.x = 1
   end
   
   if (self.delta.x < 0) then
		self.facing = Vector(-1,0)		
	elseif (self.delta.x > 0) then
		self.facing = Vector(1,0)
	end
	
	if self.facing.x == -1 then
		self.frameFlipH = -1
	else
		self.frameFlipH = 1
	end
   
   self.body:applyForce(self.delta.x * self.acceleration, 
		self.delta.y * self.acceleration)
	
	self.position.x, self.position.y = 
		self.body:getX() - self.width / 2, 
		self.body:getY() - self.height / 2
		
	self:setTilePosition()
end


function Bystander:draw()
	self.animation:draw(self.image, 
			self.position.x,
			self.position.y,
			0, -- angle
			self.scalex, -- x scale
			self.scaley, -- y scale
			0, -- x offset
			0, -- y offset
			self.frameFlipH,
			self.frameFlipV
			)
end

function Bystander:moveToShoot()
	-- Find nearest target if we don't have a target
	if self.target == nil then
		self:SetNearestTarget()
	end
	
	if self.target ~= nil then
		self:MoveToShootingSpot()
	else 
		self.state = idle
	end
end

-- when Bystander decides where to go
function Bystander:idle()
	if self.animation ~= self.standAnim then
		self.animation = self.standAnim
		
		self.timer:add(math.random(1,4), function()
			if math.random(1,4) <= 2 then
				self.state = moveLeft
				
			else
				self.state = moveRight	
						
			end
			self.animation = self.runAnim
	
			self.timer:add(math.random(1,4), function()
				self.state = idle
			end)
			
		end)
	end	
end

function Bystander:DistanceToTarget()
	local dx = self.maxTargetRange + 1
	if self.target ~= null then
		local tx = self.target.body:getX()
		dx = math.abs(tx - self.body:getX())
	end
	
	return dx
end

function Bystander:moveToCover()
	-- call move until reach end
	-- if end add timer to pause for a random amount of time 
	-- and then change target, calculate path  to call moveToShootingSpot
	-- 
	if self.isMoving then
		self:move(dt)
	else
		self.animation = self.standAnim
		self.state = idle
		self.timer:add(math.random(1, 5), function()
			_path, length = pather:getPath(tx, ty, self.target[3], self.target[4])
			self:orderMove(_path)
			self.state = moveToShoot
			end)
		-- path, length = pather:getPath(self.tile_x, self.tile_x, self.target[3], self.target[4])
		-- self:orderMove(path)
	end
end

function Bystander:shoot()
	if self.fired then
		return 
	else
		-- do the animation
		self.fired = true
		self.animation = self.shootAnim
		self.animation:gotoFrame(1)
		self.timer:add(1.0, function() 
					self:stopShoot() 
				end)
		-- face the target
		if self.behaviour == FOLLOWPLAYER then
			targetBody = self.target.body--:getWorldCenter()
		else
			targetBody = player1.body or player2.body
		end
		local tx, ty = targetBody:getWorldCenter()
		local pos = Vector(0,0)
		-- figure out origin to fire from first
		pos.x, pos.y = self.body:getWorldCenter()
		local dx = pos.x - tx
		self.delta = Vector(0,0)
		self.facing = Vector(-dx, 0):normalize_inplace()
		-- add some hilariously bad accuracy modifying
		-- randomness
		local ry = (math.random(0, 4) - 2) / 10
		local bulletDir = Vector(self.facing.x,ry)
		local aim = 0
		if (bulletDir.x < 0) then
			aim = 3.14
		end

		self.timer:add(0.10, function()
				self.gunEmitter:setDirection( aim )
			end)
		
		pos = pos + self.facing * 25
		self.timer:add(0.25, function()
			table.insert(bullets,Bullet(null, pos, bulletDir))	
			TEsound.play(gunsoundlist)	
		end)	
	end
end

function Bystander:stopShoot()
	self.fired = false
	self.animation = self.standAnim
	self.state = idle
	if (self.behaviour == MOVETOSETSPOT) then
		self.target = nil
	end
end

-- Resolve being shot here.
-- called by world collision callback in main.lua
function Bystander:isShot(bullet, collision)
	if self.state == dying then
		return
	end
	TEsound.play(screamsoundlist)		
	self.health = self.health - 1
	if self.health < 0 then 
		self:dies()
	end
end

-- where enemies goes to die
function Bystander:dies()
	self.state = dying
	self.timer:clear() -- clears all queued actions
	self.timer:add(1.0, function() 
					self.isalive = false 
					self.fixture:destroy()
				end)
	
	self.animation = self.diesAnim
	
end

-- Some simple AI decision making functions

-- Checks distance to each playing player and selects
-- the closest one to target, provided said player
-- is within range.
function Bystander:SetNearestTarget()
	self.target = nil

	if self.behaviour == FOLLOWPLAYER then 
		local leastdist = self.observePlayerRange
		local mx, my = self.body:getWorldCenter()
		
		
		-- Update the players.
		for i,player in ipairs(players) do
			if player.isplaying and player.isalive then
				local px, py = player.body:getWorldCenter()
				
				thisdist = (Vector(px, py) - Vector(mx, my)):len()
				
				if thisdist < leastdist then
					leastdist = thisdist
					self.target = player
				end
			end
		end
	end
end

-- Will move the bad guy towards a shooting channel
-- within range so they can fire at player.
function Bystander:MoveToShootingSpot()
	if (self.behaviour == FOLLOWPLAYER) then
		local tx, ty = background:toTile(
			self.target.body:getX(),
			self.target.body:getY())
		local dx = self.target.body:getX() - self.body:getX() 	
		local dy = self.target.body:getY() - self.body:getY()
		
		-- figure out where we need to go to shoot the target
		-- case 1: player is sufficiently far from Bystander 
		-- on the x axis:
		if (math.abs(dx) < self.minTargetRange) then
			-- Bystander too close to player. must back off.
			 self.delta.x = -dx		
		elseif (math.abs(dx) > self.maxTargetRange) then
			-- Bystander too far from player. must go approach.
			 self.delta.x = dx
		end
		
		-- are we close enough to shoot?
		if (math.abs(dy) < self.inRange) then
			-- is there anything (specifically another Bystander) between this Bystander and the target?
			toShoot = true
			curBystander = self
			world:rayCast(self.body:getX(), self.body:getY(), --Bystander location
						self.target.body:getX(), self.target.body:getY(), --target location
						rayCallback) -- order ofx rayCallback not necessary in order of what object is hit first
			if toShoot then
				-- has a clear shot
				self.state = shoot
			else
				-- doesn't have a clear shot.
				self.delta.y = self.body:getY() + self.height
			end
		
		else
			-- player not in range, but right distance apart
			-- player is just right. so move to his y coord
			self.delta.y = dy
			self.delta:normalize_inplace()	
		end
	elseif (self.behaviour == MOVETOSETSPOT) then
		if self.isMoving then
			self:move(dt)
		else
			self.state = shoot
		end
	end
end

-- the function to call when the ray casted by rayCast hits a fixture
function rayCallback(fixture, x, y, xn, yn, fraction)
	object = fixture:getUserData()
	if object:is_a(Bystander) then 
		if (player1.isplaying and player2.isplaying) then
			curBystander:SetNearestTarget()
		end
		--curBystander.delta.y = object.body:getY() + curBystander.height - curBystander.body:getY()
		toShoot = false 
		return 0 -- stops ray from going through other fixtures
	end

	return 1 -- Continues with ray cast through all shapes.
end

-- Sends to the Bystander the order to move
function Bystander:orderMove(path)
  self.path = path -- the path to follow
  self.isMoving = true -- whether or not the Bystander should start moving
  self.cur = 1 -- indexes the current reached step on the path to follow
  self.there = true -- whether or not the Bystander has reached a step
end

-- Moves the Bystander by checking its current route and whether
-- it has reached the end of it.
function Bystander:move(dt)
  if self.isMoving then
  	self.animation = self.runAnim
    if not self.there then
      	-- Walk to the assigned location
     	--self.moveToTile(self.path[self.cur].x,self.path[self.cur].y, dt)
     	local dx = self.path[self.cur].x*32 - self.body:getX() 	
		local dy = self.path[self.cur].y*32 - self.body:getY()
		if (math.pow(dx, 2) + math.pow(dy, 2) <= math.pow(20, 2)) then
			self.there = true
		else
			self.delta.x = dx
			self.delta.y = dy
			self.delta:normalize_inplace()	
		end
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

-- sets the logical map tile position for this Bystander
function Bystander:setTilePosition()
	self.tile_x, self.tile_y = 
		background:toTile(self.position.x, 
						self.position.y)
end

function Bystander:getCenter()
	return self.body:getX(), self.body:getY()
end
