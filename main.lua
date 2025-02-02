function love.load()
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
        menuSelection = 1  -- New: default active menu option is 1
    }

    -- Spawn food only when the game starts running
    -- (We'll initialize it later when starting the game.)

    -- Load and setup CRT shader
    shader = love.graphics.newShader([[
        extern vec2 screen = vec2(800.0, 600.0);
        extern float curvature = 4.0;
        extern float scanlines = 800.0;
        extern float vignette_intensity = 0.2;

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
            // Apply screen curvature
            vec2 curved_uv = curve(uv);

            // Check if we're outside the screen
            if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0)
                return vec4(0.0, 0.0, 0.0, 1.0);

            // Sample the texture
            vec4 texcolor = Texel(tex, curved_uv);

            // Apply scanlines
            float scanline = sin(curved_uv.y * scanlines) * 0.04;
            texcolor -= scanline;

            // Apply vignette
            float vignette = length(vec2(0.5, 0.5) - curved_uv) * vignette_intensity;
            texcolor -= vignette;

            return texcolor * color;
        }
    ]])

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
    if game.state ~= "running" then
        return  -- Only run game logic when state is "running"
    end

    game.timer = game.timer + dt

    -- Track how long any arrow key is held.
    if love.keyboard.isDown("up", "down", "left", "right") then
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
        -- Draw the menu screen background
        love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1)
        love.graphics.clear(0.1, 0.1, 0.1, 1)

        -- Draw Title
        love.graphics.setFont(gameOverFont)
        local title = "Zmijice"
        local titleWidth = gameOverFont:getWidth(title)
        local titleX = (love.graphics.getWidth() - titleWidth) / 2
        local titleY = love.graphics.getHeight() / 3
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(title, titleX, titleY)

        -- Draw buttons for Play and Exit
        local centerX = love.graphics.getWidth() / 2
        local btnY = titleY + gameOverFont:getHeight() + 40

        local playBtn = {x = centerX - 120, y = btnY, width = 100, height = 40}
        local exitBtn = {x = centerX + 20, y = btnY, width = 100, height = 40}

        love.graphics.setFont(scoreFont)
        if game.menuSelection == 1 then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", playBtn.x, playBtn.y, playBtn.width, playBtn.height)
        if game.menuSelection == 2 then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", exitBtn.x, exitBtn.y, exitBtn.width, exitBtn.height)

        -- Draw button borders
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", playBtn.x, playBtn.y, playBtn.width, playBtn.height)
        love.graphics.rectangle("line", exitBtn.x, exitBtn.y, exitBtn.width, exitBtn.height)

        local playText = "Play"
        local exitText = "Exit"
        local playTextX = playBtn.x + (playBtn.width - scoreFont:getWidth(playText)) / 2
        local exitTextX = exitBtn.x + (exitBtn.width - scoreFont:getWidth(exitText)) / 2
        local btnTextY = playBtn.y + (playBtn.height - scoreFont:getHeight()) / 2
        love.graphics.print(playText, playTextX, btnTextY)
        love.graphics.print(exitText, exitTextX, btnTextY)
        return
    end

    -- When not in menu, draw using the canvas
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.1, 0.1, 0.1, 1) -- Use a dark gray background

    -- Draw snake
    for i, segment in ipairs(game.snake) do
        -- Calculate a slight color variation based on the segment index and time.
        local factor = 0.9 + 0.1 * math.sin(love.timer.getTime() * 3 + i)
        love.graphics.setColor(0, factor, 0)
        love.graphics.rectangle('fill',
            (segment.x - 1) * game.cell_size,
            (segment.y - 1) * game.cell_size,
            game.cell_size - 2,
            game.cell_size - 2)
    end

    -- Draw food (with blinking effect if special)
    if game.food.special then
        local alpha = 0.5 + 0.5 * math.abs(math.sin(love.timer.getTime()*10))
        love.graphics.setColor(1, 0, 0, alpha)  -- Special food: red (with blinking)
    else
        love.graphics.setColor(0, 0, 1)  -- Regular food: blue
    end
    love.graphics.rectangle('fill',
        (game.food.x - 1) * game.cell_size,
        (game.food.y - 1) * game.cell_size,
        game.cell_size - 2,
        game.cell_size - 2)

    -- Draw the main border on top
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 0, 0, game.grid_size * game.cell_size, game.grid_size * game.cell_size)

    -- Reset canvas and apply shader
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(shader)
    shader:send('screen', {love.graphics.getWidth(), love.graphics.getHeight()})
    love.graphics.draw(canvas)
    love.graphics.setShader()

    -- Display score at top left
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. game.score, 10, 10)

    -- If game is over, display a game over message centered on the screen
    if game.over then
        -- Revamped game over text in two lines
        local gameOverMsg = "GAME OVER"
        local scoreMsg = "Final Score: " .. game.score

        -- Draw "GAME OVER" line using gameOverFont
        love.graphics.setFont(gameOverFont)
        local gameOverWidth = gameOverFont:getWidth(gameOverMsg)
        local gameOverHeight = gameOverFont:getHeight(gameOverMsg)
        local x = (love.graphics.getWidth() - gameOverWidth) / 2
        local y = (love.graphics.getHeight() - gameOverHeight) / 2 - 30
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(gameOverMsg, x, y)

        -- Draw "Final Score: X" line using scoreFont
        love.graphics.setFont(scoreFont)
        local scoreWidth = scoreFont:getWidth(scoreMsg)
        local scoreX = (love.graphics.getWidth() - scoreWidth) / 2
        local scoreY = y + gameOverHeight + 10
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(scoreMsg, scoreX, scoreY)

        -- Draw clickable buttons for "New Game" and "Exit"
        local centerX = love.graphics.getWidth() / 2
        local btnY = scoreY + scoreFont:getHeight() + 20

        local newGameBtn = {x = centerX - 120, y = btnY, width = 100, height = 40}
        local exitBtn = {x = centerX + 20, y = btnY, width = 100, height = 40}

        love.graphics.setFont(scoreFont)
        if game.menuSelection == 1 then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", newGameBtn.x, newGameBtn.y, newGameBtn.width, newGameBtn.height)
        if game.menuSelection == 2 then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", exitBtn.x, exitBtn.y, exitBtn.width, exitBtn.height)

        -- Button borders
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", newGameBtn.x, newGameBtn.y, newGameBtn.width, newGameBtn.height)
        love.graphics.rectangle("line", exitBtn.x, exitBtn.y, exitBtn.width, exitBtn.height)

        -- Button texts
        local newGameText = "New Game"
        local exitText = "Exit"
        local newGameTextWidth = scoreFont:getWidth(newGameText)
        local exitTextWidth = scoreFont:getWidth(exitText)
        local newGameTextX = newGameBtn.x + (newGameBtn.width - newGameTextWidth) / 2
        local exitTextX = exitBtn.x + (exitBtn.width - exitTextWidth) / 2
        local btnTextY = newGameBtn.y + (newGameBtn.height - scoreFont:getHeight()) / 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(newGameText, newGameTextX, btnTextY)
        love.graphics.print(exitText, exitTextX, btnTextY)

        love.graphics.setFont(scoreFont)  -- revert to scoreFont if necessary
    end
end

function love.keypressed(key)
    if game.state == "menu" then
        if key == "up" or key == "w" then
            game.menuSelection = game.menuSelection - 1
            if game.menuSelection < 1 then game.menuSelection = 2 end
        elseif key == "down" or key == "s" then
            game.menuSelection = game.menuSelection + 1
            if game.menuSelection > 2 then game.menuSelection = 1 end
        elseif key == "return" or key == "enter" then
            if game.menuSelection == 1 then
                resetGame()
            elseif game.menuSelection == 2 then
                love.event.quit()
            end
        elseif key == "escape" or key == "q" then
            love.event.quit()
        end
    elseif game.over then
        if key == "up" or key == "w" then
            game.menuSelection = game.menuSelection - 1
            if game.menuSelection < 1 then game.menuSelection = 2 end
        elseif key == "down" or key == "s" then
            game.menuSelection = game.menuSelection + 1
            if game.menuSelection > 2 then game.menuSelection = 1 end
        elseif key == "return" or key == "enter" then
            if game.menuSelection == 1 then
                resetGame()
            elseif game.menuSelection == 2 then
                love.event.quit()
            end
        elseif key == "escape" or key == "q" then
            love.event.quit()
        end
    else
        -- In-game, update queued direction as before.
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

    -- Check for food collision
    if new_head.x == game.food.x and new_head.y == game.food.y then
        table.insert(game.snake, 1, new_head)
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
        table.insert(game.snake, 1, new_head)
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
        arrowHoldTime = 0, -- Reset arrowHoldTime
        state = "running",  -- Set state to "running" on new game
        menuSelection = 1  -- Reset menuSelection
    }
    spawnFood(false)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if game.state == "menu" then
            local centerX = love.graphics.getWidth() / 2
            local btnY = (love.graphics.getHeight() / 3) + gameOverFont:getHeight() + 40  -- same as drawn in menu
            local playBtn = {x = centerX - 120, y = btnY, width = 100, height = 40}
            local exitBtn = {x = centerX + 20, y = btnY, width = 100, height = 40}
            if x >= playBtn.x and x <= playBtn.x + playBtn.width and
               y >= playBtn.y and y <= playBtn.y + playBtn.height then
                resetGame()
            elseif x >= exitBtn.x and x <= exitBtn.x + exitBtn.width and
               y >= exitBtn.y and y <= exitBtn.y + exitBtn.height then
                love.event.quit()
            end
        elseif game.over then
            local centerX = love.graphics.getWidth() / 2
            local btnY = (love.graphics.getHeight() - scoreFont:getHeight()) / 2 + 20 + gameOverFont:getHeight()
            local newGameBtn = {x = centerX - 120, y = btnY, width = 100, height = 40}
            local exitBtn = {x = centerX + 20, y = btnY, width = 100, height = 40}
            if x >= newGameBtn.x and x <= newGameBtn.x + newGameBtn.width and
               y >= newGameBtn.y and y <= newGameBtn.y + newGameBtn.height then
                resetGame()
            elseif x >= exitBtn.x and x <= exitBtn.x + exitBtn.width and
               y >= exitBtn.y and y <= exitBtn.y + exitBtn.height then
                love.event.quit()
            end
        end
    end
end