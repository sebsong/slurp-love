local debug = {}

function debug.load()
	BackgroundImage = love.graphics.newImage("assets/art/main_menu.png")
end

function debug.unload()
end

function debug.keypressed(key, scancode, isRepeat)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function debug.mousepressed(x, y, button, isTouch, presses)
end

function debug.mousemoved(x, y, dx, dy, isTouch)
end

function debug.wheelmoved(x, y)
end

function debug.update(dt)
end

function debug.draw()
	love.graphics.draw(BackgroundImage)
end

return debug
