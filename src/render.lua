local render = {}

local menu = require("src/ui/menu")
local options = require("src/ui/options")
local gameOver = require("src/ui/gameOver")

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
end

function render.drawHighScores(game, settings, highscores)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

    -- Draw Title
    love.graphics.setFont(gameOverFont)
    local title = "HIGH SCORES"
    local titleWidth = gameOverFont:getWidth(title)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = 50
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(title, titleX, titleY)

    -- Draw scores
    love.graphics.setFont(scoreFont)
    local startY = titleY + gameOverFont:getHeight() + 20
    local spacing = 30

    for i, score in ipairs(highscores.getScores()) do
        local text = string.format("%2d. %s %5d", i, score.name, score.score)
        local textWidth = scoreFont:getWidth(text)
        local x = (love.graphics.getWidth() - textWidth) / 2
        love.graphics.print(text, x, startY + (i-1) * spacing)
    end

    -- Draw "Back" button with LCD style
    local backBtn = {
        x = (love.graphics.getWidth() - 140) / 2,
        y = startY + 11 * spacing,
        width = 140,
        height = 40
    }

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
    love.graphics.setColor(0.75, 0.85, 0.65)
    local backText = "BACK"
    local backTextX = backBtn.x + (backBtn.width - scoreFont:getWidth(backText)) / 2
    local backTextY = backBtn.y + (backBtn.height - scoreFont:getHeight()) / 2
    love.graphics.print(backText, backTextX, backTextY)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.isCrtEnabled() then
        love.graphics.setShader(settings.getShader())
    end
    love.graphics.draw(canvas)
    if settings.isCrtEnabled() then
        love.graphics.setShader()
    end
end

function render.drawNameEntry(game, settings)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

    -- Draw Title
    love.graphics.setFont(gameOverFont)
    local title = "NEW HIGH SCORE!"
    local titleWidth = gameOverFont:getWidth(title)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() / 3
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(title, titleX, titleY)

    -- Draw score
    love.graphics.setFont(scoreFont)
    local scoreText = string.format("SCORE: %04d", game.score)
    local scoreWidth = scoreFont:getWidth(scoreText)
    local scoreX = (love.graphics.getWidth() - scoreWidth) / 2
    love.graphics.print(scoreText, scoreX, titleY + gameOverFont:getHeight() + 20)

    -- Draw name entry boxes
    local nameY = titleY + gameOverFont:getHeight() + 60
    local boxWidth = 40
    local boxSpacing = 10
    local totalWidth = (boxWidth * 3) + (boxSpacing * 2)
    local startX = (love.graphics.getWidth() - totalWidth) / 2

    for i = 1, 3 do
        local boxX = startX + (i-1) * (boxWidth + boxSpacing)
        local char = game.nameEntry.name:sub(i,i)

        -- Draw box
        love.graphics.setColor(0.2, 0.2, 0.2)
        if i == game.nameEntry.position then
            love.graphics.rectangle('fill', boxX, nameY, boxWidth, boxWidth, 4, 4)
            love.graphics.setColor(0.75, 0.85, 0.65)
        else
            love.graphics.rectangle('line', boxX, nameY, boxWidth, boxWidth, 4, 4)
        end

        -- Draw character
        local charWidth = scoreFont:getWidth(char)
        local charX = boxX + (boxWidth - charWidth) / 2
        local charY = nameY + (boxWidth - scoreFont:getHeight()) / 2
        love.graphics.print(char, charX, charY)
    end

    -- Draw instructions
    love.graphics.setColor(0.2, 0.2, 0.2)
    local instrText = "UP/DOWN: CHANGE  LEFT/RIGHT: MOVE  ENTER: OK"
    local instrWidth = scoreFont:getWidth(instrText)
    local instrX = (love.graphics.getWidth() - instrWidth) / 2
    love.graphics.print(instrText, instrX, nameY + boxWidth + 30)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.isCrtEnabled() then
        love.graphics.setShader(settings.getShader())
    end
    love.graphics.draw(canvas)
    if settings.isCrtEnabled() then
        love.graphics.setShader()
    end
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
        render.drawNameEntry(game, settings)
    elseif game.over then
        gameOver.draw(game, settings, highscores)
    else
        render.drawGame(game, settings)
    end
end

return render