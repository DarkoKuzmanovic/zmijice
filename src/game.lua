local game = {
    grid_size = 20,
    cell_size = 30,
    snake = {
        {x = 10, y = 10} -- Starting position
    },
    direction = {x = 1, y = 0},
    pendingDirection = {x = 1, y = 0},
    food = {},
    timer = 0,
    move_delay = 0.15,
    score = 0,
    over = false,
    arrowHoldTime = 0,
    state = "menu",
    menuSelection = 1,
    nameEntry = {
        active = false,
        name = "AAA",
        position = 1
    },
    mouseX = 0,
    mouseY = 0,
    sounds = {},
    foodImages = {},
    deathSoundPlayed = false,
    paused = false,
    pauseSelection = 1,
    previousState = nil
}

function game.loadAssets()
    -- Load sound effects
    local selectSound = love.audio.newSource("assets/audio/select.wav", "static")
    game.sounds = {
        food = love.audio.newSource("assets/audio/food.wav", "static"),
        special = love.audio.newSource("assets/audio/special.wav", "static"),
        die = love.audio.newSource("assets/audio/die.wav", "static"),
        select = selectSound,
        confirm = selectSound,
        back = selectSound,
        pause = selectSound,
        unpause = selectSound
    }

    -- Load food images
    game.foodImages = {
        regular = love.graphics.newImage("assets/images/food.png"),
        special = love.graphics.newImage("assets/images/special.png")
    }
end

function game.reset()
    game.snake = {{x = 10, y = 10}}
    game.direction = {x = 1, y = 0}
    game.pendingDirection = {x = 1, y = 0}
    game.food = {}
    game.timer = 0
    game.score = 0
    game.over = false
    game.deathSoundPlayed = false
    game.arrowHoldTime = 0
    game.state = "running"
    game.menuSelection = 1
    game.nameEntry = {
        active = false,
        name = "AAA",
        position = 1
    }
    game.mouseX = 0
    game.mouseY = 0
    game.paused = false
    game.pauseSelection = 1
    game.previousState = nil
    game.spawnFood(false)
end

function game.moveSnake()
    local head = game.snake[1]
    local new_head = {
        x = head.x + game.direction.x,
        y = head.y + game.direction.y
    }

    -- Check for collisions with walls
    if new_head.x < 1 or new_head.x > game.grid_size or
       new_head.y < 1 or new_head.y > game.grid_size then
        game.over = true
        game.state = "gameOver"
        return
    end

    -- Check for collisions with self
    for _, segment in ipairs(game.snake) do
        if new_head.x == segment.x and new_head.y == segment.y then
            game.over = true
            game.state = "gameOver"
            return
        end
    end

    -- Always insert the new head first
    table.insert(game.snake, 1, new_head)

    -- Check for food collision
    if new_head.x == game.food.x and new_head.y == game.food.y then
        -- Play appropriate eat sound
        if game.food.special then
            game.sounds.special:stop()
            game.sounds.special:play()
        else
            game.sounds.food:stop()
            game.sounds.food:play()
        end

        if game.food.special then
            game.score = game.score + 3
        else
            game.score = game.score + 1
        end

        -- After eating food, spawn special food if score is a multiple of 10; else spawn normal food.
        if game.score % 10 == 0 then
            game.spawnFood(true)
        else
            game.spawnFood(false)
        end
    else
        -- Remove tail only if food wasn't eaten
        table.remove(game.snake)
    end
end

function game.spawnFood(special)
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

function game.update(dt)
    -- Update mouse position
    game.mouseX, game.mouseY = love.mouse.getPosition()

    if game.state ~= "running" then
        return
    end

    if game.paused then
        return
    end

    game.timer = game.timer + dt

    -- Track how long any arrow key is held
    if love.keyboard.isDown("up", "down", "left", "right", "w", "a", "s", "d") then
        game.arrowHoldTime = game.arrowHoldTime + dt
    else
        game.arrowHoldTime = 0
    end

    -- Determine the movement delay; speed up only if arrow pressed for more than 1 sec
    local delay = game.move_delay
    if game.arrowHoldTime >= 1 then
        delay = game.move_delay / 1.5  -- 50% faster movement
    end

    -- If there is a queued direction change and enough time has passed (half delay), process it immediately
    if (game.pendingDirection.x ~= game.direction.x or game.pendingDirection.y ~= game.direction.y) and game.timer >= (delay / 2) then
         game.direction = game.pendingDirection
         game.timer = 0
         game.moveSnake()
         return
    end

    -- Otherwise, if the full delay has passed, process a move
    if game.timer >= delay then
         game.direction = game.pendingDirection
         game.timer = 0
         game.moveSnake()
    end

    if game.food and game.food.special then
         game.food.specialTimer = game.food.specialTimer - dt
         if game.food.specialTimer <= 0 then
              game.spawnFood(false)
         end
    end
end

function game.loseLife(player, settings, enemy)
    -- ... existing logic ...
    if player.lives <= 0 then
        game.state = "gameOver"
        game.over = true  -- Add this line!
        -- ... potentially other logic ...
    end
end

return game