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
    h = 64,
    aimDirection = "RIGHT"
}

local hp = {
    quantity = TILE_SIZE*4
}
local mp = {
    quantity = TILE_SIZE*4
}
local ennemies = {}
local projectiles = {}
local SPELL_DEFINITIONS = {
    Fireball = {
        damage = 30,
        speed_multiplier = 7,
        lifetime = 1.5,
        color = {1.0, 0.4, 0.0},
        size_multiplier = 0.5,
    },
    
    IceShard = {
        damage = 15,
        speed_multiplier = 10,
        lifetime = 0.8,
        color = {0.2, 0.8, 1.0}, -- Bleu clair
        size_multiplier = 0.3,
    },
}
local ENNEMIES_DEFINITIONS = {
    MonsterA = {
        max_hp = 30,
        damage = 10,
        color = {1.0, 0.2, 0.2}, -- Rouge Vif
    },
    MonsterB = {
        max_hp = 50,
        damage = 15,
        color = {0.2, 0.8, 0.2}, -- Vert Vif
    }
}
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
function createEnemy(x_tile, y_tile, enemy_type)
    local def = ENNEMIES_DEFINITIONS[enemy_type]
    if not def then 
        print("Erreur: Type d'ennemi inconnu: " .. enemy_type)
        return nil 
    end

    local new_enemy = {
        x = x_tile * TILE_SIZE,
        y = y_tile * TILE_SIZE,
        w = TILE_SIZE,
        h = TILE_SIZE,
        
        hp = def.max_hp,
        damage = def.damage,
        color = def.color,
    }
    return new_enemy
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
function doDamage(amount)
    if hp.quantity > 0 then
        hp.quantity = hp.quantity - amount
    end
end

-- FONCTIONNEL
function eSpell(mana, dt, SPELL_TO_CAST)
    E_manaTimer = E_manaTimer - dt
    if love.keyboard.isDown("e") and E_manaTimer <= 0 then
        
        if mp.quantity >= mana then 
            mp.quantity = mp.quantity - mana
            E_manaTimer = MANA_DELAY 

            local new_proj = createProjectile(SPELL_TO_CAST, player.x, player.y, player.aimDirection)
            
            if new_proj then
                table.insert(projectiles, new_proj)
            end
        end
    end
end
function aSpell(mana, dt, SPELL_TO_CAST)
    E_manaTimer = E_manaTimer - dt
    if love.keyboard.isDown("a") and E_manaTimer <= 0 then
        
        if mp.quantity >= mana then 
            mp.quantity = mp.quantity - mana
            E_manaTimer = MANA_DELAY 

            local new_proj = createProjectile(SPELL_TO_CAST, player.x, player.y, player.aimDirection)
            
            if new_proj then
                table.insert(projectiles, new_proj)
            end
        end
    end
end
function checkAimDirection()
    if love.keyboard.isDown("up") then
        player.aimDirection="UP"    
    elseif love.keyboard.isDown("down") then
        player.aimDirection="DOWN"
    elseif love.keyboard.isDown("right") then
        player.aimDirection = "RIGHT"
    elseif love.keyboard.isDown("left") then
        player.aimDirection = "LEFT"
    end 
end

function createProjectile(spell_name, x_start, y_start, direction)
    local def = SPELL_DEFINITIONS[spell_name]
    if not def then return nil end

    local speed_x, speed_y = 0, 0
    local speed = TILE_SIZE * def.speed_multiplier
    local size = TILE_SIZE * def.size_multiplier

    if direction == "UP" then speed_y = -speed
    elseif direction == "DOWN" then speed_y = speed
    elseif direction == "RIGHT" then speed_x = speed
    elseif direction == "LEFT" then speed_x = -speed
    end

    local new_projectile = {
        x = x_start + (TILE_SIZE - size) / 2,
        y = y_start + (TILE_SIZE - size) / 2,
        w = size,
        h = size,
        
        speed_x = speed_x,
        speed_y = speed_y,
        damage = def.damage,
        color = def.color,
        lifetime = def.lifetime,
    }
    return new_projectile
end
function love.quit()
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end
function updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]

        proj.x = proj.x + proj.speed_x * dt
        proj.y = proj.y + proj.speed_y * dt
        proj.lifetime = proj.lifetime - dt

        local is_dead = false

        if proj.lifetime <= 0 then
            is_dead = true
        end
        
        for j = #ennemies, 1, -1 do
            local enemy = ennemies[j]
            
            local collision = proj.x < enemy.x + enemy.w and
                              proj.x + proj.w > enemy.x and
                              proj.y < enemy.y + enemy.h and
                              proj.y + proj.h > enemy.y

            if collision then
                enemy.hp = enemy.hp - proj.damage -- Appliquer les dégâts
                is_dead = true                   -- Le projectile disparaît
                break                            -- Sortir de la boucle des ennemis
            end
        end

        if is_dead then
            table.remove(projectiles, i)
        end
    end
end
function drawAimIndicator()
    local target_x = player.x
    local target_y = player.y
    local color = {0.0, 1.0, 0.0, 0.5}
    
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


    -- AJOUT D'ENNEMIES ICI
    table.insert( ennemies, createEnemy(1, 1, "MonsterA")) 
    table.insert( ennemies, createEnemy(10, 1, "MonsterA"))
    table.insert( ennemies, createEnemy(5, 5, "MonsterB")) 
    -- FIN D'AJOUT
    function love.drawEnemy(enemy)
        love.graphics.setColor(enemy.color)
        love.graphics.rectangle("fill", enemy.x + 2, enemy.y + 2, enemy.w - 4, enemy.h - 4, 4, 4)
    end
end
function love.update(dt)
    damageTimer = math.max(0, damageTimer - dt)
    E_manaTimer = math.max(0, E_manaTimer - dt)
    checkAimDirection()
    updateProjectiles(dt)
    eSpell(10, dt, "Fireball")
    aSpell(10, dt, "IceShard")
    updateEnemy(dt)
    playerMovement(dt)

    love.quit()
    
    for _, enemy in ipairs(ennemies) do
        if player.x == enemy.x and player.y == enemy.y then
            
            if damageTimer <= 0 then
                doDamage(enemy.damage) 
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
    for _, proj in ipairs(projectiles) do
        love.graphics.setColor(proj.color)
        love.graphics.rectangle("fill", proj.x, proj.y, proj.w, proj.h, 2, 2)
    end
    love.drawPlayer()
    drawAimIndicator()
    love.showFPS()
    love.gameFrame()
    love.die()
end

