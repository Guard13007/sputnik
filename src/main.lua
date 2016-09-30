local lg = love.graphics
local lk = love.keyboard

-- planetary mass, radius, atmospheric height, gravitational constant
local p_mass, p_radius, p_atmosphere, G = 100000, 100, 20, 1

local function Ship()
  local self = {}
  self.x = 0
  self.y = -p_radius
  self.v = {x=0,y=0}        -- velocity
  self.heading = -math.pi/2 -- pointing up
  self.radius = 5 --TEMPORARY FOR LOVE.DRAW!
  return self
end

local ships = {}
local currentShip = Ship()
table.insert(ships, currentShip)
--TEMPORARY FOR ORBITAL START
currentShip.y = currentShip.y - p_atmosphere - 13
currentShip.v.x = 150

local time, tick = 0, 1/30

local function gravity(A)
  local d2 = A.x*A.x + A.y*A.y
  local Fg = G * p_mass / d2
  -- apply force
  local d = math.atan2(A.y, A.x)
  A.v.x = A.v.x - Fg * math.cos(d)
  A.v.y = A.v.y - Fg * math.sin(d)
end

local function collide(A)
  d = math.sqrt(A.x*A.x + A.y*A.y)
  if d <= p_radius then
    -- need to stop acceleration
    --TODO crash or live based on velocity at impact
    A.v.x = 0
    A.v.y = 0
    -- need to move to surface and stay on the surface
    local t = math.atan2(A.y, A.x)
    A.x = A.x + (p_radius - d) * math.cos(t)
    A.y = A.y + (p_radius - d) * math.sin(t)
  end
end

-- this updates the angle relative to planet
local function angle(A)
  d = math.sqrt(A.x*A.x + A.y*A.y)
  --TODO partial translation when in atmosphere
  if d >= p_radius + p_atmosphere then
    A.heading = math.atan2(A.y, A.x) + math.pi/2
  end
end

local function update()
  for i=1,#ships do
    gravity(ships[i])
    ships[i].x = ships[i].x + ships[i].v.x * tick
    ships[i].y = ships[i].y + ships[i].v.y * tick
    collide(ships[i])
    angle(ships[i])
    --TODO add drag calculation for in atmosphere
  end

  if lk.isDown("z") then
    --TODO 20 should be modified based on distance
    currentShip.v.x = currentShip.v.x + 20 * math.cos(currentShip.heading)
    currentShip.v.y = currentShip.v.y + 20 * math.sin(currentShip.heading)
  end
end

function love.update(dt)
  time = time + dt
  if time >= tick then
    time = time - tick
    update()
  end
end

function love.draw()
  lg.translate(lg.getWidth()/2, lg.getHeight()/2)

  lg.setColor(200, 150, 100, 255)
  for i=1,#ships do
    lg.circle("fill", ships[i].x, ships[i].y, ships[i].radius)
  end

  lg.setColor(0, 255, 0, 255)
  lg.circle("fill", 0, 0, p_radius)
  --TODO improve atmosphere rendering
  lg.setColor(0, 0, 100, 120)
  lg.circle("fill", 0, 0, p_radius + p_atmosphere)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "x" then
    currentShip = Ship()
    table.insert(ships, currentShip)
  end
end
