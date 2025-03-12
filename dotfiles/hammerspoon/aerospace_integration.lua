local M = {}
local alert = require("alert")

-- Set up a simple HTTP server to listen for requests from Aerospace
function M.start(port)
    port = port or 8765
    -- Create an HTTP server on port 8765 (you can change this if needed)
    M.server = hs.httpserver.new(false, false)

    -- Set up the callback function for handling requests
    M.server:setCallback(function(method, path, headers, body)
        if method == "GET" then
            if path == "/service-mode" then
                -- Show the alert when service mode is activated
                alert.important("Service mode activated")
                return "OK", 200, { ["Content-Type"] = "text/plain" }
            end
        end
        return "Not Found", 404, { ["Content-Type"] = "text/plain" }
    end)

    M.server:setPort(port)
    M.server:setInterface('loopback')
    -- Start the server
    M.server:start()
    print("Aerospace integration HTTP server started on port " .. port)

    return M.server
end

-- Stop the HTTP server
function M.stop()
    if M.server then
        M.server:stop()
        M.server = nil
        print("Aerospace integration HTTP server stopped")
    end
end

return M
