-- class to make objects in maps solid

local ATL = require("AdvTiledLoader")
local map

Map = Class {
	function(self, scene)
		map = ATL.Loader.load("maps/" .. scene) 
	end
}

function Map:draw() 
	map:draw()
end

--iterate through map to create objects that players can't pass through as defined in the map
function createObjects() 
end