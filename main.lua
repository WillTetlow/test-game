function love.load()
    camera = require 'libraries/camera'
    cam = camera()


    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'libraries/sti'

    gameMap = sti('maps/test-map.lua')

    player = {} --curly brackets for tables --
    player.x = 400
    player.y = 200
    player.speed = 200 --better to set the speed here for all keys to reference--
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    background = love.graphics.newImage('sprites/background.jpeg')
end

function love.update(dt)

    local isMoving = false

    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
        player.anim = player.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
        player.anim = player.animations.up
        isMoving = true
    end
    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
        player.anim = player.animations.down
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(2) --set frame to stand still when not moving--
    end

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end


end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Ground"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
    cam:detach()
end