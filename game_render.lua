local unpack = table.unpack or unpack
local Data = require("game_data")
local State = require("game_state")

local Render = {}

local TILE_SIZE = Data.TILE_SIZE
local TILE_TYPES = Data.TILE_TYPES
local GAME_MAP_W_TILES = Data.GAME_MAP_W_TILES


function Render.drawBackground()
    love.graphics.setLineWidth(2)
    for y = 1, Data.GAME_MAP_H_TILES do
        for x = 1, GAME_MAP_W_TILES do
            local tile_type = State.game_map[y][x]
            local px = (x - 1) * TILE_SIZE
            local py = (y - 1) * TILE_SIZE
            
            if tile_type == TILE_TYPES.WALL then
                love.graphics.setColor(0.3, 0.3, 0.3) 
                love.graphics.rectangle("fill", px, py, TILE_SIZE, TILE_SIZE)
            else
                love.graphics.setColor(0.549, 0.063, 0.027) 
                love.graphics.rectangle("line", px + 2, py + 2, TILE_SIZE - 4, TILE_SIZE - 4)
            end
        end
    end
end
function Render.drawSidePanel()
    love.graphics.setColor(0.243, 0.027, 0.012)
    local map_width_px = Data.GAME_MAP_W_TILES * TILE_SIZE
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    
    local panel_x = map_width_px  -- Commence juste après la carte
    local panel_y = 0             -- Commence en haut
    local panel_w = screen_width - map_width_px -- Largeur restante
    local panel_h = screen_height -- Hauteur totale
    
    -- Dessiner le rectangle rempli
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h)
    
    love.graphics.setColor(1, 0.941, 0.769)
    love.graphics.setLineWidth(10)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h)
end
function Render.drawAimIndicator()
    local player = State.player
    local target_x = player.x
    local target_y = player.y
    
    local color = {0.0, 1.0, 0.0, 0.5} -- Vert semi-transparent
    
    if player.aimDirection == "UP" then
        target_y = player.y - TILE_SIZE
    elseif player.aimDirection == "DOWN" then
        target_y = player.y + TILE_SIZE
    elseif player.aimDirection == "LEFT" then
        target_x = player.x - TILE_SIZE
    elseif player.aimDirection == "RIGHT" then
        target_x = player.x + TILE_SIZE
    end
    
    love.graphics.setColor(color)
    love.graphics.setLineWidth(4) 
    love.graphics.rectangle("line", target_x, target_y, TILE_SIZE, TILE_SIZE)
end

function Render.drawEntities()
    for _, enemy in ipairs(State.ennemies) do
        love.graphics.setColor(enemy.color)
        love.graphics.rectangle("fill", enemy.x + 2, enemy.y + 2, enemy.w - 4, enemy.h - 4, 4, 4)
    end
    
    for _, proj in ipairs(State.projectiles) do
        love.graphics.setColor(proj.color)
        love.graphics.rectangle("fill", proj.x, proj.y, proj.w, proj.h, 2, 2)
    end
    
    love.graphics.setColor(0.549, 0.063, 0.027)
    love.graphics.rectangle("fill", State.player.x + 1, State.player.y + 1, State.player.w, State.player.h, 4, 4)
end



function Render.drawUI()
    local hp = State.hp
    local mp = State.mp

    love.graphics.setColor(0.243, 0.027, 0.012)
    love.graphics.rectangle("fill", 0, TILE_SIZE * 10, TILE_SIZE * GAME_MAP_W_TILES, TILE_SIZE * (Data.GAME_MAP_H_TILES + 10))
    
    local hpFont = love.graphics.newFont(TILE_SIZE / 2)
    love.graphics.setFont(hpFont)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("HP:", 5, TILE_SIZE*10+(TILE_SIZE/5), TILE_SIZE*4)
    love.graphics.printf("MP:", 5, TILE_SIZE*11+(TILE_SIZE/5), TILE_SIZE*4)
    -- Back HP bar
    love.graphics.setColor(0.639, 0.663, 0.678)
    love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*10+(TILE_SIZE/4), TILE_SIZE*4, TILE_SIZE/2)
    -- Front HP bar
    love.graphics.setColor(0.839, 0.227, 0.29)
    love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*10+(TILE_SIZE/4), hp.quantity, TILE_SIZE/2)

    -- Back HP bar
    love.graphics.setColor(0.639, 0.663, 0.678)
    love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*11+(TILE_SIZE/4), TILE_SIZE*4, TILE_SIZE/2)
    -- Front HP bar
    love.graphics.setColor(0.227, 0.463, 0.839)
    love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*11+(TILE_SIZE/4), mp.quantity, TILE_SIZE/2)
end

function Render.drawFPS()
    local fpsFont = love.graphics.newFont(32)
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("FPS:" .. love.timer.getFPS(), 10, 10, love.graphics.getWidth(), "left")
end
function Render.drawGameFrame()
    love.graphics.setLineWidth(8)
    love.graphics.setColor(1, 0.941, 0.769)
    love.graphics.rectangle("line", 0, 0, TILE_SIZE * GAME_MAP_W_TILES, TILE_SIZE * Data.GAME_MAP_H_TILES, 10, 10, TILE_SIZE)
    love.graphics.setLineWidth(10)
    love.graphics.rectangle("line", 0, 0, love.graphics.getWidth() - 2, love.graphics.getHeight() - 2, 10, 10, TILE_SIZE)
end

return Render