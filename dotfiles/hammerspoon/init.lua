hs.ipc.cliInstall("/opt/homebrew")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
-- StreamDeck = hs.loadSpoon("StreamDeckButton")
-- StreamDeck:start()
hs.loadSpoon("EmmyLua")
hs.grid.setGrid("10x6")
-- require("keyboard.yabai") -- testing aerospace
require("tab-chooser")
-- local stateMachine = require("lib.stateMachine")
require("aerospace_integration").start(8765)
hs.application.enableSpotlightForNameSearches(true)

local function isMonitorBig()
    local windowWidth = hs.screen.mainScreen():frame().w
    if windowWidth < 2000 then
        return false
    end
end

-- WorkStates = stateMachine({
-- 	{ name = "Morning", icon = "~/.config/icons/cool.svg" },
-- 	{ name = "Workout", icon = "~/.config/icons/workout.svg" },
-- 	{ name = "Lunch", icon = "~/.config/icons/burguer.svg" },
-- })

-- StreamDeck:onWillAppear("routine", function(context, params)
-- 	local state = WorkStates.getCurrentState()
-- 	local message = StreamDeck:getImageMessage(context, state.icon)
-- 	StreamDeck:setTitle("routine", state.name)
-- 	return message
-- end)

-- StreamDeck:onKeyDown("routine", function(context, params)
-- 	local state = WorkStates()
-- 	StreamDeck:setTitle("routine", state.name)
-- 	slack.gotoChat()
-- 	return StreamDeck:getImageMessage(context, state.icon)
-- end)

--[[
-- File watcher section
-- ]]
FileWatcher = hs.loadSpoon("FileWatcher")
local rules = {
    {
        pattern = "%.pdf$",
        destination = "~/Documents/PDFs",
        action = "move",
    },
    {
        pattern = "%.jpg$|%.png$",
        destination = "~/Pictures/Downloads",
        action = "move",
    },
    {
        pattern = "%.stl$",
        destination = "~/Documents/3D-print",
        action = "move",
    },
}

FileWatcher:watchDirectory("~/Downloads", rules)

-- local secrets = require("secrets")
--[[ I specify not a hidden file because it is out of source control
In reality it lives encrypted in the chezmoi repo, and copied there on init ]]
-- secrets.start("secrets.json")

local retina = "Built-in Retina Display"
local primaryScreen = hs.screen.primaryScreen()
local statusbar = hs.menubar.new()
local chrome_app_name = "Google Chrome"
local wf = hs.window.filter
local positions = require("windowing").positions
Chrome = require("browser")("Google Chrome")
Danielo = { timer = nil }
--[[
StreamDeck:onWillAppear("vercelStatus", function(context, params)
	print("vercelStatus willAppear", context)
	return StreamDeck:getImageMessage(
		context,
		-- "~/Pictures/danielo515_programmer_fighting_blasphemy_5303f07b-4184-87fb-f043d10e18c2.png"
		"~/Pictures/tv-test.png"
	)
end)
WatchVercel = require("watch_vercel")
StreamDeck:onKeyDown("vercelStatus", function()
  print("vercelStatus keyDown")
  WatchVercel.openLatest()
end)
local vercel = hs.settings.get("secrets").tella.vercel
WatchVercel.start(function(status)
  StreamDeck:setTitle("vercelStatus", status)
  statusbar:setTitle("🚦" .. status)
end, vercel.teamId, vercel.token)
]]

local function secondaryDisplay()
    local secondary = hs.screen.find(retina)
    if secondary == nil then
        secondary = hs.screen.find("sidecar")
    end
    return secondary
end

-- Windows
-- Locates feather icons window and makes it big when you focus it
local function locateFeather(window)
    local windowLayout = {
        { nil, window, hs.screen.mainScreen(), hs.layout.left50, nil, nil },
    }
    hs.layout.apply(windowLayout)
end

-- Subscribes to focus events on a given app, and calls a callback when it happens
local function subscribeToFocus(appName, callback, filterOptions)
    local options = filterOptions or {}
    wf.new(false):setAppFilter(appName, options):subscribe(hs.window.filter.windowFocused, callback, true)
end

-- Slack listener
subscribeToFocus("Slack", function(window)
    if not isMonitorBig() then
        return
    end
    local layout = {
        { nil, window, primaryScreen, hs.geometry.rect(0.3, 0, 0.45, 0.95), nil, nil },
    }
    hs.layout.apply(layout)
end, { rejectTitles = "Huddle" })

local function find_chrome_window_looking_like_dev_env()
    -- Search a chrome tab containing something that looks like a dev-environment
    local dev_env_matches = { "http.*:%d+", "dev", "development", "debug", "localhost", "slack", "vercel", "calendar" }

    local chrome_window = nil
    for _, match in ipairs(dev_env_matches) do
        chrome_window = hs.window.find(match)
        if chrome_window ~= nil then
            print("Found window for", match)
            break
        end
        print("No window for", match)
    end

    if chrome_window == nil then
        chrome_window = hs.window.find(chrome_app_name)
    end
    return chrome_window
end

-- Whenever we focus the terminal of choice, we position chrome to the right so we can see references
-- or the web app we are working with
subscribeToFocus("Alacritty", function(window)
    -- Disabled because this is now handled by yabai
    if true then
        return
    end
    local function notHuddle(name, title)
        return not name:match("Huddle")
    end

    local windowWidth = hs.window.focusedWindow():frame().w
    if windowWidth < 2000 then
        return
    end

    local chrome_window = find_chrome_window_looking_like_dev_env()

    local layout = {
        { nil,            window,        primaryScreen,      hs.layout.right70, nil, nil },
        { nil,            chrome_window, primaryScreen,      positions.left34,  nil, nil },
        { "time tracker", nil,           secondaryDisplay(), positions.right30, nil, nil },
        -- { "Slack", "Huddle", retina, positions.left70, nil, nil }, -- If slack is not open, this layout will fail, wtf??
    }
    -- slack.gotoChat();
    hs.layout.apply(layout, notHuddle)
end)

require("keybinds")
-- require("auto_tile")
require("keyboard.auto_flasher")
-- Watches a file and updates when was it modified. I don't use it anymore
-- require("watch_files")

hs.loadSpoon("Hyper")

App = hs.application
Hyper = spoon.Hyper

Hyper:bindHotKeys({ hyperKey = { {}, "F9" } })

Hyper:bind({}, "j", function()
    App.launchOrFocusByBundleID("net.kovidgoyal.kitty")
end)

require("alert").important("Hammerspoon config loaded")
