--require 'main'
--require 'TESound.TEsound'

SCREEN_X = 2560
SCREEN_Y = 1600

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
		self.image = love.graphics.newImage('art/WomanSprite.png')
        if ARCADE then
            self.keyup = "up"
            self.keyleft = "left"
            self.keyright = "right"
            self.keydown =  "down"  
            self.keyfire = "z"
            self.keyroll = "x"
		end
	elseif num == 2 then
		self.pnum = 2
		self.keyup = "o"
		self.keyright = ";"
		self.keyleft = "k"
		self.keydown = "l"
		self.keyfire = "j"
		self.keyroll = "h" 
		self.image = love.graphics.newImage('art/ManSprite.png')
        if ARCADE then
            self.keyup = "r"
            self.keyleft = "d"
            self.keyright = "g"
            self.keydown =  "f"  
            self.keyfire = "a"
            self.keyroll = "s"
        end
		
	end
	self:init()
	-- Set up for Timers
	self.timer = Timer.new()
	
	-- Set up anim8 for spritebatch animations -----------------------------
	self.frameDelay = 0.3
	self.frameFlipH = nop
	self.frameFlipV = nop
	self.grid = Anim8.newGrid(128, 128, 
		self.image:getWidth(),
		self.image:getHeight())
	
	self.standAnim = Anim8.newAnimation(
		self.grid(1,1),
		self.frameDelay)
			
			
	self.runAnim = Anim8.newAnimation(
		self.grid('2-3', 1),
		self.frameDelay)
		

	--ready for shooting animation here:
	self.shootingAnim = Anim8.newAnimation(
		self.grid('1-2', 2),
		self.frameDelay)
		
		
	self.hurtAnim = Anim8.newAnimation(
		self.grid('1-2', 3),
		self.frameDelay)
		
		
	self.animation = self.standAnim
	
	
	-- sound stuffs go here
	self.gunsoundlist = { "sfx/gunshot1.ogg", "sfx/gunshot2.ogg"}
	--, "sfx/gunshot3.ogg" }
	
	
	-- particle sys stuff go here now!
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

function Player:init()
	self.health = 10
	self.isplaying = false
	self.scale = 0.5
	self.width = 64 -- size we will draw each frame at
	self.height = 64 -- size we will draw each frame at
	self.facing = Vector(1,0)
	self.fired = false -- keeps track of shooting state
	self.isalive = true -- keeps track of aliveness. duh.
	self.ishurt = false

	
	if self.pnum == 1 then
		self.position = Vector(4900, 900)
	elseif self.pnum == 2 then
		self.position = Vector(4200, 940)
	end

	-- love.physics code starts here -----------------------------------------
	self.facing = Vector(1,0) -- normalized direction vector
	self.acceleration = 12000 * 120
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
		self.width/3,
		self.height
		)
		
	self.fixture = love.physics.newFixture(
		self.body, 
		self.shape, 
		self.density)

	-- awkward but absolutely needed to pull out the
	-- object that owns the fixture during collision
	-- detection:
	self.fixture:setUserData(self)
	self.fixture:setCategory(PLAYER)
		
	self.body:setLinearDamping( self.damping )
	
end

function Player:setPosition(v)
	self.body:setX(v.x)
	self.body:setY(v.y)
	self.position.x = v.x
	self.position.y = v.y
end

function Player:update(dt)
	-- animation stuff
	self.animation:update(dt)
	-- sound stuff
	TEsound.cleanup()
	-- Inc timers
	self.timer:update(dt)
	-- particle stuffs
	self.gunEmitter:update(dt)
	self.bloodEmitter:update(dt)
	
	-- delta holds direction of movement input
	local delta = Vector(0,0)
	local moved = false
	
	if (not self.fired) and (not self.ishurt) and (self.isalive) and (not isGameOver) then
		if love.keyboard.isDown(self.keyleft) then
			delta.x = -1
			self.body:applyForce(-self.acceleration * dt,0)
			moved = true
			--self.frameFlipH = -1
			self.animation:flipH()
		elseif love.keyboard.isDown(self.keyright) then
			delta.x =  1
			self.body:applyForce(self.acceleration * dt,0)
			moved = true
			--self.frameFlipH = 1
			self.animation:flipH()
		end	
		if love.keyboard.isDown(self.keyup) then
			delta.y = -1
			self.body:applyForce(0,-self.acceleration * dt)
			moved = true
		elseif love.keyboard.isDown(self.keydown) then
			delta.y =  1
			self.body:applyForce(0,self.acceleration * dt)
			moved = true
		end
	end
	
	-- Want length 1 vector with correct x, y elements
    delta:normalize_inplace()
	
	-- Handle the animation switching here as needed:
	if self.ishurt or (not self.isalive) then
		self.animation = self.hurtAnim
	elseif (not self.fired) then
		if moved then 
			if delta.x ~= 0 then
				self.facing.x = delta.x
				self.facing.y = 0
			end
			self.animation = self.runAnim
		else
			self.animation = self.standAnim
		end
	end

	self.position.x, self.position.y = 
		self.body:getX() - self.width / 2, 
		self.body:getY() - self.height / 2
end

function Player:draw()
--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    self.animation:draw(self.image, 
				self.position.x,
				self.position.y,
				0, -- angle
				self.scale, -- x scale
				self.scale, -- y scale
				0, -- x offset
				0 -- y offset
				--self.frameFlipH,
				--self.frameFlipV
				)

 love.graphics.draw(self.gunEmitter)
 love.graphics.draw(self.bloodEmitter)

end


function Player:getCenter()
	return self.body:getX(), self.body:getY()
end

function Player:keyPressHandler(key)
end

function Player:fire()
		-- do the animation
		self.fired = true
		self.animation = self.shootingAnim
		self.animation:gotoFrame(1)
		self.timer:add(0.5, function()
					self:stopFire() 
                    self.shootingAnim:gotoFrame(1)
				end)
		-- figure out origin to fire from 
		-- and direction to fire in
		local pos = Vector(0,0)
		local aiming = self.facing
		aiming.y = 0
		aiming:normalize_inplace()

		pos.x, pos.y = self.body:getWorldCenter()
		pos = pos + aiming * 20

		local rads

		if aiming.x < 0 then
			rads = 3.14
		else
			rads = 0
		end
		-- set up the flashy sparkly guy
		self.gunEmitter:reset()
		self.gunEmitter:setPosition(pos.x, pos.y - 10)
		self.gunEmitter:setDirection( rads )		
		self.timer:add(0.25, function()	
			self.gunEmitter:start()
			table.insert(bullets,Bullet(null, pos, aiming)) 
			local vol = math.random(30, 50) / 100
			local pitch = math.random(50, 125) / 100
	
			TEsound.play(self.gunsoundlist, "gunshot", vol, pitch)		
	
		end)
end


function Player:stopFire()
	self.fired = false
	self.animation = self.standAnim
	self.gunEmitter:stop()
end

function Player:keyReleaseHandler(key)
	if key == self.keyfire then
		if (not self.isHurt) and (not self.fired) then
			self:fire()
			self.animation = self.shootingAnim
		end
	elseif key == self.keyroll then
		-- animate roll here
	end
end

-- Resolve being shot here.
-- called by world collision callback in main.lua
function Player:isShot(bullet, collision)
local pos = Vector(self.position.x + 10, self.position.y + 20)
-- set up the bloody splurty guy
	self.bloodEmitter:setDirection(0)
	if math.random(1,2) == 1 then
		self.bloodEmitter:setDirection(3.14)
	end
		--self.bloodEmitter:reset()
	self.bloodEmitter:setPosition(pos.x + 32, pos.y + 32)
	self.bloodEmitter:start()	
		
	self.health = self.health - 1
	

	self.ishurt = true
	self.animation = self.hurtAnim

	if self.health < 1 and (not isGameOver) then
		self:dies()
	else 

		self.timer:add(0.5, function() 
				self.ishurt = false
				self.animation = self.standAnim
				self.bloodEmitter:stop()
			end)
			
	end	
end

function Player:dies()
    self.isalive = false
    self.timer:clear()
    StartGameOver(self)
end
