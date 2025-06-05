function love.load()

    wf = require "libraries/windfield"

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Creating the world
    world = wf.newWorld(0, 500)

    -- Initialising the player table to contain all the player data
    player = {}
    -- Making the player collision box
    player.collider = world:newRectangleCollider(350, 100, 64, 128)
    -- Player can't rotate
    player.collider:setFixedRotation(true)
    -- Force the player pushes with
    player.force = 3000000

    -- Generating world geometry
    ground = world:newRectangleCollider(0, screenHeight-100, screenWidth, 100)
    ground:setType('static')

    leftWall = world:newRectangleCollider(0, 0, 50, screenHeight-100)
    leftWall:setType('static')

    rightWall = world:newRectangleCollider(screenWidth-50, 0, 50, screenHeight-100)
    rightWall:setType('static')

    -- Initialising table to hold all interactive objects
    objects = {}

    objects.squareBox = {}
    objects.squareBox.collider = world:newRectangleCollider(screenWidth/2, screenHeight/2, 50, 50)

end


function love.update(dt)
    -- make the physics do physics every frame
    world:update(dt)

    -- player left and right movement
    local px, py = player.collider:getLinearVelocity()
    if love.keyboard.isDown('a') and px > -300 then
        player.collider:applyForce(-8000, 0)
    elseif love.keyboard.isDown('d') and px < 300 then
        player.collider:applyForce(8000, 0)
    end

    -- pulling closest thing towards player
    closest, closestDist = getClosestObjectToObject(player, objects)
    if love.mouse.isDown(1) then
        applyForceTowardsObject(closest.collider, player.collider, forceAsFunctionOfDistance(getDistanceSquaredBetweenObjects(player.collider, closest.collider), player.force))
    end

    -- pushing closest thing towards mouse (need to apply limits depending on mouse location)
    if love.mouse.isDown(2) and mouseInValidPosition(player.collider, closest.collider) then
        applyForceTowardsMouse(closest.collider, forceAsFunctionOfDistance(getDistanceSquaredBetweenObjects(player.collider, closest.collider), player.force))
        applyForceTowardsMouse(player.collider, forceAsFunctionOfDistance(getDistanceSquaredBetweenObjects(player.collider, closest.collider), -player.force))
    end

end


function love.draw()
    -- Draw the world
    world:draw()

    -- Drawing line between player and closest object
    local x1, y1 = player.collider:getPosition()
    local x2, y2 = closest.collider:getPosition()
    love.graphics.setColor(0, 150, 255)
    love.graphics.line(x1, y1, x2, y2)

    if love.mouse.isDown(1) then
      love.graphics.setColor(1, 0, 0)
      love.graphics.line(x1, y1, x2, y2)
    end

    if love.mouse.isDown(2) then
      love.graphics.setColor(0.18, 0.76, 0.05)
      love.graphics.line(x1, y1, x2, y2)
    end

end


-- jumping function
function love.keypressed(key)
    if key == 'w' then
        player.collider:applyLinearImpulse(0, -7000)
    end

end


-- function to find closest object to another object and return it and the distance to it
function getClosestObjectToObject(target, objects)

  local closest = nil
  local minDistSq = math.huge

  for _, obj in pairs(objects) do

    local x1, y1 = target.collider:getPosition()
    local x2, y2 = obj.collider:getPosition()
    local dx, dy = x2 - x1, y2 - y1
    local distSq = dx * dx + dy * dy

    if distSq  < minDistSq then

    minDistSq = distSq
    closest = obj

    end
  end

  return closest, math.sqrt(minDistSq)

end

-- Function
function applyForceTowardsObject(obj, target, force_magnitude)

  local x1, y1 = obj:getPosition()
  local x2, y2 = target:getPosition()

  local dx = x2 - x1
  local dy = y2 - y1

  local distance = math.sqrt(dx * dx + dy * dy)

  if distance > 0 then
    local normalised_dx = dx / distance
    local normalised_dy = dy / distance

    obj:applyForce(force_magnitude * normalised_dx, force_magnitude * normalised_dy)
    target:applyForce(-force_magnitude * normalised_dx, -force_magnitude * normalised_dy)
  end
end


function forceAsFunctionOfDistance(distanceSquared, force)

    
    resultantForce = force/math.sqrt(distanceSquared)
    return resultantForce

end


function getDistanceSquaredBetweenObjects(a, b)

    local x1, y1 = a:getPosition()
    local x2, y2 = b:getPosition()
    local dx, dy = x2 - x1, y2 - y1

    local distanceSquared = dx * dx + dy * dy

    return distanceSquared

end


function applyForceTowardsMouse(obj, force_magnitude)

  local x1, y1 = obj:getPosition()
  local x2, y2 = love.mouse.getPosition()

  local dx = x2 - x1
  local dy = y2 - y1

  local distance = math.sqrt(dx * dx + dy * dy)

  if distance > 0 then
    local normalised_dx = dx / distance
    local normalised_dy = dy / distance

    obj:applyForce(force_magnitude * normalised_dx, force_magnitude * normalised_dy)
  end
end


function mouseInValidPosition(player, object)

    px, py = player:getPosition()
    ox, oy = object:getPosition()
    mx, my = love.mouse.getPosition()

    -- if object is in-between player and mouse then mouse is in valid position
    -- else mouse is in invalid position

    -- this needs work!!
    if mx < px and ox < px and ox > mx then
        return true
    elseif mx > px and ox > px and mx > ox then
        return true
    elseif my < py and oy < px and oy > my then
        return true
    elseif my > py and oy > py and oy < my then
        return true
    else
        return false
    end

end
