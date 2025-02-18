local menu = {}

local gameOverFont = nil
local scoreFont = nil

function menu.load()
    gameOverFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 16)

    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    gameOverFont:setFilter("nearest", "nearest")
    scoreFont:setFilter("nearest", "nearest")
end

function menu.draw(game, settings)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

    -- Draw Title
    love.graphics.setFont(gameOverFont)
    local title = "ZMIJICE"
    local titleWidth = gameOverFont:getWidth(title)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() / 4
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(title, titleX, titleY)

    -- Draw buttons with LCD style
    local centerX = love.graphics.getWidth() / 2
    local btnY = titleY + gameOverFont:getHeight() + 40
    local btnSpacing = 50
    local btnWidth = 140
    local btnHeight = 40

    -- Three options: PLAY, OPTIONS, QUIT
    local playBtn = {x = centerX - btnWidth/2, y = btnY, width = btnWidth, height = btnHeight}
    local optionsBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
    local quitBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}

    love.graphics.setFont(scoreFont)

    local buttons = {
        {btn = playBtn, text = "PLAY", selected = game.menuSelection == 1},
        {btn = optionsBtn, text = "OPTIONS", selected = game.menuSelection == 2},
        {btn = quitBtn, text = "QUIT", selected = game.menuSelection == 3}
    }

    local function isMouseOver(btn)
        return game.mouseX >= btn.x and game.mouseX <= btn.x + btn.width and
               game.mouseY >= btn.y and game.mouseY <= btn.y + btn.height
    end

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

    -- Draw copyright notice
    love.graphics.setColor(0.2, 0.2, 0.2)
    local copyright = "(C) 2024 ZMIJICE v0.9.0 - Darko Kuzmanovic for Lenkalica"
    local copyrightWidth = scoreFont:getWidth(copyright)
    local copyrightX = (love.graphics.getWidth() - copyrightWidth) / 2
    local copyrightY = love.graphics.getHeight() - scoreFont:getHeight() - 20
    love.graphics.print(copyright, copyrightX, copyrightY)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function menu.keypressed(game, key)
    if key == "up" or key == "w" then
        game.menuSelection = game.menuSelection - 1
        if game.menuSelection < 1 then game.menuSelection = 3 end
    elseif key == "down" or key == "s" then
        game.menuSelection = game.menuSelection + 1
        if game.menuSelection > 3 then game.menuSelection = 1 end
    elseif key == "return" or key == "enter" then
        if game.menuSelection == 1 then
            game.reset()
        elseif game.menuSelection == 2 then
            game.state = "options"
        elseif game.menuSelection == 3 then
            love.event.quit()
        end
    elseif key == "escape" or key == "q" then
        love.event.quit()
    end
end

function menu.mousepressed(game, x, y, button)
    if button == 1 then
        local centerX = love.graphics.getWidth() / 2
        local titleY = love.graphics.getHeight() / 4
        local btnY = titleY + gameOverFont:getHeight() + 40
        local btnSpacing = 50
        local btnWidth = 140
        local btnHeight = 40

        local playBtn = {x = centerX - btnWidth/2, y = btnY, width = btnWidth, height = btnHeight}
        local optionsBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
        local quitBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}

        if x >= playBtn.x and x <= playBtn.x + playBtn.width and
           y >= playBtn.y and y <= playBtn.y + playBtn.height then
            game.reset()
        elseif x >= optionsBtn.x and x <= optionsBtn.x + optionsBtn.width and
               y >= optionsBtn.y and y <= optionsBtn.y + optionsBtn.height then
            game.state = "options"
        elseif x >= quitBtn.x and x <= quitBtn.x + quitBtn.width and
               y >= quitBtn.y and y <= quitBtn.y + quitBtn.height then
            love.event.quit()
        end
    end
end

return menu