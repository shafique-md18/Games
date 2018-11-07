WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.window.setTitle('Pong!')
	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)
	love.graphics.setFont(smallFont)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
			fullscreen = false,
			resizable = true, -- requires love.resize()
			vsync = true
		}
	)
	-- game sounds as a table
	sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

	servingPlayer = 1
	winningPlayer = 0
	-- scores of players
	player1Score = 0
	player2Score = 0

	-- create two paddles
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)

	-- create a ball
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- create two paddles

	gameState = 'start'

end

function love.resize(w, h)
	push:resize(w, h)
end

function love.update(dt)
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end

	--detect collision
	elseif gameState == 'play' then
		if ball:collides(player1) then
			-- reverse the direction by negating the x velocity
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5

			-- dy is y velocity
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- detect boundry collision
        if ball.y <= 0 then
        	ball.y = 0
        	ball.dy = -ball.dy
        	sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
        	ball.y = VIRTUAL_HEIGHT - 4
        	ball.dy = -ball.dy
        	sounds['wall_hit']:play()
        end
	end

	-- if the ball goes beyond vertical edges increment score
	if ball.x < 0 then
		servingPlayer = 1
		player2Score = player2Score + 1
		sounds['score']:play()
		if player2Score >= 10 then
			gameState = 'done'
			winningPlayer = 2
			ball:reset()
		else
			ball:reset()
			gameState = 'serve'
		end
	end

	if ball.x > VIRTUAL_WIDTH then
		servingPlayer = 2
		player1Score = player1Score + 1
		sounds['score']:play()
		if player1Score >= 10 then
			gameState = 'done'
			winningPlayer = 1
			ball:reset()
		else
			ball:reset()
			gameState = 'serve'
		end
	end

	-- player1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- player 2s movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end


	-- if the play is started then draw ball
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

-- detect keys pressed
-- here we manage the transitions to gameState
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then 
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			-- a match has completed, reset the game
			gameState = 'serve'
			ball:reset()
			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end 
		end
	end
end

function love.draw()
	push:apply('start')
	-- set background color
	love.graphics.clear(40/255, 45/255, 52/255, 255)

	love.graphics.setFont(smallFont)

	displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
    	love.graphics.setFont(largeFont)
    	love.graphics.printf('Player' .. tostring(winningPlayer) .. ' wins!',
    		0, 10, VIRTUAL_WIDTH, 'center')
    	love.graphics.setFont(smallFont)
    	love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

	player1:render()
	player2:render()
	ball:render()

	displayFPS()

	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

--[[
    Simply draws the score to the screen.
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end