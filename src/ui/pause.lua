local pause = {}

local common = require("src/ui/common")
local fonts = nil
local buttons = {}
local stateManager = common.StateManager:new()


function pause.load()
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
        common.Button:new(centerX - btnWidth/2, btnY, btnWidth, btnHeight, "RESUME"),
        common.Button:new(centerX - btnWidth/2, btnY + btnSpacing, btnWidth, btnHeight, "OPTIONS"),
        common.Button:new(centerX - btnWidth/2, btnY + btnSpacing * 2, btnWidth, btnHeight, "QUIT")
    }
end

function pause.draw(game)
    -- Initialize buttons if not already done
    if #buttons == 0 then
        initButtons()
    end

    -- Draw 50% overlay
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setFont(fonts.title)
    local titleText = "PAUSED"
    local titleWidth = fonts.title:getWidth(titleText)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() / 4
    love.graphics.print(titleText, titleX, titleY)

    -- Draw buttons
    love.graphics.setFont(fonts.button)

    for i, button in ipairs(buttons) do
        button:draw(fonts, i == stateManager:getSelection(), button:isMouseOver(game.mouseX, game.mouseY))
    end
end

function pause.mousepressed(game, x, y, button)
    if button == 1 then
        -- Initialize buttons if not already done
        if #buttons == 0 then
            initButtons()
        end

        for i, btn in ipairs(buttons) do
            if btn:isMouseOver(x, y) then
                stateManager:setSelection(i)
                if i == 1 then
                    game.paused = false
                elseif i == 2 then
                    game.previousState = game.state
                    game.state = "options"
                elseif i == 3 then
                    game.state = "menu"
                    game.paused = false
                end
                break
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
        stateManager:moveUp(#buttons)
    elseif key == "down" or key == "s" then
        stateManager:moveDown(#buttons)
    elseif key == "return" or key == "enter" or key == "space" then
        local selection = stateManager:getSelection()
        if selection == 1 then  -- Resume
            game.paused = false
        elseif selection == 2 then  -- Options
            game.previousState = game.state
            game.state = "options"
        elseif selection == 3 then  -- Quit
            game.state = "menu"
            game.paused = false
        end
    end
end

function pause.mousemoved(game, x, y)
    -- Initialize buttons if not already done
    if #buttons == 0 then
        initButtons()
    end

    for i, btn in ipairs(buttons) do
        if btn:isMouseOver(x, y) then
            stateManager:setSelection(i)
            break
        end
    end
end

return pause