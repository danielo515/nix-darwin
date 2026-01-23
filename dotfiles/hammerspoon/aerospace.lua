-- cSpell:words nikitabobko aerospace
-- https://github.com/nikitabobko/AeroSpace
--
local function trim(str)
	return str:gsub("^%s+", ""):gsub("%s+$", "")
end

-- Find aerospace executable path dynamically
-- This ensures we have the correct path regardless of Hammerspoon's PATH
local aerospacePath = hs.execute("which aerospace", true)

if aerospacePath == "" or aerospacePath == nil then
	hs.alert.show("aerospace not found")
	return
end

aerospacePath = trim(aerospacePath)

-- Helper function to execute aerospace commands
-- and return true if the command was successful
---@param command string
---@return boolean, string
local function aerospace1(command)
	local cmd = aerospacePath .. " " .. command
	local _, _, all_ok = os.execute(cmd)
	return all_ok == 0, cmd
end

---@param command string
function aerospaceQuery(command)
	local result = hs.execute(aerospacePath .. " " .. command)
	return result
end

function aerospaceWindows()
	return aerospaceQuery("list-windows --all --format '%{window-id} | %{app-name}'")
end

---Queries aerospace for the current workspace
function aerospaceWorkspace()
	return aerospaceQuery("list-workspaces --focused"):gsub("%s+", "")
end

-- executes aerospace commands
-- If a command fails, it will show an alert
---@param commands string[]
function aerospace(commands)
	for _, cmd in ipairs(commands) do
		local status, fullCmd = aerospace1(cmd)
		if not status then
			hs.alert.show("aerospace command failed: " .. fullCmd)
		end
	end
end

-- Check if an app is currently open
---@param appName string
---@return boolean
local function isAppOpen(appName)
	local checkClosed = aerospaceQuery("list-windows --all --format '%{app-name}' | grep '" .. appName .. "'")
	return checkClosed and checkClosed ~= ""
end

-- Check if an app is currently focused
---@param bundleId string
---@return boolean
local function isAppFocused(bundleId)
	local checkFocused = aerospaceQuery("list-windows --focused --format '%{app-bundle-id}'")
	return checkFocused and checkFocused:match(bundleId)
end

-- Get the window ID for an app
---@param appName string
---@return string|nil
local function getAppWindowId(appName)
	local windowId = aerospaceQuery("list-windows --all --format '%{window-id} | %{app-name}' | grep '" .. appName .. "' | cut -d' ' -f1"):gsub("%s+", "")
	return windowId and windowId ~= "" and windowId or nil
end

-- Focus and move an app window to the current workspace
---@param windowId string
local function focusAndMoveWindow(windowId)
	local currentWorkspace = aerospaceWorkspace()
	aerospace({
		"focus --window-id " .. windowId,
		"move-node-to-workspace " .. currentWorkspace,
		"workspace " .. currentWorkspace,
		"move-mouse window-lazy-center"
	})
end

-- Focus an application and move it to the current workspace
-- If the app is closed, it will open it
-- If the app is focused, it will move it to scratchpad
---@param appName string
---@param bundleId string
function focusApp(appName, bundleId)
	if not isAppOpen(appName) then
		hs.execute("open -a " .. appName)
		hs.timer.doAfter(1.5, function()
			local windowId = getAppWindowId(appName)
			if windowId then
				focusAndMoveWindow(windowId)
			else
				hs.alert.show("Could not find " .. appName .. " window after opening")
			end
		end)
		return
	end
	
	if isAppFocused(bundleId) then
		-- Move to scratchpad if focused
		aerospace({ "move-node-to-workspace scratchpad" })
	else
		-- Focus the app and move to current workspace
		local windowId = getAppWindowId(appName)
		if windowId then
			focusAndMoveWindow(windowId)
		else
			hs.alert.show("Could not find " .. appName .. " window")
		end
	end
end

return {
	focusApp = focusApp,
	query = aerospaceQuery,
	windows = aerospaceWindows,
	workspace = aerospaceWorkspace,
	exec = aerospace
}
