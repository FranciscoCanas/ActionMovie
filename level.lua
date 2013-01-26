-- class to make objects in maps solid

local ATL = require("AdvTiledLoader")
local collisionMapMaker = require 'collision_map'
obstacles = {}
ATL.Loader.path = 'maps/'


-- -- Define the translation
-- local tx, ty = 0, 0

Level = Class {
	function(self, scene, drawAll, camera)
		self.cam = camera
		self.map = ATL.Loader.load(scene..".tmx") 
		self.collisionMap = collisionMapMaker.create(self.map, "Ground", "Collision")
		self.drawObstacles = drawAll --if obstacles should be drawn or not 
	end
}

-- Function which converts x,y on the screen to tile coordinates
-- All tiles are 32-pixels wide (width, height). Function returns nil
-- if we clicked out of the map bounds
--takes screen coordinates and converts to tile coordinates
function Level:toTile(x,y)
	x_,y_ = self.cam:worldCoords(x, y)
	local _x = math.floor(x_/(self.map.tileWidth))
	local _y = math.floor(y_/(self.map.tileHeight))
	if self.collisionMap[_y] and self.collisionMap[_y][_x] then 
	  return _x,_y
	end
end

-- Made obstacle class so we could more consistently
-- handle collisions in the main:beginContact function
Obstacle = Class {
	function(self, map, x, y, bulletPassable, peoplePassable, category)
		self.body = love.physics.newBody(world, 
			((x * map.tileWidth) + map.tileWidth / 2),
			((y * map.tileHeight) + map.tileHeight / 2))

		self.shape = love.physics.newRectangleShape(
			map.tileWidth,
			map.tileHeight
			)
			
		self.fixture = love.physics.newFixture(
			self.body, 
			self.shape)
			
		-- Use this to detect obstacles when handling collisions	
		self.fixture:setUserData(self)
		self.fixture:setCategory(category)
		if bulletPassable then
			self.fixture:setMask(BULLET)
		end

		if peoplePassable then
			self.fixture:setMask(PLAYER, ENEMY)
		end

		particleImage = love.graphics.newImage( "art/dustParticle.png" )
		self.fxEmitter = love.graphics.newParticleSystem( particleImage, 500 )
		self.fxEmitter:setEmissionRate(800)
		self.fxEmitter:setLifetime(0.02)
		self.fxEmitter:setParticleLife(0.075)
		self.fxEmitter:setDirection(0)
		self.fxEmitter:setSpread(2*3.14)
		self.fxEmitter:setSizes(0.05, 0.25)
		self.fxEmitter:setGravity(0,9)
		self.fxEmitter:setSpeed(300,500)

	end
}

function Obstacle:update(dt)
	self.fxEmitter:update(dt)
end

function Obstacle:impactEffect(bullet)
	self.fxEmitter:reset()
	self.fxEmitter:setPosition(bullet.position.x + 3, bullet.position.y + 3)
	self.fxEmitter:start()	
end


function Level:update(dt)
	for id, object in ipairs(obstacles) do
		object:update(dt)
	end
	
end

function Level:draw() 

	-- Draw the map
	self.map:draw()
	

	-- drawing out the position of collision boxes
	if self.drawObstacles then
		for id, object in next,obstacles,nil do
			love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))

			
		end	
	end

	for id, object in ipairs(obstacles) do
		love.graphics.draw(object.fxEmitter)
	end
end

--iterate through the collision layer of the map to create objects that players can't pass through as defined in the map
function Level:createObjects() 
	self:clearObstacles()
	obstacles = {} -- clears out the table
	for x, y, tile in self.map("Collision"):iterate() do
		obstacles[x..","..y] = Obstacle(self.map, x, y, tile.properties.bulletPassable,tile.properties.playerPassable, OBSTACLE)
	end

	if self.map("Barricade") then
		for x, y, tile in self.map("Barricade"):iterate() do
			obstacles[x..","..y] = Obstacle(self.map, x, y, tile.properties.bulletPassable, tile.properties.playerPassable, BARRICADE)	
		end
	end
end

function Level:clearObstacles()
	for id, object in next,obstacles,nil do
		object.fixture:destroy()
	end
end

function Level:createPathFinding()
	local _map = {}
	for x,y in self.map(groundLayer):iterate() do
		_map[y] = _map[y] or {}
    	_map[y][x] = walkable or 0
  	end
  	for x,y in self.map(collisionLayer):iterate() do
    	_map[y][x] = unwalkable or 1
  	end
	return _map
end
