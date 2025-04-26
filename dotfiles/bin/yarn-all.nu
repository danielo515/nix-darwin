#!/usr/bin/env nu

# Get all package.json folders, excluding .yarn folders
def get-package-folders [] {
    glob ./**/package.json | filter { $in | str contains ".yarn" | not $in }
}

# Get folders sorted by modification time (most recent first)
def get-sorted-folders [] {
    get-package-folders | 
    each { |path| 
        let folder = $path | path dirname
        {
            path: $path,
            folder: $folder,
            modified: (ls -la $folder | get modified | first)
        }
    } | 
    sort-by modified -r | 
    get folder
}

# Select folders using fzf
def select-folders [] {
    get-sorted-folders | 
    to text | 
    bash -c "fzf --multi --height=40% --layout=reverse" | 
    lines | 
    where { |line| $line != "" }
}

# Executes a yarn command in all subfolders containing a package.json
# You should provide the entire command, e.g. "yarn run build"
export def main [
    cmd: string, 
    --dry(-d),   # Dry run mode
    --select(-s) # Select folders using fzf
] {
    let folders = if $select {
        print "Select folders to run command in (use TAB to select multiple):"
        select-folders
    } else {
        get-package-folders | each { |path| $path | path dirname }
    }
    
    print $"Running '($cmd)' in ($folders | length) subfolders containing a package.json"
    
    $folders | par-each { |folder|
        cd $folder
        try {
            if $dry {
                print $"Not running '($cmd)' in '($folder)'"
            } else {
                print -n "."
                bash -c $"($cmd)"
            }
        } catch {
            print -e $"Error in '($folder)'"
        }
    }
}
