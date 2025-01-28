function love.load()
	sprites = {}
	sprites.background = love.graphics.newImage("sprites/background.png")
	sprites.bullet = love.graphics.newImage("sprites/bullet.png")
	sprites.player = love.graphics.newImage("sprites/player.png")
	sprites.zombie = love.graphics.newImage("sprites/zombie.png")

	player = {}
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.speed = 180
end

function love.update(dt)
	if love.keyboard.isDown("l") then
		player.x = player.x + player.speed * dt
	end
	if love.keyboard.isDown("h") then
		player.x = player.x - player.speed * dt
	end
	if love.keyboard.isDown("j") then
		player.y = player.y + player.speed * dt
	end
	if love.keyboard.isDown("k") then
		player.y = player.y - player.speed * dt
	end

	mouseX = love.mouse.getX()
	mouseY = love.mouse.getY()
end

function love.draw()
	love.graphics.draw(sprites.background, 0, 0)

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

function playerMouseAngle()
	return math.atan2(player.y - mouseY, player.x - mouseX) + math.pi
end
