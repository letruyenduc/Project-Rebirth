function love.conf(t)
    t.window.title = "Projet jeu"
    t.identity = "data/saves"
    t.version = "1.0.0"
    t.console = true
    t.window.height = 1080
    t.window.width = 1920
    t.window.fullscreen = false
    t.modules.Joystick = false
    t.window.resizeable = false
end