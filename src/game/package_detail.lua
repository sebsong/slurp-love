local PackageDetail = {}

local Sprite = require("engine/sprite")
local Animation = require("engine/animation")
local Ui = require("engine/ui")
local Scene = require("engine/scene")

local Font = require("game/font")

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

function PackageDetail.open(_packageIndex, _onClose)
	packageIndex = _packageIndex
	onClose = _onClose
	Scene.start(Scene.scenes.packageDetail)
end

function PackageDetail.close()
	isOpen = false
	Animation.play(detailBox.drawComponent, true, function() shouldClose = true end)
end

function PackageDetail.load()
	isOpen = false
	shouldClose = false

	local detailBoxImage = love.graphics.newImage("assets/art/package_detail_box.png")
	-- local detailBoxDrawComponent = Sprite.new(detailBoxImage)
	local detailBoxDrawComponent = Animation.new(detailBoxImage, 6, 0.15)
	Animation.play(detailBoxDrawComponent, false, function() isOpen = true end)
	detailBox = {
		drawComponent = detailBoxDrawComponent,
		transform = Ui.newAlignedTransform(detailBoxDrawComponent.width, detailBoxDrawComponent.height, Ui.align.CENTER, Ui.align.CENTER)
	}

	local packageDetailsImage = love.graphics.newImage("assets/art/package_details.png")
	local packageDetailAnimation = Animation.new(packageDetailsImage, 5)
	packageDetailAnimation.currentFrame = packageIndex or 1
	packageDetailPortrait = {
		drawComponent = packageDetailAnimation,
		transform = Ui.newAlignedTransform(packageDetailAnimation.width, packageDetailAnimation.height, Ui.align.CENTER, Ui.align.CENTER, 0, -50)
	}

	textWidth = 420
	textHeight = 105
	textTransform = Ui.newAlignedTransform(textWidth, textHeight, Ui.align.CENTER, Ui.align.BOTTOM)
end

function PackageDetail.unload()
end

function PackageDetail.onPause()
end

function PackageDetail.onResume()
end

function PackageDetail.keypressed(key, scancode, isRepeat)
	if key == "space" then
		PackageDetail.close()
	end
end

function PackageDetail.mousepressed(x, y, button, isTouch, presses)
end

function PackageDetail.mousemoved(x, y, dx, dy, isTouch)
end

function PackageDetail.wheelmoved(x, y)
end

function PackageDetail.update(dt)
	if shouldClose then
		if onClose then
			onClose()
		end
		Scene.stop(Scene.scenes.packageDetail)
	end

	Animation.update(detailBox.drawComponent, dt)
end

function PackageDetail.draw()
	love.graphics.push()

	love.graphics.setShader()
	Sprite.draw(detailBox.drawComponent, detailBox.transform)

	if not isOpen then
		love.graphics.pop()
		return
	end

	Sprite.draw(packageDetailPortrait.drawComponent, packageDetailPortrait.transform)

	love.graphics.setFont(Font.medium)
	love.graphics.printf(FLAVOR_TEXTS[packageIndex], textTransform, textWidth, "center")

	love.graphics.pop()
end

return PackageDetail
