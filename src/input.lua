local input = {}

local menu = require("src/ui/menu")
local options = require("src/ui/options")
local gameOver = require("src/ui/gameOver")
local highscoresUI = require("src/ui/highscores") -- Import highscores UI
local nameEntry = require("src/ui/nameEntry") -- Require the new module
local settings = require("src/settings")

-- Ensure volume adjustment functions exist on settings
if not settings.decreaseSfxVolume then
    settings.decreaseSfxVolume = _G.decreaseSfxVolume
end
if not settings.increaseSfxVolume then
    settings.increaseSfxVolume = _G.increaseSfxVolume
end

-- Define fonts
local gameOverFont = nil
local scoreFont = nil

function input.load()
    gameOverFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 16)

    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    gameOverFont:setFilter("nearest", "nearest")
    scoreFont:setFilter("nearest", "nearest")

    highscoresUI.load() -- Load highscores UI
    nameEntry.load() -- Load nameEntry
end

-- Helper function to safely play a sound
local function playSound(sounds, soundName)
    if sounds and sounds[soundName] then
        sounds[soundName]:stop()
        sounds[soundName]:play()
    end
end

function input.keypressed(game, settings, highscores, key)
    if game.state == "menu" then
        menu.keypressed(game, key)
    elseif game.state == "running" then
        if key == "p" or key == "escape" then
            game.paused = not game.paused
            if game.paused then
                playSound(game.sounds, "pause")
            else
                playSound(game.sounds, "unpause")
            end
            return
        end

        if game.paused then
            if key == "up" or key == "w" then
                game.pauseSelection = game.pauseSelection - 1
                if game.pauseSelection < 1 then game.pauseSelection = 3 end
                playSound(game.sounds, "select")
            elseif key == "down" or key == "s" then
                game.pauseSelection = game.pauseSelection + 1
                if game.pauseSelection > 3 then game.pauseSelection = 1 end
                playSound(game.sounds, "select")
            elseif key == "return" or key == "space" then
                if game.pauseSelection == 1 then
                    game.paused = false
                    playSound(game.sounds, "unpause")
                elseif game.pauseSelection == 2 then
                    game.previousState = "running"
                    game.state = "options"
                    game.paused = false
                    playSound(game.sounds, "confirm")
                elseif game.pauseSelection == 3 then
                    game.state = "menu"
                    game.paused = false
                    playSound(game.sounds, "confirm")
                end
            end
            return
        end

        if key == "up" or key == "w" then
            if game.direction.y == 0 then
                game.pendingDirection = {x = 0, y = -1}
            end
        elseif key == "down" or key == "s" then
            if game.direction.y == 0 then
                game.pendingDirection = {x = 0, y = 1}
            end
        elseif key == "left" or key == "a" then
            if game.direction.x == 0 then
                game.pendingDirection = {x = -1, y = 0}
            end
        elseif key == "right" or key == "d" then
            if game.direction.x == 0 then
                game.pendingDirection = {x = 1, y = 0}
            end
        end
    elseif game.state == "options" then
        if key == "escape" then
            if game.previousState then
                game.state = game.previousState
                game.previousState = nil
            else
                game.state = "menu"
            end
            playSound(game.sounds, "back")
            return
        end

        if key == "up" or key == "w" then
            settings.selectedOption = settings.selectedOption - 1
            if settings.selectedOption < 1 then settings.selectedOption = 3 end
            playSound(game.sounds, "select")
        elseif key == "down" or key == "s" then
            settings.selectedOption = settings.selectedOption + 1
            if settings.selectedOption > 3 then settings.selectedOption = 1 end
            playSound(game.sounds, "select")
        elseif key == "left" or key == "a" then
            if settings.selectedOption == 1 then
                settings.decreaseSfxVolume()
                playSound(game.sounds, "select")
            elseif settings.selectedOption == 2 then
                settings.previousCrtEffect()
                playSound(game.sounds, "select")
            end
        elseif key == "right" or key == "d" then
            if settings.selectedOption == 1 then
                settings.increaseSfxVolume()
                playSound(game.sounds, "select")
            elseif settings.selectedOption == 2 then
                settings.nextCrtEffect()
                playSound(game.sounds, "select")
            end
        elseif key == "return" or key == "space" then
            if settings.selectedOption == 3 then
                if game.previousState then
                    game.state = game.previousState
                    game.previousState = nil
                else
                    game.state = "menu"
                end
                playSound(game.sounds, "back")
            end
        end
    elseif game.state == "highscores" then
        highscoresUI.keypressed(game, key) -- Delegate to highscoresUI
    elseif game.state == "gameOver" then
        if game.nameEntry.active then
            nameEntry.keypressed(game, key) -- Delegate to nameEntry
        else
            gameOver.keypressed(game, highscores, key)
        end
    end
end

function input.mousepressed(game, settings, highscores, x, y, button)
    -- Reset keyboard selections on mouse use
    if game.state == "menu" then game.menuSelection = 0 end
    if game.state == "options" then settings.selectedOption = 0 end
    if game.state == "running" and game.paused then game.pauseSelection = 0 end

    if button == 1 then
        if game.state == "options" then
            local screenWidth = love.graphics.getWidth()
            local sliderWidth = 200
            local sliderX = (screenWidth - sliderWidth) / 2
            local sliderLeft = sliderX
            local sliderRight = sliderLeft + sliderWidth
            if x >= sliderLeft and x <= sliderRight then
                game.draggingSfxSlider = true
                -- Initial set
                local volume = (x - sliderLeft) / sliderWidth
                settings.sfxVolume = math.min(1, math.max(0, volume))
                settings.updateSoundVolumes(game.sounds)
                playSound(game.sounds, "select")
                return
            end
        end
    elseif button == 2 then  -- Mouse release
        if game.draggingSfxSlider then
            game.draggingSfxSlider = false
            return
        end
    end

    if button ~= 1 then return end

    if game.state == "menu" then
        local screenHeight = love.graphics.getHeight()
        local titleY = screenHeight / 4
        local gameOverFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
        local btnY = titleY + gameOverFont:getHeight() + 40
        local btnSpacing = 50
        local btnWidth = 140
        local btnHeight = 40

        local playBtn = {x = (love.graphics.getWidth() / 2) - btnWidth/2, y = btnY, width = btnWidth, height = btnHeight}
        local optionsBtn = {x = playBtn.x, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
        local highscoresBtn = {x = playBtn.x, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}
        local quitBtn = {x = playBtn.x, y = btnY + btnSpacing * 3, width = btnWidth, height = btnHeight}

        if y >= playBtn.y and y <= playBtn.y + playBtn.height then
            game.state = "running"
            game.reset()
            playSound(game.sounds, "confirm")
            return
        elseif y >= optionsBtn.y and y <= optionsBtn.y + optionsBtn.height then
            game.state = "options"
            playSound(game.sounds, "confirm")
            return
        elseif y >= highscoresBtn.y and y <= highscoresBtn.y + highscoresBtn.height then
            game.state = "highscores"
            playSound(game.sounds, "confirm")
            return
        elseif y >= quitBtn.y and y <= quitBtn.y + quitBtn.height then
            love.event.quit()
            playSound(game.sounds, "confirm")
            return
        end
    elseif game.state == "running" and game.paused then
        local screenHeight = love.graphics.getHeight()
        local menuY = screenHeight / 2
        local buttonHeight = 40
        local spacing = 20

        -- Check RESUME button
        if y >= menuY - buttonHeight/2 and y <= menuY + buttonHeight/2 then
            game.paused = false
            playSound(game.sounds, "unpause")
            return
        -- Check OPTIONS button
        elseif y >= menuY + spacing + buttonHeight/2 and y <= menuY + spacing + buttonHeight*1.5 then
            game.previousState = "running"
            game.state = "options"
            game.paused = false
            playSound(game.sounds, "confirm")
            return
        -- Check QUIT button (to menu)
        elseif y >= menuY + spacing*2 + buttonHeight*1.5 and y <= menuY + spacing*2 + buttonHeight*2.5 then
            game.state = "menu"
            game.paused = false
            playSound(game.sounds, "confirm")
            return
        end
    elseif game.state == "options" then
        local screenHeight = love.graphics.getHeight()
        local screenWidth = love.graphics.getWidth()
        local titleY = screenHeight / 4
        local gameOverFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
        local startY = titleY + gameOverFont:getHeight() + 50
        local optionSpacing = 80
        local scoreFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 16)

        -- SFX area (tighter Y bounds to prevent bleed)
        local sfxSliderY = startY + scoreFont:getHeight() + 15
        local sliderHeight = 20
        local sliderArea = {x = (screenWidth - 200)/2, y = sfxSliderY, width = 200, height = sliderHeight}

        -- CRT area (text only, no description)
        local crtY = startY + optionSpacing
        local crtTextHeight = scoreFont:getHeight()
        local crtArea = {x = (screenWidth - 200)/2, y = crtY, width = 200, height = crtTextHeight}

        -- BACK button
        local backBtnY = crtY + optionSpacing
        local backBtn = {x = (screenWidth - 140) / 2, y = backBtnY, width = 140, height = 40}

        local function isMouseOver(mx, my, area)
            return mx >= area.x and mx <= area.x + area.width and my >= area.y and my <= area.y + area.height
        end

        if isMouseOver(x, y, sliderArea) then
            -- Update volume based on relative x in slider
            local sliderWidth = 200
            local sliderX = (screenWidth - sliderWidth) / 2
            local sliderLeft = sliderX
            local sliderRight = sliderLeft + sliderWidth
            if x >= sliderLeft and x <= sliderRight then
                local volume = (x - sliderLeft) / sliderWidth
                settings.sfxVolume = math.min(1, math.max(0, volume))
                settings.updateSoundVolumes(game.sounds)
                playSound(game.sounds, "select")
            end
            return
        elseif isMouseOver(x, y, crtArea) then
            -- Split CRT area: left half for previous, right for next
            local crtMidX = crtArea.x + crtArea.width / 2
            if x < crtMidX then
                settings.previousCrtEffect()
            else
                settings.nextCrtEffect()
            end
            playSound(game.sounds, "select")
            return
        elseif isMouseOver(x, y, backBtn) then
            if game.previousState then
                game.state = game.previousState
                game.previousState = nil
            else
                game.state = "menu"
            end
            playSound(game.sounds, "back")
            return
        end
    elseif game.state == "highscores" then
        highscoresUI.mousepressed(game, x, y) -- Delegate to highscoresUI
    elseif game.state == "gameOver" then
        if game.nameEntry.active then
            nameEntry.mousepressed(game, x, y) -- Delegate
        else
            gameOver.mousepressed(game, highscores, x, y, button)
        end
    end
end

function input.mousemoved(game, settings, x, y, dx, dy)
    game.mouseX = x
    game.mouseY = y

    if game.state == "menu" then
        local screenHeight = love.graphics.getHeight()
        local titleY = screenHeight / 4
        local gameOverFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
        local btnY = titleY + gameOverFont:getHeight() + 40
        local btnSpacing = 50
        local btnHeight = 40

        if y >= btnY and y <= btnY + btnHeight then
            game.menuSelection = 1
        elseif y >= btnY + btnSpacing and y <= btnY + btnSpacing + btnHeight then
            game.menuSelection = 2
        elseif y >= btnY + btnSpacing * 2 and y <= btnY + btnSpacing * 2 + btnHeight then
            game.menuSelection = 3
        elseif y >= btnY + btnSpacing * 3 and y <= btnY + btnSpacing * 3 + btnHeight then
            game.menuSelection = 4
        else
            game.menuSelection = 0  -- Deselect if not over any button
        end
    elseif game.state == "running" and game.paused then
        local menuY = love.graphics.getHeight() / 2
        local buttonHeight = 40
        local spacing = 20

        -- Update pause menu selection based on mouse position
        if y >= menuY - buttonHeight/2 and y <= menuY + buttonHeight/2 then
            game.pauseSelection = 1
        elseif y >= menuY + spacing + buttonHeight/2 and y <= menuY + spacing + buttonHeight*1.5 then
            game.pauseSelection = 2
        elseif y >= menuY + spacing*2 + buttonHeight*1.5 and y <= menuY + spacing*2 + buttonHeight*2.5 then
            game.pauseSelection = 3
        end
    elseif game.state == "options" then
        local screenHeight = love.graphics.getHeight()
        local screenWidth = love.graphics.getWidth()
        local titleY = screenHeight / 4
        local gameOverFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
        local startY = titleY + gameOverFont:getHeight() + 50
        local optionSpacing = 80
        local scoreFont = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 16)

        -- SFX area (tighter Y bounds)
        local sfxSliderY = startY + scoreFont:getHeight() + 15
        local sliderHeight = 20
        local sfxArea = {x = (screenWidth - 200)/2, y = sfxSliderY, width = 200, height = sliderHeight}

        -- CRT area (text only)
        local crtY = startY + optionSpacing
        local crtTextHeight = scoreFont:getHeight()
        local crtArea = {x = (screenWidth - 200)/2, y = crtY, width = 200, height = crtTextHeight}

        -- BACK
        local backBtnY = crtY + optionSpacing
        local backBtn = {x = (screenWidth - 140) / 2, y = backBtnY, width = 140, height = 40}

        local function isMouseOver(mx, my, area)
            return mx >= area.x and mx <= area.x + area.width and my >= area.y and my <= area.y + area.height
        end

        if isMouseOver(x, y, sfxArea) then
            settings.selectedOption = 1
        elseif isMouseOver(x, y, crtArea) then
            settings.selectedOption = 2
        elseif y >= backBtn.y and y <= backBtn.y + backBtn.height then
            settings.selectedOption = 3
        else
            settings.selectedOption = 0
        end
    elseif game.state == "gameOver" and not game.nameEntry.active then
        -- Update game over menu selection based on mouse position
        local btnY = (love.graphics.getHeight() / 3) + gameOverFont:getHeight() + scoreFont:getHeight() + 60
        local btnWidth = 140
        local btnHeight = 40
        local btnSpacing = 20

        local newGameBtn = {x = (love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2, y = btnY, width = btnWidth, height = btnHeight}
        local exitBtn = {x = newGameBtn.x + btnWidth + btnSpacing, y = btnY, width = btnWidth, height = btnHeight}

        if x >= newGameBtn.x and x <= newGameBtn.x + newGameBtn.width and
           y >= newGameBtn.y and y <= newGameBtn.y + newGameBtn.height then
            game.menuSelection = 1
        elseif x >= exitBtn.x and x <= exitBtn.x + exitBtn.width and
               y >= exitBtn.y and y <= exitBtn.y + exitBtn.height then
            game.menuSelection = 2
        end
    elseif game.nameEntry.active then
        nameEntry.mousemoved(game, x, y)
    elseif game.state == "highscores" then
        highscoresUI.mousemoved(game, x, y)
    end
end

-- Add mousewheel function for changing characters
function input.wheelmoved(game, settings, highscores, x, y)
    if game.nameEntry.active then
        if y > 0 then
            -- Wheel up - increment character
            local char = string.byte(game.nameEntry.name:sub(game.nameEntry.position, game.nameEntry.position))
            char = char + 1
            if char > string.byte('Z') then char = string.byte('A') end
            game.nameEntry.name = game.nameEntry.name:sub(1, game.nameEntry.position - 1) ..
                                   string.char(char) ..
                                   game.nameEntry.name:sub(game.nameEntry.position + 1)
            playSound(game.sounds, "select")
        elseif y < 0 then
            -- Wheel down - decrement character
            local char = string.byte(game.nameEntry.name:sub(game.nameEntry.position, game.nameEntry.position))
            char = char - 1
            if char < string.byte('A') then char = string.byte('Z') end
            game.nameEntry.name = game.nameEntry.name:sub(1, game.nameEntry.position - 1) ..
                                   string.char(char) ..
                                   game.nameEntry.name:sub(game.nameEntry.position + 1)
            playSound(game.sounds, "select")
        end
    end
end

return input