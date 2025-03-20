-- Flappy Bird Game in Lua using LÖVE framework

-- Game variables
local player = {
    x = 100,
    y = 200,
    width = 30,
    height = 30,
    gravity = 500,
    jump = -200,
    velocity = 0
}

local pipes = {}
local pipeWidth = 70
local pipeGap = 150
local pipeSpeed = 200
local spawnTimer = 0
local spawnInterval = 1.5
local score = 0
local gameState = "title" -- title, playing, gameover
local groundY = 400
local scrollX = 0
local scrollSpeed = 60

-- Load game assets and initialize
function love.load()
    love.graphics.setNewFont(20)
    math.randomseed(os.time())
end

-- Update game state
function love.update(dt)
    scrollX = scrollX - scrollSpeed * dt
    if scrollX <= -800 then
        scrollX = 0
    end
    
    if gameState == "playing" then
        -- Update player
        player.velocity = player.velocity + player.gravity * dt
        player.y = player.y + player.velocity * dt
        
        -- Update pipes
        spawnTimer = spawnTimer + dt
        if spawnTimer >= spawnInterval then
            spawnTimer = 0
            local gapY = math.random(100, groundY - 100 - pipeGap)
            
            table.insert(pipes, {
                x = 800,
                gapY = gapY
            })
        end
        
        for i, pipe in ipairs(pipes) do
            pipe.x = pipe.x - pipeSpeed * dt
            
            -- Check collision
            if checkCollision(player, pipe) then
                gameState = "gameover"
            end
            
            -- Check for score
            if pipe.x + pipeWidth < player.x and not pipe.scored then
                pipe.scored = true
                score = score + 1
            end
            
            -- Remove pipes that are off-screen
            if pipe.x < -pipeWidth then
                table.remove(pipes, i)
            end
        end
        
        -- Ground collision
        if player.y + player.height > groundY then
            player.y = groundY - player.height
            player.velocity = 0
            gameState = "gameover"
        end
        
        -- Ceiling collision
        if player.y < 0 then
            player.y = 0
            player.velocity = 0
        end
    end
end

-- Draw game elements
function love.draw()
    -- Draw background
    love.graphics.setColor(0.4, 0.7, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Draw clouds (background)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", (scrollX % 800) + 100, 80, 120, 40)
    love.graphics.rectangle("fill", (scrollX % 800) + 500, 120, 90, 30)
    love.graphics.rectangle("fill", ((scrollX + 400) % 800) + 200, 100, 100, 35)
    
    -- Draw pipes
    love.graphics.setColor(0.2, 0.8, 0.2)
    for _, pipe in ipairs(pipes) do
        -- Top pipe
        love.graphics.rectangle("fill", pipe.x, 0, pipeWidth, pipe.gapY)
        -- Bottom pipe
        love.graphics.rectangle("fill", pipe.x, pipe.gapY + pipeGap, pipeWidth, groundY - (pipe.gapY + pipeGap))
    end
    
    -- Draw ground
    love.graphics.setColor(0.8, 0.5, 0.2)
    love.graphics.rectangle("fill", 0, groundY, 800, 200)
    
    -- Draw grass
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.rectangle("fill", 0, groundY, 800, 10)
    
    -- Draw player
    love.graphics.setColor(1, 1, 0.2)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    if gameState == "title" then
        love.graphics.printf("Flappy Bird", 0, 150, 800, "center")
        love.graphics.printf("Press Space to Start", 0, 220, 800, "center")
    elseif gameState == "playing" then
        love.graphics.print("Score: " .. score, 20, 20)
    elseif gameState == "gameover" then
        love.graphics.printf("Game Over", 0, 150, 800, "center")
        love.graphics.printf("Score: " .. score, 0, 200, 800, "center")
        love.graphics.printf("Press R to Restart", 0, 250, 800, "center")
    end
end

-- Handle key presses
function love.keypressed(key)
    if gameState == "title" and key == "space" then
        gameState = "playing"
        resetGame()
    elseif gameState == "playing" and key == "space" then
        player.velocity = player.jump
    elseif gameState == "gameover" and key == "r" then
        gameState = "title"
        resetGame()
    elseif key == "escape" then
        love.event.quit()
    end
end

-- Reset game to initial state
function resetGame()
    player.y = 200
    player.velocity = 0
    pipes = {}
    spawnTimer = 0
    score = 0
end

-- Check collision between player and pipe
function checkCollision(player, pipe)
    -- Check collision with top pipe
    if player.x + player.width > pipe.x and player.x < pipe.x + pipeWidth and
        player.y < pipe.gapY then
        return true
    end
    
    -- Check collision with bottom pipe
    if player.x + player.width > pipe.x and player.x < pipe.x + pipeWidth and
        player.y + player.height > pipe.gapY + pipeGap then
        return true
    end
    
    return false
end 