--require 'TESound.TEsound'

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
		
	elseif num == 2 then
		self.pnum = 2
		self.keyup = "o"
		self.keyright = ";"
		self.keyleft = "k"
		self.keydown = "l"
		self.keyfire = "j"
		self.keyroll = "h" 
		self.image = love.graphics.newImage('art/ManSprite.png')
		
	end
	self:init()
	-- Set up for Timers
	self.timer = Timer.new()
	
	-- Set up anim8 for spritebatch animations -----------------------------
	self.frameDelay = 0.3
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

	--ready for shooting animation here:
	self.shootingAnim = Anim8.newAnimation('loop',
		self.grid('1-2, 2'),
		self.frameDelay)
		
	self.hurtAnim = Anim8.newAnimation('loop',
		self.grid('1-2, 3'),
		self.frameDelay)
		
	self.animation = self.standAnim
	
	-- love.physics code starts here -----------------------------------------
	self.facing = Vector(1,0) -- normalized direction vector
	self.acceleration = 12000
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
	--self.fixture:setCategory(PLAYER)
		
	self.body:setLinearDamping( self.damping )
	
	-- self.body:setMassData(
		-- (self.position.x + self.image:getWidth()) / 2,
		-- (self.position.y + self.image:getHeight()) / 2,
		-- 64, -- mass (kg)
		-- 10) -- inertia
	-- love.physics ends here
	
	-- sound stuffs go here
	self.gunsoundlist = { "sfx/gunshot1.ogg", "sfx/gunshot2.ogg"}
	--, "sfx/gunshot3.ogg" }
	
	
	-- particle sys stuff go here now!
	gunParticleImage = love.graphics.newImage( "art/gunParticle.png" )

	self.gunEmitter = love.graphics.newParticleSystem( gunParticleImage, 100 )
	self.gunEmitter:setEmissionRate(500)
	self.gunEmitter:setLifetime(0.01)
	self.gunEmitter:setParticleLife(0.25)
	self.gunEmitter:setSpread(3.14/4)
	self.gunEmitter:setSizes(0.05, 0.25)
	self.gunEmitter:setGravity(0,0)
	self.gunEmitter:setSpeed(200,300)
	
	-- particle sys stuff go here now!
	bloodParticleImage = love.graphics.newImage( "art/bloodParticle.png" )
	self.bloodEmitter = love.graphics.newParticleSystem( bloodParticleImage, 500 )
	self.bloodEmitter:setEmissionRate(500)
	self.bloodEmitter:setLifetime(0.01)
	self.bloodEmitter:setParticleLife(0.6)
	self.bloodEmitter:setSpread(3.14/3)
	self.bloodEmitter:setSizes(0.3, 1.0)
	self.bloodEmitter:setGravity(0,9.8)
	self.bloodEmitter:setSpeed(100,220)

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
		self.position = Vector(4200,940)
	end
	
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
	
	if (not self.fired) and (not self.ishurt) then
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
	end
	
	-- Want length 1 vector with correct x, y elements
    delta:normalize_inplace()
	
	-- Handle the animation switching here as needed:
	if self.ishurt then
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
		-- set up the flashy sparkly guy
		self.gunEmitter:reset()
		self.gunEmitter:setPosition(pos.x, pos.y - 20)
		self.gunEmitter:start()
		if aiming.x < 0 then
			rads = 3.14
		else
			rads = 0
		end

		
		self.timer:add(0.10, function()
				self.gunEmitter:setDirection( rads )
			end)

		self.timer:add(0.25, function()	

			table.insert(bullets,Bullet(null, pos, aiming)) 
			local vol = math.random(15, 30) / 100
			local pitch = math.random(25, 150) / 100
	
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
	self.timer:add(0.5, function() 
			self.ishurt = false
			self.animation = self.standAnim
			self.bloodEmitter:stop()
		end)
			
	
end



