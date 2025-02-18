local game = require("src/game")
local settings = require("src/settings")
local highscores = require("src/highscores")
local input = require("src/input")
local render = require("src/render")
local pause = require("src/ui/pause")

function love.load()
    -- Set window properties
    love.window.setMode(800, 600)
    love.window.setTitle("Snake Game")
    love.mouse.setVisible(false)

    -- Initialize high scores
    highscores.load()

    -- Initialize shader and canvas
    settings.initializeShader()

    -- Load game assets (includes sounds and images)
    game.loadAssets()

    -- Load rendering assets
    render.load()

    -- Initialize game state
    game.reset()
end

function love.update(dt)
    game.update(dt)
end

function love.draw()
    if game.state == "menu" then
        render.draw(game, settings, highscores)
    elseif game.state == "running" then
        -- Draw the game scene
        render.drawGame(game, settings)
        -- If paused, overlay the pause menu
        if game.paused then
            pause.draw(game)
        end
    elseif game.state == "options" then
        render.draw(game, settings, highscores)
    elseif game.state == "highscores" then
        render.draw(game, settings, highscores)
    elseif game.over then
        render.draw(game, settings, highscores)
    elseif game.nameEntry.active then
        render.draw(game, settings, highscores)
    else
        render.draw(game, settings, highscores)
    end
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

function love.quit()
    settings.save()
    highscores.save()
end