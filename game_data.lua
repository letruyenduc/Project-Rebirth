local Data = {}

Data.TILE_SIZE = 64
Data.GAME_MAP_W_TILES = 15
Data.GAME_MAP_H_TILES = 10

Data.TILE_TYPES = {
    GROUND = 0,
    WALL = 1,
    SPAWN = 2,
}
Data.MANA_REGEN_RATE = 10
Data.MAX_MP_QUANTITY = Data.TILE_SIZE * 4

Data.MOVE_DELAY = 0.1

Data.MANA_DELAY = 0.5
Data.DAMAGE_DELAY = 0.5
Data.ENEMY_MOVE_DELAY = 0.2
Data.E_MANA_COOLDOWN = 1.0
Data.MELEE_DAMAGE = 20
Data.MELEE_DELAY = 0.3

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
Data.MAP_PRESETS = {
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W..WW.....WW..W",
        "W..WW.....WW..W",
        "W......W......W",
        "W......W......W",
        "W..WW.....WW..W",
        "W..WW.....WW..W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W.W.W.W.W.W.W.W",
        "W.............W",
        "W.W.W.W.W.W.W.W",
        "W.............W",
        "W.W.W.W.W.W.W.W",
        "W.............W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W..WWWW.WWWW..W",
        "W.............W",
        "W....W...W....W",
        "W....W...W....W",
        "W.............W",
        "W..WWWW.WWWW..W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W.............W",
        "W....WWWWW....W",
        "W....W...W....W",
        "W....W...W....W",
        "W....WWWWW....W",
        "W.............W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W..W..W..W..W.W",
        "W.............W",
        "W..W..W..W..W.W",
        "W.............W",
        "W..W..W..W..W.W",
        "W.............W",
        "W..W..W..W..W.W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W.............W",
        "W..WWW...WWW..W",
        "W..WWW...WWW..W",
        "W.............W",
        "W..WWW...WWW..W",
        "W..WWW...WWW..W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W.W.........W.W",
        "W.W....W....W.W",
        "W.WWWWWWWWWWW.W",
        "W.W....W....W.W",
        "W.W.........W.W",
        "W.W.........W.W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    },
    {
        "WWWWWWWWWWWWWWW",
        "W.............W",
        "W......W......W",
        "W......W......W",
        "W...WWWWWWW...W",
        "W......W......W",
        "W......W......W",
        "W......W......W",
        "W.............W",
        "WWWWWWWWWWWWWWW",
    }
}
return Data