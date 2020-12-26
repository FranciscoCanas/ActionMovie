
Bomb = Class{
	function(self, position)
		self.health = 100
		self:reset()
		self.position = position
		self.image = love.graphics.newImage('art/bomb.png')

		--percentage bar for bomb

		self.difuseImg = love.graphics.newImage('art/difuse.png')

		self.numbers= {}
		self.numbers.img = love.graphics.newImage('art/numbers.png')
		self.numbers.grid = Anim8.newGrid(4, 6, 
			self.numbers.img:getWidth(),
			self.numbers.img:getHeight())

		for i=1,11,1 do
			self.numbers[i] = Anim8.newAnimation(
				self.numbers.grid:getFrames(i,1),
				1,
				'pauseAtEnd')
		end

		self.bar = {}
		self.bar.img = love.graphics.newImage('art/bombBar.png')
		self.bar.grid = Anim8.newGrid(1, 3, 
			self.bar.img:getWidth(),
			self.bar.img:getHeight())

		
		self.bar.filled = Anim8.newAnimation(
			self.bar.grid:getFrames(1,1),
			1, 'pauseAtEnd')
		self.bar.empty = Anim8.newAnimation(
			self.bar.grid:getFrames(2,1), 1, 'pauseAtEnd')

		self.width = self.image:getWidth()
		self.height = self.image:getHeight()

		self.body = love.physics.newBody(world, 
		--	self.position.x, self.position.y)
		(self.position.x + (self.width / 2)),
		(self.position.y + (self.height / 2)));

	self.shape = love.physics.newRectangleShape(
		self.width,
		self.height
		)
		
	self.fixture = love.physics.newFixture(
		self.body, 
		self.shape)
	
		self.fixture:setCategory(BOMB)
		self.fixture:setMask(PLAYER)

		self.fixture:setUserData(self)

		particleImage = love.graphics.newImage( "art/dustParticle.png" )
		self.fxEmitter = love.graphics.newParticleSystem( particleImage, 500 )
		self.fxEmitter:setEmissionRate(800)
		self.fxEmitter:setEmitterLifetime(0.05)
		self.fxEmitter:setParticleLifetime(0.075)
		self.fxEmitter:setDirection(0)
		self.fxEmitter:setSpread(2*3.14)
		self.fxEmitter:setSizes(0.05, 1.25)
		self.fxEmitter:setLinearAcceleration(0,9)
		self.fxEmitter:setSpeed(300,500)
	end
}

function Bomb:draw()

	love.graphics.draw(self.image, self.position.x, self.position.y)
	--love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.draw(self.difuseImg, self.position.x, self.position.y-5)
	self:drawNumber(tens, Vector(self.position.x+43, self.position.y+12))
	self:drawNumber(ones, Vector(self.position.x+47, self.position.y+12))

	remainHealth = math.floor(100-self.health)
	for i=1,50,1 do
		if (i <= remainHealth/2) then
			self.bar.filled:draw(self.bar.img, self.position.x+(7+i), self.position.y+8)
		else
			self.bar.empty:draw(self.bar.img, self.position.x+(7+i), self.position.y+8)
		end
	end

end



function Bomb:drawNumber(num, position) 
	if (num == 1) then
		self.numbers[1]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 2) then
 		self.numbers[2]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 3) then
		self.numbers[3]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 4) then
		self.numbers[4]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 5) then
		self.numbers[5]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 6) then
		self.numbers[6]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 7) then
		self.numbers[7]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 8) then
		self.numbers[8]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 9) then
		self.numbers[9]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 0) then
		self.numbers[10]:draw(self.numbers.img, position.x, position.y)
	elseif (num == 10) then
		self.numbers[10]:draw(self.numbers.img, position.x, position.y)
		self.numbers[1]:draw(self.numbers.img, position.x-4, position.y)
	else
		self.numbers[11]:draw(self.numbers.img, position.x, position.y)
	end
end

function Bomb:reset() 

	self.health = 100
	tens = -1
	ones = 0
	if self.fixture then
		self.fixture:destroy()
	end
end



function Bomb:update(dt)
	self.fxEmitter:update(dt)
end

function Bomb:defuse(rate) 
	if self.health > 0 then
		self.health = self.health - 1.5*rate
		tens = math.floor((100-self.health)/10)
		if tens == 0 then tens = -1 end	
		ones = math.floor((100 - self.health)%10)
	end	
end

function Bomb:infuse(rate)
	if not rate then rate = 2 end
	if self.health < 100 then
		self.health = self.health + 0.5*rate
		tens = math.floor((100-self.health)/10)
		ones =math.floor((100 - self.health)%10)
	end
end

function Bomb:impactEffect(coll)
    local posx, posy, posa,posb
    posx, posy, posa, posb = coll:getPositions()
    --print("Bullet struck at "..posx..","..posy)
	self.fxEmitter:setPosition(posx + 3, posy + 3)
	self.fxEmitter:start()	
end