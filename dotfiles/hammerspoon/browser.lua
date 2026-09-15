return function(browserName)
	local function open()
		hs.application.launchOrFocus(browserName)
	end
	local function jump(url)
		local script = ([[(function() {
      var browser = Application('%s');

      for (win of browser.windows()) {
        var tabIndex =
          win.tabs().findIndex(tab => tab.url().match(/%s/));

        if (tabIndex != -1) {
          browser.activate();
          win.activeTabIndex = (tabIndex + 1);
          win.index = 1;
        }
      }
    })();
  ]]):format(browserName, url)

		-- print(script) -- debug. It is very useful when you are in development
		hs.osascript.javascript(script)
	end

	local function tabById(tabId)
		if not tabId then
			hs.alert("No tab ID provided")
			return
		end
		local script = ([[(function() {
      var browser = Application('%s');

      for (const win of browser.windows()) {
        var tabIndex = win.tabs.id().indexOf("%s");

        if (tabIndex != -1) {
          browser.activate();
          win.activeTabIndex = (tabIndex + 1);
          win.index = 1;
          return;
        }
      }
    })();
  ]]):format(browserName, tabId)

		-- print(script) -- debug. It is very useful when you are in development
		hs.osascript.javascript(script)
	end

	---gathers all the browser tabs, with ID (so you can jump to them) and title, in case you need them for displaying
	local function getTabs()
		local script = ([[(function () {
      const browser = Application("%s");
      const tabs = [];

      for (const win of browser.windows()) {
      const winTabs = win.tabs;
      const ids = winTabs.id(), titles = winTabs.title(), urls = winTabs.url();
      for (let i = 0; i < ids.length; i++) {
      tabs.push({ id: ids[i], title: titles[i], url: urls[i] });
      }
      }
      return tabs;
      })();
    ]]):format(browserName)

		-- print(script) -- debug. It is very useful when you are in development
		return hs.osascript.javascript(script)
	end
	return { open = open, jump = jump, tabById = tabById, getTabs = getTabs }
end
