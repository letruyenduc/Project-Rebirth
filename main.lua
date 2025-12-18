_G.love = require("love")


local Data = require("game_data")   
local State = require("game_state") 
local Logic = require("game_logic") 
local Render = require("game_render") 



function love.load()
    love.mouse.setVisible(false)
    love.window.setTitle("Project : Rebirth")
    
    math.randomseed(os.time())
    
    Logic.generateMap()
    
    table.insert(State.ennemies, Logic.createEnemy(1, 1, "MonsterA")) 
    table.insert(State.ennemies, Logic.createEnemy(10, 1, "MonsterA"))
    table.insert(State.ennemies, Logic.createEnemy(5, 5, "MonsterB"))
end

function love.update(dt)

    State.damageTimer = math.max(0, State.damageTimer - dt)
    State.eManaTimer = math.max(0, State.eManaTimer - dt)

    Logic.regenMana(dt)
    Logic.checkAimDirection()
    Logic.checkQuit() 

    Logic.updateProjectiles(dt)
    Logic.updateEnemy(dt)
    Logic.playerMovement(dt)

    Logic.castSpell("e", 10, dt, "Fireball") 
    Logic.castSpell("a", 10, dt, "IceShard")
    
    Logic.checkActions(dt)
    for _, enemy in ipairs(State.ennemies) do
        if State.player.x == enemy.x and State.player.y == enemy.y then
            if State.damageTimer <= 0 then
                Logic.doDamage(enemy.damage) 
                State.damageTimer = Data.DAMAGE_DELAY 
            end
        end
    end
    if State.game.state.ended then
        Logic.updateDeathMenu(dt)
        return
    end
    Logic.checkDie() 
end


function love.draw()

    Render.drawBackground()
    Render.drawEntities()
    Render.drawAimIndicator()
    
    Render.drawUI()
    Render.drawGameFrame()
    Render.drawSidePanel()
    Render.drawFPS()


    Render.drawDeathMenu()
end