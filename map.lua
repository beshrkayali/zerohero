local Map = {}
Map.__index = Map

local anim8 = require 'libs/anim8'

local function new(world, index)
   brick_gfx = love.graphics.newImage('gfx/brick.png')

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
   objects = {}

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
  
   for ldx, line in pairs(l_table) do
      ldx = ldx - 1
      for cdx, c in pairs(line) do
	 cdx = cdx - 1

	 -- labove = l_table[ldx - 1]
	 -- lbelow = l_table[ldx + 1]
	 -- if labove then
	 --    babove = labove[cdx]
	 -- end

	 -- if lbelow then
	 --    bbelow = lbelow[cdx]
	 -- end

	 -- bbefore = line[cdx - 1]
	 -- bafter = line[cdx + 1]

	 -- print(require "pl/pretty".dump(c))
	 if c == "P" then
	    player_pos.x = cdx * 32
	    player_pos.y = ldx * 32
	    player_found = true
	 elseif c == "#" or c == "G" then
	    brick = {}
	    brick.body = love.physics.newBody(world, (29 * cdx) + 16, (32 * ldx) + 16)
	    brick.shape = love.physics.newRectangleShape(32, 32)
	    brick.fixture = love.physics.newFixture(brick.body, brick.shape)
	    brick.fixture:setFriction(0.5)

	    if c == "G" then
	       brick.fixture:setUserData("brick")
	    end

	    table.insert(bricks, brick)
	 -- Growth
	 elseif c == "2" or c == "3" then
	    object = {}
	    object.is_anim = true
	    object.is_active = true	    
	    object.grow_to = tonumber(c)
	    object.gfx = anims.potion
	    object.x = cdx * 23
	    object.y = ldx * 32

	    object.body = love.physics.newBody(world, object.x + 16, object.y + 16)
	    object.shape = love.physics.newRectangleShape(32, 32)
	    object.fixture = love.physics.newFixture(object.body, object.shape)
	    table.insert(objects, object)
	 end
      end
   end

   return setmetatable(
      {
	 player_pos=player_pos,
	 bricks=bricks,
	 objects=objects,
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
end

function Map:draw()
   love.graphics.setColor(1, 1, 1, 1)
   -- love.graphics.setColor(0.28, 0.63, 0.05)
   for _, b in pairs(self.bricks) do
      love.graphics.draw(
      	 brick_gfx,
      	 b.body:getX() - 16, b.body:getY() - 16,
      	 b.body:getAngle()
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
end


return setmetatable(
   {new = new},
   {__call = function(_, ...)
       return new(...)
   end}
)
