local options = {}

local gameOverFont = nil
local scoreFont = nil

function options.load()
    gameOverFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 16)

    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    gameOverFont:setFilter("nearest", "nearest")
    scoreFont:setFilter("nearest", "nearest")
end

-- Helper function to check if mouse is over an area
local function isMouseOver(x, y, area)
    return x >= area.x and x <= area.x + area.width and
           y >= area.y and y <= area.y + area.height
end

function options.draw(game, settings)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

    love.graphics.setFont(gameOverFont)
    local title = "OPTIONS"
    local titleWidth = gameOverFont:getWidth(title)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() / 4
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(title, titleX, titleY)

    love.graphics.setFont(scoreFont)
    local startY = titleY + gameOverFont:getHeight() + 40

    -- Option 1: SFX Volume slider
    local sfxText = string.format("SFX Volume: %d%%", settings.sfxVolume * 100)
    local sfxTextWidth = scoreFont:getWidth(sfxText)
    local sfxX = (love.graphics.getWidth() - sfxTextWidth) / 2

    -- Draw volume text with color based on selection
    if game.optionsSelection == 1 then
        love.graphics.setColor(0.1, 0.4, 0.1) -- Darker green when selected
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
    love.graphics.print(sfxText, sfxX, startY)

    local sliderWidth = 200
    local sliderHeight = 20
    local sliderX = (love.graphics.getWidth() - sliderWidth) / 2
    local sliderY = startY + scoreFont:getHeight() + 10

    -- Draw slider background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", sliderX, sliderY, sliderWidth, sliderHeight, 4, 4)

    -- Draw slider fill with brighter color when selected
    if game.optionsSelection == 1 then
        love.graphics.setColor(0.1, 0.4, 0.1) -- Darker green when selected
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
    love.graphics.rectangle("fill", sliderX, sliderY, sliderWidth * settings.sfxVolume, sliderHeight, 4, 4)

    -- Draw slider knob
    local knobWidth = 8
    local knobHeight = sliderHeight + 8
    local knobX = sliderX + (sliderWidth * settings.sfxVolume) - (knobWidth / 2)
    local knobY = sliderY - 4
    love.graphics.rectangle("fill", knobX, knobY, knobWidth, knobHeight, 2, 2)

    -- Option 2: CRT Effect toggle
    local crtText = string.format("CRT Effect: %s", settings.crtEffect)
    local crtTextWidth = scoreFont:getWidth(crtText)
    local crtX = (love.graphics.getWidth() - crtTextWidth) / 2
    local crtY = sliderY + sliderHeight + 30

    -- Draw CRT text with color based on selection
    if game.optionsSelection == 2 then
        love.graphics.setColor(0.1, 0.4, 0.1) -- Darker green when selected
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
    love.graphics.print(crtText, crtX, crtY)

    -- Draw arrow indicators for CRT effect selection when selected
    if game.optionsSelection == 2 then
        -- Left arrow
        love.graphics.polygon('fill',
            crtX - 20, crtY + scoreFont:getHeight()/2,
            crtX - 10, crtY + scoreFont:getHeight()/2 - 5,
            crtX - 10, crtY + scoreFont:getHeight()/2 + 5
        )
        -- Right arrow
        love.graphics.polygon('fill',
            crtX + crtTextWidth + 20, crtY + scoreFont:getHeight()/2,
            crtX + crtTextWidth + 10, crtY + scoreFont:getHeight()/2 - 5,
            crtX + crtTextWidth + 10, crtY + scoreFont:getHeight()/2 + 5
        )
    end

    -- Draw effect description
    local description = ""
    if settings.crtEffect == "OFF" then
        description = "Screen curvature only"
    elseif settings.crtEffect == "CLASSIC" then
        description = "Standard CRT look"
    elseif settings.crtEffect == "HEAVY" then
        description = "Maximum retro effect"
    end

    local descriptionWidth = scoreFont:getWidth(description)
    local descriptionX = (love.graphics.getWidth() - descriptionWidth) / 2
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.print(description, descriptionX, crtY + scoreFont:getHeight() + 5)

    -- Option 3: BACK button
    local backBtn = {x = (love.graphics.getWidth() - 140) / 2, y = sliderY + sliderHeight + 80, width = 140, height = 40}

    -- Draw back button with different style when selected
    if game.optionsSelection == 3 or isMouseOver(game.mouseX, game.mouseY, backBtn) then
        love.graphics.setColor(0.1, 0.4, 0.1) -- Darker green when selected
        love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
        love.graphics.setColor(0.75, 0.85, 0.65) -- Light green text
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("line", backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
        love.graphics.setColor(0.2, 0.2, 0.2)
    end

    local backText = "BACK"
    local backTextWidth = scoreFont:getWidth(backText)
    local backTextX = backBtn.x + (backBtn.width - backTextWidth) / 2
    local backTextY = backBtn.y + (backBtn.height - scoreFont:getHeight()) / 2
    love.graphics.print(backText, backTextX, backTextY)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.crtEffect then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.crtEffect then love.graphics.setShader() end
end

function options.mousepressed(game, settings, x, y, button)
    if button == 1 then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        local titleY = screenHeight / 4
        local startY = titleY + gameOverFont:getHeight() + 40
        local sliderWidth = 200
        local sliderHeight = 20
        local sfxTextHeight = scoreFont:getHeight()
        local sliderX = (screenWidth - sliderWidth) / 2
        local sliderY = startY + sfxTextHeight + 10

        -- Define interactive areas
        -- SFX slider area (Option 1)
        local sliderArea = { x = sliderX, y = sliderY, width = sliderWidth, height = sliderHeight }

        -- CRT toggle area (Option 2)
        local crtText = string.format("CRT Effect: %s", settings.crtEffect)
        local crtTextWidth = scoreFont:getWidth(crtText)
        local crtX = (screenWidth - crtTextWidth) / 2
        local crtY = sliderY + sliderHeight + 30
        local crtArea = { x = crtX, y = crtY, width = crtTextWidth + 40, height = scoreFont:getHeight() }

        -- BACK button area (Option 3)
        local backBtn = { x = (screenWidth - 140) / 2, y = sliderY + sliderHeight + 80, width = 140, height = 40 }

        -- Check if click is in the SFX slider area
        if isMouseOver(x, y, sliderArea) then
            game.optionsSelection = 1
            settings.sfxVolume = math.min(1, math.max(0, (x - sliderArea.x) / sliderArea.width))
            settings.updateSoundVolumes(game.sounds)
            return
        end

        -- Check if click is in the CRT toggle area
        if isMouseOver(x, y, crtArea) then
            game.optionsSelection = 2
            settings.crtEffect = not settings.crtEffect
            return
        end

        -- Check if click is in the BACK button area
        if isMouseOver(x, y, backBtn) then
            game.optionsSelection = 3
            game.state = "menu"
            return
        end

        -- Update selection based on Y position
        if y < crtY then
            game.optionsSelection = 1
        elseif y < backBtn.y then
            game.optionsSelection = 2
        else
            game.optionsSelection = 3
        end
    end
end

function options.keypressed(game, settings, key)
    if not game.optionsSelection then game.optionsSelection = 1 end
    if key == "up" or key == "w" then
        game.optionsSelection = game.optionsSelection - 1
        if game.optionsSelection < 1 then game.optionsSelection = 3 end
    elseif key == "down" or key == "s" then
        game.optionsSelection = game.optionsSelection + 1
        if game.optionsSelection > 3 then game.optionsSelection = 1 end
    elseif key == "left" or key == "a" then
        if game.optionsSelection == 1 then
            settings.sfxVolume = math.max(0, settings.sfxVolume - 0.1)
            settings.updateSoundVolumes(game.sounds)
        elseif game.optionsSelection == 2 then
            settings.previousCrtEffect()
        end
    elseif key == "right" or key == "d" then
        if game.optionsSelection == 1 then
            settings.sfxVolume = math.min(1, settings.sfxVolume + 0.1)
            settings.updateSoundVolumes(game.sounds)
        elseif game.optionsSelection == 2 then
            settings.nextCrtEffect()
        end
    elseif key == "return" or key == "enter" or key == "space" then
        if game.optionsSelection == 3 then
            game.state = "menu"
        end
    elseif key == "escape" then
        game.state = "menu"
    end
end

return options