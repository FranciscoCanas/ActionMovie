--different types of enemies
FOLLOWPLAYER = 1

 --**********
 -- This type of enemy moves to a position defined by the table 
 -- movementPositions defined in the scene.
MOVETOSETSPOT = 2
--movementPositions = {}

Enemy = Class{
function(self, image, position, type, rand)
	self.rand = rand
	self:init()
--	wx, wy = cam:worldCoords(position.x, position.y)
	self.position = position
	self.behaviour = type
	images = {'art/Enemy1Sprite.png','art/Enemy1SpriteB.png','art/Enemy1SpriteC.png', 
				'art/Enemy2Sprite.png', 'art/Enemy2SpriteB.png'}

	-- set up image stuffs here
	if not image then
		self.type = math.random(1,5)
		randImage = images[self.type]
		
		self.image = love.graphics.newImage(randImage)
	else
		self.image = image --love.graphics.newImage(image)
	end
	--self.image = love.graphics.newImage('art/gunman.png')
	-- Set up anim8 for spritebatch animations:
	self.frameDelay = 0.5
	self.frameFlipH = nop
	self.frameFlipV = nop
	self.grid = Anim8.newGrid(128, 128, 
			self.image:getWidth(),
			self.image:getHeight())
	

	self.standAnim = Anim8.newAnimation(
			self.grid:getFrames(1, 1),
			self.frameDelay)
			
	self.runAnim = Anim8.newAnimation(
		self.grid('1-3', 1),
		self.frameDelay-0.2)
		
	self.shootAnim = Anim8.newAnimation(
		self.grid('1-2', 2),
		self.frameDelay, 'pauseAtEnd')

    self.hurtAnim = Anim8.newAnimation(
        self.grid(1,3),
        self.frameDelay, 'pauseAtEnd')
		
	self.diesAnim = Anim8.newAnimation(
		self.grid('1-2', 3),
		self.frameDelay, 'pauseAtEnd')
		
	self.animation = self.standAnim
	
	-- Set up for Timers
	self.timer = Timer.new()
	
	-- love.physics code starts here
	self.facing = Vector(-1,0)
	self.acceleration = 8000 * 120
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
	
	self.fixture:setCategory(ENEMY)	
	if (self.behaviour == MOVETOSETSPOT) then 
		self.fixture:setMask(OBSTACLE, BARRICADE, ENEMY)
	end

	self.body:setLinearDamping( self.damping )

-- gun particles:
	gunParticleImage = love.graphics.newImage( "art/gunParticle.png" )
	self.gunEmitter = love.graphics.newParticleSystem( gunParticleImage, 200 )
	self.gunEmitter:setEmissionRate(800)
	self.gunEmitter:setEmitterLifetime(0.02)
	self.gunEmitter:setParticleLifetime(0.075)
	self.gunEmitter:setSpread(3.14/4)
	self.gunEmitter:setSizes(0.05, 0.25)
	self.gunEmitter:setLinearAcceleration(0,9.8)
	self.gunEmitter:setSpeed(300,500)

-- particle sys stuff go here now!
	bloodParticleImage = love.graphics.newImage( "art/bloodParticle.png" )
	self.bloodEmitter = love.graphics.newParticleSystem( bloodParticleImage, 500 )
	self.bloodEmitter:setEmissionRate(500)
	self.bloodEmitter:setEmitterLifetime(0.02)
	self.bloodEmitter:setParticleLifetime(0.35)
	self.bloodEmitter:setSpread(3.14/3)
	self.bloodEmitter:setSizes(0.1, 0.5)
	self.bloodEmitter:setLinearAcceleration(0,100)
	self.bloodEmitter:setSpeed(200,300)
    self.bloodEmitter:stop()
end
}

function Enemy:init()
	self.isalive = true
	self.health = math.random(1,2)
	self.fired = false
	self.target = nil
	self.destination = nil

	self.inRange = 32  -- y axis shooting boundary
	self.maxTargetRange = dimScreen.x-300 --/ max distance from player to shoot
	self.minTargetRange = 100 --/ min distance from player to shoot
	self.observePlayerRange = dimScreen.x-100 -- distance to interact with player
	
	if (self.rand) then
		self.scalex = math.random(50, 70)/ 100
		self.scaley = math.random(50, 90)/ 100
	else
		self.scalex = 0.7
		self.scaley = 0.7
	end

	self.width = 128 * self.scalex
	self.height = 128 * self.scaley

	self.counted = false
	
	-- state machine info
	dying = 0
	idle = 1
	moveToShoot = 2
	shoot = 4
	moveToCover = 8
    hurt = 16
	self.state = idle
	
	-- direction to move to during an update
	self.delta = Vector(0,0)
	
	-- sound stuff
	gunsoundlist = { "sfx/gunshot1.ogg", "sfx/gunshot2.ogg", "sfx/gunshot3.ogg"}
	screamsoundlist = { "sfx/scream1.ogg", "sfx/scream2.ogg", "sfx/scream3.ogg"}
	self.isScreaming = false

	-- advancement info
	self.tier = 1 
	self.coverCount = math.random(1, 3) -- number of times cover before moving up
	
end

function Enemy:update(dt)
	-- update particles
	self.gunEmitter:update(dt)
	self.bloodEmitter:update(dt)
	-- update the timer
	self.timer:update(dt)
	-- delta holds direction of movement input
	self.delta = Vector(0,0)
	
	if self.fired then 
		return
	end
	
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
   elseif self.state == dying then
        return
   elseif self.state == hurt then
        return
   end
   
   if (self.delta.x < 0) then
		self.facing = Vector(-1,0)		
	elseif (self.delta.x > 0) then
		self.facing = Vector(1,0)
	end
	
	if self.facing.x == -1 then
		--self.frameFlipH = -1
		self.animation:flipH()
	else
		--self.frameFlipH = 1
		self.animation:flipH()
	end
   
   self.body:applyForce(self.delta.x * self.acceleration * dt, 
		self.delta.y * self.acceleration * dt)
	
	self.position.x, self.position.y = 
		self.body:getX() - self.width / 2, 
		self.body:getY() - self.height / 2
		
	self:setTilePosition()
end


function Enemy:draw()
	--if self.isalive then
		--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	--end
	self.animation:draw(self.image, 
			self.position.x,
			self.position.y,
			0, -- angle
			self.scalex, -- x scale
			self.scaley, -- y scale
			0, -- x offset
			0 -- y offset
			--self.frameFlipH,
			--self.frameFlipV
			)
 love.graphics.draw(self.gunEmitter)
 love.graphics.draw(self.bloodEmitter)
 --jumperDebug.drawPath(font12, self.path, true)
end

function Enemy:setPosition(v)
	self.body:setX(v.x)
	self.body:setY(v.y)
	self.position.x = v.x
	self.position.y = v.y
end

-- when enemy decides where to go
function Enemy:idle()
	if self.animation ~= self.standAnim then
		self.animation = self.standAnim
	end
	if self.target == nil then
		if (self.behaviour == FOLLOWPLAYER) then
			self:SetNearestTarget()
		elseif (self.behaviour == MOVETOSETSPOT) then
			-- target is set to one of preapproved cover positions
			--print("type:"..self.type.." tier:"..self.tier.."\n")
			iter = math.random(1, 4)
			for i = iter, iter+4, 1 do 
				--print("type", self.type, "pos: ", i)
				self.target = movementPositions[self.tier][i%4+1]
				
				if not self.target[5] then
					break
				end
			end
			--print("type:"..self.type.." target:", self.target[1], self.target[2])
			self.target[5] = true
		end 
	end
	
	if (self.behaviour == FOLLOWPLAYER) and (self:DistanceToTarget() 
			< self.observePlayerRange) then
		self.state = moveToShoot
	elseif (self.behaviour == MOVETOSETSPOT) then
		--calculate the path and order the move
		--change state to move to cover
		x_, y_ = self:getCenter()
		tx, ty = background:toTile(x_, y_)
		if not ((tx == self.target[1]) and (ty == self.target[2])) then
			_path, length = pather:getPath(tx, ty, self.target[1], self.target[2])
			if _path then
				self:orderMove(_path)
				self.state = moveToCover
				--print("type:"..self.type.." state chaged to moveTocover from idle")
			else 
				self.target = nil
			end
		end
	end
	
end

-- Sends to the enemy the order to move
function Enemy:orderMove(path)
  self.path = path -- the path to follow
  self.isMoving = true -- whether or not the enemy should start moving
  self.cur = 1 -- indexes the current reached step on the path to follow
  self.there = true -- whether or not the enemy has reached a step
end

function Enemy:moveToCover()
	-- call move until reach end
	-- if end add timer to pause for a random amount of time 
	-- and then change target, calculate path  to call moveToShootingSpot
	-- 
	if self.isMoving then
		self:move(dt)
	else
		self.animation = self.standAnim
		self.state = idle
--		--print("type: "..self.type.." state changed to idle from moveTocover")
		self.timer:add(math.random(1, 5), function()
			x_, y_ = self:getCenter()
			tx, ty = background:toTile(x_, y_)
			_path, length = pather:getPath(tx, ty, self.target[3], self.target[4])
			if _path then
				self:orderMove(_path)
				self.state = moveToShoot
--				--print("type: "..self.type.." state changed to moveToShoot from idle")
			else 
				--error handling
				--print("error")
				self.target = nil
				self.state = idle

			end
			end)
		-- path, length = pather:getPath(self.tile_x, self.tile_x, self.target[3], self.target[4])
		-- self:orderMove(path)
	end
end

function Enemy:moveToShoot()
	-- Find nearest target if we don't have a target
	if self.target == nil then
		self:SetNearestTarget()
	end
	
	if self.target ~= nil then
		self:MoveToShootingSpot()
	else 
--		--print("type: "..self.type.." state changed to idle from moveToShoot")
		self.state = idle
	end
end

-- Moves the enemy by checking its current route and whether
-- it has reached the end of it.
function Enemy:move(dt)
  if self.isMoving then
  	self.animation = self.runAnim
    if not self.there then
      	-- Walk to the assigned location
     	--self.moveToTile(self.path[self.cur].x,self.path[self.cur].y, dt)
     	local dx = (self.path[self.cur].x*32 + 16) - self.body:getX() 	
		local dy = (self.path[self.cur].y*32 + 16) - self.body:getY()
		if (math.pow(dx, 2) + math.pow(dy, 2) <= math.pow(10, 2)) then
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
       -- _path = nil
      end
    end
  end
end

-- Will move the bad guy towards a shooting channel
-- within range so they can fire at player.
function Enemy:MoveToShootingSpot()
	if (self.behaviour == FOLLOWPLAYER) then
		local tx, ty = background:toTile(
			self.target.body:getX(),
			self.target.body:getY())
		local dx = self.target.body:getX() - self.body:getX() 	
		local dy = self.target.body:getY() - self.body:getY()
		
		-- figure out where we need to go to shoot the target
		-- case 1: player is sufficiently far from enemy 
		-- on the x axis:
		if (math.abs(dx) < self.minTargetRange) then
			-- enemy too close to player. must back off.
			 self.delta.x = -dx		
		elseif (math.abs(dx) > self.maxTargetRange) then
			-- enemy too far from player. must go approach.
			 self.delta.x = dx
		end
		
		-- are we close enough to shoot?
		if (math.abs(dy) < self.inRange) then
			-- is there anything (specifically another enemy) between this enemy and the target?
			toShoot = true
			curEnemy = self
			world:rayCast(self.body:getX(), self.body:getY(), --enemy location
						self.target.body:getX(), self.target.body:getY(), --target location
						Enemy.rayCallback) -- order ofx rayCallback not necessary in order of what object is hit first
			if toShoot then
				-- has a clear shot
				self.state = shoot
			else
				self.state = moveToShoot
				-- doesn't have a clear shot.
				self.delta.y = self.body:getY() + self.height
			end
		
		else
			-- player not in range, but right distance apart
			-- player is just right. so move to his y coord
			self.delta.y = dy
			--self.delta:normalize_inplace()	
		end
	self.delta:normalize_inplace()	
	elseif (self.behaviour == MOVETOSETSPOT) then
		if self.isMoving then
			self:move(dt)
		else
			--print("type: "..self.type.." state changed to shoot in moveToShootingSpot")
			self.state = shoot
		end
	end
end

function Enemy:shoot()
	if self.fired then
		return 
	else
		-- do the animation
		self.fired = true
		self.animation = self.shootAnim
		self.animation:gotoFrame(1)
		self.timer:add(1.5, function() 
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
		self.gunEmitter:reset()
		self.gunEmitter:setDirection( aim )
		
		pos = pos + self.facing * 25
        self.gunEmitter:setPosition(pos.x, pos.y-10)
		self.timer:add(0.25, function()
			
			self.gunEmitter:start()
			table.insert(bullets,Bullet(null, pos, bulletDir))	
			local vol = math.random(30, 50) / 100
			local pitch = math.random(50, 125) / 100
	
			TEsound.play(gunsoundlist, "gunshot", vol, pitch)		
		end)	
	end
end

function Enemy:stopShoot()
	self.fired = false
	self.animation = self.standAnim
	self.state = idle
	--print("type: "..self.type.." state chagned to idle in stopShoot")
	if (self.behaviour == MOVETOSETSPOT) then
		--print(self.type, "target removed")
		self.target[5] = false
		self.target = nil
		self.coverCount = self.coverCount - 1
		if (self.coverCount == 0) then
			self.coverCount = math.random(1, 3)
			self.tier = self.tier + 1
			if (self.tier > #movementPositions) then
				-- when no more tiers, follow players instead
				--print("behaviour changed")
				self.behaviour = FOLLOWPLAYER
				self.fixture:setMask(BARRICADE)
			end
		end 
	end
end

-- Resolve being shot here.
-- called by world collision callback in main.lua
function Enemy:isShot(bullet, collision)
local pos = Vector(self.position.x + 10, self.position.y + 20)

    -- change animation temporarily
    self.animation = self.hurtAnim
    self.state = hurt
    self.timer:add(0.5, function()
            self.state = idle
            self.animation = self.standAnim
        end)

-- set up the bloody splurty guy
	self.bloodEmitter:setDirection(0)
	if math.random(1,2) == 1 then
		self.bloodEmitter:setDirection(3.14)
	end
		--self.bloodEmitter:reset()
		self.bloodEmitter:setPosition(pos.x + 32, pos.y + 32)
		self.bloodEmitter:start()	
	
	if self.state == dying then
		return
	end
	
	if not self.isScreaming then
		local vol = math.random(15, 35) / 100
		local pitch = math.random(45, 100) / 100
		self.isScreaming = true
		TEsound.play(screamsoundlist, "scream", vol, pitch, function() self.isScreaming = false end)		
	end
	self.health = self.health - 1
	if self.health < 0 then 
		self:dies()
	end
end

-- where enemies goes to die
function Enemy:dies()
	self.state = dying
	self.timer:clear() -- clears all queued actions
	self.timer:add(1.0, function() 
					self.isalive = false 
					self.fixture:destroy()
				end)
	
	self.animation = self.diesAnim
	
end

function Enemy:DistanceToTarget()
	local dx = self.maxTargetRange + 1
	if self.target ~= null then
		local tx = self.target.body:getX()
		dx = math.abs(tx - self.body:getX())
	end
	
	return dx
end

-- Some simple AI decision making functions

-- Checks distance to each playing player and selects
-- the closest one to target, provided said player
-- is within range.
function Enemy:SetNearestTarget()
	self.target = nil

	if self.behaviour == FOLLOWPLAYER then 
		local leastdist = self.observePlayerRange
		local mx, my = self.body:getWorldCenter()
		
		
		-- Update the players.
		for i,player in ipairs(players) do
			if player.isplaying and player.isalive then
				local px, py = player.body:getWorldCenter()
				
				--thisdist = (Vector(px, py) - Vector(mx, my)):len()
				-- y dist only:
					thisdist = math.abs(py-my)
				
				if thisdist < leastdist then
					leastdist = thisdist
					self.target = player
				end
			end
		end
	end
end

-- the function to call when the ray casted by rayCast hits a fixture
function Enemy.rayCallback(fixture, x, y, xn, yn, fraction)
	object = fixture:getUserData()
	if object:is_a(Enemy) then 
		if (player1.isplaying and player2.isplaying) then
			curEnemy:SetNearestTarget()
		end
		--curEnemy.delta.y = object.body:getY() + curEnemy.height - curEnemy.body:getY()
		toShoot = false 
		return 0 -- stops ray from going through other fixtures
	end
	return 1 -- Continues with ray cast through all shapes.
end

-- sets the logical map tile position for this enemy
function Enemy:setTilePosition()
	self.tile_x, self.tile_y = 
		background:toTile(self.position.x, 
						self.position.y)
end

function Enemy:getCenter()
	return self.body:getX(), self.body:getY()
end
