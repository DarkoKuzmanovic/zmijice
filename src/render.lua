local render = {}

local menu = require("src/ui/menu")
local options = require("src/ui/options")
local gameOver = require("src/ui/gameOver")
local highscoresUI = require("src/ui/highscores")
local nameEntry = require("src/ui/nameEntry")

local gameOverFont = nil
local scoreFont = nil

function render.load()
    gameOverFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 16)

    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    gameOverFont:setFilter("nearest", "nearest")
    scoreFont:setFilter("nearest", "nearest")

    -- Load other UI modules
    menu.load()
    options.load()
    gameOver.load()
    highscoresUI.load()
    nameEntry.load()
end

function render.drawHighScores(game, settings, highscores)
    highscoresUI.draw(game, settings, highscores)
end

function render.drawGame(game, settings)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

    -- Draw snake
    for _, segment in ipairs(game.snake) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill',
            (segment.x - 1) * game.cell_size + 1,
            (segment.y - 1) * game.cell_size + 1,
            game.cell_size - 2,
            game.cell_size - 2,
            4, 4)  -- Added corner radius
    end

    -- Draw food using the appropriate image
    local foodX = (game.food.x - 1) * game.cell_size + 1
    local foodY = (game.food.y - 1) * game.cell_size + 1
    local blinkAlpha = 1
    if game.food and game.food.special then
        blinkAlpha = math.abs(math.sin(love.timer.getTime() * 10))
        love.graphics.setColor(1, 1, 1, blinkAlpha)
        love.graphics.draw(game.foodImages.special, foodX, foodY)
    else
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(game.foodImages.regular, foodX, foodY)
    end

    -- Draw the main border
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0,
        game.grid_size * game.cell_size,
        game.grid_size * game.cell_size)

    -- Reset canvas and apply shader
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.isCrtEnabled() then
        love.graphics.setShader(settings.getShader())
    end
    love.graphics.draw(canvas)
    if settings.isCrtEnabled() then
        love.graphics.setShader()
    end

    -- Display score with LCD style
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0.75, 0.85, 0.65)
    love.graphics.print("SCORE: " .. string.format("%04d", game.score), 10, 10)
end

function render.draw(game, settings, highscores)
    if game.state == "menu" then
        menu.draw(game, settings)
    elseif game.state == "options" then
        options.draw(game, settings)
    elseif game.state == "highscores" then
        render.drawHighScores(game, settings, highscores)
    elseif game.nameEntry.active then
        nameEntry.draw(game, settings)
    elseif game.over then
        gameOver.draw(game, settings, highscores)
    else
        render.drawGame(game, settings)
    end
end

return render