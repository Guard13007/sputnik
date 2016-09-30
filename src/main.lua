local lg = love.graphics
local lk = love.keyboard

local bodies = {
  {
    x = 0,
    y = 0,
    mass = 100000,
    radius = 100,
    v = {
      x = 0,
      y = 0
    }
  },
  {
    x = 0,
    y = -200,
    mass = 10,
    radius = 2,
    v = {
      x = 50,
      y = 0
    }
  }
}

local time, tick = 0, 1/30

local function gravity(A, B)
  local dx = A.x - B.x
  local dy = A.y - B.y
  local d2 = dx*dx + dy*dy
  local Fg = A.mass * B.mass / d2
  -- apply force
  local d = math.atan2(dy,dx)
  A.v.x = A.v.x - (Fg/A.mass) * math.cos(d)
  A.v.y = A.v.y - (Fg/A.mass) * math.sin(d)
  B.v.x = B.v.x + (Fg/B.mass) * math.cos(d)
  B.v.y = B.v.y + (Fg/B.mass) * math.sin(d)
end

local function update()
  for i=1,#bodies-1,2 do
    for j=i+1,#bodies do
      gravity(bodies[i], bodies[j])
    end
  end
  for _, body in ipairs(bodies) do
    body.x = body.x + body.v.x * tick
    body.y = body.y + body.v.y * tick
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
  for _, body in ipairs(bodies) do
    lg.circle("fill", body.x, body.y, body.radius)
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
