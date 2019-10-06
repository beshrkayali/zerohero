local Game = {}
Game.__index = Game

MS = require 'libs/moonshine'
Camera = require 'libs/Camera'
Map = require "map"
Player = require "player"

local function new()
   -- World
   love.physics.setMeter(32)
   world = love.physics.newWorld(0, 400, true)
   world:setCallbacks(beginContact, endContact, preSolve, postSolve)

   -- Camera
   camera = Camera()   
   camera:setFollowLerp(0.2)
   camera:setFollowLead(10)
   camera:setFollowStyle('SCREEN_BY_SCREEN')
   
   
   -- Map/Player
   map = Map(world, "1")
   player = Player(map.player_pos.x, map.player_pos.y, world)
   player:grow(1)

   -- Assets
   large_font = love.graphics.newFont('fonts/m6x11.ttf', 80)
   medium_font = love.graphics.newFont('fonts/m6x11.ttf', 30)
   small_font = love.graphics.newFont('fonts/m6x11.ttf', 16)
   
   effect = MS(MS.effects.dmg)
      .chain(MS.effects.filmgrain)
      .chain(MS.effects.crt)
      .chain(MS.effects.chromasep)

   effect.filmgrain.size = 3
   effect.dmg.palette = "pocket"
   effect.crt.feather= 0.02
   effect.crt.distortionFactor = {1, 1.09}

   mode = GameMode.gameplay
   -- mode = GameMode.menu
   -- menu = require("mainmenu")()
   
   return setmetatable(
      {
	 world=world,
	 map=map,
	 effect=effect,
	 player=player,
	 mode=mode,
	 menu=menu,
      },
      Game
   )
end

function Game:draw()
   love.graphics.setBackgroundColor( 0, 0, 0, 1 )
   
   self.effect(function()
	 camera:attach()

	 if self.mode == GameMode.menu and self.menu then
	    self.menu:draw()
	 elseif self.mode == GameMode.gameplay then
	    map:draw()
	    player:draw()
	 end
	 camera:detach()
	 camera:draw()
   end)
end

function Game:update(dt)
   camera:update(dt)
   self.world:update(dt)

   if self.mode == GameMode.menu then
      self.menu:update()
   elseif self.mode == GameMode.gameplay then
      self.map:update(dt)
      self.player:update(dt)
      camera:follow(self.player.x, self.player.y)
   end

   for _, o in pairs(self.map.objects) do
      if o.is_active and self.player.body then
	 if o.grow_to and o.body:isTouching(self.player.body) then
	    self.player:grow(o.grow_to)
	    o.is_active = false
	    o.body:destroy()
	    o.body:release()
	    o.shape:release()
	 end
      end
   end

   -- Remove menu when inactive
   if self.menu and self.menu.active == false then
      self.menu = nil
      self.mode = GameMode.gameplay
   end
end

function beginContact(a, b, coll)
   x,y = coll:getNormal()
   y = math.floor(y * 100 + 0.5) / 10;
   top_of_something = y <= -9
   player_touching_brick = a:getUserData() == "brick" and b:getUserData() == "player" or a:getUserData() == "player" and b:getUserData() == "brick"
   player.can_jump = player_touching_brick and top_of_something
   if player.can_jump then
      camera:shake(1, 0.5, 60, 'XY')
   end
end
 
function endContact(a, b, coll)
end
 
function preSolve(a, b, coll)
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

return setmetatable(
   {new = new},
   {__call = function(_, ...)
       return new(...)
   end}
)
