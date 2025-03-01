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
    gameOverFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 32)
    scoreFont = love.graphics.newFont("assets/fonts/hlazor_pixel.ttf", 16)

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
    if button ~= 1 then return end

    if game.state == "menu" then
        local menuY = love.graphics.getHeight() / 2
        local buttonHeight = 40
        local spacing = 20

        -- Check START button
        if y >= menuY - buttonHeight/2 and y <= menuY + buttonHeight/2 then
            game.menuSelection = 1
            game.state = "running"
            game.reset()
            playSound(game.sounds, "confirm")
        -- Check OPTIONS button
        elseif y >= menuY + spacing + buttonHeight/2 and y <= menuY + spacing + buttonHeight*1.5 then
            game.menuSelection = 2
            game.state = "options"
            playSound(game.sounds, "confirm")
        -- Check QUIT button
        elseif y >= menuY + spacing*2 + buttonHeight*1.5 and y <= menuY + spacing*2 + buttonHeight*2.5 then
            game.menuSelection = 3
            love.event.quit()
            playSound(game.sounds, "confirm")
        end
    elseif game.state == "running" and game.paused then
        local menuY = love.graphics.getHeight() / 2
        local buttonHeight = 40
        local spacing = 20

        -- Check RESUME button
        if y >= menuY - buttonHeight/2 and y <= menuY + buttonHeight/2 then
            game.pauseSelection = 1
            game.paused = false
            playSound(game.sounds, "unpause")
        -- Check OPTIONS button
        elseif y >= menuY + spacing + buttonHeight/2 and y <= menuY + spacing + buttonHeight*1.5 then
            game.pauseSelection = 2
            game.previousState = "running"
            game.state = "options"
            game.paused = false
            playSound(game.sounds, "confirm")
        -- Check QUIT button
        elseif y >= menuY + spacing*2 + buttonHeight*1.5 and y <= menuY + spacing*2 + buttonHeight*2.5 then
            game.pauseSelection = 3
            game.state = "menu"
            game.paused = false
            playSound(game.sounds, "confirm")
        end
    elseif game.state == "options" then
        local centerY = love.graphics.getHeight() / 2
        local buttonHeight = 40
        local spacing = 20

        -- Check BACK button
        if y >= centerY + spacing*2 + buttonHeight*1.5 and y <= centerY + spacing*2 + buttonHeight*2.5 then
            settings.selectedOption = 3
            if game.previousState then
                game.state = game.previousState
                game.previousState = nil
            else
                game.state = "menu"
            end
            playSound(game.sounds, "back")
        end

        -- Check SFX Volume area
        if y >= centerY - buttonHeight/2 and y <= centerY + buttonHeight/2 then
            settings.selectedOption = 1
            -- Update volume based on x position
            local centerX = love.graphics.getWidth() / 2
            local sliderWidth = 200
            local sliderLeft = centerX + 50
            local sliderRight = sliderLeft + sliderWidth

            if x >= sliderLeft and x <= sliderRight then
                local volume = (x - sliderLeft) / sliderWidth
                settings.setSfxVolume(volume)
                playSound(game.sounds, "select")
            end
        end

        -- Check CRT Effect area
        if y >= centerY + spacing + buttonHeight/2 and y <= centerY + spacing + buttonHeight*1.5 then
            settings.selectedOption = 2
            local centerX = love.graphics.getWidth() / 2
            -- Left arrow area
            if x >= centerX + 50 and x <= centerX + 80 then
                settings.previousCrtEffect()
                playSound(game.sounds, "select")
            -- Right arrow area
            elseif x >= centerX + 250 and x <= centerX + 280 then
                settings.nextCrtEffect()
                playSound(game.sounds, "select")
            end
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
        local menuY = love.graphics.getHeight() / 2
        local buttonHeight = 40
        local spacing = 20

        -- Update menu selection based on mouse position
        if y >= menuY - buttonHeight/2 and y <= menuY + buttonHeight/2 then
            game.menuSelection = 1
        elseif y >= menuY + spacing + buttonHeight/2 and y <= menuY + spacing + buttonHeight*1.5 then
            game.menuSelection = 2
        elseif y >= menuY + spacing*2 + buttonHeight*1.5 and y <= menuY + spacing*2 + buttonHeight*2.5 then
            game.menuSelection = 3
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
        local centerY = love.graphics.getHeight() / 2
        local buttonHeight = 40
        local spacing = 20

        -- Update options selection based on mouse position
        if y >= centerY - buttonHeight/2 and y <= centerY + buttonHeight/2 then
            settings.selectedOption = 1
        elseif y >= centerY + spacing + buttonHeight/2 and y <= centerY + spacing + buttonHeight*1.5 then
            settings.selectedOption = 2
        elseif y >= centerY + spacing*2 + buttonHeight*1.5 and y <= centerY + spacing*2 + buttonHeight*2.5 then
            settings.selectedOption = 3
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