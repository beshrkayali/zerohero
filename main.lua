debug = false

Game = require "game"
GameMode = { menu="menu", gameplay="gameplay" }

function love.load()
   love.graphics.setDefaultFilter('nearest', 'nearest')
   love.window.setMode(1000, 350)
   game = Game()
end

function love.draw()
   game:draw()
end

function love.update(dt)
   game:update(dt)
end
