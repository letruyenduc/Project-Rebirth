
local Data = require("game_data")
local State = require("game_state")

local Logic = {}

local player = State.player
local ennemies = State.ennemies
local projectiles = State.projectiles
local game_map = State.game_map


function Logic.isColliding(target_x, target_y)
    local tx = math.floor(target_x / Data.TILE_SIZE) + 1
    local ty = math.floor(target_y / Data.TILE_SIZE) + 1
    
    if tx < 1 or ty < 1 or tx > Data.GAME_MAP_W_TILES or ty > Data.GAME_MAP_H_TILES then
        return true
    end

    if game_map[ty] and game_map[ty][tx] == Data.TILE_TYPES.WALL then
        return true
    end
    
    return false 
end

function Logic.createEnemy(x_tile, y_tile, enemy_type)
    local def = Data.ENNEMIES_DEFINITIONS[enemy_type]
    if not def then 
        print("Erreur: Type d'ennemi inconnu: " .. enemy_type)
        return nil 
    end

    local new_enemy = {
        x = x_tile * Data.TILE_SIZE,
        y = y_tile * Data.TILE_SIZE,
        w = Data.TILE_SIZE,
        h = Data.TILE_SIZE,
        
        hp = def.max_hp,
        damage = def.damage,
        color = def.color,
    }
    return new_enemy
end

function Logic.createProjectile(spell_name, x_start, y_start, direction)
    local def = Data.SPELL_DEFINITIONS[spell_name]
    if not def then return nil end

    local speed_x, speed_y = 0, 0
    local speed = Data.TILE_SIZE * def.speed_multiplier
    local size = Data.TILE_SIZE * def.size_multiplier

    if direction == "UP" then speed_y = -speed
    elseif direction == "DOWN" then speed_y = speed
    elseif direction == "RIGHT" then speed_x = speed
    elseif direction == "LEFT" then speed_x = -speed
    end

    local new_projectile = {
        x = x_start + (Data.TILE_SIZE - size) / 2,
        y = y_start + (Data.TILE_SIZE - size) / 2,
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


function Logic.playerMovement(dt)
    State.moveTimer = State.moveTimer - dt
    if State.moveTimer <= 0 then
        local moved = false
        local next_x = player.x
        local next_y = player.y

        if love.keyboard.isDown("z") then
            next_y = player.y - Data.TILE_SIZE
        elseif love.keyboard.isDown("s") then
            next_y = player.y + Data.TILE_SIZE
        elseif love.keyboard.isDown("d") then
            next_x = player.x + Data.TILE_SIZE
        elseif love.keyboard.isDown("q") then
            next_x = player.x - Data.TILE_SIZE
        end
        
        if not Logic.isColliding(next_x, next_y) then
            player.x = next_x
            player.y = next_y
            moved = true
        end

        if moved then
            State.moveTimer = Data.MOVE_DELAY
        end
    end
end

function Logic.checkAimDirection()
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

function Logic.doDamage(amount)
    if State.hp.quantity > 0 then
        State.hp.quantity = State.hp.quantity - amount
    end
end

function Logic.checkQuit()
    if love.keyboard.isDown("escape") then love.event.quit() end
end

function Logic.checkDie()
    if State.hp.quantity <= 0 then
        State.game.state.ended = true
    end
end


function Logic.castSpell(key, mana_cost, dt, spell_name)
    State.eManaTimer = State.eManaTimer - dt
    
    if love.keyboard.isDown(key) and State.eManaTimer <= 0 then
        if State.mp.quantity >= mana_cost then 
            State.mp.quantity = State.mp.quantity - mana_cost
            State.eManaTimer = Data.MANA_DELAY 
            
            local new_proj = Logic.createProjectile(spell_name, player.x, player.y, player.aimDirection)
            
            if new_proj then
                table.insert(projectiles, new_proj)
            end
        end
    end
end

function Logic.updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]

        proj.x = proj.x + proj.speed_x * dt
        proj.y = proj.y + proj.speed_y * dt
        proj.lifetime = proj.lifetime - dt

        local is_dead = false

        if proj.lifetime <= 0 then
            is_dead = true
        end

        local center_x = proj.x + proj.w / 2
        local center_y = proj.y + proj.h / 2
        
        if Logic.isColliding(center_x, center_y) then
             is_dead = true
        end
        
        if not is_dead then
            for j = #ennemies, 1, -1 do
                local enemy = ennemies[j]
                
                local collision = proj.x < enemy.x + enemy.w and
                                  proj.x + proj.w > enemy.x and
                                  proj.y < enemy.y + enemy.h and
                                  proj.y + proj.h > enemy.y

                if collision then
                    enemy.hp = enemy.hp - proj.damage 
                    is_dead = true
                    break
                end
            end
        end

        if is_dead then
            table.remove(projectiles, i)
        end
    end
end

function Logic.isTileOccupied(target_x, target_y, self_enemy)
    for _, enemy in ipairs(State.ennemies) do
        if enemy ~= self_enemy then
            
            if enemy.x == target_x and enemy.y == target_y then
                return true 
            end
        end
    end
    return false 
end

function Logic.updateEnemy(dt)
    State.enemyMoveTimer = State.enemyMoveTimer - dt
    
    if State.enemyMoveTimer <= 0 then
        for i = #State.ennemies, 1, -1 do
            local enemy = State.ennemies[i]

            if enemy.hp > 0 then
                
                local moved = false
                
                if not (State.player.x == enemy.x and State.player.y == enemy.y) then
                    moved = Logic.moveEnemyTowardsPlayer(enemy, State.player)
                end

            else
                table.remove(State.ennemies, i)
            end
        end
        
        State.enemyMoveTimer = Data.ENEMY_MOVE_DELAY
    end
end

-- Dans game_logic.lua

function Logic.moveEnemyTowardsPlayer(enemy, player)
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    
    local move_x = 0
    local move_y = 0

    if dx ~= 0 then
        move_x = (dx > 0 and Data.TILE_SIZE) or (dx < 0 and -Data.TILE_SIZE)
    end
    
    if dy ~= 0 then
        move_y = (dy > 0 and Data.TILE_SIZE) or (dy < 0 and -Data.TILE_SIZE)
    end

    local next_x = enemy.x
    local next_y = enemy.y
    
    if move_x ~= 0 then
        next_x = enemy.x + move_x
    elseif move_y ~= 0 then
        next_y = enemy.y + move_y
    end
    
    local moved = false
    
    if move_x ~= 0 then
        local not_colliding_with_wall = not Logic.isColliding(next_x, enemy.y)
        local not_occupied = not Logic.isTileOccupied(next_x, enemy.y, enemy)

        if not_colliding_with_wall and not_occupied then
            enemy.x = next_x
            moved = true
        end
    end
    
    if not moved and move_y ~= 0 then
        local not_colliding_with_wall = not Logic.isColliding(enemy.x, next_y)
        local not_occupied = not Logic.isTileOccupied(enemy.x, next_y, enemy)
        
        if not_colliding_with_wall and not_occupied then
            enemy.y = next_y
            moved = true
        end
    end

    return moved
end


function Logic.generateMap()
    for y = 1, Data.GAME_MAP_H_TILES do
        game_map[y] = {}
        for x = 1, Data.GAME_MAP_W_TILES do
            game_map[y][x] = Data.TILE_TYPES.GROUND
        end
    end
    
    local wall_chance = 0.15 
    
    for y = 2, Data.GAME_MAP_H_TILES - 1 do
        for x = 2, Data.GAME_MAP_W_TILES - 1 do
            if math.random() < wall_chance then
                game_map[y][x] = Data.TILE_TYPES.WALL
            end
        end
    end
    
    local start_x = player.x / Data.TILE_SIZE + 1
    local start_y = player.y / Data.TILE_SIZE + 1
    game_map[start_y][start_x] = Data.TILE_TYPES.GROUND
end

return Logic