local Textr = {}
Textr.__index = Textr


local function new()
   text = ""
   duration = 1
   previsible_timer = 0
   visibility_timer = 0
   visible = false
   queue = {}
   return setmetatable(
      {
	 text=text,
	 duration=duration,
	 previsible_timer=previsible_timer,
	 visibility_timer=visibility_timer,
	 visible=visible,
	 queue=queue,
      }, Textr)
end


function Textr:show(text, previsible_duration, duration)
   self.text = text
   if previsible_duration == 0 then
      self.visible = true
   else
      self.previsible_timer = previsible_duration
   end

   self.duration = duration   
   self.visiblity_timer = 0
end

function Textr:add_to_queue(text, previsible_duration, duration)
   msg = {text=text, previsible_duration=previsible_duration, duration=duration}
   table.insert(self.queue, msg)
end

function Textr:draw()
   if self.visible and self.text then
      love.graphics.setColor(1, 1, 1, 0.6)
      love.graphics.rectangle("fill", 0, 280, 1000, 55 )

      love.graphics.setFont(medium_font)
      love.graphics.setColor(0, 0, 0, 0.9)
      love.graphics.printf(self.text, 0, 295, 1000, "center")
   end
end

function Textr:update(dt)
   if self.visible then
      self.visiblity_timer = self.visiblity_timer + dt

      if self.visiblity_timer > self.duration then
	 self.visible = false
	 self.visiblity_timer = 0
	 self.previsible_timer = 0
	 self.text = ""
      end
   end

   if self.previsible_timer > 0 then
      self.previsible_timer = self.previsible_timer - dt
      if self.previsible_timer <= 0 then
	 self.previsible_timer = 0
	 self.visible = true
      end
   end

   if table.getn(self.queue) > 0 and self.text == "" then
      msg = table.remove(self.queue, 1)
      self:show(msg.text, msg.previsible_duration, msg.duration)
   end
end

return setmetatable(
   {new = new},
   {__call = function(_, ...)
       return new(...)
   end}
)
