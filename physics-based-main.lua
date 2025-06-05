function love.load()

  Map = require 'map'

  sti = require 'libraries/sti'

  love.graphics.setDefaultFilter("nearest", "nearest")

  gameMap = sti('maps/magnet-map.lua')

  -- Setting one meter as 64 pixels
  love.physics.setMeter(64) 

  -- Creating a world with accurate gravity
  world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
  
  Text = ""
  Persisting = 0
  
  -- screenwidth values
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()

  -- initialising closest object detection
  closest = "none"
  closestDist = 0

  -- table to hold all physical objects
  objects = {}

  -- Creating the player's physics
  objects.player = {}
  player = objects.player
  player.width = 50
  player.height = 50
  player.physType = "player"
  player.body = love.physics.newBody(world, screenWidth/2, screenHeight/2, "dynamic")
  player.shape = love.physics.newRectangleShape(player.width, player.height)
  player.fixture = love.physics.newFixture(player.body, player.shape, 1)
  player.fixture:setUserData("Player")
  player.fixture:setFriction(0.5)
  player.maxSpeed = 10
  player.isGrounded = False

  -- Creating a left bounding wall
  objects.lwall = {}
  lwall = objects.lwall
  lwall.width = 50
  lwall.height = screenHeight
  lwall.body = love.physics.newBody(world, lwall.width / 2, lwall.height/2)
  lwall.shape = love.physics.newRectangleShape(lwall.width, screenHeight)
  lwall.fixture = love.physics.newFixture(lwall.body, lwall.shape)
  lwall.fixture:setUserData("Left Wall")
  lwall.fixture:setFriction(0.3)
  lwall.physType = "static"

  -- Creating a right bounding wall
  objects.rwall = {}
  rwall = objects.rwall
  rwall.width = 50
  rwall.height = screenHeight
  rwall.body = love.physics.newBody(world, screenWidth-rwall.width/2, rwall.height/2)
  rwall.shape = love.physics.newRectangleShape(lwall.width, rwall.height)
  rwall.fixture = love.physics.newFixture(rwall.body, rwall.shape)
  rwall.fixture:setUserData("Right Wall")
  rwall.fixture:setFriction(0.3)
  rwall.physType = "static"

  -- Creating the ground
  objects.ground = {}
  ground = objects.ground
  ground.width = screenWidth
  ground.height = 50
  ground.body = love.physics.newBody(world, ground.width/2, screenHeight-ground.height/2)
  ground.shape = love.physics.newRectangleShape(ground.width, ground.height)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)
  ground.fixture:setUserData("Ground")
  ground.fixture:setFriction(0.3)
  ground.physType = "static"

  -- Creating some test blocks to play with
  objects.testBlock = {}
  testBlock = objects.testBlock
  testBlock.width = 100
  testBlock.height = 100
  testBlock.body = love.physics.newBody(world, 475, 650/2, "dynamic")
  testBlock.shape = love.physics.newRectangleShape(testBlock.width, testBlock.height)
  testBlock.fixture = love.physics.newFixture(testBlock.body, testBlock.shape, 0.5)
  testBlock.fixture:setUserData("Square Block")
  testBlock.physType = "dynamic"
  testBlock.name = "Square Block"

  objects.testBlock2 = {}
  testBlock2 = objects.testBlock2
  testBlock2.width = 50
  testBlock2.height = 100
  testBlock2.body = love.physics.newBody(world, 100, 650/2, "dynamic")
  testBlock2.shape = love.physics.newRectangleShape(testBlock2.width, testBlock2.height)
  testBlock2.fixture = love.physics.newFixture(testBlock2.body, testBlock2.shape, 0.2)
  testBlock2.fixture:setUserData("Long Block")
  testBlock2.physType = "dynamic"
  testBlock2.name = "Long Block"


  love.graphics.setBackgroundColor(0.41, 0.53, 0.97)

end


-- What happens on start of collision
function beginContact(a, b, coll)

  Persisting = 1
	local x, y = coll:getNormal()
	local textA = a:getUserData()
	local textB = b:getUserData()
-- Get the normal vector of the collision and concatenate it with the collision information
	Text = Text.."\n 1.)" .. textA.." colliding with "..textB.." with a vector normal of: ("..x..", "..y..")"
	love.window.setTitle ("Persisting: "..Persisting)

end


-- What happens on end of collision
function endContact(a, b, coll)
  -- If player leaves ground, they are not grounded
  if (a:getUserData() == "Player") or (b:getUserData() == "Player") then
    player.isGrounded = false
  end

  Persisting = 0
	local textA = a:getUserData()
	local textB = b:getUserData()
-- Update the Text to indicate that the objects are no longer colliding
	Text = Text.."\n 3.)" .. textA.." uncolliding with "..textB
	love.window.setTitle ("Persisting: "..Persisting)

end


-- What happens just before a frame is resolved for current collision 
function preSolve(a, b, coll)
-- If player is colliding with something, they are 'Grounded'
  if (a:getUserData() == "Player") or (b:getUserData() == "Player") then
    player.isGrounded = true
  end

  if Persisting == 1 then
	local textA = a:getUserData()
	local textB = b:getUserData()
-- If this is the first update where the objects are touching, add a message to the Text
		Text = Text.."\n 2.)" .. textA.." touching "..textB..": "..Persisting
	elseif Persisting <= 10 then
-- If the objects have been touching for less than 20 updates, add a count to the Text
		Text = Text.." "..Persisting
	end
	
-- Update the Persisting counter to keep track of how many updates the objects have been touching
	Persisting = Persisting + 1
	love.window.setTitle ("Persisting: "..Persisting)

end

-- What happens after a frame is resolved for curent collision
function postSolve(a, b, coll)
end


-- function to find closest object to another object and return it and the distance to it
function getClosestObjectToObject(target, objects)

  local closest = nil
  local minDistSq = math.huge

  for _, obj in pairs(objects) do

    if obj ~= target and obj.physType == "dynamic" and obj.body and target.body then
      local x1, y1 = target.body:getPosition()
      local x2, y2 = obj.body:getPosition()
      local dx, dy = x2 - x1, y2 - y1
      local distSq = dx * dx + dy * dy

      if distSq  < minDistSq then

        minDistSq = distSq
        closest = obj

      end
    end
  end

  return closest, math.sqrt(minDistSq)

end


function applyForceTowardsObject(obj, target, force_magnitude)

  local x1, y1 = obj.body:getPosition()
  local x2, y2 = target.body:getPosition()

  local dx = x2 - x1
  local dy = y2 - y1

  local distance = math.sqrt(dx * dx + dy * dy)

  if distance > 0 then
    local normalised_dx = dx / distance
    local normalised_dy = dy / distance

    obj.body:applyForce(force_magnitude * normalised_dx, force_magnitude * normalised_dy)
    target.body:applyForce(-force_magnitude * normalised_dx, -force_magnitude * normalised_dy)
  end
end



-- jumping function
function love.keypressed(key)
  if player.isGrounded then
    if key == 'w' then
      objects.player.body:applyLinearImpulse(0, -200)
    end
  end
end


function love.update(dt)
  world:update(dt) --this puts the world into motion

  closest, closestDist = getClosestObjectToObject(objects.player, objects)

  jumping = false
  player_vx, player_vy = objects.player.body:getLinearVelocityFromLocalPoint(objects.player.body:getPosition())
  
  --here we are going to create some keyboard events
  if love.keyboard.isDown("a") and player_vx < objects.player.maxSpeed then 
    objects.player.body:applyForce(-400, 0)
  end
  if love.keyboard.isDown("d") and player_vx > -objects.player.maxSpeed then 
    objects.player.body:applyForce(400, 0)
  end

  -- pushing and pulling closest thing
  if love.mouse.isDown(1) and closest then
    applyForceTowardsObject(closest, objects.player, 1000)
  end

  if love.mouse.isDown(2) and closest then
    applyForceTowardsObject(closest, objects.player, -1000)
  end

  if string.len(Text) > 768 then-- Cleanup when 'Text' gets too long
		Text = "" -- Reset the Text variable when it exceeds the specified length
	end

end


function love.draw()

  Map:draw()


  -- set the drawing color to green for the ground
  love.graphics.setColor(0.28, 0.63, 0.05)
  -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
  love.graphics.polygon("fill", objects.lwall.body:getWorldPoints(objects.lwall.shape:getPoints()))
  love.graphics.polygon("fill", objects.rwall.body:getWorldPoints(objects.rwall.shape:getPoints()))


  -- set the drawing color to red for the ball
  love.graphics.setColor(0.76, 0.18, 0.05)
  love.graphics.polygon("fill", objects.player.body:getWorldPoints(objects.player.shape:getPoints()))

  -- test block
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.polygon("fill", objects.testBlock.body:getWorldPoints(objects.testBlock.shape:getPoints()))

  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.polygon("fill", objects.testBlock2.body:getWorldPoints(objects.testBlock2.shape:getPoints()))


  -- line to closest obj
  -- love.graphics.print(closestDist, 10, 10)
  -- love.graphics.print(closest.name, 10, 50)
  love.graphics.print(Text, 10, 10)

  if closest and objects.player.body and closest.body then
    local x1, y1 = objects.player.body:getPosition()
    local x2, y2 = closest.body:getPosition()
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


	

end
