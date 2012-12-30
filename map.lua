-- class to make objects in maps solid

local ATL = require("AdvTiledLoader")
local map
obstacles = {}

Map = Class {
	function(self, scene)
		map = ATL.Loader.load("maps/" .. scene) 
	end
}

function Map:draw() 
	map:draw()
	for id, object in next,obstacles,nil do
		love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	end	
end

--iterate through map to create objects that players can't pass through as defined in the map
function Map:createObjects() 
	for x, y, tile in map("Ground"):iterate() do
		if tile.properties.obstacle then
			obstacles[x..","..y] = {}
			obstacles[x..","..y].body = love.physics.newBody(world, 
				((x * map.tileWidth) + map.tileWidth / 2),
				((y * map.tileHeight) + map.tileHeight / 2))

			obstacles[x..","..y].shape = love.physics.newRectangleShape(
				map.tileWidth,
				map.tileHeight
				)
				
			obstacles[x..","..y].fixture = love.physics.newFixture(
				obstacles[x..",".. y].body, 
				obstacles[x..",".. y].shape)
		end
	end
end