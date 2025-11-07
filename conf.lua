function love.conf(t)
    t.window.title = "Projet jeu"
    t.identity = "data/saves"
    t.version = "11.5"
    t.console = true
    t.window.height = 840
    t.window.width = 1344 
    t.modules.Joystick = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.vsync = 1
end