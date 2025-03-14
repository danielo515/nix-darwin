local log = hs.logger.new('aerospace-web-service', 'debug')
local M = {}
local alert = require("alert")

-- Set up a simple HTTP server to listen for requests from Aerospace
function M.start(port)
    port = port or 8765
    -- Create an HTTP server on port 8765 (you can change this if needed)
    M.server = hs.httpserver.new(false, false)

    -- Set up the callback function for handling requests
    M.server:setCallback(function(method, path, headers, body)
        log.i("Aerospace integration HTTP server received request:")
        if method == "GET" then
            -- Check if the path starts with /service-mode
            if path:match("^/service%-mode") then
                -- Extract message from the URL if present
                local message = M.extractMessage(path)
                -- Show the alert with custom message or default
                log.i("message", message)
                local alertMessage = message or "Service mode activated"
                alert.important(alertMessage)
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

-- Extract message parameter from a path
function M.extractMessage(path)
    -- Check if the path contains a message parameter
    local message = path:match("%?message=(.+)$")

    if not message then
        return nil
    end

    -- URL decode the message (replace %20 with spaces, etc.)
    message = message:gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)

    return message
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
