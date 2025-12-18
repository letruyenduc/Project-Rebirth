
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
    
    for i = #State.ennemies, 1, -1 do
        local enemy = State.ennemies[i]
        if enemy.hp <= 0 then
            table.remove(State.ennemies, i)
        end
    end

    if #State.ennemies == 0 then
        Logic.nextLevel()
        
        return
    end

    if State.enemyMoveTimer <= 0 then
        for _, enemy in ipairs(State.ennemies) do
            Logic.moveEnemyPathfinding(enemy, State.player)
        end
        State.enemyMoveTimer = Data.ENEMY_MOVE_DELAY
    end
end

function Logic.moveEnemyPathfinding(enemy, player)
    local targetNode, cameFrom = Logic.findPath(enemy.x, enemy.y, player.x, player.y)
    
    if targetNode and cameFrom then
        local path = {}
        local curr = targetNode
        local enemyNode = {
            x = math.floor(enemy.x / Data.TILE_SIZE) + 1,
            y = math.floor(enemy.y / Data.TILE_SIZE) + 1
        }
        
        while curr and not (curr.x == enemyNode.x and curr.y == enemyNode.y) do
            table.insert(path, curr)
            curr = cameFrom[curr.y .. "_" .. curr.x]
        end
        
        local nextStep = path[#path]
        if nextStep then
            local nextX = (nextStep.x - 1) * Data.TILE_SIZE
            local nextY = (nextStep.y - 1) * Data.TILE_SIZE
            
            if not Logic.isTileOccupied(nextX, nextY, enemy) then
                enemy.x = nextX
                enemy.y = nextY
                return true
            end
        end
    end
    return false
end

function Logic.generateMap()
    local presetIndex = math.random(1, #Data.MAP_PRESETS)
    local selectedPreset = Data.MAP_PRESETS[presetIndex]
    
    local walkableTiles = {}

    for y = 1, Data.GAME_MAP_H_TILES do
        State.game_map[y] = {}
        local line = selectedPreset[y]
        
        for x = 1, Data.GAME_MAP_W_TILES do
            local char = line:sub(x, x)
            
            if char == "W" then
                State.game_map[y][x] = Data.TILE_TYPES.WALL
            else
                State.game_map[y][x] = Data.TILE_TYPES.GROUND
                table.insert(walkableTiles, {x = x, y = y})
            end
        end
    end

    if #walkableTiles > 0 then
        local randomIndex = math.random(1, #walkableTiles)
        local spawnTile = walkableTiles[randomIndex]
        
        State.player.x = (spawnTile.x - 1) * Data.TILE_SIZE
        State.player.y = (spawnTile.y - 1) * Data.TILE_SIZE
    end
end

function Logic.regenMana(dt)
    local mp = State.mp
    local max_mp = Data.MAX_MP_QUANTITY
    local regen_amount = Data.MANA_REGEN_RATE * dt

    mp.quantity = mp.quantity + regen_amount

    if mp.quantity > max_mp then
        mp.quantity = max_mp
    end
end
function Logic.closeAttack()
    local player = State.player
    local target_x = player.x
    local target_y = player.y

    if player.aimDirection == "UP" then
        target_y = player.y - Data.TILE_SIZE
    elseif player.aimDirection == "DOWN" then
        target_y = player.y + Data.TILE_SIZE
    elseif player.aimDirection == "LEFT" then
        target_x = player.x - Data.TILE_SIZE
    elseif player.aimDirection == "RIGHT" then
        target_x = player.x + Data.TILE_SIZE
    end
    for i = #State.ennemies, 1, -1 do
        local enemy = State.ennemies[i]
        
        if enemy.x == target_x and enemy.y == target_y then
            enemy.hp = enemy.hp - Data.MELEE_DAMAGE
            return true
        end
    end
    
    return false
end
function Logic.checkActions(dt)
    State.meleeTimer = (State.meleeTimer or 0) - dt

    if love.keyboard.isDown("space") and State.meleeTimer <= 0 then
        local hit = Logic.closeAttack()
        State.meleeTimer = Data.MELEE_DELAY
    end
end
function Logic.findPath(startX, startY, targetX, targetY)
    local startNode = {
        x = math.floor(startX / Data.TILE_SIZE) + 1,
        y = math.floor(startY / Data.TILE_SIZE) + 1
    }
    local targetNode = {
        x = math.floor(targetX / Data.TILE_SIZE) + 1,
        y = math.floor(targetY / Data.TILE_SIZE) + 1
    }

    local openList = {startNode}
    local closedList = {}
    local cameFrom = {}
    local gScore = {}
    
    gScore[startNode.y] = {}
    gScore[startNode.y][startNode.x] = 0

    while #openList > 0 do
        local current = openList[1]
        table.remove(openList, 1)

        if current.x == targetNode.x and current.y == targetNode.y then
            return current, cameFrom
        end

        if not closedList[current.y] then closedList[current.y] = {} end
        closedList[current.y][current.x] = true

        local neighbors = {
            {x = current.x + 1, y = current.y}, {x = current.x - 1, y = current.y},
            {x = current.x, y = current.y + 1}, {x = current.x, y = current.y - 1}
        }

        for _, neighbor in ipairs(neighbors) do
            if neighbor.x > 0 and neighbor.x <= Data.GAME_MAP_W_TILES and 
               neighbor.y > 0 and neighbor.y <= Data.GAME_MAP_H_TILES and
               State.game_map[neighbor.y][neighbor.x] ~= Data.TILE_TYPES.WALL and
               not (closedList[neighbor.y] and closedList[neighbor.y][neighbor.x]) then
                
                local tentative_gScore = gScore[current.y][current.x] + 1
                if not gScore[neighbor.y] then gScore[neighbor.y] = {} end
                
                if not gScore[neighbor.y][neighbor.x] or tentative_gScore < gScore[neighbor.y][neighbor.x] then
                    cameFrom[neighbor.y .. "_" .. neighbor.x] = current
                    gScore[neighbor.y][neighbor.x] = tentative_gScore
                    table.insert(openList, neighbor)
                end
            end
        end
    end
    return nil, nil
end
function Logic.moveEnemyRandomly(enemy)
    local dirs = {{x=1,y=0},{x=-1,y=0},{x=0,y=1},{x=0,y=-1}}
    for i = #dirs, 2, -1 do
        local j = math.random(i)
        dirs[i], dirs[j] = dirs[j], dirs[i]
    end

    for _, d in ipairs(dirs) do
        local nx = enemy.x + d.x * Data.TILE_SIZE
        local ny = enemy.y + d.y * Data.TILE_SIZE
        if not Logic.isColliding(nx, ny) and not Logic.isTileOccupied(nx, ny, enemy) then
            enemy.x, enemy.y = nx, ny
            return true
        end
    end
    return false
end
function Logic.nextLevel()
    for i = #State.projectiles, 1, -1 do table.remove(State.projectiles, i) end
    for i = #State.ennemies, 1, -1 do table.remove(State.ennemies, i) end
    
    Logic.generateMap()
    
    local nbEnemies = math.random(3, 6)
    local walkableTiles = {}
    for y = 1, Data.GAME_MAP_H_TILES do
        for x = 1, Data.GAME_MAP_W_TILES do
            if State.game_map[y][x] == Data.TILE_TYPES.GROUND then
                local tx = (x-1) * Data.TILE_SIZE
                local ty = (y-1) * Data.TILE_SIZE
                if tx ~= State.player.x or ty ~= State.player.y then
                    table.insert(walkableTiles, {x=x, y=y})
                end
            end
        end
    end

    for i = 1, nbEnemies do
        if #walkableTiles > 0 then
            local spot = table.remove(walkableTiles, math.random(#walkableTiles))
            local e = Logic.createEnemy(spot.x - 1, spot.y - 1, "MonsterA")
            table.insert(State.ennemies, e)
        end
    end
    State.level = State.level + 1
end
function Logic.updateDeathMenu(dt)
    -- On ne gère le menu que si le jeu est fini
    if not State.game.state.ended then return end

    -- Navigation avec les flèches (utilisation de love.keypressed est préférable, 
    -- mais voici une version adaptée à votre structure actuelle avec timers)
    State.menuTimer = (State.menuTimer or 0) - dt
    
    if State.menuTimer <= 0 then
        if love.keyboard.isDown("up") then
            State.menu.selected = State.menu.selected - 1
            if State.menu.selected < 1 then State.menu.selected = #State.menu.options end
            State.menuTimer = 0.2 -- Délai pour éviter un défilement trop rapide
        elseif love.keyboard.isDown("down") then
            State.menu.selected = State.menu.selected + 1
            if State.menu.selected > #State.menu.options then State.menu.selected = 1 end
            State.menuTimer = 0.2
        end
    end

    -- Validation avec Entrée
    if love.keyboard.isDown("return") then
        local choice = State.menu.options[State.menu.selected]
        if choice == "RECOMMENCER" then
            Logic.restartGame()
        elseif choice == "QUITTER" then
            love.event.quit()
        end
    end
end

function Logic.restartGame()
    State.hp.quantity = Data.MAX_HP_QUANTITY or 100
    State.mp.quantity = Data.MAX_MP_QUANTITY
    State.game.state.ended = false
    
    State.ennemies = {}
    State.projectiles = {}
    Logic.generateMap()
    Logic.nextLevel()
end
return Logic