function love.load()
    
    love.graphics.setDefaultFilter("nearest", "nearest") -- Set the default filter to nearest for pixel art

    gravity = 500

    pipe = {}
    pipe.image = love.graphics.newImage("sprites/pipe.png") -- Load the pipe image
    pipe.width = pipe.image:getWidth() -- Get the width of the pipe image
    pipe.x = love.graphics.getWidth() - 100 -- Set the x position to the width of the screen
    pipe.y = 400

    player = {}
    player.x = 200
    player.y = love.graphics.getHeight()/2

end


function love.keypressed(key)
    if love.keyboard.isDown("space") then
        player.y = player.y + 150
    end
end


function love.update(dt)
    player.y = player.y - gravity * dt

end


function love.draw()
    love.graphics.clear(0.5, 0.8, 1) -- Clear the screen with a light blue color

    love.graphics.circle("fill", player.x, player.y, 30)

    love.graphics.draw(pipe.image, pipe.x, pipe.y) -- Draw the pipe image at the specified position
    love.graphics.draw(pipe.image, pipe.x, pipe.y, math.pi) -- Draw the pipe image at the specified position
end