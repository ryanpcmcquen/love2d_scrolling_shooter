-- http://osmstudios.com/tutorials/your-first-love2d-game-in-200-lines-part-1-of-3

debug = true

-- Timers:
-- We declare these here so we don't have
-- to edit them in multiple places.
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- Enemy timers:
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- More images
enemyImg = nil

-- This will hold our enemies:
enemies = {}

-- Image storage:
bulletImg = nil
-- Entity storage:
-- A table of bullets being drawn and updated.
bullets = {}

player = {
    x = 200,
    y = 710,
    speed = 150,
    img = nil
}

isAlive = true
score = 0

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
    x2 < x1 + w1 and
    y1 < y2 + h2 and
    y2 < y1 + h1
end

--[===[
Loader!
--]===]
function love.load(arg)
    player.img = love.graphics.newImage('assets/goodGuy.png')
    bulletImg = love.graphics.newImage('assets/bullet.png')
    enemyImg = love.graphics.newImage('assets/badGuy.png')
end
--[===[
End of loader.
--]===]


--[===[
Updater!
--]===]
function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    if love.keyboard.isDown('left', 'a') then
        -- Keep user from leaving the map:
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    elseif love.keyboard.isDown('right', 'd') then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed * dt)
        end
    end

    -- Time out how far apart our shots can be.
    canShootTimer = canShootTimer - (1 * dt)
    if canShootTimer < 0 then
        canShoot = true
    end

    if
    love.keyboard.isDown('space', 'rctrl', 'lctrl', 's')
    and canShoot
    then
        -- Create some bullets:
        newBullet = {
            x = player.x + (player.img:getWidth() / 2),
            y = player.y,
            img = bulletImg
        }
        table.insert(bullets, newBullet)
        canShoot = false
        canShootTimer = canShootTimerMax
    end

    -- Update the positions of the bullets:
    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (250 * dt)

        if bullet.y < 0 then
            -- Remove bullets that leave the screen:
            table.remove(bullets, i)
        end
    end

    -- Time out enemy creation:
    createEnemyTimer = createEnemyTimer - (1 * dt)
    if createEnemyTimer < 0 then
        createEnemyTimer = createEnemyTimerMax

        -- Create an enemy:
        randomNumber = math.random(10, love.graphics.getWidth() - 10)
        newEnemy = {
            x = randomNumber,
            y = -10,
            img = enemyImg
        }

        table.insert(enemies, newEnemy)
    end

    -- Update the positions of enemies:
    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (200 * dt)

        if enemy.y > 850 then
            table.remove(enemies, i)
        end
    end

    -- Run collision detection.
    -- Since there will be fewer enemies on screen than bullets,
    -- we will loop through them first.
    --
    -- Also, we need to see if the enemies hit our player.
    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if checkCollision(
                enemy.x,
                enemy.y,
                enemy.img:getWidth(),
                enemy.img:getHeight(),
                bullet.x,
                bullet.y,
                bullet.img:getWidth(),
                bullet.img:getHeight()
                ) then
                table.remove(bullets, j)
                table.remove(enemies, i)
                score = score + 1
            end
        end

        if checkCollision(
            enemy.x,
            enemy.y,
            enemy.img:getWidth(),
            enemy.img:getHeight(),
            player.x,
            player.y,
            player.img:getWidth(),
            player.img:getHeight()
            ) and isAlive
        then
            table.remove(enemies, i)
            isAlive = false
        end
    end

    if not isAlive and love.keyboard.isDown('r') then
        -- Remove all our bullets and enemies from screen:
        bullets = {}
        enemies = {}

        -- Reset timers:
        canShootTimer = canShootTimerMax
        createEnemyTimer = createEnemyTimerMax

        -- Move player back to default position
        player.x = 50
        player.y = 710

        -- Reset our game state:
        score = 0
        isAlive = true
    end

end
--[===[
End of updater.
--]===]

--[===[
Drawer!
--]===]
function love.draw(dt)
    if isAlive then
        love.graphics.draw(player.img, player.x, player.y)
    else
        love.graphics.print(
            "Press 'R' to restart.",
            love.graphics:getWidth() / 2 - 50,
            love.graphics:getHeight() / 2 - 10
        )
    end
    for i, bullet in ipairs(bullets) do
        love.graphics.draw(bullet.img, bullet.x, bullet.y)
    end
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end
end
--[===[
End of drawer.
--]===]
