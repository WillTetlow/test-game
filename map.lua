sti = require 'libraries/sti'
gameMap = sti('maps/magnet-map.lua')


functio gameMap:load()

    collisionLayer = gameMap.layers["Ground"] 

    for i, v in pairs(collisionLayer) do
        local collisionObjectX = gameMap.layers["Ground"].objects[i].x
        local collisionObjectY = gameMap.layers["Ground"].objects[i].y
        

end


function gameMap:update(dt)

end


function gameMap:draw()

    gameMap:draw(0, 0, 3, 3)

end

return gameMap
