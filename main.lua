_G.love = require("love")
-- VARIABLES --
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
TILE_SIZE = 64
MAP_WIDTH = WINDOW_WIDTH / TILE_SIZE
MAP_HEIGHT = WINDOW_WIDTH / TILE_SIZE
local MOVE_DELAY = 0.1
local MANA_DELAY = 0.5
local DAMAGE_DELAY = 0.5
local ENEMY_MOVE_DELAY = 0.2
local damageTimer = 0
local moveTimer = 0
local enemyMoveTimer = 0
local E_manaCooldown = 1.0
local E_manaTimer = 0
local cd = 60
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
    x = 0,
    y = 0,
    w = 64,
    h = 64

}
local hp = {
    quantity = TILE_SIZE*4
}
local mp = {
    quantity = TILE_SIZE*4
}
local ennemies = {}
function playerMovement(dt)
    moveTimer = moveTimer - dt
    if moveTimer <= 0 then
        local moved = false
        if love.keyboard.isDown("z") then
            if player.y > 0 then
                player.y = player.y - TILE_SIZE
                moved = true
            end
            
        elseif love.keyboard.isDown("s") then
            if player.y < TILE_SIZE*9 then
                player.y = player.y + TILE_SIZE
                moved = true
            end

        elseif love.keyboard.isDown("d") then
            if player.x < TILE_SIZE*14 then
                player.x = player.x + TILE_SIZE
                moved = true
            end
            
        elseif love.keyboard.isDown("q") then
            if player.x > 0 then
                player.x = player.x - TILE_SIZE
                moved = true
            end
        end
        if moved then
            moveTimer = MOVE_DELAY
        end
    end
    
end
-- LOGIQUE INTERACTION ENNEMIES
function updateEnemy(dt)
    enemyMoveTimer = enemyMoveTimer - dt
    
    if enemyMoveTimer <= 0 then
        for i = #ennemies, 1, -1 do
            local enemy = ennemies[i]

            if not (player.x == enemy.x and player.y == enemy.y) then
                moveEnemyTowardsPlayer(enemy, player)
            end

            if enemy.hp <= 0 then
                table.remove(ennemies, i)
            end
        end
        
        -- Réinitialisation du timer IA
        enemyMoveTimer = ENEMY_MOVE_DELAY
    end
end
function love.die()
    if hp.quantity < 0 then
        love.graphics.clear(0, 0, 0, 0)
    end
end
function moveEnemyTowardsPlayer(enemy, player)
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    
    local move_x = 0
    local move_y = 0

    if dx ~= 0 then
        move_x = (dx > 0 and TILE_SIZE) or (dx < 0 and -TILE_SIZE)
    end
    
    if dy ~= 0 then
        move_y = (dy > 0 and TILE_SIZE) or (dy < 0 and -TILE_SIZE)
    end
    if move_x ~= 0 then
        enemy.x = enemy.x + move_x
    elseif move_y ~= 0 then
        enemy.y = enemy.y + move_y
    end
end
function doDamage(amount, dt)
    damageTimer = damageTimer - dt
    if damageTimer <= 0 then
        local isPressed = false
        if hp.quantity > 0 then
            hp.quantity = hp.quantity - amount
            damageTimer = 0.1
            isPressed = true
        end
        if isPressed then
            damageTimer = DAMAGE_DELAY
        end
    end
end

-- FONCTIONNEL
function love.eSpell(mana, dt)
    E_manaTimer = E_manaTimer - dt
    if love.keyboard.isDown("e") and E_manaTimer <= 0 then
        local isPressed = false
        if mp.quantity > 0 + mana then
            mp.quantity = mp.quantity - mana
            E_manaTimer = 1.0
            isPressed = true
        end
        if isPressed then
            E_manaTimer = MANA_DELAY
        end
    end
end

function love.quit()
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.load()
    

    love.mouse.setVisible(false)
    love.window.setTitle("Project : Rebirth")
    -- FONCTIONS --
    function love.drawBackground()
        love.graphics.setLineWidth(2)
        for i = 2, MAP_WIDTH * TILE_SIZE, TILE_SIZE do
            for j = 2, MAP_HEIGHT * TILE_SIZE, TILE_SIZE do
                love.graphics.setColor(0.549, 0.063, 0.027)
                love.graphics.rectangle("line", i, j, TILE_SIZE - 2, TILE_SIZE - 2, 4, 4)
            end
        end
    end
    function love.UI()
        love.graphics.setColor(0.243, 0.027, 0.012)
        love.graphics.rectangle("fill", 0, TILE_SIZE*10, TILE_SIZE*MAP_WIDTH, TILE_SIZE*MAP_HEIGHT)
        love.graphics.rectangle("fill", TILE_SIZE*15, 0, TILE_SIZE*MAP_WIDTH, TILE_SIZE*MAP_HEIGHT)
    end
    function love.userHP()
        -- Write HP txt
        local hpFont = love.graphics.newFont(TILE_SIZE/2)
        love.graphics.setFont(hpFont)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("HP:", 5, TILE_SIZE*10+(TILE_SIZE/5), TILE_SIZE*4)
        -- Back HP bar
        love.graphics.setColor(0.639, 0.663, 0.678)
        love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*10+(TILE_SIZE/4), TILE_SIZE*4, TILE_SIZE/2)
        -- Front HP bar
        love.graphics.setColor(0.839, 0.227, 0.29)
        love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*10+(TILE_SIZE/4), hp.quantity, TILE_SIZE/2)
    end
    function love.userMP()
        -- Write HP txt
        local hpFont = love.graphics.newFont(TILE_SIZE/2)
        love.graphics.setFont(hpFont)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("MP:", 5, TILE_SIZE*11+(TILE_SIZE/5), TILE_SIZE*4)
        -- Back HP bar
        love.graphics.setColor(0.639, 0.663, 0.678)
        love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*11+(TILE_SIZE/4), TILE_SIZE*4, TILE_SIZE/2)
        -- Front HP bar
        love.graphics.setColor(0.227, 0.463, 0.839)
        love.graphics.rectangle("fill", TILE_SIZE, TILE_SIZE*11+(TILE_SIZE/4), mp.quantity, TILE_SIZE/2)
    end
    function love.gameFrame()
        love.graphics.setLineWidth(8)
        love.graphics.setColor(1, 0.941, 0.769)
        -- Inner frame
        love.graphics.rectangle("line",0, 0,TILE_SIZE*15,TILE_SIZE*10, 10, 10, TILE_SIZE)
        -- Outer frame
        love.graphics.setLineWidth(10)
        love.graphics.rectangle("line",0, 0, TILE_SIZE*21-2, 838, 10,10,TILE_SIZE)
    end
    function love.showFPS()
        local fpsFont = love.graphics.newFont(32)
        love.graphics.setFont(fpsFont)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("FPS:" .. love.timer.getFPS(), 10, 10, love.graphics.getWidth(), "left")
    end
    function love.drawPlayer()
        love.graphics.setColor(0.549, 0.063, 0.027)
        love.graphics.rectangle("fill", player.x+1, player.y+1, player.w, player.h, 4,4)
    end
    function love.createEnemy(x_tile, y_tile)
        local new_enemy = {
            x = x_tile * TILE_SIZE,
            y = y_tile * TILE_SIZE,
            w = TILE_SIZE,
            h = TILE_SIZE,
            
            hp = 30,
            damage = 10,
            color = {1, 1, 0} -- Couleur jaune
        }
        return new_enemy
    end

    -- AJOUT D'ENNEMIES ICI
    table.insert( ennemies, love.createEnemy(1,1))
    table.insert( ennemies, love.createEnemy(10,1))
    -- FIN D'AJOUT
    function love.drawEnemy(enemy)
        love.graphics.setColor(enemy.color)
        love.graphics.rectangle("fill", enemy.x + 2, enemy.y + 2, enemy.w - 4, enemy.h - 4, 4, 4)
    end
end
function love.update(dt)
    damageTimer = math.max(0, damageTimer - dt)
    E_manaTimer = math.max(0, E_manaTimer - dt)

    updateEnemy(dt)
    playerMovement(dt)
    love.quit()
    
    for _, enemy in ipairs(ennemies) do
        if player.x == enemy.x and player.y == enemy.y then
            
            if damageTimer <= 0 then
                doDamage(enemy.damage, dt) 
                damageTimer = DAMAGE_DELAY 
            end
        end
    end
    love.die() 
end

function love.draw()
    love.drawBackground()
    love.UI()
    love.userHP()
    love.userMP()
    for _, enemy in ipairs(ennemies) do
        love.drawEnemy(enemy)
    end
    love.drawPlayer()
    love.showFPS()
    love.gameFrame()
    love.die()
end

