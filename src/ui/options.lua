local options = {}

local gameOverFont = nil
local scoreFont = nil

function options.load()
    gameOverFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 16)

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
    local startY = titleY + gameOverFont:getHeight() + 50
    local optionSpacing = 80  -- Increased spacing between options

    -- Option 1: SFX Volume slider
    local sfxText = string.format("SFX Volume: %d%%", settings.sfxVolume * 100)
    local sfxTextWidth = scoreFont:getWidth(sfxText)
    local sfxX = (love.graphics.getWidth() - sfxTextWidth) / 2

    local sliderWidth = 200
    local sliderHeight = 20
    local sliderX = (love.graphics.getWidth() - sliderWidth) / 2
    local sliderY = startY + scoreFont:getHeight() + 15

    -- Draw selection rectangle for SFX Volume option (wider and taller)
    local selectionWidth = sliderWidth + 60
    local selectionHeight = scoreFont:getHeight() + sliderHeight + 45
    local selectionX = (love.graphics.getWidth() - selectionWidth) / 2
    local selectionY = startY - 15

    if settings.selectedOption == 1 then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", selectionX, selectionY, selectionWidth, selectionHeight, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end

    -- Draw volume text
    love.graphics.print(sfxText, sfxX, startY)

    -- Draw slider background (inverted color when selected)
    if settings.selectedOption == 1 then
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
    love.graphics.rectangle("line", sliderX, sliderY, sliderWidth, sliderHeight, 4, 4)

    -- Draw slider fill (inverted color when selected)
    if settings.selectedOption == 1 then
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
    love.graphics.rectangle("fill", sliderX, sliderY, sliderWidth * settings.sfxVolume, sliderHeight, 4, 4)

    -- Draw slider knob
    local knobWidth = 8
    local knobHeight = sliderHeight + 8
    local knobX = sliderX + (sliderWidth * settings.sfxVolume) - (knobWidth / 2)
    local knobY = sliderY - 4

    -- Draw slider knob (inverted color when selected)
    if settings.selectedOption == 1 then
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end
    love.graphics.rectangle("fill", knobX, knobY, knobWidth, knobHeight, 2, 2)

    -- Option 2: CRT Effect toggle
    local crtText = string.format("CRT Effect: %s", settings.crtEffect)
    local crtTextWidth = scoreFont:getWidth(crtText)
    local crtX = (love.graphics.getWidth() - crtTextWidth) / 2
    local crtY = startY + optionSpacing

    -- Draw effect description first to calculate total height
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
    local descriptionY = crtY + scoreFont:getHeight() + 5

    -- Draw selection rectangle for CRT Effect option (taller to include description)
    local crtSelectionWidth = crtTextWidth + 80
    local crtSelectionHeight = scoreFont:getHeight() * 2 + 20  -- Tall enough for both lines
    local crtSelectionX = (love.graphics.getWidth() - crtSelectionWidth) / 2
    local crtSelectionY = crtY - 10

    if settings.selectedOption == 2 then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", crtSelectionX, crtSelectionY, crtSelectionWidth, crtSelectionHeight, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end

    -- Draw CRT text
    love.graphics.print(crtText, crtX, crtY)

    -- Draw arrow indicators for CRT effect selection when selected
    if settings.selectedOption == 2 then
        -- Left arrow (inverted color when selected)
        love.graphics.setColor(0.75, 0.85, 0.65)
        love.graphics.polygon('fill',
            crtX - 30, crtY + scoreFont:getHeight()/2,
            crtX - 15, crtY + scoreFont:getHeight()/2 - 10,
            crtX - 15, crtY + scoreFont:getHeight()/2 + 10
        )
        -- Right arrow (inverted color when selected)
        love.graphics.polygon('fill',
            crtX + crtTextWidth + 30, crtY + scoreFont:getHeight()/2,
            crtX + crtTextWidth + 15, crtY + scoreFont:getHeight()/2 - 10,
            crtX + crtTextWidth + 15, crtY + scoreFont:getHeight()/2 + 10
        )
    end

    -- Draw effect description (with inverted color when selected)
    if settings.selectedOption == 2 then
        love.graphics.setColor(0.75, 0.85, 0.65, 0.8)
    else
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    end
    love.graphics.print(description, descriptionX, descriptionY)

    -- Option 3: BACK button
    local backBtn = {x = (love.graphics.getWidth() - 140) / 2, y = crtY + optionSpacing, width = 140, height = 40}

    -- Draw back button like the main menu (no larger rectangle)
    if settings.selectedOption == 3 or isMouseOver(game.mouseX, game.mouseY, backBtn) then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
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
        local startY = titleY + gameOverFont:getHeight() + 50
        local optionSpacing = 80
        local sliderWidth = 200
        local sliderHeight = 20
        local sfxTextHeight = scoreFont:getHeight()
        local sliderX = (screenWidth - sliderWidth) / 2
        local sliderY = startY + sfxTextHeight + 15

        -- Define interactive areas to match the larger visual highlights
        -- SFX slider area (Option 1) - wider and taller to match the visual highlight
        local sfxText = string.format("SFX Volume: %d%%", settings.sfxVolume * 100)
        local sfxTextWidth = scoreFont:getWidth(sfxText)
        local sfxX = (screenWidth - sfxTextWidth) / 2
        local selectionWidth = sliderWidth + 60
        local selectionHeight = scoreFont:getHeight() + sliderHeight + 45
        local selectionX = (screenWidth - selectionWidth) / 2
        local selectionY = startY - 15
        local sliderArea = { x = selectionX, y = selectionY, width = selectionWidth, height = selectionHeight }

        -- CRT toggle area (Option 2) - taller to include description text
        local crtText = string.format("CRT Effect: %s", settings.crtEffect)
        local crtTextWidth = scoreFont:getWidth(crtText)
        local crtX = (screenWidth - crtTextWidth) / 2
        local crtY = startY + optionSpacing
        local crtSelectionWidth = crtTextWidth + 80
        local crtSelectionHeight = scoreFont:getHeight() * 2 + 20
        local crtSelectionX = (screenWidth - crtSelectionWidth) / 2
        local crtSelectionY = crtY - 10
        local crtArea = { x = crtSelectionX, y = crtSelectionY, width = crtSelectionWidth, height = crtSelectionHeight }

        -- BACK button area (Option 3) - same size as visual (like main menu)
        local backBtn = { x = (screenWidth - 140) / 2, y = crtY + optionSpacing, width = 140, height = 40 }

        -- Check if click is in the SFX slider area
        if isMouseOver(x, y, sliderArea) then
            settings.selectedOption = 1
            settings.sfxVolume = math.min(1, math.max(0, (x - sliderArea.x) / sliderArea.width))
            settings.updateSoundVolumes(game.sounds)
            return
        end

        -- Check if click is in the CRT toggle area
        if isMouseOver(x, y, crtArea) then
            settings.selectedOption = 2
            settings.crtEffect = not settings.crtEffect
            return
        end

        -- Check if click is in the BACK button area
        if isMouseOver(x, y, backBtn) then
            settings.selectedOption = 3
            game.state = "menu"
            return
        end

        -- Update selection based on Y position
        if y < crtY then
            settings.selectedOption = 1
        elseif y < backBtn.y then
            settings.selectedOption = 2
        else
            settings.selectedOption = 3
        end
    end
end

function options.keypressed(game, settings, key)
    if not settings.selectedOption then settings.selectedOption = 1 end
    if key == "up" or key == "w" then
        settings.selectedOption = settings.selectedOption - 1
        if settings.selectedOption < 1 then settings.selectedOption = 3 end
    elseif key == "down" or key == "s" then
        settings.selectedOption = settings.selectedOption + 1
        if settings.selectedOption > 3 then settings.selectedOption = 1 end
    elseif key == "left" or key == "a" then
        if settings.selectedOption == 1 then
            settings.sfxVolume = math.max(0, settings.sfxVolume - 0.1)
            settings.updateSoundVolumes(game.sounds)
        elseif settings.selectedOption == 2 then
            settings.previousCrtEffect()
        end
    elseif key == "right" or key == "d" then
        if settings.selectedOption == 1 then
            settings.sfxVolume = math.min(1, settings.sfxVolume + 0.1)
            settings.updateSoundVolumes(game.sounds)
        elseif settings.selectedOption == 2 then
            settings.nextCrtEffect()
        end
    elseif key == "return" or key == "enter" or key == "space" then
        if settings.selectedOption == 3 then
            game.state = "menu"
        end
    elseif key == "escape" then
        game.state = "menu"
    end
end

return options