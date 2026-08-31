local MailBoxEffect = require("game.effects.mailbox_effect")
local Sprite = require("engine.sprite")

local Mailbox = {}

local DEFAULT_STATE = 1
local DELIVERED_STATE = 2

function Mailbox.new(image, tileObject)
    local mailBoxSprite = Sprite.newAnimated(image, {
        [DEFAULT_STATE] = {},
        [DELIVERED_STATE] = {
            numFrames = 10,
            duration = 1,
            isLooping = false,
            isReversed = false,
            onFinish = nil,
        },
    })
    local mailBox = {
        transform = tileObject.transform,
        sprite = mailBoxSprite,

        package = nil,
    }

    mailBoxSprite.setShader = function()
        MailBoxEffect.setShader(mailBox)
    end
end

return Mailbox
