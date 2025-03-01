local game = require("src/game")
local settings = require("src/settings")
local highscores = require("src/highscores")
local input = require("src/input")
local render = require("src/render")

function love.load()
    -- Initialize high scores
    highscores.load()

    -- Initialize shader and canvas
    settings.initializeShader()

    -- Load game assets
    game.loadAssets()

    -- Load rendering assets
    render.load()

    -- Load input assets
    input.load()
end

function love.update(dt)
    game.update(dt)
end

function love.draw()
    render.draw(game, settings, highscores)
end

function love.keypressed(key)
    input.keypressed(game, settings, highscores, key)
end

function love.mousepressed(x, y, button)
    input.mousepressed(game, settings, highscores, x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    input.mousemoved(game, settings, x, y, dx, dy)
end

function love.wheelmoved(x, y)
    input.wheelmoved(game, settings, highscores, x, y)
end

function love.quit()
    settings.save()
    highscores.save()
end