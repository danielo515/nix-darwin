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

def find-and-move [appName: string, windowTitle: string, workspace: string] {
    let windows = find-window $appName $windowTitle
    $windows | each { 
        move-window $in.window-id $workspace 
        {Workspace: $workspace, AppName: $in.app-name, WindowTitle: $in.window-title}
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
        windowTitle: "WhatsApp",
        workspace: "9"
    },
    {
        appName: "MongoDB Compass",
        windowTitle: "",
        workspace: "2"
    }
 ]

def execute-config [] {
    $config| each  {||
        find-and-move $in.appName $in.windowTitle $in.workspace
    }
}
    

export def main [appName = "", windowTitle = "", workspace = ""] {
    if $appName == "" and $windowTitle == "" {
        print $"No app name or window title specified, (ansi blue)executing config(ansi reset)"
        execute-config
    } else {
        if $workspace == "" {
            error make { msg: "Please specify a workspace"}
        } else {
            print { Workspace: $workspace, AppName: $appName, WindowTitle: $windowTitle }
            find-and-move $appName $windowTitle $workspace
        }
    }
}
    