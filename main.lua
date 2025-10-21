_G.love = require("love")


function love.load()
    TILE_SIZE = 32
    MAP_WIDTH = 60
    MAP_HEIGHT = 35
    love.window.setMode(MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE)
    SafeX, SafeY, SafeW, SafeH = love.window.getSafeArea()
    GameMap = {}
    Player = {}
    Rectangle = {
        x = 50,
        y = 50,
        w = 50,
        h = 50
    }
end

function love.update(dt)
    if (love.keyboard.isDown("z") and Rectangle.y > SafeY) then
        Rectangle.y = Rectangle.y - 1
    end
    if (love.keyboard.isDown("d") and Rectangle.x > SafeX) then
        Rectangle.x = Rectangle.x + 1
    end
    if (love.keyboard.isDown("s") and Rectangle.y > SafeY) then
        Rectangle.y = Rectangle.y + 1
    end
    if (love.keyboard.isDown("q") and Rectangle.x > SafeX) then
        Rectangle.x = Rectangle.x - 1
    end

    if love.keyboard.isDown("f") then
        love.window.fullscreen = true
    end
    if love.keyboard.isDown("escape") then
        love.window.close()
    end
end

function love.draw()
    love.graphics.rectangle("fill", Rectangle.x, Rectangle.y, Rectangle.w, Rectangle.h)
    love.graphics.printf("FPS:" .. love.timer.getFPS(), love.graphics.newFont(16), 10, 10, love.graphics.getWidth())
end
