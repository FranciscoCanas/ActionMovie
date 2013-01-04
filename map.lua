-- class to make objects in maps solid

local ATL = require("AdvTiledLoader")
local map
obstacles = {}
ATL.Loader.path = 'maps/'

-- Define the translation
local tx, ty = 0, 0

Map = Class {
	function(self, scene)
		map = ATL.Loader.load(scene..".tmx") 
	end
}

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
	end
}

function Map:draw() 
	-- Apply the translation
	love.graphics.translate( math.floor(tx), math.floor(ty) )
	
	-- Set the draw range. Setting this will significantly increase drawing performance.
	map:autoDrawRange( math.floor(tx), math.floor(ty), 1, pad)
	
	-- Draw the map
	map:draw()

	-- for id, object in next,obstacles,nil do
	-- 	love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	-- end	
end

--iterate through map to create objects that players can't pass through as defined in the map
function Map:createObjects() 
	for x, y, tile in map("Ground"):iterate() do
		if tile.properties.obstacle then
			obstacles[x..","..y] = Obstacle(map, x, y)
		end
	end
end