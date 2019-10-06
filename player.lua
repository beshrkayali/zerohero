local Player = {}
Player.__index = Player

local anim8 = require 'libs/anim8'

local function new(x, y, world)
   -- Stats
   x = x or love.graphics.getWidth() / 2
   y = y or love.graphics.getHeight() / 2   
   can_jump = true
   hflip = false
   vflip = false
   moving = false
   growth = 0

   return setmetatable(
      {	 
	 body=nil,
	 shape=nil,
	 growth=growth,
	 character=character,
	 x=x,
	 y=y,
	 force=force,
	 can_jump=can_jump,
	 moving=moving,
	 hflip=hflip,
	 vflip=vflip,
      },
      Player
   )
end

function Player:setCharacter()
   character = {}

   if self.growth == 1 then
      local sprite = love.graphics.newImage(string.format("gfx/char_1.png"))
      local sprite_grid = anim8.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
      character.sprite = sprite
      character.idle = anim8.newAnimation(sprite_grid('1-1', 1), 0.1)
      character.walk = anim8.newAnimation(sprite_grid('2-4', 1), 0.1)
      character.circleSize = 5
      character.force = 30
      character.jump_power = 0

   elseif self.growth == 2 then
      local sprite = love.graphics.newImage(string.format("gfx/char_1.png"))
      local sprite_grid = anim8.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
      character.sprite = sprite
      character.idle = anim8.newAnimation(sprite_grid('1-1', 1), 0.1)
      character.walk = anim8.newAnimation(sprite_grid('2-4', 1), 0.1)
      character.circleSize = 5
      character.force = 40
      character.jump_power = 0.75
   elseif self.growth == 3 then
      local sprite = love.graphics.newImage(string.format("gfx/char_2.png"))
      local sprite_grid = anim8.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
      character.sprite = sprite
      character.idle = anim8.newAnimation(sprite_grid('1-1', 1), 0.1)
      character.walk = anim8.newAnimation(sprite_grid('2-4', 1), 0.1)
      character.circleSize = 10
      character.force = 100
      character.jump_power = 2
   elseif self.growth == 4 then
      local sprite = love.graphics.newImage(string.format("gfx/char_2.png"))
      local sprite_grid = anim8.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
      character.sprite = sprite
      character.idle = anim8.newAnimation(sprite_grid('1-1', 1), 0.1)
      character.walk = anim8.newAnimation(sprite_grid('2-4', 1), 0.1)
      character.circleSize = 10
      character.force = 140
      character.jump_power = 3
   elseif self.growth == 5 then
      local sprite = love.graphics.newImage(string.format("gfx/char_3.png"))
      local sprite_grid = anim8.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
      character.sprite = sprite
      character.idle = anim8.newAnimation(sprite_grid('1-1', 1), 0.1)
      character.walk = anim8.newAnimation(sprite_grid('2-4', 1), 0.1)
      character.circleSize = 13
      character.force = 200
      character.jump_power = 6
   elseif self.growth == 6 then
      local sprite = love.graphics.newImage(string.format("gfx/char_4.png"))
      local sprite_grid = anim8.newGrid(32, 32, sprite:getWidth(), sprite:getHeight())
      character.sprite = sprite
      character.idle = anim8.newAnimation(sprite_grid('1-4', 1), 0.1)
      character.walk = anim8.newAnimation(sprite_grid('1-4', 1), 0.1)
      character.circleSize = 14
      character.force = 230
      character.jump_power = 8
   end

   -- character.circleSize = 13
   -- character.force = 200
   --  character.jump_power = 5
   
   self.character = character
end

function Player:setPhysics()
   -- Physics
   self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
   self.body:setFixedRotation(true)
   self.body:setLinearDamping(0.01)
   self.shape = love.physics.newCircleShape(character.circleSize)
   fixture = love.physics.newFixture(self.body, self.shape, 1)
   fixture:setUserData("player")
   fixture:setFriction(1)
   fixture:setRestitution(-1)
end

function Player:grow(g)
   self.growth = g
   self:setCharacter()
   self:setPhysics()
   print(string.format("Growth %s", self.growth))
end

function Player:draw()
   if debug then
      love.graphics.setColor(0.76, 0.18, 0.05, 0.8)
      love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
   end

   if self.hflip then
      xscale = -1
   else
      xscale = 1
   end
   if self.vflip then
      yscale = -1
   else
      yscale = 1
   end

   self.x = self.body:getX()
   self.y = self.body:getY()

   love.graphics.setColor(1,1,1, 1)
   if self.moving then
      self.character.walk:draw(self.character.sprite, self.x, self.y, 0, xscale, yscale, 16, 16)
   else
      self.character.idle:draw(self.character.sprite, self.x, self.y, 0, xscale, yscale, 16, 16)
   end

   if debug then
      love.graphics.setColor(0.28, 0.63, 0.05, 1)
      love.graphics.setFont(medium_font)
      love.graphics.print(string.format("Can jump: %s", self.can_jump), self.x - 50, self.y - 50)
   end
end

function Player:update(dt)
   self.moving = false
   self.character.walk:update(dt)

   if love.keyboard.isDown("right") then
      self.hflip = false
      self.moving = true

      self.body:applyForce(self.character.force, 0)
   elseif love.keyboard.isDown("left") then
      self.hflip = true
      self.moving = true
      self.body:applyForce(self.character.force * -1, 0)
   end

   if love.keyboard.isDown("up") and self.can_jump then
      self.can_jump = false
      self.body:applyForce(0, self.character.jump_power * -1000)
   end
end

return setmetatable(
   {new = new},
   {__call = function(_, ...)
       return new(...)
   end}
)
