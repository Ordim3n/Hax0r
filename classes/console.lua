console = class("console")

function console:init(string, color, func)
	self.x = 2
	self.y = 2
	self.width = gameFunctions.getWidth() - 4
	self.height = 16

	self.delay = 0.04
	self.i = 0
	self.timer = 0
	self.index = 1
	self.string = (string or "")
	self.fade = 1
	self.drawstring = ""

	self.endTimer = 0
	self.stringColor = color or {255, 255, 255}
	
	if func then
		func()
	end
end


function console:update(dt)
	if self.i < #self.string then
		if self.timer < self.delay then
			self.timer = self.timer + dt
		else
			hitproxysnd:play()

			local s = self.string
			self.i = self.i + 1
			self.drawstring = self.drawstring .. s:sub(self.i, self.i)

			self.timer = 0
		end
	else
		self.endTimer = self.endTimer + 2 * dt
		self.fade = math.floor(self.endTimer%2)

		if self.endTimer > 4 then
			self.remove = true
		end
	end
end

function console:draw()
	love.graphics.setFont(consoleFont)

	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)
	love.graphics.setColor(self.stringColor)
	
	love.graphics.print("> " .. self.drawstring, (self.x + 2) * scale, (self.y + self.height / 2) * scale - consoleFont:getHeight(self.drawstring) / 2)

	if self.i == #self.string then
		love.graphics.setColor(self.stringColor[1], self.stringColor[2], self.stringColor[3], 255 * self.fade)
		love.graphics.print("_", (self.x + 2) * scale + consoleFont:getWidth("> " .. self.string), (self.y + self.height / 2) * scale - consoleFont:getHeight(self.string) / 2)
	end

	love.graphics.setFont(backgroundFont)
end