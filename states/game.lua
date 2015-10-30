function game_init()
	eventSystem = eventsystem:new()

	currentMap = 1

	maplist = {}

	maplist[1] = maps[1]

	local listCount = 2

	while (listCount < 17) do
		local rand = math.random(2, #maps)
		maplist[listCount] = maps[rand]
		table.remove(maps, rand)
		listCount = listCount + 1
	end

	loadMap(currentMap)

	titleNums = 
	{
		["top"] = {},
		["bottom"] = {}
	}

	makeTitleNums()

	score = 0

	gameover = false
	gameoversin = 0

	scoreTypes = {"KB", "MB", "GB"}
	scorei = 1

	combo = 0
	combotimeout = 0
	paused = false
end

function game_update(dt)
	if paused then
		return
	end

	eventSystem:update(dt)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.remove then
				table.remove(objects[k], j)
			end
		end
	end

	for k, j in pairs(titleNums) do
		for i, v in ipairs(j) do
			v[3] = v[3] + v[4] * dt

			if v[3] * 16 > gameFunctions.getHeight() then
				v[3] = 0
			end
		end
	end

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end	
	end

	for k, v in pairs(consoles) do
		v:update(dt)

		if v.remove then
			table.remove(consoles, k)
		end
	end

	--hacky shit but whatever
	if not objects["player"][1] then
		if not bgmstart:isPlaying() then
			bgmstart:play()
		end
	else
		if not bgm:isPlaying() then
			bgm:play()
		end
	end

	if mapscrollx > 0 then
		mapscrollx = mapscrollx - 200 * dt
	elseif mapscrollx < 0 then
		mapscrollx = mapscrollx + 200 * dt
	end

	physicsupdate(dt)
end

function game_draw()
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.push()

	love.graphics.translate(mapscrollx, mapscrolly)

	love.graphics.setFont(backgroundFont)
	for k, v in ipairs(titleNums["top"]) do
		love.graphics.setScreen("top")
		love.graphics.setColor(0, 128, 0)
		love.graphics.print(v[1], 5 + (v[2] - 1) * 16, 1 + (v[3] - 1) * 16)
	end

	love.graphics.setScreen("top")

	love.graphics.setColor(255, 255, 255)
	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
		end	
	end

	love.graphics.pop()

	for k, v in pairs(consoles) do
		v:draw()
	end

	--INTERFACE

	if homebrewMode then
		love.graphics.setScreen("bottom")

		local state, percent = love.system.getPowerInfo()
		local batteryimg = UIIcons["battery"][1]

		local batteryColor = {0, 127, 14}
		local percentColor = {0, 155, 15}

		local batteryLeft = percent

		love.graphics.print("Battery left: " .. batteryLeft, 0, 0)
		
		if state == "charging" then
			percentColor = {255, 106, 0}
			batteryColor = {196, 78, 0}
			love.graphics.draw(UIIcons["battery"][2], 2, gameFunctions.getHeight() - batteryimg:getHeight() - 2)
		end

		if not batteryLeft then
			batteryLeft = 0
		end

		if state ~= "charging" then
			if batteryLeft > 50 and batteryLeft < 75 then
				percentColor = {219, 182, 0}
				batteryColor = {193, 161, 0}
			elseif batteryLeft > 25 and batteryLeft < 50 then
				percentColor = {255, 106, 0}
				batteryColor = {196, 78, 0}
			elseif batteryLeft < 25 then
				percentColor = {232, 0, 0}
				batteryColor = {190, 0, 0}
			end
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(UIIcons["background"], 0, 18)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(UIIcons["linux"], gameFunctions.getWidth() / 2 - UIIcons["linux"]:getWidth() / 2, gameFunctions.getHeight() / 2 - UIIcons["linux"]:getHeight() / 2)

		love.graphics.setColor(64, 64, 64)
		love.graphics.rectangle("fill", 0, 0, gameFunctions.getWidth(), 18)
		love.graphics.rectangle("fill", 0, gameFunctions.getHeight() - 18, gameFunctions.getWidth(), 18)


		love.graphics.setColor(unpack(batteryColor))
		love.graphics.draw(batteryimg, 2, gameFunctions.getHeight() - batteryimg:getHeight() - 2)

		love.graphics.setColor(unpack(percentColor))
		love.graphics.rectangle("fill", 5, (gameFunctions.getHeight() - batteryimg:getHeight() - 2) + 2, (batteryLeft / 100) * 14, 9)

		love.graphics.setColor(255, 255, 255)
		love.graphics.print(os.date("%I:%M %p"), gameFunctions.getWidth() - backgroundFont:getWidth(os.date("%I:%M %p")) - 2, gameFunctions.getHeight() - backgroundFont:getHeight(os.date("%I:%M %p")) - 1)
		
		if objects["player"][1] then
			love.graphics.draw(UIIcons["health"][objects["player"][1].health], 2, 1)
		end

		love.graphics.draw(UIIcons["power"], gameFunctions.getWidth() - 18, 1)
	end
end

function game_keypressed(key)
	if key == controls["pause"] then
		if not gameover then
			paused = not paused
		else
			gameFunctions.changeState("game")
		end
	end

	if key == "select" then
		if paused then
			gameFunctions.changeState("title")
		end
	end

	if paused then
		--pauseMenu:keypressed(key)
	end

	if not objects["player"][1] then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveleft(true)
	elseif key == controls["right"] then
		objects["player"][1]:moveright(true)
	elseif key == controls["jump"] then
		objects["player"][1]:jump()
	end

	if key == "lshift" then
		objects["player"][1]:dash()
	end
end

function game_mousepressed(x, y, button)
	if x > gameFunctions.getWidth() - 18 and x < (gameFunctions.getWidth() - 18) + 16 and y > 1 and y < 18 then
		paused = not paused
	end
end

function game_keyreleased(key)
	if not objects["player"][1] then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveleft(false)
	elseif key == controls["right"] then
		objects["player"][1]:moveright(false)
	end
end

function loadMap(mapn)
	--objects = {}

	objects["firewall"] = {}

	objects["player"] = {}
	objects["playerdeath"] = {}

	objects["tile"] = {}

	objects["audioblaster"] = {}
	objects["notes"] = {}

	objects["paintbird"] = {}
	objects["paintdrop"] = {}

	consoles = {}

	currentMap = mapn
	
	local map = maplist[mapn]

	mapscrollx = 0
	mapscrolly = 0

	playerX, playerY = 0, 0
	for y = 1, #map do
		for x = 1, #map[1] do
			if map[y][x] == 1 then
				objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16)
			elseif map[y][x] == 3 then
				playerX = (x - 1) * 16
				playerY = (y - 1) * 16
			elseif map[y][x] == 2 then
				table.insert(objects["firewall"], firewall:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 4 then
				table.insert(objects["audioblaster"], audioblaster:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 5 then
				objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16, "water", 5)
			elseif map[y][x] == 6 then
				objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16, "waterbase")
			elseif map[y][x] == 7 then
				--save point
			elseif map[y][x] == 8 then
				table.insert(objects["paintbird"], paintbird:new((x - 1) * 16, (y - 1) * 16))
			end
		end
	end

	if playerX == 0 and playerY == 0 then
		playerX = 0
		playerY = 14 * 16

		objects["player"][1] = player:new(playerX, playerY)
	end

	eventsystem:onMapLoad(mapn)
end

function consoleDelay(t, s, c, f)
	table.insert(timers["console"], newTimer(t, function()
		objects["console"][1] = newConsole(s, c, f)
	end))
end

function newTimer(t, f, stopAtMax)
	local timerthing = {}

	timerthing.maxtime = t
	timerthing.func = f
	timerthing.time = 0
	timerthing.stopAtMax = stopAtMax

	timerthing.stop = false

	function timerthing:update(dt)
		if self.time < self.maxtime then
			self.time = self.time + dt
		else
			if not self.stop then
				self.func()
				self.remove = true
				self.stop = true
			end
		end
	end

	return timerthing
end

function newRepeatTimer(t, f)
	local timerthing = {}

	timerthing.maxtime = t
	timerthing.func = f
	timerthing.time = 0
	timerthing.stopAtMax = stopAtMax

	timerthing.stop = false

	function timerthing:update(dt)
		if self.time < self.maxtime then
			self.time = self.time + dt
		else
			self.func()
			self.time = 0
		end
	end

	return timerthing
end