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
	self.frameDelay = 0.2
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
	gunsoundlist = { "sfx/gunshot1.ogg", "sfx/gunshot2.ogg"}
	--, "sfx/gunshot3.ogg" }
	
	
	-- particle sys stuff go here now!
	gunParticleImage = love.graphics.newImage( "art/gunParticle.png" )
	gunEmitter = love.graphics.newParticleSystem( gunParticleImage, 30 )
	gunEmitter:setEmissionRate(30)
	gunEmitter:setLifetime(0.01)
	gunEmitter:setParticleLife(0.5)
	gunEmitter:setSpread(30)
	--gunEmitter:setSize(0.3, 0.7, 0.5)
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
	
	if self.pnum == 2 then
		self.position = Vector(
			dimScreen.x - (50 + self.width),
			dimScreen.y - 80)
	elseif self.pnum == 1 then
		self.position = Vector(50,dimScreen.y - 80)
	end
	
end

function Player:update(dt)
	-- sound stuff
	TEsound.cleanup()
	-- Inc timers
	self.timer:update(dt)
	-- particle stuffs
	gunEmitter:update(dt)
	
	-- delta holds direction of movement input
	local delta = Vector(0,0)
	local moved = false
	
	if not self.fired then
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
	if not self.fired then
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
		-- figure out origin to fire from first
		local pos = Vector(0,0)
		pos.x, pos.y = self.body:getWorldCenter()
		pos = pos + self.facing * 25
		
		-- set up the flashy sparkly guy
		gunEmitter:reset()
		gunEmitter:setPosition(pos.x, pos.y)
		
		self.timer:add(0.25, function()	
			gunEmitter:start()
			table.insert(bullets,Bullet(null, pos, self.facing)) 
			TEsound.play(gunsoundlist)
		end)
end

function Player:stopFire()
	self.fired = false
	self.animation = self.standAnim
end

function Player:keyReleaseHandler(key)
	if key == self.keyfire then
		self:fire()
		self.animation = self.shootingAnim
	elseif key == self.keyroll then
		-- animate roll here
	end
end

-- Resolve being shot here.
-- called by world collision callback in main.lua
function Player:isShot(bullet, collision)
	self.health = self.health - 1
	
end



