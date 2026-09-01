local MailboxEffect = require("game.effects.mailbox_effect")
local Sprite = require("engine.sprite")

local Mailbox = {}
Mailbox.__index = Mailbox

local DEFAULT_STATE = 1
local DELIVERED_STATE = 2

function Mailbox.new(image, tileObject, tilemap)
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
    mailboxSprite.xOffset = -mailboxSprite.width / 2
    mailboxSprite.yOffset = -mailboxSprite.height + tilemap.tileHeight / 2
    local mailbox = {
        transform = tileObject.transform,
        sprite = mailboxSprite,

        id = tileObject.id,
        package = nil,
    }

    mailboxSprite.setShader = function()
        MailboxEffect.setShader(mailbox)
    end

    setmetatable(mailbox, Mailbox)

    return mailbox
end

function Mailbox:deliverPackage()
    self.sprite:transitionAnimationState(DELIVERED_STATE)
end

function Mailbox:update(dt)
    self.sprite:update(dt)
end

return Mailbox
