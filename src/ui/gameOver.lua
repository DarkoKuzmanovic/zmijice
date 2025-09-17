local gameOver = {}

local common = require("src/ui/common")
local fonts = nil
local buttons = {}
local stateManager = common.StateManager:new()

function gameOver.load()
    fonts = common.loadFonts()
end

-- Initialize buttons
local function initButtons()
    local y = love.graphics.getHeight() / 3
    local scoreY = y + fonts.title:getHeight() + 20
    local btnY = scoreY + fonts.button:getHeight() + 40
    local btnWidth = 140
    local btnHeight = 40
    local btnSpacing = 20

    buttons = {
        common.Button:new((love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2, btnY, btnWidth, btnHeight, "NEW GAME"),
        common.Button:new(((love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2) + btnWidth + btnSpacing, btnY, btnWidth, btnHeight, "EXIT")
    }
end

function gameOver.draw(game, settings, highscores)
    -- Play death sound only when transitioning to game over screen
    if not game.deathSoundPlayed then
        game.sounds.die:play()
        game.deathSoundPlayed = true
    end

    local canvas = common.setupCanvas(settings)

    -- Draw "GAME OVER" text
    love.graphics.setFont(fonts.title)
    local gameOverMsg = "GAME OVER"
    local gameOverWidth = fonts.title:getWidth(gameOverMsg)
    local x = (love.graphics.getWidth() - gameOverWidth) / 2
    local y = love.graphics.getHeight() / 3
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(gameOverMsg, x, y)

    -- Draw final score
    love.graphics.setFont(fonts.button)
    local scoreMsg = string.format("FINAL SCORE: %04d", game.score)
    local scoreWidth = fonts.button:getWidth(scoreMsg)
    local scoreX = (love.graphics.getWidth() - scoreWidth) / 2
    local scoreY = y + fonts.title:getHeight() + 20
    love.graphics.print(scoreMsg, scoreX, scoreY)

    -- Initialize buttons if not already done
    if #buttons == 0 then
        initButtons()
    end

    -- Draw buttons
    for i, button in ipairs(buttons) do
        button:draw(fonts, i == stateManager:getSelection(), button:isMouseOver(game.mouseX, game.mouseY))
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function gameOver.mousepressed(game, highscores, x, y, button)
    if button == 1 then
        -- Initialize buttons if not already done
        if #buttons == 0 then
            initButtons()
        end

        for i, btn in ipairs(buttons) do
            if btn:isMouseOver(x, y) then
                stateManager:setSelection(i)
                if i == 1 then
                    if highscores.isHighScore(game.score) then
                        -- Initialize name entry
                        game.nameEntry.active = true
                        game.nameEntry.name = "AAA"
                        game.nameEntry.position = 1
                        if game.sounds and game.sounds.confirm then
                            game.sounds.confirm:stop()
                            game.sounds.confirm:play()
                        end
                    else
                        game.reset()
                        if game.sounds and game.sounds.confirm then
                            game.sounds.confirm:stop()
                            game.sounds.confirm:play()
                        end
                    end
                elseif i == 2 then
                    love.event.quit()
                end
                break
            end
        end
    end
end

function gameOver.keypressed(game, highscores, key)
    if key == "up" or key == "w" or key == "left" or key == "a" then
        stateManager:moveUp(#buttons)
        if game.sounds and game.sounds.select then
            game.sounds.select:stop()
            game.sounds.select:play()
        end
    elseif key == "down" or key == "s" or key == "right" or key == "d" then
        stateManager:moveDown(#buttons)
        if game.sounds and game.sounds.select then
            game.sounds.select:stop()
            game.sounds.select:play()
        end
    elseif key == "return" or key == "enter" or key == "space" then
        local selection = stateManager:getSelection()
        if selection == 1 then
            if highscores.isHighScore(game.score) then
                -- Initialize name entry
                game.nameEntry.active = true
                game.nameEntry.name = "AAA"
                game.nameEntry.position = 1
                if game.sounds and game.sounds.confirm then
                    game.sounds.confirm:stop()
                    game.sounds.confirm:play()
                end
            else
                game.reset()
                if game.sounds and game.sounds.confirm then
                    game.sounds.confirm:stop()
                    game.sounds.confirm:play()
                end
            end
        elseif selection == 2 then
            love.event.quit()
        end
    elseif key == "escape" or key == "q" then
        if game.sounds and game.sounds.back then
            game.sounds.back:stop()
            game.sounds.back:play()
        end
        game.state = "menu"
    end
end

return gameOver