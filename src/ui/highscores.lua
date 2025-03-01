local highscoresUI = {}

local gameOverFont = nil

function highscoresUI.load()
    gameOverFont = love.graphics.newFont("assets/fonts/VGA New.ttf", 32)
    gameOverFont:setFilter("nearest", "nearest")
end

function highscoresUI.draw(game, settings, highscores)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green

    love.graphics.setFont(gameOverFont)
    love.graphics.setColor(0.2, 0.2, 0.2)
    local title = "HIGH SCORES"
    local titleWidth = gameOverFont:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - titleWidth) / 2, 50)

    local startY = 50 + gameOverFont:getHeight() + 20
    local spacing = 30
    local scores = highscores.getScores()

    for i = 1, 10 do
        local scoreText = string.format("%2d. %s %04d", i, scores[i].name, scores[i].score)
        local textWidth = gameOverFont:getWidth(scoreText)
        love.graphics.print(scoreText, (love.graphics.getWidth() - textWidth) / 2, startY + i * spacing)
    end

    -- Back button
    local backBtn = {
        x = (love.graphics.getWidth() - 140) / 2,
        y = startY + 11 * spacing,
        width = 140,
        height = 40
    }

    -- Helper function to check if mouse is over a button
    local function isMouseOver(btn)
        return game.mouseX >= btn.x and game.mouseX <= btn.x + btn.width and
               game.mouseY >= btn.y and game.mouseY <= btn.y + btn.height
    end

    -- Draw Back button with highlight
    if game.highscoresBackSelected or isMouseOver(backBtn) then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('line', backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
    end

    local backText = "BACK"
    local textWidth = gameOverFont:getWidth(backText)
    local textX = backBtn.x + (backBtn.width - textWidth) / 2
    local textY = backBtn.y + (backBtn.height - gameOverFont:getHeight()) / 2
    love.graphics.print(backText, textX, textY)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function highscoresUI.keypressed(game, key)
    if key == "escape" or key == "q" or key == "b" or key == "return" or key == "enter" or key == "space" then
        game.state = "menu"
        game.highscoresBackSelected = false -- Reset selection on exit
        if key == "escape" or key == "q" or key == "b" then
            if game.sounds and game.sounds.back then
                game.sounds.back:stop()
                game.sounds.back:play()
            end
        else
            if game.sounds and game.sounds.confirm then
                game.sounds.confirm:stop()
                game.sounds.confirm:play()
            end
        end
    end
end

function highscoresUI.mousepressed(game, x, y)
    local startY = 50 + gameOverFont:getHeight() + 20
    local spacing = 30
    local backBtn = {
        x = (love.graphics.getWidth() - 140) / 2,
        y = startY + 11 * spacing,
        width = 140,
        height = 40
    }

    if x >= backBtn.x and x <= backBtn.x + backBtn.width and
       y >= backBtn.y and y <= backBtn.y + backBtn.height then
        game.state = "menu"
        game.highscoresBackSelected = false -- Reset selection on exit
        if game.sounds and game.sounds.back then
            game.sounds.back:stop()
            game.sounds.back:play()
        end
    end
end

function highscoresUI.mousemoved(game, x, y)
    local startY = 50 + gameOverFont:getHeight() + 20
    local spacing = 30
    local backBtn = {
        x = (love.graphics.getWidth() - 140) / 2,
        y = startY + 11 * spacing,
        width = 140,
        height = 40
    }
    game.highscoresBackSelected = (x >= backBtn.x and x <= backBtn.x + backBtn.width and y >= backBtn.y and y <= backBtn.y + backBtn.height)
end

return highscoresUI