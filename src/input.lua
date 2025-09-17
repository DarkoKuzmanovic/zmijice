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

function input.load()
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
            local pause = require("src/ui/pause")
            if key == "up" or key == "w" then
                pause.keypressed(game, key)
                playSound(game.sounds, "select")
            elseif key == "down" or key == "s" then
                pause.keypressed(game, key)
                playSound(game.sounds, "select")
            elseif key == "return" or key == "space" then
                pause.keypressed(game, key)
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

        options.keypressed(game, settings, key)
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
    if game.state == "running" and game.paused then game.pauseSelection = 0 end

    if button ~= 1 then return end

    if game.state == "menu" then
        menu.mousepressed(game, x, y, button)
        return
    end

    if game.state == "running" and game.paused then
        local pause = require("src/ui/pause")
        pause.mousepressed(game, x, y, button)
        return
    elseif game.state == "options" then
        options.mousepressed(game, settings, x, y, button)
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
        -- Menu doesn't currently have a mousemoved function
    elseif game.state == "running" and game.paused then
        local pause = require("src/ui/pause")
        pause.mousemoved(game, x, y)
    elseif game.state == "options" then
        -- Options screen handles its own mouse movement
    elseif game.state == "gameOver" and not game.nameEntry.active then
        -- Game over screen handles its own mouse movement
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