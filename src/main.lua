local lg = love.graphics
local lk = love.keyboard

-- planet mass, planet radius, atmosphere height, gravitational constant
local m, r, h, G = 100000, 100, 20, 1

local function Ship()
  local self = {}
  self.x = 0
  self.y = -r
  self.v = {x=0,y=0}  -- velocity
  self.r = -math.pi/2 -- pointing up
  return self
end

local ships = {}
local currentShip = Ship()
table.insert(ships, currentShip)

function gravity(ship)
  local d2 = ship.x*ship.x + ship.y*ship.y
  local g = G * m / d2

  local x = math.abs(ship.x) * g / (math.abs(ship.x)+math.abs(ship.y))
  if ship.x < 0 then
    ship.v.x = ship.v.x - x * 1/30
  else
    ship.v.x = ship.v.x + x * 1/30
  end
  if ship.y < 0 then
    ship.v.y = ship.v.y + (g - x) * 1/30
  else
    ship.v.y = ship.v.y - (g - x) * 1/30
  end
end

function accelerate(ship)
  local a = 11 -- approximately 1m/s^2 higher than g
  ship.v.x = ship.v.x + a*math.cos(ship.r)*1/30
  ship.v.y = ship.v.y + a*math.sin(ship.r)*1/30
end

function collide(ship)
  local d = math.sqrt(ship.x*ship.x + ship.y*ship.y)
  if d <= r then
    -- move ship radially to surface,
    ship.x = ship.x + (r-d)*math.cos(math.atan2(ship.y, ship.x))
    ship.y = ship.y + (r-d)*math.sin(math.atan2(ship.y, ship.x))
    -- reset velocity in that direction to 0
  end
end

function update()
  for _, ship in pairs(ships) do
    gravity(ship)
    collide(ship)
    ship.x = ship.x + ship.v.x
    ship.y = ship.y + ship.v.y
    ship.r = math.atan2(ship.y, ship.x) + math.pi/2
  end

  if lk.isDown("z") then
    accelerate(currentShip)
  end
end

local time, tick = 0, 1/30
function love.update(dt)
  time = time + dt
  if time >= tick then
    time = time - tick
    update()
  end
end

function love.draw()
  lg.setColor(0, 255, 0, 255)
  lg.circle("fill", lg.getWidth()/2, lg.getHeight()/2, r)
  lg.setColor(0, 0, 100, 120)
  lg.circle("fill", lg.getWidth()/2, lg.getHeight()/2, r+h)

  lg.setColor(200, 150, 100, 255)
  for _, ship in pairs(ships) do
    lg.rectangle("fill", ship.x - 2 + lg.getWidth()/2, ship.y - 2 + lg.getHeight()/2, 4, 4)
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "x" then
    currentShip = Ship()
    table.insert(ships, currentShip)
  end
end
