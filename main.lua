function love.load()
	math.randomseed(os.time())

	love.window.setFullscreen(true, "exclusive")

	sprites = {}
	sprites.background = love.graphics.newImage("sprites/background.png")
	sprites.bullet = love.graphics.newImage("sprites/bullet.png")
	sprites.player = love.graphics.newImage("sprites/player.png")
	sprites.zombie = love.graphics.newImage("sprites/zombie.png")

	player = {}
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.speed = 180
	player.injured = false

	myFont = love.graphics.newFont(30)

	zombies = {}
	bullets = {}

	gameState = false
	maxTime = 2
	timer = maxTime
	score = 0
end

function love.update(dt)
	if gameState == true then
		if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
			player.x = player.x + player.speed * dt
		end
		if love.keyboard.isDown("a") and player.x > 0 then
			player.x = player.x - player.speed * dt
		end
		if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
			player.y = player.y + player.speed * dt
		end
		if love.keyboard.isDown("w") and player.y > 0 then
			player.y = player.y - player.speed * dt
		end
	end

	mouseX = love.mouse.getX()
	mouseY = love.mouse.getY()

	for i, z in ipairs(zombies) do
		z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt
		z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt

		if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
			if player.injured == false then
				player.injured = true
				player.speed = 250
				table.remove(zombies, i)
			elseif player.injured == true then
				for i, z in ipairs(zombies) do
					zombies[i] = nil
					player.injured = false
					gameState = false
					player.x = love.graphics.getWidth() / 2
					player.y = love.graphics.getHeight() / 2
				end
			end
		end
	end

	for i, b in ipairs(bullets) do
		b.x = b.x + (math.cos(b.direction) * b.speed * dt)
		b.y = b.y + (math.sin(b.direction) * b.speed * dt)
	end

	for i = #bullets, 1, -1 do
		b = bullets[i]
		if b.x < 0 or b.y < 0 or b.x >= love.graphics.getWidth() or b.y >= love.graphics.getHeight() then
			table.remove(bullets, i)
		end
	end

	for i, z in ipairs(zombies) do
		for j, b in ipairs(bullets) do
			if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
				z.dead = true
				b.dead = true
				score = score + 1
			end
		end
	end

	for i = #zombies, 1, -1 do
		local z = zombies[i]
		if z.dead == true then
			table.remove(zombies, i)
		end
	end

	for i = #bullets, 1, -1 do
		local b = bullets[i]
		if b.dead == true then
			table.remove(bullets, i)
		end
	end

	if gameState == true then
		timer = timer - dt
		if timer <= 0 then
			spawnZombie()
			maxTime = 0.95 * maxTime
			timer = maxTime
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(sprites.background, 0, 0)

	if gameState == false then
		love.graphics.setFont(myFont)
		love.graphics.printf("Click anywhere to begin", 0, 50, love.graphics.getWidth(), "center")
	end
	love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

	for i, z in ipairs(zombies) do
		love.graphics.draw(
			sprites.zombie,
			z.x,
			z.y,
			zombiePlayerAngle(z),
			nil,
			nil,
			sprites.zombie:getWidth() / 2,
			sprites.zombie:getHeight() / 2
		)
	end

	for i, b in ipairs(bullets) do
		love.graphics.draw(
			sprites.bullet,
			b.x,
			b.y,
			nil,
			0.5,
			0.5,
			sprites.bullet:getWidth() / 2,
			sprites.bullet:getHeight() / 2
		)
	end
	if player.injured == true then
		love.graphics.setColor(1, 0, 0)
	end
	love.graphics.draw(
		sprites.player,
		player.x,
		player.y,
		playerMouseAngle(),
		nil,
		nil,
		sprites.player:getWidth() / 2,
		sprites.player:getHeight() / 2
	)
end

function love.keypressed(key)
	if key == "space" then
		spawnZombie()
	end
end

function love.mousepressed(x, y, button)
	if button == 1 and gameState == true then
		spawnBullet()
	elseif button == 1 and gameState == false then
		gameState = true
		maxTime = 2
		timer = maxTime
		score = 0
	end
end

function playerMouseAngle()
	return math.atan2(player.y - mouseY, player.x - mouseX) + math.pi
end

function zombiePlayerAngle(enemy)
	return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
	local zombie = {}
	zombie.x = 0
	zombie.y = 0
	zombie.speed = 140
	zombies.dead = false

	local side = math.random(1, 4)
	if side == 1 then
		zombie.x = -30
		zombie.y = math.random(0, love.graphics.getHeight())
	elseif side == 2 then
		zombie.x = love.graphics.getWidth() + 30
		zombie.y = math.random(0, love.graphics.getHeight())
	elseif side == 3 then
		zombies.x = math.random(0, love.graphics.getWidth())
		zombies.y = -30
	elseif side == 4 then
		zombies.x = math.random(0, love.graphics.getWidth())
		zombies.y = love.graphics.getHeight() + 30
	end
	table.insert(zombies, zombie)
end

function spawnBullet()
	local bullet = {}
	bullet.x = player.x
	bullet.y = player.y
	bullet.speed = 500
	bullet.direction = playerMouseAngle()
	table.insert(bullets, bullet)
end

function distanceBetween(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
