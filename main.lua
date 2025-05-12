function love.load()
    
    love.graphics.setDefaultFilter("nearest", "nearest") -- Set the default filter to nearest for pixel art 

    pipe = {}
    pipe.image = love.graphics.newImage("sprites/pipe.png") -- Load the pipe image
    pipe.width = pipe.image:getWidth() -- Get the width of the pipe image
    pipe.x = love.graphics.getWidth() - 100 -- Set the x position to the width of the screen
    pipe.y = 400


end


function love.update(dt)

end


function love.draw()
    love.graphics.clear(0.5, 0.8, 1) -- Clear the screen with a light blue color
    love.graphics.draw(pipe.image, pipe.x, pipe.y) -- Draw the pipe image at the specified position
    love.graphics.draw(pipe.image, pipe.x, pipe.y, math.pi) -- Draw the pipe image at the specified position
end