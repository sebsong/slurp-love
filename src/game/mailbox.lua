local MailboxEffect = require("game.effects.mailbox_effect")
local Sprite = require("engine.sprite")

local Mailbox = {}

local DEFAULT_STATE = 1
local DELIVERED_STATE = 2

function Mailbox.new(image, tileObject)
    local mailboxSprite = Sprite.newAnimated(image, {
        [DEFAULT_STATE] = {},
        [DELIVERED_STATE] = {
            numFrames = 10,
            duration = 1,
            isLooping = false,
            isReversed = false,
            onFinish = nil,
        },
    })
    local mailbox = {
        transform = tileObject.transform,
        sprite = mailboxSprite,

        package = nil,
    }

    mailboxSprite.setShader = function()
        MailboxEffect.setShader(mailbox)
    end

    return mailbox
end

return Mailbox
