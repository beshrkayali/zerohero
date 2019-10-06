local Map = {}
Map.__index = Map

local anim8 = require 'libs/anim8'

local function new(world, index)
   brick_gfx = love.graphics.newImage('gfx/brick.png')
   gateway_gfx = love.graphics.newImage('gfx/gateway.png')

   anims = {}
   anims.potion = {}
   anims.potion.sprite = love.graphics.newImage('gfx/potion.png')
   potion_grid = anim8.newGrid(
      32, 32,
      anims.potion.sprite:getWidth(),
      anims.potion.sprite:getHeight()
   )
   anims.potion.anim = anim8.newAnimation(potion_grid('1-5', 1), 0.1)

   level_map = require("scenes/scene"..index)
   player_found = false
   player_pos = {}
   bricks = {}
   moving_bricks = {}
   objects = {}
   gateways = {}

   local l_table = {}
   for i in level_map:gmatch("[^\r\n]+") do
      local c_table = {}
      for c in i:gmatch(".") do
	 c_table[#c_table + 1] = c
      end
      if c_table then
	 l_table[#l_table + 1] = c_table
      end
   end 

   brick_chars = {}
   brick_chars['#'] = '#'
   brick_chars['G'] = 'G'
   brick_chars['H'] = 'H'
   
   moving_brick_chars = {}
   moving_brick_chars["M"] = "M"
   moving_brick_chars["N"] = "N"

   growth_chars = {}
   growth_chars["1"] = "1"
   growth_chars["2"] = "2"
   growth_chars["3"] = "3"
   growth_chars["4"] = "4"
   growth_chars["5"] = "5"
   growth_chars["6"] = "6"

   gateway_chars = {}
   gateway_chars["A"] = "A"
   gateway_chars["B"] = "B"
   gateway_chars["C"] = "C"
   gateway_chars["D"] = "D"
   gateway_chars["E"] = "E"

   for ldx, line in pairs(l_table) do
      ldx = ldx - 1
      for cdx, c in pairs(line) do
	 -- print(require "pl/pretty".dump(c))
	 if c == "P" then
	    player_pos.x = cdx * 32
	    player_pos.y = ldx * 32
	    player_found = true
	 elseif brick_chars[c] ~= nil then
	    brick = {}
	    brick.x = (32 * cdx) + 16
	    brick.y = (32 * ldx) + 16
	    if c ~= "H" then	       
	       brick.body = love.physics.newBody(world, brick.x, brick.y)
	       brick.shape = love.physics.newRectangleShape(32, 32)
	       brick.fixture = love.physics.newFixture(brick.body, brick.shape)
	       brick.fixture:setFriction(0.5)
	       brick.angle = brick.body:getAngle()
	    end
	    
	    if c == "G" then
	       brick.fixture:setUserData("brick")
	    end

	    table.insert(bricks, brick)

	 elseif moving_brick_chars[c] ~= nil then
	    brick = {}
	    brick.x = (32 * cdx) + 16
	    brick.y = (32 * ldx) + 16

	    brick.angle = 0
	    brick.body = love.physics.newBody(world, brick.x, brick.y, "kinematic", 0)
	    brick.body:setMass(0)
	    
	    brick.shape = love.physics.newRectangleShape(32, 32)
	    brick.fixture = love.physics.newFixture(brick.body, brick.shape)
	    brick.fixture:setFriction(1)
	    brick.angle = brick.body:getAngle()
	    brick.fixture:setUserData("brick")

	    brick.original_x = brick.x
	    brick.original_y = brick.y

	    if c == "M" then
	       brick.speed = math.random(0.9, 1.1)
	       brick.size = 250
	       brick.slider = true
	    elseif c == "N" then
	       brick.speed = math.random(0.9, 1.1) * -1
	       brick.size = 250
	       brick.slider = true
	    end
	    
	    table.insert(moving_bricks, brick)

	 -- Growth
	 elseif growth_chars[c] ~= nil then
	    object = {}
	    object.is_anim = true
	    object.is_active = true	    
	    object.grow_to = tonumber(c)
	    object.gfx = anims.potion
	    object.x = cdx * 32
	    object.y = ldx * 32

	    object.body = love.physics.newBody(world, object.x + 16, object.y + 16)
	    object.shape = love.physics.newRectangleShape(32, 32)
	    object.fixture = love.physics.newFixture(object.body, object.shape)

	    object.txts = {}
	    if c == "2" then
	       txt = {}
	       txt.text = ":thumbsup:"
	       txt.duration = 2
	       txt.previsible = 0.5
	       table.insert(object.txts, txt)
	       
	       txt = {}
	       txt.text = "Those unproportional potion \"bottles\" are not just decorative you know..."
	       txt.duration = 4
	       txt.previsible = 0.5
	       table.insert(object.txts, txt)

	    elseif c == "3" then
	       txt = {}
	       txt.text = "Ok. Looks like you got this..."
	       txt.duration = 4
	       txt.previsible = 0.5
	       table.insert(object.txts, txt)

	       txt = {}
	       txt.text = "FREE TIP!"
	       txt.duration = 1
	       txt.previsible = 4
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "\"Some bricks are no bricks\""
	       txt.duration = 4
	       txt.previsible = 0.1
	       table.insert(object.txts, txt)
	    elseif c == "4" then
	       txt = {}
	       txt.text = "HIGH JUMP ACQUIRED"
	       txt.duration = 4
	       txt.previsible = 0.5
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "There's a portal here somewhere"
	       txt.duration = 4
	       txt.previsible = 3
	       table.insert(object.txts, txt)

	    elseif c == "5" then
	       txt = {}
	       txt.text = "LOL"
	       txt.duration = 4
	       txt.previsible = 0.5
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "(sorry)"
	       txt.duration = 2
	       txt.previsible = 0.1
	       table.insert(object.txts, txt)

	    elseif c == "6" then
	       txt = {}
	       txt.text = "Now that you've got your \"spaceship\" back"
	       txt.duration = 4
	       txt.previsible = 1
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "(I know it doesn't look like a spaceship)"
	       txt.duration = 3
	       txt.previsible = 0
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "You're free roam and discover the empty world around you"
	       txt.duration = 4
	       txt.previsible = 0
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "(There's not much to do)"
	       txt.duration = 4
	       txt.previsible = 0
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "It must be pretty weird..."
	       txt.duration = 4
	       txt.previsible = 10
	       table.insert(object.txts, txt)
	       txt = {}
	       txt.text = "If you look around, you might find some portals"
	       txt.duration = 4
	       txt.previsible = 10
	       table.insert(object.txts, txt)
	       txt.text = "There's really nothing left"
	       txt.duration = 4
	       txt.previsible = 20
	       table.insert(object.txts, txt)
	    end

	    table.insert(objects, object)
	 elseif gateway_chars[c] ~= nil then
	    gateway = {}
	    gateway.x = cdx * 32
	    gateway.y = ldx * 32

	    gateway.body = love.physics.newBody(world, gateway.x + 16, gateway.y + 16)
	    gateway.shape = love.physics.newRectangleShape(32, 32)
	    gateway.fixture = love.physics.newFixture(gateway.body, gateway.shape)

	    -- Each gateway has two chars to teleport from/to
	    if gateways[c] then
	       gateways[c][1] = gateway
	    else
	       local gs = {}
	       gs[0] = gateway
	       gateways[c] = gs
	    end
	 end
      end
   end

   return setmetatable(
      {
	 player_pos=player_pos,
	 bricks=bricks,
	 moving_bricks=moving_bricks,
	 objects=objects,
	 gateways=gateways,
	 anims=anims
      },
      Map)
end

function Map:update(dt)
   for _, o in pairs(self.objects) do
      if o.is_active then
	 if o.is_anim then
	    o.gfx.anim:update(dt)
	 end
      end
   end

   for _, b in pairs(self.moving_bricks) do
      if b.slider then
	 b.x = b.x + b.speed
	 b.body:setX(b.x)

	 if b.speed > 0 then
	    if b.x - b.original_x > b.size then
	       b.speed = b.speed * -1
	    end
	 elseif b.speed < 0 then
	    if  b.original_x - b.x > b.size then
	       b.speed = b.speed * -1
	    end
	 end
      end
      
   end
end

function Map:draw()
   love.graphics.setColor(1, 1, 1, 1)
   -- love.graphics.setColor(0.28, 0.63, 0.05)
   for _, b in pairs(self.bricks) do

      love.graphics.draw(
	 brick_gfx,
	 b.x - 16,
	 b.y - 16,
	 b.angle or 0
      )
      -- love.graphics.polygon("line", b.body:getWorldPoints(b.shape:getPoints()))
   end

   for _, b in pairs(self.moving_bricks) do
      love.graphics.draw(
	 brick_gfx,
	 b.x - 16,
	 b.y - 16,
	 b.angle or 0
      )
      -- love.graphics.polygon("line", b.body:getWorldPoints(b.shape:getPoints()))
   end

   for _, o in pairs(self.objects) do
      if o.is_active then
	 if o.is_anim then
	    o.gfx.anim:draw(o.gfx.sprite, o.x, o.y, 0)
	 end
      end
   end
   for _, gs in pairs(self.gateways) do
      for _, g in pairs(gs) do
	 love.graphics.draw(
	    gateway_gfx,
	    g.x,
	    g.y,
	    g.angle or 0
	 )
	 -- love.graphics.polygon("line", g.body:getWorldPoints(g.shape:getPoints()))
      end
   end

end


return setmetatable(
   {new = new},
   {__call = function(_, ...)
       return new(...)
   end}
)
