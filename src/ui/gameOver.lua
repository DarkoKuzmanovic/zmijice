local gameOver = {}

local gameOverFont = nil
local scoreFont = nil

function gameOver.load()
    gameOverFont = love.graphics.newFont("assets/fonts/VGA New.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/VGA New.ttf", 16)

    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    gameOverFont:setFilter("nearest", "nearest")
    scoreFont:setFilter("nearest", "nearest")
end

function gameOver.draw(game, settings, highscores)
    -- Play death sound only when transitioning to game over screen
    if not game.deathSoundPlayed then
        game.sounds.die:play()
        game.deathSoundPlayed = true
    end

    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

    -- Draw "GAME OVER" text
    love.graphics.setFont(gameOverFont)
    local gameOverMsg = "GAME OVER"
    local gameOverWidth = gameOverFont:getWidth(gameOverMsg)
    local x = (love.graphics.getWidth() - gameOverWidth) / 2
    local y = love.graphics.getHeight() / 3
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(gameOverMsg, x, y)

    -- Draw final score
    love.graphics.setFont(scoreFont)
    local scoreMsg = string.format("FINAL SCORE: %04d", game.score)
    local scoreWidth = scoreFont:getWidth(scoreMsg)
    local scoreX = (love.graphics.getWidth() - scoreWidth) / 2
    local scoreY = y + gameOverFont:getHeight() + 20
    love.graphics.print(scoreMsg, scoreX, scoreY)

    -- Draw buttons
    local btnY = scoreY + scoreFont:getHeight() + 40
    local btnWidth = 140
    local btnHeight = 40
    local btnSpacing = 20

    local newGameBtn = {x = (love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2, y = btnY, width = btnWidth, height = btnHeight}
    local exitBtn = {x = newGameBtn.x + btnWidth + btnSpacing, y = btnY, width = btnWidth, height = btnHeight}

    -- Helper function to check if mouse is over a button
    local function isMouseOver(btn)
        return game.mouseX >= btn.x and game.mouseX <= btn.x + btn.width and
               game.mouseY >= btn.y and game.mouseY <= btn.y + btn.height
    end

    local buttons = {
        {btn = newGameBtn, text = "NEW GAME", selected = game.menuSelection == 1},
        {btn = exitBtn, text = "EXIT", selected = game.menuSelection == 2}
    }

    for _, button in ipairs(buttons) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        if button.selected or isMouseOver(button.btn) then
            love.graphics.rectangle('fill', button.btn.x, button.btn.y, button.btn.width, button.btn.height, 4, 4)
            love.graphics.setColor(0.75, 0.85, 0.65)
        else
            love.graphics.rectangle('line', button.btn.x, button.btn.y, button.btn.width, button.btn.height, 4, 4)
            love.graphics.setColor(0.2, 0.2, 0.2)
        end

        local textWidth = scoreFont:getWidth(button.text)
        local textX = button.btn.x + (button.btn.width - textWidth) / 2
        local textY = button.btn.y + (button.btn.height - scoreFont:getHeight()) / 2
        love.graphics.print(button.text, textX, textY)
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function gameOver.mousepressed(game, highscores, x, y, button)
    if button == 1 and not game.nameEntry.active then
        local btnY = (love.graphics.getHeight() / 3) + gameOverFont:getHeight() + scoreFont:getHeight() + 60
        local btnWidth = 140
        local btnHeight = 40
        local btnSpacing = 20

        local newGameBtn = {x = (love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2, y = btnY, width = btnWidth, height = btnHeight}
        local exitBtn = {x = newGameBtn.x + btnWidth + btnSpacing, y = btnY, width = btnWidth, height = btnHeight}

        if x >= newGameBtn.x and x <= newGameBtn.x + newGameBtn.width and
           y >= newGameBtn.y and y <= newGameBtn.y + newGameBtn.height then
            if highscores.isHighScore(game.score) then
                -- Initialize name entry
                game.nameEntry.active = true
                game.nameEntry.name = "AAA"
                game.nameEntry.position = 1
            else
                game.reset()
            end
        elseif x >= exitBtn.x and x <= exitBtn.x + exitBtn.width and
               y >= exitBtn.y and y <= exitBtn.y + exitBtn.height then
            love.event.quit()
        end
    end
end

function gameOver.keypressed(game, highscores, key)
    if key == "up" or key == "w" or key == "left" or key == "a" then
        game.menuSelection = game.menuSelection - 1
        if game.menuSelection < 1 then game.menuSelection = 2 end
    elseif key == "down" or key == "s" or key == "right" or key == "d" then
        game.menuSelection = game.menuSelection + 1
        if game.menuSelection > 2 then game.menuSelection = 1 end
    elseif key == "return" or key == "enter" then
        if highscores.isHighScore(game.score) then
            game.nameEntry.active = true
            game.nameEntry.name = "AAA"
            game.nameEntry.position = 1
        else
            if game.menuSelection == 1 then
                game.reset()
            elseif game.menuSelection == 2 then
                love.event.quit()
            end
        end
    elseif key == "escape" or key == "q" then
        love.event.quit()
    end
end

return gameOver