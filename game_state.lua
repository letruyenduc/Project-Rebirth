local Data = require("game_data")

local State = {}

State.game = {
    difficulty = 1,
    state = { menu = true, paused = false, running = false, ended = false }
}

State.player = {
    x = 0, y = 0, w = Data.TILE_SIZE, h = Data.TILE_SIZE,
    aimDirection = "RIGHT"
}
State.hp = { quantity = Data.TILE_SIZE * 4 }
State.mp = { quantity = Data.TILE_SIZE * 4 }
State.ennemies = {}
State.projectiles = {}

State.damageTimer = 0
State.moveTimer = 0
State.enemyMoveTimer = 0
State.eManaTimer = 0

State.game_map = {}

return State