local options = {}

local common = require("src/ui/common")
local fonts
local sfxSlider
local crtToggle
local backButton
local layout
local stateManager = common.StateManager:new()

local COLOR_DARK = {0.2, 0.2, 0.2}
local COLOR_ACCENT = {0.9, 1.0, 0.7}
local COLOR_MUTED = {0.2, 0.2, 0.2, 0.75}

local CRT_DESCRIPTIONS = {
    OFF = "Screen curvature only",
    CLASSIC = "Standard CRT look",
    HEAVY = "Maximum retro effect"
}

local function resetUI()
    sfxSlider = nil
    crtToggle = nil
    backButton = nil
    layout = nil
end

function options.load()
    fonts = common.loadFonts()
    resetUI()
    stateManager:setSelection(1)
end

local function getCrtIndex(effect)
    if effect == "CLASSIC" then
        return 2
    elseif effect == "HEAVY" then
        return 3
    end
    return 1
end

local function ensureUI(settings)
    if not fonts then
        options.load()
    end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if not layout or layout.screenW ~= screenW or layout.screenH ~= screenH then
        local titleY = screenH / 4
        local titleHeight = fonts.title:getHeight()
        local rowSpacing = 24
        local rowWidth = math.min(380, screenW - 80)
        rowWidth = math.max(rowWidth, 240)
        local rowX = (screenW - rowWidth) / 2

        local buttonHeight = fonts.button:getHeight()
        local sliderHeight = 18
        local toggleHeight = 32
        local sliderRowHeight = math.max(buttonHeight * 4, buttonHeight * 2 + sliderHeight + 24)
        local toggleRowHeight = math.max(buttonHeight * 5, 3 * buttonHeight + toggleHeight + 22)

        local sliderRowY = titleY + titleHeight + 40
        local toggleRowY = sliderRowY + sliderRowHeight + rowSpacing
        local backButtonY = toggleRowY + toggleRowHeight + rowSpacing

        layout = {
            screenW = screenW,
            screenH = screenH,
            titleY = titleY,
            sliderRow = { x = rowX, y = sliderRowY, width = rowWidth, height = sliderRowHeight },
            toggleRow = { x = rowX, y = toggleRowY, width = rowWidth, height = toggleRowHeight },
            backButton = { x = rowX, y = backButtonY, width = rowWidth, height = 40 }
        }

        local sliderWidth = rowWidth - 64
        local sliderX = rowX + (rowWidth - sliderWidth) / 2
        local sliderY = sliderRowY + buttonHeight * 2
        sfxSlider = common.Slider:new(sliderX, sliderY, sliderWidth, sliderHeight, settings.sfxVolume, 0, 1)

        local crtWidth = rowWidth - 64
        local crtX = rowX + (rowWidth - crtWidth) / 2
        local crtY = toggleRowY + buttonHeight * 2
        crtToggle = common.Toggle:new(crtX, crtY, crtWidth, toggleHeight, getCrtIndex(settings.crtEffect), {"OFF", "CLASSIC", "HEAVY"})

        backButton = common.Button:new(layout.backButton.x, layout.backButton.y, layout.backButton.width, layout.backButton.height, "BACK")
    end

    sfxSlider:setValue(settings.sfxVolume or 0)
    crtToggle:setValue(getCrtIndex(settings.crtEffect))
end

local function applyCrtSelection(settings)
    local crtValue = crtToggle:getValue()
    if crtValue == 1 then
        settings.crtEffect = "OFF"
    elseif crtValue == 2 then
        settings.crtEffect = "CLASSIC"
    elseif crtValue == 3 then
        settings.crtEffect = "HEAVY"
    end
    settings.updateShaderValues()
    settings.save()
end

local function drawOptionPanel(bounds, isSelected, isHovered)
    love.graphics.setLineWidth(1)
    if isSelected then
        love.graphics.setColor(COLOR_DARK)
        love.graphics.rectangle("fill", bounds.x - 2, bounds.y - 2, bounds.width + 4, bounds.height + 4)
        love.graphics.setColor(COLOR_ACCENT)
        love.graphics.rectangle("line", bounds.x - 2, bounds.y - 2, bounds.width + 4, bounds.height + 4)
    else
        love.graphics.setColor(COLOR_DARK)
        love.graphics.rectangle("line", bounds.x, bounds.y, bounds.width, bounds.height)
        if isHovered then
            love.graphics.setColor(COLOR_ACCENT)
            love.graphics.rectangle("line", bounds.x - 1, bounds.y - 1, bounds.width + 2, bounds.height + 2)
        end
    end
end

function options.draw(game, settings)
    ensureUI(settings)

    local canvas = common.setupCanvas(settings)

    love.graphics.setFont(fonts.title)
    local title = "OPTIONS"
    local titleWidth = fonts.title:getWidth(title)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = layout.titleY
    love.graphics.setColor(COLOR_DARK)
    love.graphics.print(title, titleX, titleY)

    love.graphics.setFont(fonts.button)
    local selection = stateManager:getSelection()
    local mouseX = game.mouseX or -1
    local mouseY = game.mouseY or -1

    local sliderRow = layout.sliderRow
    local sliderHovered = common.isMouseOver(mouseX, mouseY, sliderRow)
    local sliderControlHovered = sfxSlider:isMouseOver(mouseX, mouseY)

    drawOptionPanel(sliderRow, selection == 1, sliderHovered or sliderControlHovered)

    local volumePercent = math.floor((settings.sfxVolume or 0) * 100 + 0.5)
    love.graphics.setColor(selection == 1 and COLOR_ACCENT or COLOR_DARK)
    love.graphics.print("SFX VOLUME", sliderRow.x + 16, sliderRow.y + 12)

    local valueText = string.format("%03d%%", volumePercent)
    love.graphics.print(valueText, sliderRow.x + sliderRow.width - fonts.button:getWidth(valueText) - 16, sliderRow.y + 12)

    sfxSlider:draw(fonts, selection == 1, sliderControlHovered)

    local toggleRow = layout.toggleRow
    local toggleHovered = common.isMouseOver(mouseX, mouseY, toggleRow)
    local toggleControlHovered = crtToggle:isMouseOver(mouseX, mouseY)

    drawOptionPanel(toggleRow, selection == 2, toggleHovered or toggleControlHovered)

    local toggleValue = crtToggle:getValueText()
    love.graphics.setColor(selection == 2 and COLOR_ACCENT or COLOR_DARK)
    love.graphics.print("CRT EFFECT", toggleRow.x + 16, toggleRow.y + 12)
    love.graphics.print(toggleValue, toggleRow.x + toggleRow.width - fonts.button:getWidth(toggleValue) - 16, toggleRow.y + 12)

    crtToggle:draw(fonts, selection == 2, toggleControlHovered)

    local description = CRT_DESCRIPTIONS[toggleValue]
    if description and description ~= "" then
        love.graphics.setColor(selection == 2 and COLOR_ACCENT or COLOR_MUTED)
        love.graphics.print(description, toggleRow.x + 16, crtToggle.y + crtToggle.height + 10)
    end

    local backHovered = backButton:isMouseOver(mouseX, mouseY)
    backButton:draw(fonts, selection == 3, backHovered)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    if settings.isCrtEnabled() then love.graphics.setShader(settings.getShader()) end
    love.graphics.draw(canvas)
    if settings.isCrtEnabled() then love.graphics.setShader() end
end

function options.mousepressed(game, settings, x, y, button)
    if button ~= 1 then
        return
    end

    ensureUI(settings)

    if sfxSlider:isMouseOver(x, y) then
        if stateManager:getSelection() ~= 1 then
            stateManager:setSelection(1)
        end
        sfxSlider:setValueFromMouse(x)
        settings.sfxVolume = sfxSlider:getValue()
        settings.updateSoundVolumes(game.sounds)
        common.playSound(game.sounds, "select")
        return
    end

    if common.isMouseOver(x, y, layout.sliderRow) then
        if stateManager:getSelection() ~= 1 then
            stateManager:setSelection(1)
            common.playSound(game.sounds, "select")
        end
        return
    end

    if crtToggle:isMouseOver(x, y) then
        if stateManager:getSelection() ~= 2 then
            stateManager:setSelection(2)
        end
        crtToggle:next()
        applyCrtSelection(settings)
        common.playSound(game.sounds, "select")
        return
    end

    if common.isMouseOver(x, y, layout.toggleRow) then
        if stateManager:getSelection() ~= 2 then
            stateManager:setSelection(2)
            common.playSound(game.sounds, "select")
        end
        return
    end

    if backButton:isMouseOver(x, y) then
        if stateManager:getSelection() ~= 3 then
            stateManager:setSelection(3)
        end
        game.state = "menu"
        common.playSound(game.sounds, "back")
    end
end

function options.keypressed(game, settings, key)
    ensureUI(settings)

    if key == "up" or key == "w" then
        stateManager:moveUp(3)
    elseif key == "down" or key == "s" then
        stateManager:moveDown(3)
    elseif key == "left" or key == "a" then
        local selection = stateManager:getSelection()
        if selection == 1 then
            settings.sfxVolume = math.max(0, (settings.sfxVolume or 0) - 0.1)
            settings.updateSoundVolumes(game.sounds)
            sfxSlider:setValue(settings.sfxVolume)
            common.playSound(game.sounds, "select")
        elseif selection == 2 then
            crtToggle:previous()
            applyCrtSelection(settings)
            common.playSound(game.sounds, "select")
        end
    elseif key == "right" or key == "d" then
        local selection = stateManager:getSelection()
        if selection == 1 then
            settings.sfxVolume = math.min(1, (settings.sfxVolume or 0) + 0.1)
            settings.updateSoundVolumes(game.sounds)
            sfxSlider:setValue(settings.sfxVolume)
            common.playSound(game.sounds, "select")
        elseif selection == 2 then
            crtToggle:next()
            applyCrtSelection(settings)
            common.playSound(game.sounds, "select")
        end
    elseif key == "home" then
        if stateManager:getSelection() == 1 then
            settings.sfxVolume = 0
            settings.updateSoundVolumes(game.sounds)
            sfxSlider:setValue(settings.sfxVolume)
            common.playSound(game.sounds, "select")
        end
    elseif key == "end" then
        if stateManager:getSelection() == 1 then
            settings.sfxVolume = 1
            settings.updateSoundVolumes(game.sounds)
            sfxSlider:setValue(settings.sfxVolume)
            common.playSound(game.sounds, "select")
        end
    elseif key == "return" or key == "enter" or key == "space" then
        if stateManager:getSelection() == 3 then
            game.state = "menu"
            common.playSound(game.sounds, "confirm")
        end
    elseif key == "escape" then
        if game.previousState then
            game.state = game.previousState
            game.previousState = nil
        else
            game.state = "menu"
        end
        common.playSound(game.sounds, "back")
    end
end

return options
