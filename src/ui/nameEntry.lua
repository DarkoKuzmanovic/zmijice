local nameEntry = {}
local highscores = require("src/highscores")

local gameOverFont = nil
local scoreFont = nil

function nameEntry.load()
    gameOverFont = love.graphics.newFont("assets/fonts/VGA New.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/VGA New.ttf", 16)
    gameOverFont:setFilter("nearest", "nearest")
    scoreFont:setFilter("nearest", "nearest")
end

function nameEntry.draw(game, settings)
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

    -- Draw OK button
    local okBtn = {
        x = (love.graphics.getWidth() - 140) / 2,
        y = nameY + boxWidth + 60,
        width = 140,
        height = 40
    }

    -- Helper function to check if mouse is over a button
    local function isMouseOver(btn)
        return game.mouseX >= btn.x and game.mouseX <= btn.x + btn.width and
               game.mouseY >= btn.y and game.mouseY <= btn.y + btn.height
    end

    -- Draw OK button with highlight
    if game.nameEntryOkSelected or isMouseOver(okBtn) then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', okBtn.x, okBtn.y, okBtn.width, okBtn.height, 4, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("line", okBtn.x, okBtn.y, okBtn.width, okBtn.height, 4, 4)
    end

    love.graphics.setColor(0.2, 0.2, 0.2)
    local okText = "OK"
    local okTextX = okBtn.x + (okBtn.width - scoreFont:getWidth(okText)) / 2
    local okTextY = okBtn.y + (okBtn.height - scoreFont:getHeight()) / 2
    love.graphics.print(okText, okTextX, okTextY)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function nameEntry.keypressed(game, key)
    if key == "left" or key == "a" then
        game.nameEntry.position = game.nameEntry.position - 1
        if game.nameEntry.position < 1 then game.nameEntry.position = 3 end
        if game.sounds and game.sounds.select then
            game.sounds.select:stop()
            game.sounds.select:play()
        end
    elseif key == "right" or key == "d" then
        game.nameEntry.position = game.nameEntry.position + 1
        if game.nameEntry.position > 3 then game.nameEntry.position = 1 end
        if game.sounds and game.sounds.select then
            game.sounds.select:stop()
            game.sounds.select:play()
        end
    elseif key == "up" or key == "w" then
        local char = string.byte(game.nameEntry.name:sub(game.nameEntry.position, game.nameEntry.position))
        char = char - 1
        if char < string.byte('A') then char = string.byte('Z') end
        game.nameEntry.name = game.nameEntry.name:sub(1, game.nameEntry.position - 1) ..
                               string.char(char) ..
                               game.nameEntry.name:sub(game.nameEntry.position + 1)
        if game.sounds and game.sounds.select then
            game.sounds.select:stop()
            game.sounds.select:play()
        end
    elseif key == "down" or key == "s" then
        local char = string.byte(game.nameEntry.name:sub(game.nameEntry.position, game.nameEntry.position))
        char = char + 1
        if char > string.byte('Z') then char = string.byte('A') end
        game.nameEntry.name = game.nameEntry.name:sub(1, game.nameEntry.position - 1) ..
                               string.char(char) ..
                               game.nameEntry.name:sub(game.nameEntry.position + 1)
        if game.sounds and game.sounds.select then
            game.sounds.select:stop()
            game.sounds.select:play()
        end
    elseif key == "return" or key == "enter" or key == "space" then
        -- Submit the name
        highscores.add(game.nameEntry.name, game.score)
        game.nameEntry.active = false
        game.state = "menu"  -- Go back to the menu
        if game.sounds and game.sounds.confirm then
            game.sounds.confirm:stop()
            game.sounds.confirm:play()
        end
    end
end

function nameEntry.mousepressed(game, x, y)
    -- Handle mouse input for name entry screen
    local nameY = (love.graphics.getHeight() / 3) + gameOverFont:getHeight() + 60
    local boxWidth = 40
    local boxSpacing = 10
    local totalWidth = (boxWidth * 3) + (boxSpacing * 2)
    local startX = (love.graphics.getWidth() - totalWidth) / 2

    -- Check if clicked on any of the character boxes
    for i = 1, 3 do
        local boxX = startX + (i-1) * (boxWidth + boxSpacing)
        if x >= boxX and x <= boxX + boxWidth and
           y >= nameY and y <= nameY + boxWidth then
            -- Select this position
            game.nameEntry.position = i
            if game.sounds and game.sounds.select then
                game.sounds.select:stop()
                game.sounds.select:play()
            end
            return
        end
    end

    -- Check if clicked on OK button
    local okBtnX = (love.graphics.getWidth() - 140) / 2
    local okBtnY = nameY + boxWidth + 60
    local okBtnWidth = 140
    local okBtnHeight = 40

    if x >= okBtnX and x <= okBtnX + okBtnWidth and
       y >= okBtnY and y <= okBtnY + okBtnHeight then
        -- Submit the name
        highscores.add(game.nameEntry.name, game.score)
        game.nameEntry.active = false
        game.state = "menu"
        if game.sounds and game.sounds.confirm then
            game.sounds.confirm:stop()
            game.sounds.confirm:play()
        end
    end
end

function nameEntry.mousemoved(game, x, y)
    local nameY = (love.graphics.getHeight() / 3) + gameOverFont:getHeight() + 60
    local boxWidth = 40
    local boxSpacing = 10
    local totalWidth = (boxWidth * 3) + (boxSpacing * 2)
    local startX = (love.graphics.getWidth() - totalWidth) / 2

    --Check OK button
    local okBtnX = (love.graphics.getWidth() - 140) / 2
    local okBtnY = nameY + boxWidth + 60
    local okBtnWidth = 140
    local okBtnHeight = 40

    game.nameEntryOkSelected = (x >= okBtnX and x <= okBtnX + okBtnWidth and y >= okBtnY and y <= okBtnY + okBtnHeight)

    for i = 1, 3 do
        local boxX = startX + (i-1) * (boxWidth + boxSpacing)
        if x >= boxX and x <= boxX + boxWidth and
           y >= nameY and y <= nameY + boxWidth then
            game.nameEntry.position = i
            break
        end
    end
end

return nameEntry