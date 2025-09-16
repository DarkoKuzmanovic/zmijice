local pause = {}

local titleFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
local buttonFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 16)

local function drawButton(text, btn, selected)
    love.graphics.setColor(0.2, 0.2, 0.2)
    if selected then
        love.graphics.rectangle('fill', btn.x, btn.y, btn.width, btn.height, 4, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.rectangle('line', btn.x, btn.y, btn.width, btn.height, 4, 4)
        love.graphics.setColor(0.2, 0.2, 0.2)
    end

    love.graphics.setFont(buttonFont)
    local textWidth = buttonFont:getWidth(text)
    local textX = btn.x + (btn.width - textWidth) / 2
    local textY = btn.y + (btn.height - buttonFont:getHeight()) / 2
    love.graphics.print(text, textX, textY)
end

function pause.draw(game)
    -- Draw 50% overlay
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setFont(titleFont)
    local titleText = "PAUSED"
    local titleWidth = titleFont:getWidth(titleText)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() / 4
    love.graphics.print(titleText, titleX, titleY)

    -- Draw buttons
    local centerX = love.graphics.getWidth() / 2
    local btnY = titleY + titleFont:getHeight() + 40
    local btnSpacing = 50
    local btnWidth = 140
    local btnHeight = 40
    local resumeBtn = {x = centerX - btnWidth/2, y = btnY, width = btnWidth, height = btnHeight}
    local optionsBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
    local quitBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}

    drawButton("RESUME", resumeBtn, game.pauseSelection == 1)
    drawButton("OPTIONS", optionsBtn, game.pauseSelection == 2)
    drawButton("QUIT", quitBtn, game.pauseSelection == 3)
end

function pause.mousepressed(game, x, y, button)
    if button == 1 then
        local titleY = love.graphics.getHeight() / 4
        local btnY = titleY + 32 + 40
        local btnSpacing = 50
        local btnWidth = 140
        local btnHeight = 40

        local resumeBtn = {x = (love.graphics.getWidth() - btnWidth)/2, y = btnY, width = btnWidth, height = btnHeight}
        local optionsBtn = {x = (love.graphics.getWidth() - btnWidth)/2, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
        local quitBtn = {x = (love.graphics.getWidth() - btnWidth)/2, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}

        if x >= resumeBtn.x and x <= resumeBtn.x + resumeBtn.width and
           y >= resumeBtn.y and y <= resumeBtn.y + resumeBtn.height then
            game.paused = false
        elseif x >= optionsBtn.x and x <= optionsBtn.x + optionsBtn.width and
               y >= optionsBtn.y and y <= optionsBtn.y + optionsBtn.height then
            game.previousState = game.state
            game.state = "options"
        elseif x >= quitBtn.x and x <= quitBtn.x + quitBtn.width and
               y >= quitBtn.y and y <= quitBtn.y + quitBtn.height then
            game.state = "menu"
            game.paused = false
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