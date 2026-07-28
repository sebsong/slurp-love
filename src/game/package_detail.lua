local packageDetail = {}

local draw = require("engine/draw")
local animation = require("engine/animation")
local ui = require("engine/ui")
local scene = require("engine/scene")

local font = require("game/font")

local FLAVOR_TEXTS = {
	"fragile, handle with care",
	"pedal to the metal",
	"see that which is unseen",
	"caution, radioctive materials",
	"uno reverse",
}

local isOpen
local shouldClose

local detailBox
local packageDetailPortrait

local textTransform
local textWidth
local textHeight

local packageIndex
local onClose

function packageDetail.open(_packageIndex, _onClose)
	packageIndex = _packageIndex
	onClose = _onClose
	scene.start(scene.scenes.packageDetail)
end

function packageDetail.close()
	isOpen = false
	animation.play(detailBox.drawComponent, true, function() shouldClose = true end)
end

function packageDetail.load()
	isOpen = false
	shouldClose = false

	local detailBoxImage = love.graphics.newImage("assets/art/package_detail_box.png")
	-- local detailBoxDrawComponent = draw.new(detailBoxImage)
	local detailBoxDrawComponent = animation.new(detailBoxImage, 6, 0.15)
	animation.play(detailBoxDrawComponent, false, function() isOpen = true end)
	detailBox = {
		drawComponent = detailBoxDrawComponent,
		transform = ui.newAlignedTransform(detailBoxDrawComponent.width, detailBoxDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}

	local packageDetailsImage = love.graphics.newImage("assets/art/package_details.png")
	local packageDetailAnimation = animation.new(packageDetailsImage, 5)
	packageDetailAnimation.currentFrame = packageIndex or 1
	packageDetailPortrait = {
		drawComponent = packageDetailAnimation,
		transform = ui.newAlignedTransform(packageDetailAnimation.width, packageDetailAnimation.height, ui.align.CENTER, ui.align.CENTER, 0, -50)
	}

	textWidth = 420
	textHeight = 105
	textTransform = ui.newAlignedTransform(textWidth, textHeight, ui.align.CENTER, ui.align.BOTTOM)
end

function packageDetail.unload()
end

function packageDetail.onPause()
end

function packageDetail.onResume()
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
	if shouldClose then
		if onClose then
			onClose()
		end
		scene.stop(scene.scenes.packageDetail)
	end

	animation.update(detailBox.drawComponent, dt)
end

function packageDetail.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(detailBox.drawComponent, detailBox.transform)

	if not isOpen then
		love.graphics.pop()
		return
	end

	draw.draw(packageDetailPortrait.drawComponent, packageDetailPortrait.transform)

	love.graphics.setFont(font.medium)
	love.graphics.printf(FLAVOR_TEXTS[packageIndex], textTransform, textWidth, "center")

	love.graphics.pop()
end

return packageDetail
