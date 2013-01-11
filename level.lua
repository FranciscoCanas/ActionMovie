-- class to make objects in maps solid

local ATL = require("AdvTiledLoader")
local collisionMapMaker = require 'collision_map'
obstacles = {}
ATL.Loader.path = 'maps/'


-- -- Define the translation
-- local tx, ty = 0, 0

Level = Class {
	function(self, scene)
		self.map = ATL.Loader.load(scene..".tmx") 
		self.collisionMap = collisionMapMaker.create(self.map, "Ground", "Collision")
	end
}

-- Function which converts x,y on the screen to tile coordinates
-- All tiles are 32-pixels wide (width, height). Function returns nil
-- if we clicked out of the map bounds
--takes screen coordinates and converts to tile coordinates
function Level:toTile(x,y)
	x_,y_ = cam:worldCoords(x, y)
	local _x = math.floor(x_/(self.map.tileWidth))
	local _y = math.floor(y_/(self.map.tileHeight))
	if self.collisionMap[_y] and self.collisionMap[_y][_x] then 
	  return _x,_y
	end
end

-- Made obstacle class so we could more consistently
-- handle collisions in the main:beginContact function
Obstacle = Class {
	function(self, map, x, y)
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
		--self.fixture:setCategory(OBSTACLE)
	end
}

function Level:draw() 

	-- Draw the map
	self.map:draw()

	-- drawing out the position of collision boxes
	-- for id, object in next,obstacles,nil do
	-- 	love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	-- end	
end

--iterate through the collision layer of the map to create objects that players can't pass through as defined in the map
function Level:createObjects() 
	for x, y, tile in self.map("Collision"):iterate() do
		obstacles[x..","..y] = Obstacle(self.map, x, y)
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
