_G.love = require("love") 
local game = {
    difficulty = 1,
    state = {
        menu = true,
        paused = false,
        running = false,
        ended = false
    }
}
local player = {
    x = 40,
    y = 20,
    w = 50,
    h = 50

}

local ennemies = {
    
}

function love.load()
    -- VARIABLES --
    TILE_SIZE = 32
    MAP_WIDTH = 60
    MAP_HEIGHT = 35
    love.window.setMode(MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE)
    love.mouse.setVisible(false)
    love.window.setTitle("Project : Rebirth")
    -- FONCTIONS --
    function love.playerMovement()
        if (love.keyboard.isDown("z") and player.y > 0) then
            player.y = player.y - 10
        end
        if (love.keyboard.isDown("d") and player.x >= 0) then
            player.x = player.x + 10
        end
        if (love.keyboard.isDown("s") and player.y >= 0) then
            player.y = player.y + 10
        end
        if (love.keyboard.isDown("q") and player.x > 0) then
            player.x = player.x - 10
        end
    end

    function love.fullscreen()
        if love.keyboard.isDown("f") then
            love.window.fullscreen = true
        end
    end

    function love.quit()
        if love.keyboard.isDown("escape") then
            love.window.close()
        end
    end
end

function love.update(dt)
    love.playerMovement()
    love.fullscreen()
    love.quit()
end

function love.draw()
    love.graphics.setColor(0,0.4,0.4)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
    love.graphics.printf("FPS:" .. love.timer.getFPS(), love.graphics.newFont(16), 10, 10, love.graphics.getWidth())
end
