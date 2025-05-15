#!/usr/bin/env nu
# Organize windows to their designated workspaces

def find-window [appName: string, windowTitle = ""] {
    let allApps = aerospace list-windows --all --json | from json
    let result = if $windowTitle == "" {
        $allApps | filter { $in.app-name == $appName }
    } else {
        $allApps | filter { $in.app-name == $appName and ($in.window-title | str contains $windowTitle) }
    }
    if ($result | length) == 0 {
        error make { 
            msg: $"(ansi red)No window found for app name:(ansi reset) '($appName)' and window title: '($windowTitle)'",
        help: $"Try using one of the following available windows:\n\n(ansi blue)($allApps | table)(ansi reset)"
         }
    } else {
        $result
    }
}

def move-window [windowId: int, workspace: string] {
    aerospace move-node-to-workspace $workspace --window-id $windowId
}

def find-and-move [appName: string, windowTitle: string, workspace: string, width: int] {
    let windows = find-window $appName $windowTitle
    $windows | each {|win|
        move-window $win.window-id $workspace 
        if $width > 0 {
            print $"Resizing WINDOW $($win.window-id) to width: $($width)"
            aerospace resize --window-id $win.window-id width $width
        }
        {Workspace: $workspace, AppName: $in.app-name, WindowTitle: $in.window-title, windowId: $in.window-id}
        }
}

let config = [ 
    {
        appName :"Code",
        windowTitle : "",
        workspace : "2"
    },
    {
        appName: "Obsidian",
        windowTitle: "",
        workspace: "3"
    },
    {
        appName: "Windsurf",
        windowTitle: "",
        workspace: "6"
    },
    {
        appName: "Google Chrome",
        windowTitle: "Danielo",
        workspace: "4"
    },
    {
        appName: "Google Chrome",
        windowTitle: "WhatsApp",
        workspace: "9"
    },
    {
        appName: "MongoDB Compass",
        windowTitle: "",
        workspace: "2"
    },
    {
        appName: "time tracker app",
        windowTitle: "",
        workspace: "1",
        width: 500,
    }
 ]

# Apply a single configuration entry
# 
# Parameters:
#   cfg: A configuration entry with appName, windowTitle, workspace, and optional width
# Returns:
#   A record with the result of the operation
def apply-single-config [cfg] {
    let width = if 'width' in $cfg { $cfg.width } else { 0 }
    try { 
        find-and-move $cfg.appName $cfg.windowTitle $cfg.workspace $width
    } catch {|err|
        print $"Failed to move window for app name: '($cfg.appName)' and window title: '($cfg.windowTitle)'"
        if 'msg' in $err {
            print $err.msg
        } else {
            print $err
        }
        { Workspace: $cfg.workspace, AppName: $cfg.appName, WindowTitle: $cfg.windowTitle, status: "Failed" }
    }
}

# Execute the entire configuration
def execute-config [] {
    $config | each { |cfg| apply-single-config $cfg }
}
    

# Organize windows according to configuration or move specific windows to workspaces
# 
# Usage:
#   - With no arguments: Apply the entire configuration to organize all windows
#   - With app name only: Apply the configuration for that specific app
#   - With app name, window title, and workspace: Move the specific window to the specified workspace
#
# Parameters:
#   appName: The name of the application to organize
#   windowTitle: Optional title of the window to filter by
#   workspace: The workspace to move the window to (required when appName and windowTitle are provided)
export def main [appName = "", windowTitle = "", workspace = ""] {
    if $appName == "" and $windowTitle == "" {
        print $"No app name or window title specified, (ansi blue)executing config(ansi reset)"
        execute-config | table --collapse
    } else if $workspace == "" and $windowTitle == "" {
        # When only app name is provided, apply config for that app
        let app_config = $config | where appName == $appName
        if ($app_config | length) == 0 {
            print $"(ansi yellow)No configuration found for app:(ansi reset) '($appName)'"
            print $"(ansi blue)Available configured apps:(ansi reset)"
            $config | select appName windowTitle workspace | table --collapse
        } else {
            print $"(ansi green)Applying configuration for:(ansi reset) '($appName)'"
            $app_config | each { |cfg| apply-single-config $cfg } | table --collapse
        }
    } else {
        if $workspace == "" {
            error make { msg: "Please specify a workspace"}
        } else {
            print { Workspace: $workspace, AppName: $appName, WindowTitle: $windowTitle }
            find-and-move $appName $windowTitle $workspace 0
        }
    }
}
    