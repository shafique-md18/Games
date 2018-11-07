-- Create a Paddle Class
Paddle = Class{}

function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	-- This variable will contain paddle speed
	-- will start at 0, then if up is pressed becomes -200 otherwise +200
	-- check the boundries at both cases
	self.dy = 0
end

function Paddle:update( dt )
	-- if 'w' or 'up' is pressed, dy will be -200
	if self.dy < 0 then
		self.y = math.max(0, self.y + self.dy * dt)
	-- dy is + 200
	else
		self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
	end
end

function Paddle:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end