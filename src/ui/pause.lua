local pause = {}

local titleFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 48)
local buttonFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 24)

local function drawButton(text, y, selected)
    local screenWidth = love.graphics.getWidth()
    local buttonWidth = 200
    local buttonHeight = 40
    local x = (screenWidth - buttonWidth) / 2

    -- Draw button background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y - buttonHeight/2, buttonWidth, buttonHeight)

    -- Draw button border
    if selected then
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
    end
    love.graphics.rectangle("line", x, y - buttonHeight/2, buttonWidth, buttonHeight)

    -- Draw button text
    love.graphics.setFont(buttonFont)
    local textWidth = buttonFont:getWidth(text)
    local textX = (screenWidth - textWidth) / 2
    love.graphics.print(text, textX, y - buttonFont:getHeight()/2)
end

function pause.draw(game)
    -- Draw semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(titleFont)
    local titleText = "PAUSED"
    local titleWidth = titleFont:getWidth(titleText)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    love.graphics.print(titleText, (screenWidth - titleWidth) / 2, screenHeight / 4)

    -- Draw buttons
    local centerY = screenHeight / 2
    local spacing = 20

    drawButton("RESUME", centerY, game.pauseSelection == 1)
    drawButton("OPTIONS", centerY + spacing + 40, game.pauseSelection == 2)
    drawButton("QUIT", centerY + spacing*2 + 80, game.pauseSelection == 3)

    -- Draw mouse cursor
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", game.mouseX, game.mouseY, 3)
end

function pause.mousepressed(game, x, y, button)
    if button == 1 then
        local btnWidth = 140
        local btnHeight = 40
        local btnSpacing = 20
        local titleY = love.graphics.getHeight() / 3
        local startY = titleY + love.graphics.newFont("assets/fonts/VGA New.ttf", 32):getHeight() + 40

        for i = 1, 3 do
            local btnY = startY + (i-1) * (btnHeight + btnSpacing)
            local btnX = (love.graphics.getWidth() - btnWidth) / 2
            local area = {x = btnX, y = btnY, width = btnWidth, height = btnHeight}

            if x >= area.x and x <= area.x + area.width and
               y >= area.y and y <= area.y + area.height then
                if i == 1 then  -- Resume
                    game.paused = false
                elseif i == 2 then  -- Options
                    game.previousState = game.state
                    game.state = "options"
                elseif i == 3 then  -- Quit
                    game.state = "menu"
                    game.paused = false
                end
                return
            end
        end
    end
end

function pause.keypressed(game, key)
    if key == "escape" or key == "p" then
        game.paused = false
        return
    end

    if key == "up" or key == "w" then
        game.pauseSelection = game.pauseSelection - 1
        if game.pauseSelection < 1 then game.pauseSelection = 3 end
    elseif key == "down" or key == "s" then
        game.pauseSelection = game.pauseSelection + 1
        if game.pauseSelection > 3 then game.pauseSelection = 1 end
    elseif key == "return" or key == "enter" or key == "space" then
        if game.pauseSelection == 1 then  -- Resume
            game.paused = false
        elseif game.pauseSelection == 2 then  -- Options
            game.previousState = game.state
            game.state = "options"
        elseif game.pauseSelection == 3 then  -- Quit
            game.state = "menu"
            game.paused = false
        end
    end
end

return pause