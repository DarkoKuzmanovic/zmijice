function love.load()
    -- Initialize high scores table
    highScores = loadHighScores()

    -- Load sound effects
    sounds = {
        food = love.audio.newSource("food.wav", "static"),
        special = love.audio.newSource("special.wav", "static"),
        die = love.audio.newSource("die.wav", "static")
    }

    -- Load food images
    foodImages = {
        regular = love.graphics.newImage("food.png"),
        special = love.graphics.newImage("special.png")
    }

    -- Initialize game state
    game = {
        grid_size = 20,
        cell_size = 30,
        snake = {
            {x = 10, y = 10} -- Starting position
        },
        direction = {x = 1, y = 0},
        pendingDirection = {x = 1, y = 0},  -- New: queued direction change
        food = {},
        timer = 0,
        move_delay = 0.15, -- Snake movement speed
        score = 0,         -- track the score
        over = false,      -- game over flag
        arrowHoldTime = 0, -- track how long an arrow key is held
        state = "menu",    -- Start in the menu state
        menuSelection = 1,  -- New: default active menu option is 1
        nameEntry = {      -- New: for high score name entry
            active = false,
            name = "AAA",
            position = 1
        },
        mouseX = 0,        -- Track mouse position
        mouseY = 0
    }

    -- Spawn food only when the game starts running
    -- (We'll initialize it later when starting the game.)

    -- Load and setup CRT shader
    shader = love.graphics.newShader([[
        extern vec2 screen;
        extern float curvature;
        extern float scanlines;
        extern float vignette_intensity;

        vec2 curve(vec2 uv)
        {
            uv = (uv - 0.5) * 2.0;
            uv *= 1.1;
            vec2 offset = uv.yx / vec2(screen.y/screen.x, 1.0);
            uv.x *= 1.0 + pow((abs(offset.y) / curvature), 2.0);
            uv.y *= 1.0 + pow((abs(offset.x) / curvature), 2.0);
            uv = (uv / 2.0) + 0.5;
            return uv;
        }

        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
        {
            vec2 curved_uv = curve(uv);

            if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0)
                return vec4(0.0, 0.0, 0.0, 1.0);

            vec4 texcolor = Texel(tex, curved_uv);

            float scanline = sin(curved_uv.y * scanlines) * 0.02;
            texcolor -= scanline;

            float vignette = length(vec2(0.5, 0.5) - curved_uv) * vignette_intensity;
            texcolor -= vignette;

            return texcolor * color;
        }
    ]])

    -- Set shader variables
    shader:send('screen', {love.graphics.getWidth(), love.graphics.getHeight()})
    shader:send('curvature', 10.0)
    shader:send('scanlines', 800.0)
    shader:send('vignette_intensity', 0.1)

    -- Create canvas for post-processing
    canvas = love.graphics.newCanvas()
    -- Load retro fonts (ensure "VGA New.ttf" is in your project folder)
    scoreFont = love.graphics.newFont("VGA New.ttf", 16)
    gameOverFont = love.graphics.newFont("VGA New.ttf", 32)
    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    scoreFont:setFilter("nearest", "nearest")
    gameOverFont:setFilter("nearest", "nearest")
end

function love.update(dt)
    -- Update mouse position
    game.mouseX, game.mouseY = love.mouse.getPosition()

    if game.state ~= "running" then
        return  -- Only run game logic when state is "running"
    end

    game.timer = game.timer + dt

    -- Track how long any arrow key is held.
    if love.keyboard.isDown("up", "down", "left", "right", "w", "a", "s", "d") then
        game.arrowHoldTime = game.arrowHoldTime + dt
    else
        game.arrowHoldTime = 0
    end

    -- Determine the movement delay; speed up only if arrow pressed for more than 1 sec.
    local delay = game.move_delay
    if game.arrowHoldTime >= 1 then
        delay = game.move_delay / 1.5  -- 50% faster movement
    end

    -- If there is a queued direction change and enough time has passed (half delay), process it immediately.
    if (game.pendingDirection.x ~= game.direction.x or game.pendingDirection.y ~= game.direction.y) and game.timer >= (delay / 2) then
         game.direction = game.pendingDirection  -- apply the pending direction
         game.timer = 0
         moveSnake()
         return
    end

    -- Otherwise, if the full delay has passed, process a move.
    if game.timer >= delay then
         game.direction = game.pendingDirection  -- always update to the queued direction
         game.timer = 0
         moveSnake()
    end

    if game.food and game.food.special then
         game.food.specialTimer = game.food.specialTimer - dt
         if game.food.specialTimer <= 0 then
              spawnFood(false)
         end
    end
end

function love.draw()
    if game.state == "menu" then
        -- Draw the menu screen with LCD style
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

        local playBtn = {x = centerX - btnWidth/2, y = btnY, width = btnWidth, height = btnHeight}
        local scoresBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
        local exitBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}

        love.graphics.setFont(scoreFont)

        -- Helper function to check if mouse is over a button
        local function isMouseOver(btn)
            return game.mouseX >= btn.x and game.mouseX <= btn.x + btn.width and
                   game.mouseY >= btn.y and game.mouseY <= btn.y + btn.height
        end

        -- Draw button backgrounds and borders
        local buttons = {
            {btn = playBtn, text = "PLAY", selected = game.menuSelection == 1},
            {btn = scoresBtn, text = "HIGH SCORES", selected = game.menuSelection == 2},
            {btn = exitBtn, text = "EXIT", selected = game.menuSelection == 3}
        }

        for _, button in ipairs(buttons) do
            -- Draw darker background for selected button or when hovered
            love.graphics.setColor(0.2, 0.2, 0.2)
            if button.selected or isMouseOver(button.btn) then
                love.graphics.rectangle('fill', button.btn.x, button.btn.y, button.btn.width, button.btn.height, 4, 4)
                love.graphics.setColor(0.75, 0.85, 0.65) -- LCD green for text
            else
                love.graphics.rectangle('line', button.btn.x, button.btn.y, button.btn.width, button.btn.height, 4, 4)
                love.graphics.setColor(0.2, 0.2, 0.2) -- Dark for text
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

        -- Apply shader effects
        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader(shader)
        love.graphics.draw(canvas)
        love.graphics.setShader()
        return

    elseif game.state == "highscores" then
        -- Draw high scores with LCD style
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

        -- Draw Title
        love.graphics.setFont(gameOverFont)
        local title = "HIGH SCORES"
        local titleWidth = gameOverFont:getWidth(title)
        local titleX = (love.graphics.getWidth() - titleWidth) / 2
        local titleY = 50
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.print(title, titleX, titleY)

        -- Draw scores
        love.graphics.setFont(scoreFont)
        local startY = titleY + gameOverFont:getHeight() + 20
        local spacing = 30

        for i, score in ipairs(highScores) do
            local text = string.format("%2d. %s %5d", i, score.name, score.score)
            local textWidth = scoreFont:getWidth(text)
            local x = (love.graphics.getWidth() - textWidth) / 2
            love.graphics.print(text, x, startY + (i-1) * spacing)
        end

        -- Draw "Back" button with LCD style
        local backBtn = {
            x = (love.graphics.getWidth() - 140) / 2,
            y = startY + 11 * spacing,
            width = 140,
            height = 40
        }

        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", backBtn.x, backBtn.y, backBtn.width, backBtn.height, 4, 4)
        love.graphics.setColor(0.75, 0.85, 0.65)
        local backText = "BACK"
        local backTextX = backBtn.x + (backBtn.width - scoreFont:getWidth(backText)) / 2
        local backTextY = backBtn.y + (backBtn.height - scoreFont:getHeight()) / 2
        love.graphics.print(backText, backTextX, backTextY)

        -- Apply shader effects
        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader(shader)
        love.graphics.draw(canvas)
        love.graphics.setShader()
        return

    elseif game.nameEntry.active then
        -- Draw name entry with LCD style
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

        -- Draw Title
        love.graphics.setFont(gameOverFont)
        local title = "NEW HIGH SCORE!"
        local titleWidth = gameOverFont:getWidth(title)
        local titleX = (love.graphics.getWidth() - titleWidth) / 2
        local titleY = love.graphics.getHeight() / 3
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.print(title, titleX, titleY)

        -- Draw score
        love.graphics.setFont(scoreFont)
        local scoreText = string.format("SCORE: %04d", game.score)
        local scoreWidth = scoreFont:getWidth(scoreText)
        local scoreX = (love.graphics.getWidth() - scoreWidth) / 2
        love.graphics.print(scoreText, scoreX, titleY + gameOverFont:getHeight() + 20)

        -- Draw name entry boxes
        local nameY = titleY + gameOverFont:getHeight() + 60
        local boxWidth = 40
        local boxSpacing = 10
        local totalWidth = (boxWidth * 3) + (boxSpacing * 2)
        local startX = (love.graphics.getWidth() - totalWidth) / 2

        for i = 1, 3 do
            local boxX = startX + (i-1) * (boxWidth + boxSpacing)
            local char = game.nameEntry.name:sub(i,i)

            -- Draw box
            love.graphics.setColor(0.2, 0.2, 0.2)
            if i == game.nameEntry.position then
                love.graphics.rectangle('fill', boxX, nameY, boxWidth, boxWidth, 4, 4)
                love.graphics.setColor(0.75, 0.85, 0.65)
            else
                love.graphics.rectangle('line', boxX, nameY, boxWidth, boxWidth, 4, 4)
            end

            -- Draw character
            local charWidth = scoreFont:getWidth(char)
            local charX = boxX + (boxWidth - charWidth) / 2
            local charY = nameY + (boxWidth - scoreFont:getHeight()) / 2
            love.graphics.print(char, charX, charY)
        end

        -- Draw instructions
        love.graphics.setColor(0.2, 0.2, 0.2)
        local instrText = "UP/DOWN: CHANGE  LEFT/RIGHT: MOVE  ENTER: OK"
        local instrWidth = scoreFont:getWidth(instrText)
        local instrX = (love.graphics.getWidth() - instrWidth) / 2
        love.graphics.print(instrText, instrX, nameY + boxWidth + 30)

        -- Apply shader effects
        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader(shader)
        love.graphics.draw(canvas)
        love.graphics.setShader()
        return
    end

    -- When not in menu, draw using the canvas
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background color

    -- Draw snake
    for _, segment in ipairs(game.snake) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill',
            (segment.x - 1) * game.cell_size + 1,
            (segment.y - 1) * game.cell_size + 1,
            game.cell_size - 2,
            game.cell_size - 2,
            4, 4)  -- Added corner radius
    end

    -- Draw food using the appropriate image
    local foodX = (game.food.x - 1) * game.cell_size + 1
    local foodY = (game.food.y - 1) * game.cell_size + 1
    local blinkAlpha = 1
    if game.food and game.food.special then
        blinkAlpha = math.abs(math.sin(love.timer.getTime() * 10))
        love.graphics.setColor(1, 1, 1, blinkAlpha)
        love.graphics.draw(foodImages.special, foodX, foodY)
    else
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(foodImages.regular, foodX, foodY)
    end

    -- Draw the main border
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0,
        game.grid_size * game.cell_size,
        game.grid_size * game.cell_size)

    -- Reset canvas and apply shader
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(shader)
    love.graphics.draw(canvas)
    love.graphics.setShader()

    -- Display score with LCD style
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0.75, 0.85, 0.65)  -- Changed to LCD green color
    love.graphics.print("SCORE: " .. string.format("%04d", game.score), 10, 10)

    -- If game is over, display game over screen with LCD style
    if game.over then
        -- Play death sound only when transitioning to game over screen
        if not game.deathSoundPlayed then
            sounds.die:play()
            game.deathSoundPlayed = true
        end

        love.graphics.setCanvas(canvas)
        love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background

        -- Draw "GAME OVER" text
        love.graphics.setFont(gameOverFont)
        local gameOverMsg = "GAME OVER"
        local gameOverWidth = gameOverFont:getWidth(gameOverMsg)
        local x = (love.graphics.getWidth() - gameOverWidth) / 2
        local y = love.graphics.getHeight() / 3
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.print(gameOverMsg, x, y)

        -- Draw final score
        love.graphics.setFont(scoreFont)
        local scoreMsg = string.format("FINAL SCORE: %04d", game.score)
        local scoreWidth = scoreFont:getWidth(scoreMsg)
        local scoreX = (love.graphics.getWidth() - scoreWidth) / 2
        local scoreY = y + gameOverFont:getHeight() + 20
        love.graphics.print(scoreMsg, scoreX, scoreY)

        -- Draw buttons
        local btnY = scoreY + scoreFont:getHeight() + 40
        local btnWidth = 140
        local btnHeight = 40
        local btnSpacing = 20

        local newGameBtn = {x = (love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2, y = btnY, width = btnWidth, height = btnHeight}
        local exitBtn = {x = newGameBtn.x + btnWidth + btnSpacing, y = btnY, width = btnWidth, height = btnHeight}

        -- Helper function to check if mouse is over a button
        local function isMouseOver(btn)
            return game.mouseX >= btn.x and game.mouseX <= btn.x + btn.width and
                   game.mouseY >= btn.y and game.mouseY <= btn.y + btn.height
        end

        local buttons = {
            {btn = newGameBtn, text = "NEW GAME", selected = game.menuSelection == 1},
            {btn = exitBtn, text = "EXIT", selected = game.menuSelection == 2}
        }

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

        -- Apply shader effects
        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader(shader)
        love.graphics.draw(canvas)
        love.graphics.setShader()
    end
end

function love.keypressed(key)
    if game.state == "menu" then
        if key == "up" or key == "w" then
            game.menuSelection = game.menuSelection - 1
            if game.menuSelection < 1 then game.menuSelection = 3 end
        elseif key == "down" or key == "s" then
            game.menuSelection = game.menuSelection + 1
            if game.menuSelection > 3 then game.menuSelection = 1 end
        elseif key == "return" or key == "enter" then
            if game.menuSelection == 1 then
                resetGame()
            elseif game.menuSelection == 2 then
                game.state = "highscores"
            elseif game.menuSelection == 3 then
                love.event.quit()
            end
        elseif key == "escape" or key == "q" then
            love.event.quit()
        end
    elseif game.state == "highscores" then
        if key == "escape" or key == "return" or key == "enter" or key == "backspace" then
            game.state = "menu"
        end
    elseif game.nameEntry.active then
        if key == "up" or key == "w" then
            -- Get current character and increment it
            local char = string.byte(game.nameEntry.name:sub(game.nameEntry.position, game.nameEntry.position))
            char = char + 1
            if char > string.byte('Z') then char = string.byte('A') end

            -- Update the character at the current position
            game.nameEntry.name = game.nameEntry.name:sub(1, game.nameEntry.position - 1) ..
                                string.char(char) ..
                                game.nameEntry.name:sub(game.nameEntry.position + 1)

        elseif key == "down" or key == "s" then
            -- Get current character and decrement it
            local char = string.byte(game.nameEntry.name:sub(game.nameEntry.position, game.nameEntry.position))
            char = char - 1
            if char < string.byte('A') then char = string.byte('Z') end

            -- Update the character at the current position
            game.nameEntry.name = game.nameEntry.name:sub(1, game.nameEntry.position - 1) ..
                                string.char(char) ..
                                game.nameEntry.name:sub(game.nameEntry.position + 1)

        elseif key == "left" or key == "a" then
            game.nameEntry.position = game.nameEntry.position - 1
            if game.nameEntry.position < 1 then game.nameEntry.position = 3 end

        elseif key == "right" or key == "d" then
            game.nameEntry.position = game.nameEntry.position + 1
            if game.nameEntry.position > 3 then game.nameEntry.position = 1 end

        elseif key == "return" or key == "enter" then
            -- Save the high score and return to menu
            addHighScore(game.nameEntry.name, game.score)
            game.nameEntry.active = false
            game.state = "menu"
        end
    elseif game.over then
        if key == "up" or key == "w" or key == "left" or key == "a" then
            game.menuSelection = game.menuSelection - 1
            if game.menuSelection < 1 then game.menuSelection = 2 end
        elseif key == "down" or key == "s" or key == "right" or key == "d" then
            game.menuSelection = game.menuSelection + 1
            if game.menuSelection > 2 then game.menuSelection = 1 end
        elseif key == "return" or key == "enter" then
            if isHighScore(game.score) then
                -- Initialize name entry
                game.nameEntry.active = true
                game.nameEntry.name = "AAA"
                game.nameEntry.position = 1
            else
                if game.menuSelection == 1 then
                    resetGame()
                elseif game.menuSelection == 2 then
                    love.event.quit()
                end
            end
        elseif key == "escape" or key == "q" then
            love.event.quit()
        end
    else
        -- In-game controls
        if (key == 'up' or key == 'w') and game.pendingDirection.y == 0 then
            game.pendingDirection = {x = 0, y = -1}
        elseif (key == 'down' or key == 's') and game.pendingDirection.y == 0 then
            game.pendingDirection = {x = 0, y = 1}
        elseif (key == 'left' or key == 'a') and game.pendingDirection.x == 0 then
            game.pendingDirection = {x = -1, y = 0}
        elseif (key == 'right' or key == 'd') and game.pendingDirection.x == 0 then
            game.pendingDirection = {x = 1, y = 0}
        end
    end
end

function moveSnake()
    local head = game.snake[1]
    local new_head = {
        x = head.x + game.direction.x,
        y = head.y + game.direction.y
    }

    -- Check for collisions with walls
    if new_head.x < 1 or new_head.x > game.grid_size or
       new_head.y < 1 or new_head.y > game.grid_size then
        game.over = true  -- Set game over state instead of quitting
        return
    end

    -- Check for collisions with self
    for _, segment in ipairs(game.snake) do
        if new_head.x == segment.x and new_head.y == segment.y then
            game.over = true  -- Set game over state instead of quitting
            return
        end
    end

    -- Always insert the new head first
    table.insert(game.snake, 1, new_head)

    -- Check for food collision
    if new_head.x == game.food.x and new_head.y == game.food.y then
        -- Play appropriate eat sound
        if game.food.special then
            sounds.special:stop()  -- Stop any currently playing instance
            sounds.special:play()  -- Play the special food sound
        else
            sounds.food:stop()  -- Stop any currently playing instance
            sounds.food:play()  -- Play the regular food sound
        end

        if game.food.special then
            game.score = game.score + 3  -- Special food is worth 3 points
        else
            game.score = game.score + 1
        end

        -- After eating food, spawn special food if score is a multiple of 10; else spawn normal food.
        if game.score % 10 == 0 then
            spawnFood(true)
        else
            spawnFood(false)
        end
    else
        -- Remove tail only if food wasn't eaten
        table.remove(game.snake)
    end
end

function spawnFood(special)
    local valid = false
    local new_food = {}
    special = special or false

    while not valid do
        valid = true
        new_food = {
            x = love.math.random(1, game.grid_size),
            y = love.math.random(1, game.grid_size),
            special = special
        }

        if special then
            new_food.specialTimer = 5  -- Food lasts 5 seconds
        end

        for _, segment in ipairs(game.snake) do
            if new_food.x == segment.x and new_food.y == segment.y then
                valid = false
                break
            end
        end
    end

    game.food = new_food
end

function resetGame()
    game = {
        grid_size = 20,
        cell_size = 30,
        snake = {
            {x = 10, y = 10} -- Starting position
        },
        direction = {x = 1, y = 0},
        pendingDirection = {x = 1, y = 0},  -- Reset pending direction as well
        food = {},
        timer = 0,
        move_delay = 0.15, -- Snake movement speed
        score = 0,         -- Reset the score
        over = false,      -- Reset game over flag
        deathSoundPlayed = false,  -- Add flag to track if death sound has been played
        arrowHoldTime = 0, -- Reset arrowHoldTime
        state = "running",  -- Set state to "running" on new game
        menuSelection = 1,  -- Reset menuSelection
        nameEntry = {      -- Reset nameEntry
            active = false,
            name = "AAA",
            position = 1
        },
        mouseX = 0,        -- Reset mouse position
        mouseY = 0
    }
    spawnFood(false)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if game.state == "menu" then
            local centerX = love.graphics.getWidth() / 2
            local titleY = love.graphics.getHeight() / 4
            local btnY = titleY + gameOverFont:getHeight() + 40
            local btnSpacing = 50
            local btnWidth = 140
            local btnHeight = 40

            local playBtn = {x = centerX - btnWidth/2, y = btnY, width = btnWidth, height = btnHeight}
            local scoresBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing, width = btnWidth, height = btnHeight}
            local exitBtn = {x = centerX - btnWidth/2, y = btnY + btnSpacing * 2, width = btnWidth, height = btnHeight}

            if x >= playBtn.x and x <= playBtn.x + playBtn.width and
               y >= playBtn.y and y <= playBtn.y + playBtn.height then
                resetGame()
            elseif x >= scoresBtn.x and x <= scoresBtn.x + scoresBtn.width and
                   y >= scoresBtn.y and y <= scoresBtn.y + scoresBtn.height then
                game.state = "highscores"
            elseif x >= exitBtn.x and x <= exitBtn.x + exitBtn.width and
                   y >= exitBtn.y and y <= exitBtn.y + exitBtn.height then
                love.event.quit()
            end
        elseif game.state == "highscores" then
            -- Handle back button click
            local startY = 50 + gameOverFont:getHeight() + 20
            local backBtn = {
                x = (love.graphics.getWidth() - 140) / 2,
                y = startY + 11 * 30,
                width = 140,
                height = 40
            }

            if x >= backBtn.x and x <= backBtn.x + backBtn.width and
               y >= backBtn.y and y <= backBtn.y + backBtn.height then
                game.state = "menu"
            end
        elseif game.over and not game.nameEntry.active then
            local btnY = (love.graphics.getHeight() / 3) + gameOverFont:getHeight() + scoreFont:getHeight() + 60
            local btnWidth = 140
            local btnHeight = 40
            local btnSpacing = 20

            local newGameBtn = {x = (love.graphics.getWidth() - btnWidth*2 - btnSpacing) / 2, y = btnY, width = btnWidth, height = btnHeight}
            local exitBtn = {x = newGameBtn.x + btnWidth + btnSpacing, y = btnY, width = btnWidth, height = btnHeight}

            if x >= newGameBtn.x and x <= newGameBtn.x + newGameBtn.width and
               y >= newGameBtn.y and y <= newGameBtn.y + newGameBtn.height then
                if isHighScore(game.score) then
                    -- Initialize name entry
                    game.nameEntry.active = true
                    game.nameEntry.name = "AAA"
                    game.nameEntry.position = 1
                else
                    resetGame()
                end
            elseif x >= exitBtn.x and x <= exitBtn.x + exitBtn.width and
                   y >= exitBtn.y and y <= exitBtn.y + exitBtn.height then
                love.event.quit()
            end
        end
    end
end

-- High score related functions
function loadHighScores()
    local scores = {}
    local file = io.open("highscores.txt", "r")
    if file then
        for line in file:lines() do
            local name, score = line:match("(%w+):(%d+)")
            if name and score then
                table.insert(scores, {name = name, score = tonumber(score)})
            end
        end
        file:close()
    end

    -- If we don't have 10 scores, fill with defaults
    while #scores < 10 do
        table.insert(scores, {name = "AAA", score = 0})
    end

    -- Sort scores
    table.sort(scores, function(a, b) return a.score > b.score end)
    return scores
end

function saveHighScores()
    local file = io.open("highscores.txt", "w")
    if file then
        for _, score in ipairs(highScores) do
            file:write(string.format("%s:%d\n", score.name, score.score))
        end
        file:close()
    end
end

function isHighScore(score)
    return score > highScores[#highScores].score
end

function addHighScore(name, score)
    table.insert(highScores, {name = name, score = score})
    table.sort(highScores, function(a, b) return a.score > b.score end)
    if #highScores > 10 then
        table.remove(highScores, 11)
    end
    saveHighScores()
end