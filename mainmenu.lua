local Menu = {}
Menu.__index = Menu


local function new()
   active = true
   camera.fade_color = {0, 0, 0, 1}
   return setmetatable({active=active}, Menu)
end

function Menu:draw()
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setFont(large_font)
   love.graphics.printf("ZERO > HERO", 0, 60, 1000, "center")
   love.graphics.setFont(medium_font)
   love.graphics.printf("You are nothing", 0, 150, 1000, "center")
   love.graphics.printf("your goal is ", 0, 190, 1000, "center")
   love.graphics.printf("to become something", 0, 230, 1000, "center")
   love.graphics.setFont(small_font)
   love.graphics.printf("[Press Enter to Start]", 0, 275, 1000, "center")
end

function Menu:update()
   if self.introduced == nil then
      self.introduced = true
      camera:fade(3, {0, 0, 0, 0})
   end

   if love.keyboard.isDown("return") then
      camera:fade(
	 3,
	 {0, 0, 0, 1},
	 function()
	    camera:fade(3, {0, 0, 0, 0})
	    self.active = false
	 end
      )
   end
end

return setmetatable(
   {new = new},
   {__call = function(_, ...)
       return new(...)
   end}
)
