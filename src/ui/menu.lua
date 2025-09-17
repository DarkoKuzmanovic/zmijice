local menu = {}

local common = require("src/ui/common")
local fonts = nil
local buttons = {}
local stateManager = common.StateManager:new()

function menu.load()
    fonts = common.loadFonts()
end

-- Initialize buttons
local function initButtons()
    local centerX = love.graphics.getWidth() / 2
    local titleY = love.graphics.getHeight() / 4
    local btnY = titleY + fonts.title:getHeight() + 40
    local btnSpacing = 50
    local btnWidth = 140
    local btnHeight = 40

    buttons = {
        common.Button:new(centerX - btnWidth/2, btnY, btnWidth, btnHeight, "PLAY"),
        common.Button:new(centerX - btnWidth/2, btnY + btnSpacing, btnWidth, btnHeight, "OPTIONS"),
        common.Button:new(centerX - btnWidth/2, btnY + btnSpacing * 2, btnWidth, btnHeight, "HIGHSCORES"),
        common.Button:new(centerX - btnWidth/2, btnY + btnSpacing * 3, btnWidth, btnHeight, "QUIT")
    }
end

function menu.draw(game, settings)
    -- Initialize buttons if not already done
    if #buttons == 0 then
        initButtons()
    end

    local canvas = common.setupCanvas(settings)

    -- Draw Title
    love.graphics.setFont(fonts.title)
    local title = "ZMIJICE"
    local titleWidth = fonts.title:getWidth(title)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() / 4
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(title, titleX, titleY)

    -- Draw buttons with LCD style
    love.graphics.setFont(fonts.button)

    for i, button in ipairs(buttons) do
        button:draw(fonts, i == stateManager:getSelection(), button:isMouseOver(game.mouseX, game.mouseY))
    end

    -- Draw copyright notice
    love.graphics.setColor(0.2, 0.2, 0.2)
    local copyright = "(C) 2025 ZMIJICE v1.0.0 - Darko Kuzmanovic for Lenkalica"
    local copyrightWidth = fonts.button:getWidth(copyright)
    local copyrightX = (love.graphics.getWidth() - copyrightWidth) / 2
    local copyrightY = love.graphics.getHeight() - fonts.button:getHeight() - 20
    love.graphics.print(copyright, copyrightX, copyrightY)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function menu.keypressed(game, key)
    if key == "up" or key == "w" then
        stateManager:moveUp(#buttons)
    elseif key == "down" or key == "s" then
        stateManager:moveDown(#buttons)
    elseif key == "return" or key == "enter" then
        local selection = stateManager:getSelection()
        if selection == 1 then
            game.reset()
        elseif selection == 2 then
            game.state = "options"
        elseif selection == 3 then
            game.state = "highscores"
        elseif selection == 4 then
            love.event.quit()
        end
    elseif key == "escape" or key == "q" then
        love.event.quit()
    end
end

function menu.mousepressed(game, x, y, button)
    if button == 1 then
        -- Initialize buttons if not already done
        if #buttons == 0 then
            initButtons()
        end

        for i, btn in ipairs(buttons) do
            if btn:isMouseOver(x, y) then
                stateManager:setSelection(i)
                if i == 1 then
                    game.reset()
                elseif i == 2 then
                    game.state = "options"
                elseif i == 3 then
                    game.state = "highscores"
                elseif i == 4 then
                    love.event.quit()
                end
                break
            end
        end
    end
end

return menu