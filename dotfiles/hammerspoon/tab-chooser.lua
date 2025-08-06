local Chrome = require("browser")("Google Chrome")

-- Search Functionality
local chooser = hs.chooser.new(function(selection)
	if not selection then
		return
	end
	Chrome.tabById(selection.action)
end)

-- Configure chooser appearance and behavior
chooser:rows(5)
chooser:width(30) -- Increased width to better accommodate URLs
chooser:bgDark(true)
chooser:searchSubText(true) -- Enable searching in the URL text too

-- Activate the chooser with a hotkey
hs.hotkey.bind({ "ctrl", "alt" }, "Space", function()
	local _, browserTabs, _ = Chrome.getTabs()
	local searchItems = {}
	for _, tab in ipairs(browserTabs) do
		table.insert(searchItems, {
			text = tab.title,
			subText = tab.url, -- Show URL as subtext
			action = tab.id
		})
	end
	chooser:choices(searchItems)
	chooser:show()
end)
