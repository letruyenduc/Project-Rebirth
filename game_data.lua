local Data = {}

Data.TILE_SIZE = 64
Data.GAME_MAP_W_TILES = 15
Data.GAME_MAP_H_TILES = 10

Data.TILE_TYPES = {
    GROUND = 0,
    WALL = 1,
    SPAWN = 2,
}

Data.MOVE_DELAY = 0.1
Data.MANA_DELAY = 0.5
Data.DAMAGE_DELAY = 0.5
Data.ENEMY_MOVE_DELAY = 0.2
Data.E_MANA_COOLDOWN = 1.0

Data.SPELL_DEFINITIONS = {
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
        color = {0.2, 0.8, 1.0},
        size_multiplier = 0.3,
    },
}

Data.ENNEMIES_DEFINITIONS = {
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

return Data