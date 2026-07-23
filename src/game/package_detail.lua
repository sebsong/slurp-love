local packageDetail = {}

local draw = require("engine/draw")
local ui = require("engine/ui")
local scene = require("engine/scene")

local font = require("game/font")
local gameUi = require("game/ui")

local detailBox

local flavorText
local textTransform
local textWidth
local textHeight

local onClose

function packageDetail.open(pacakgeTileId, _onClose)
	onClose = _onClose
	scene.start(scene.scenes.packageDetail)
end

function packageDetail.close()
	if onClose then
		onClose()
	end
	scene.stop(scene.scenes.packageDetail)
end

function packageDetail.load()
	local detailBoxImage = love.graphics.newImage("assets/art/package_detail_box.png")
	local detailBoxDrawComponent = draw.new(detailBoxImage)
	detailBox = {
		drawComponent = detailBoxDrawComponent,
		transform = ui.newAlignedTransform(detailBoxDrawComponent.width, detailBoxDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}

	flavorText = "see that which is unseen"
	textWidth = 420
	textHeight = 105
	textTransform = ui.newAlignedTransform(textWidth, textHeight, ui.align.CENTER, ui.align.BOTTOM)
end

function packageDetail.unload()
end

function packageDetail.keypressed(key, scancode, isRepeat)
	if key == "space" then
		packageDetail.close()
	end
end

function packageDetail.mousepressed(x, y, button, isTouch, presses)
end

function packageDetail.mousemoved(x, y, dx, dy, isTouch)
end

function packageDetail.wheelmoved(x, y)
end

function packageDetail.update(dt)
end

function packageDetail.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(detailBox.drawComponent, detailBox.transform)

	love.graphics.setFont(font.small)
	love.graphics.printf(flavorText, textTransform, textWidth, "center")

	love.graphics.pop()
end

return packageDetail
