require("engine/settings")

local ui = {}


function ui.load()
	ui.image = love.graphics.newImage("assets/art/ui.png")
	ui.gasMeterQuad = love.graphics.newQuad(0, 0, 32, 120, ui.image:getWidth(), ui.image:getHeight())
	ui.gasMeterProgressQuad = love.graphics.newQuad(32, 0, 32, 120, ui.image:getWidth(), ui.image:getHeight())
	ui.gasMeterShader = love.graphics.newShader("assets/shader/progress_bar.frag")
	ui.gasMeterShader:send("progress", 1.0)
end

function ui.draw()
	local _, _, gasMeterWidth, gasMeterHeight = ui.gasMeterQuad:getViewport()
	love.graphics.draw(ui.image, ui.gasMeterQuad, 10, BaseCanvasHeight - gasMeterHeight - 10)
	love.graphics.setShader(ui.gasMeterShader)
	love.graphics.draw(ui.image, ui.gasMeterProgressQuad, 10, BaseCanvasHeight - gasMeterHeight - 10)
	love.graphics.setShader()
end

return ui
