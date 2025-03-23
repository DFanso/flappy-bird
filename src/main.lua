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
local pipeDistance = 300 -- Fixed distance between pipe pairs
local pipeSpeed = 200
local minPipeHeight = 50 -- Minimum height for pipes
local spawnTimer = 0
local spawnInterval = 0 -- Will be calculated based on speed and distance
local score = 0
local gameState = "title" -- title, playing, gameover
local groundY = 400
local scrollX = 0
local scrollSpeed = 60
local difficulty = 1 -- Difficulty multiplier

-- Cloud variables
local clouds = {}
local numClouds = 5

-- Load game assets and initialize
function love.load()
    love.graphics.setNewFont(20)
    math.randomseed(os.time())
    
    -- Calculate spawn interval based on pipe distance and speed
    spawnInterval = pipeDistance / pipeSpeed
    
    -- Create cloud data
    for i=1, numClouds do
        local cloudType = love.math.random(1, 3)
        table.insert(clouds, {
            x = love.math.random(0, 800),
            y = love.math.random(50, 200),
            speed = love.math.random(15, 40),
            size = love.math.random(50, 120) / 100,
            type = cloudType
        })
    end
end

-- Generate a cloud shape
function drawCloud(x, y, size, cloudType)
    love.graphics.setColor(1, 1, 1, 0.9)
    
    if cloudType == 1 then
        -- Cloud type 1 (puffy)
        local baseSize = 30 * size
        love.graphics.circle("fill", x, y, baseSize)
        love.graphics.circle("fill", x + baseSize * 0.8, y - baseSize * 0.3, baseSize * 0.7)
        love.graphics.circle("fill", x + baseSize * 0.8, y + baseSize * 0.3, baseSize * 0.6)
        love.graphics.circle("fill", x - baseSize * 0.5, y, baseSize * 0.8)
        love.graphics.circle("fill", x + baseSize * 1.5, y, baseSize * 0.7)
    elseif cloudType == 2 then
        -- Cloud type 2 (flat)
        local width = 100 * size
        local height = 35 * size
        love.graphics.ellipse("fill", x, y, width/2, height/2)
        love.graphics.ellipse("fill", x - width/3, y - height/4, width/4, height/3)
        love.graphics.ellipse("fill", x + width/3, y - height/5, width/3, height/4)
    else
        -- Cloud type 3 (mixed)
        local baseSize = 25 * size
        love.graphics.circle("fill", x, y, baseSize)
        love.graphics.circle("fill", x + baseSize, y, baseSize * 1.2)
        love.graphics.circle("fill", x + baseSize * 2, y, baseSize * 0.9)
        love.graphics.circle("fill", x + baseSize * 0.5, y - baseSize * 0.7, baseSize * 0.8)
        love.graphics.circle("fill", x + baseSize * 1.5, y - baseSize * 0.5, baseSize)
    end
end

-- Update game state
function love.update(dt)
    scrollX = scrollX - scrollSpeed * dt
    if scrollX <= -800 then
        scrollX = 0
    end
    
    -- Update clouds
    for i, cloud in ipairs(clouds) do
        cloud.x = cloud.x - cloud.speed * dt
        if cloud.x < -150 then
            cloud.x = 850
            cloud.y = love.math.random(50, 200)
            cloud.speed = love.math.random(15, 40)
            cloud.size = love.math.random(50, 120) / 100
            cloud.type = love.math.random(1, 3)
        end
    end
    
    if gameState == "playing" then
        -- Update player
        player.velocity = player.velocity + player.gravity * dt
        player.y = player.y + player.velocity * dt
        
        -- Update pipes
        spawnTimer = spawnTimer + dt
        if spawnTimer >= spawnInterval then
            spawnTimer = 0
            
            -- Calculate pipe gap position with increasing randomness based on score
            local minGapPos = minPipeHeight + 10
            local maxGapPos = groundY - pipeGap - minPipeHeight - 10
            local variance = math.min(100, 20 + score * 2) -- Variance increases with score
            local baseGapY = (minGapPos + maxGapPos) / 2 -- Middle point
            local offset = love.math.random(-variance, variance)
            local gapY = math.max(minGapPos, math.min(maxGapPos, baseGapY + offset))
            
            table.insert(pipes, {
                x = 800,
                gapY = gapY,
                scored = false,
                -- Add some height variation to the pipes
                topHeight = gapY,
                bottomHeight = groundY - (gapY + pipeGap)
            })
        end
        
        -- Increase difficulty based on score
        difficulty = 1 + score * 0.01
        pipeSpeed = 200 + (score * 3)
        
        -- Update pipe positions
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
                
                -- Recalculate spawn interval when speed changes
                spawnInterval = pipeDistance / pipeSpeed
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
    
    -- Draw clouds (now using the cloud drawing function)
    for _, cloud in ipairs(clouds) do
        drawCloud(cloud.x, cloud.y, cloud.size, cloud.type)
    end
    
    -- Draw pipes
    love.graphics.setColor(0.2, 0.8, 0.2)
    for _, pipe in ipairs(pipes) do
        -- Top pipe
        love.graphics.rectangle("fill", pipe.x, 0, pipeWidth, pipe.gapY)
        
        -- Add pipe cap to top pipe
        love.graphics.setColor(0.1, 0.6, 0.1)
        love.graphics.rectangle("fill", pipe.x - 5, pipe.gapY - 15, pipeWidth + 10, 15)
        
        -- Reset pipe color
        love.graphics.setColor(0.2, 0.8, 0.2)
        
        -- Bottom pipe
        love.graphics.rectangle("fill", pipe.x, pipe.gapY + pipeGap, pipeWidth, groundY - (pipe.gapY + pipeGap))
        
        -- Add pipe cap to bottom pipe
        love.graphics.setColor(0.1, 0.6, 0.1)
        love.graphics.rectangle("fill", pipe.x - 5, pipe.gapY + pipeGap, pipeWidth + 10, 15)
        
        -- Reset pipe color
        love.graphics.setColor(0.2, 0.8, 0.2)
    end
    
    -- Draw ground
    love.graphics.setColor(0.8, 0.5, 0.2)
    love.graphics.rectangle("fill", 0, groundY, 800, 200)
    
    -- Draw grass
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.rectangle("fill", 0, groundY, 800, 10)
    
    -- Draw player
    love.graphics.setColor(1, 0.8, 0.2) -- Bird color: yellow
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Draw bird's eye
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", player.x + player.width - 5, player.y + 10, 3)
    
    -- Draw bird's beak
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.polygon("fill", 
        player.x + player.width, player.y + 15,
        player.x + player.width + 10, player.y + 15,
        player.x + player.width, player.y + 20
    )
    
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
    difficulty = 1
    pipeSpeed = 200
    spawnInterval = pipeDistance / pipeSpeed
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