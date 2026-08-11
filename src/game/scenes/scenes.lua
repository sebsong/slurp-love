local SceneManager = require("engine.scene_manager")

local DayTracker = require("game.scenes.day_tracker")
local Debug = require("game.scenes.debug")
local Game = require("game.scenes.game")
local GameOverMenu = require("game.scenes.game_over_menu")
local Global = require("game.scenes.global")
local MailDialogue = require("game.scenes.mail_dialogue")
local MainMenu = require("game.scenes.main_menu")
local Map = require("game.scenes.map")
local PackageDetail = require("game.scenes.package_detail")
local PauseMenu = require("game.scenes.pause_menu")
local VictoryMenu = require("game.scenes.victory_menu")

local Scenes = {}

function Scenes.register()
    SceneManager.register("global", Global, true)
    SceneManager.register("debug", Debug, true)

    SceneManager.register("mainMenu", MainMenu)
    SceneManager.register("dayTracker", DayTracker)
    SceneManager.register("game", Game)
    SceneManager.register("mailDialogue", MailDialogue)
    SceneManager.register("packageDetail", PackageDetail)
    SceneManager.register("map", Map)
    SceneManager.register("pauseMenu", PauseMenu)
    SceneManager.register("gameOverMenu", GameOverMenu)
    SceneManager.register("victoryMenu", VictoryMenu)

    SceneManager.scenes.global:start()
    SceneManager.scenes.debug:start()
    -- SceneManager.scenes.mainMenu:start()
    SceneManager.scenes.game:start()
    -- SceneManager.scenes.packageDetail:start()
end

return Scenes
