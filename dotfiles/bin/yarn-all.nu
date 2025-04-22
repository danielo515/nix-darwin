#!/usr/bin/env nu
# exclusion rules are specific to yarn, to prevent getting into .yarn dependency folders
let folders = glob ./**/package.json | filter { $in | str contains ".yarn" | not $in }

# Executes a yarn command in all subfolders containing a package.json
# You should provide the entire command, e.g. "yarn run build"
export def main [cmd: string, --dry = false] {

print $"Running '($cmd)' in ($folders | length) subfolders containing a package.json"
    
$folders | par-each {
    let folder = $in | path dirname
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
